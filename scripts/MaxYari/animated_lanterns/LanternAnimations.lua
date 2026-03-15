local mp = 'scripts/MaxYari/animated_lanterns/'

local core = require('openmw.core')
local world = require('openmw.world')
local util = require('openmw.util')
local markup = require('openmw.markup')
local vfs = require('openmw.vfs')

local gutils = require(mp .. 'utils/gutils')
local s = require(mp .. 'settings_global')


local PLAYER_EVENT_RAYCAST_REQUEST = "LanternRaycastRequest"
local PLAYER_EVENT_RAYCAST_RESULT = "LanternRaycastResult"

local currentCell = nil
local currentCellsGroup = nil
local player = world.players[1]

local activeLanternDistance = 100*69
-- Animation framerate limiting parameters
local minAnimFPS = 120      -- Closest possible: 60 FPS
local maxAnimFPS = 25      -- Furthest possible: 10 FPS
local minAnimDist = 10*69      -- Distance at which minAnimFPS applies
local maxAnimDist = activeLanternDistance   -- Distance at which maxAnimFPS applies

local lanterns = {} -- Now a table indexed by object.id
-- Deferred lantern search state
local pendingLanternObjects = nil -- list of lists (cell objects)
local pendingLanternCellIdx = 1
local pendingLanternObjIdx = 1
local PENDING_LANTERN_BATCH = 12
local PENDING_LANTERN_RAYCASTS = 3

local ZUnitVector = util.vector3(0,0,1)
local angleLimit = (math.pi / 2) - 0.001

local gravity = 9.8
local angularDamping = 0.99
local windDirection = util.vector3(1, -1, 0):normalize()
local baseYawRotationSpeed = 0.02
local yawRotationSpeed = baseYawRotationSpeed
local yawRotationAmplitude = 0.5

local windPowerMin = 0
local windPowerMax = 0
local extWindPowerMin = 0.5
local extWindPowerMax = 1.5
local stormWindPowerMin = 10
local stormWindPowerMax = 15
local intWindPowerMin = 0
local intWindPowerMax = 0.5
local windBurstProbability = 0.5
local windPowerChangeInterval = 1

-- Weather check cache (updates once per second)
local weatherCheckTimer = 0
local weatherCheckInterval = 1.0
local lastWeatherState = nil

--if true then return end


local function initializeLanternWindData(lantern)
    local positionLength = lantern.position:length()
    local initialTimer = math.abs(math.sin(positionLength / 1000))
    return {
        windForce = 0,
        windPowerTarget = 0,
        windPowerChangeTimer = initialTimer,
        angularVelocity = 0,
        swingAngle = 0
    }
end

local function updateLanternWindForce(lanternData, dt)
    lanternData.windPowerChangeTimer = lanternData.windPowerChangeTimer - dt
    if lanternData.windPowerChangeTimer <= 0 then
        if math.random() < windBurstProbability then
            lanternData.windPowerTarget = math.random() * (windPowerMax - windPowerMin) + windPowerMin
        else
            lanternData.windPowerTarget = 0
        end
        lanternData.windPowerChangeTimer = windPowerChangeInterval / 2 + math.random() * windPowerChangeInterval / 2
    end
    lanternData.windForce = gutils.lerpClamped(lanternData.windForce, lanternData.windPowerTarget, dt * 2)
    if lanternData.windForce < 0 then lanternData.windForce = 0 end
end

local function mergeArray(target, source)
    if source then
        for _, item in ipairs(source) do
            table.insert(target, item)
        end
    end
end

local function loadLanternConfigs()
    local mergedConfig = {
        lantern_configs = {},
        blacklisted_names = {},
        blacklisted_ids = {}
    }

    for filePath in vfs.pathsWithPrefix('scripts/MaxYari/animated_lanterns/configs/') do
        if filePath:match('%.yaml$') then
            local config = markup.loadYaml(filePath)
            if config then
                mergeArray(mergedConfig.lantern_configs, config.lantern_configs)
                mergeArray(mergedConfig.blacklisted_names, config.blacklisted_names)
                mergeArray(mergedConfig.blacklisted_ids, config.blacklisted_ids)
            end
        end
    end

    -- Convert offsets and directions to vectors
    for _, config_entry in ipairs(mergedConfig.lantern_configs) do
        config_entry.offset = util.vector3(config_entry.offset[1], config_entry.offset[2], config_entry.offset[3])
        if config_entry.localSwingDirection then
            config_entry.localSwingDirection = util.vector3(config_entry.localSwingDirection[1], config_entry.localSwingDirection[2], config_entry.localSwingDirection[3])
        end
    end

    return mergedConfig
end

local lanternConfig = loadLanternConfigs()
local lanternConfigs = lanternConfig.lantern_configs


local function isBlacklisted(obj)
    -- Check blacklisted_ids (exact match)
    for _, id in ipairs(lanternConfig.blacklisted_ids) do
        if obj.id == id or obj.recordId == id then
            return true
        end
    end
    -- Check blacklisted_names (partial match)
    for _, name in ipairs(lanternConfig.blacklisted_names) do
        if obj.recordId:find(name) then
            return true
        end
    end
    return false
end

local function findConfig(obj)
    for _, config in ipairs(lanternConfigs) do
        local model = obj.type.record(obj).model
        if obj.recordId:find(config.name) or (model and model:find(config.name)) then
            return config
        end
    end
    return nil
end





local function getCellsAround(centerCell)
    local ret = {}
    local centerX, centerY = centerCell.gridX, centerCell.gridY
    table.insert(ret, centerCell)

    if centerCell.isExterior then
        -- Iterate over the surrounding cells
        for dx = -1, 1 do
            for dy = -1, 1 do
                if dx == 0 and dy == 0 then goto continue end
                local cellX = centerX + dx
                local cellY = centerY + dy
                local cell = world.getExteriorCell(cellX, cellY)
                table.insert(ret, cell)
                ::continue::
            end
        end
    end

    return ret
end





local function findLanternsDeferredStep()
    if not pendingLanternObjects then return end
    local processed = 0
    local raycastsThisFrame = 0
    while processed < PENDING_LANTERN_BATCH and pendingLanternObjects and raycastsThisFrame < PENDING_LANTERN_RAYCASTS do
        local cellList = pendingLanternObjects[pendingLanternCellIdx]
        
        if not cellList then
            pendingLanternObjects = nil
            break
        end
        local cellListLen = #cellList
        while pendingLanternObjIdx <= cellListLen and processed < PENDING_LANTERN_BATCH and raycastsThisFrame < PENDING_LANTERN_RAYCASTS do
            local obj = cellList[pendingLanternObjIdx]
            -- Find config
            local foundConfig = findConfig(obj)
            
            -- Skip blacklisted objects
            if isBlacklisted(obj) then goto continue end            
            
            if foundConfig then                
                local finishedInitialise = false
                if foundConfig.onlyHangs then
                    finishedInitialise = true
                end
                local timerOffset = math.random() / 4
                
                local initialSwingAxis = nil
                if foundConfig.localSwingDirection then
                    initialSwingAxis = obj.rotation:apply(foundConfig.localSwingDirection):normalize():cross(ZUnitVector)
                end

                lanterns[obj.id] = {
                    object = obj,
                    swingPhaseOffset = math.random() * 2 * math.pi,
                    yawPhaseOffset = math.random() * 2 * math.pi,
                    initialYawRotation = obj.rotation:getYaw(),
                    originOffset = foundConfig.offset,
                    localSwingDirection = foundConfig.localSwingDirection,
                    initialSwingAxis = initialSwingAxis,
                    avoidYawRotation = foundConfig.avoidYawRotation,
                    weight = foundConfig.weight or 1,
                    windData = initializeLanternWindData(obj),
                    animTimer = timerOffset,
                    finishedInitialise = finishedInitialise,
                    configName = foundConfig.name,
                    onlyHangs = foundConfig.onlyHangs,
                }                
                obj:teleport(obj.cell, obj.startingPosition, { rotation = obj.startingRotation }) -- Ensure correct initial rotation
                -- If not finishedInitialise, send for raycast (up to PENDING_LANTERN_RAYCASTS per frame)
                if not finishedInitialise  then
                    -- print("Sending lantern raycast request event for:", obj)
                    player:sendEvent(PLAYER_EVENT_RAYCAST_REQUEST, { lantern = obj })
                    raycastsThisFrame = raycastsThisFrame + 1
                end
            end

            ::continue::
            processed = processed + 1
            pendingLanternObjIdx = pendingLanternObjIdx + 1            
        end        
        if pendingLanternObjIdx > cellListLen then
            pendingLanternCellIdx = pendingLanternCellIdx + 1
            pendingLanternObjIdx = 1
        end
    end
    -- print("Processed lanterns:", processed, "Raycasts this frame:", raycastsThisFrame)
end

local function prepareLanternSearch()
    pendingLanternObjects = {}
    pendingLanternCellIdx = 1
    pendingLanternObjIdx = 1
    for _, cell in ipairs(currentCellsGroup or {}) do
        table.insert(pendingLanternObjects, cell:getAll())
    end
end

local function cleanUpLanterns()
    if not currentCellsGroup then return end
    
    -- Build O(1) lookup table for current cells
    local validCells = {}
    for _, cell in ipairs(currentCellsGroup) do
        validCells[cell] = true
    end
    
    for id, lanternData in pairs(lanterns) do
        if not lanternData.object:isValid() or not validCells[lanternData.object.cell] then
            lanterns[id] = nil
        end
    end
end

local function getAnimIntervalForDistance(dist)
    if dist <= minAnimDist then return 1 / minAnimFPS end
    if dist >= maxAnimDist then return 1 / maxAnimFPS end
    local t = (dist - minAnimDist) / (maxAnimDist - minAnimDist)
    local fps = minAnimFPS + (maxAnimFPS - minAnimFPS) * t
    return 1 / fps
end

local function onRaycastResult(data)
    -- results: array of { objectId = lantern.object.id, shouldInit = true/false }

    --print("Raycast result for lantern", data.lantern.id, "shouldInit:", data.shouldInit)
    
    local lantern = lanterns[data.lantern.id]
    if lantern then
        if data.shouldInit then
            lantern.finishedInitialise = true
        else
            -- print("Not initialising lantern", data.lantern.id, "due to raycast hit")
            lanterns[data.lantern.id] = nil
        end
    end
    
end


local teleportOptsPayload = {}


local function animateLanterns(dt)
    local lookDir = gutils.lookDirection(player)
    for id, lanternData in pairs(lanterns) do
        if not lanternData.finishedInitialise then goto continue end
        local lantern = lanternData.object
        local toLantern = lantern.position - player.position
        local dist = toLantern:length()
        if dist > activeLanternDistance then goto continue end
        if toLantern:dot(lookDir) < 0 then goto continue end

        local interval = getAnimIntervalForDistance(dist)
        lanternData.animTimer = (lanternData.animTimer or 0) - dt
        if lanternData.animTimer > 0 then goto continue end
        lanternData.animTimer = interval

        if lantern.count < 1 or lantern.cell == nil then
            lanterns[id] = nil
        else
            local windData = lanternData.windData
            local originOffset = lanternData.originOffset
            local localSwingDirection = lanternData.localSwingDirection
            local avoidYawRotation = lanternData.avoidYawRotation
            local weight = lanternData.weight or 1            

            updateLanternWindForce(windData, dt)

            local swingDirection = windDirection
            local swingAxis = lanternData.initialSwingAxis -- For fixed-axis swinged objects such as guild signs this will have a value and theres no point in recalculating it
            if not swingAxis then
                -- For non-fixed axis swinging objects (lanterns) - we calculate axis every frame
                swingAxis = swingDirection:cross(ZUnitVector):normalize()
            end

            local gravityForce = -gravity * math.sin(windData.swingAngle)
            local windForceEffect = (windData.windForce / weight) * math.cos(windData.swingAngle)
            local netTorque = gravityForce + windForceEffect

            local angularAcceleration = netTorque
            windData.angularVelocity = (windData.angularVelocity + angularAcceleration * dt) * angularDamping
            windData.swingAngle = windData.swingAngle + windData.angularVelocity * dt
            

            local swingRotation = util.transform.rotate(windData.swingAngle, swingAxis)

            local combinedRotation
            if avoidYawRotation then
                combinedRotation = swingRotation * util.transform.rotateZ(lanternData.initialYawRotation)
            else
                local yawAngle = math.sin(core.getGameTime() * yawRotationSpeed + lanternData.yawPhaseOffset) * yawRotationAmplitude
                local yawRotation = util.transform.rotateZ(yawAngle)
                combinedRotation = swingRotation * yawRotation
            end

            local currOriginOffset = lantern.rotation:apply(originOffset)
            local newOriginOffset = combinedRotation:apply(originOffset)
            local finalOffset = currOriginOffset - newOriginOffset

            teleportOptsPayload.rotation = combinedRotation
            lantern:teleport(lantern.cell, lantern.position + finalOffset, teleportOptsPayload)
        end

        ::continue::
    end
end

local function updateWeatherSettings(cell)
    local weatherRecord = core.weather.getCurrent(cell)
    local isExterior = cell.isExterior
    local isStorm = false
    if weatherRecord then isStorm = weatherRecord.isStorm end
    
    -- Check if weather state actually changed
    local newWeatherState = isExterior and (isStorm and "storm" or "exterior") or "interior"
    if lastWeatherState == newWeatherState then
        return false  -- No change, skip update
    end
    lastWeatherState = newWeatherState
    
    if isExterior then
        if isStorm then
            windPowerMin = stormWindPowerMin * s.settings.StormWindMult
            windPowerMax = stormWindPowerMax * s.settings.StormWindMult
            yawRotationSpeed = baseYawRotationSpeed * s.settings.StormWindMult
        else
            windPowerMin = extWindPowerMin * s.settings.CalmWindMult
            windPowerMax = extWindPowerMax * s.settings.CalmWindMult
            yawRotationSpeed = baseYawRotationSpeed * s.settings.CalmWindMult
        end
    else
        windPowerMin = intWindPowerMin * s.settings.InteriorWindMult
        windPowerMax = intWindPowerMax * s.settings.InteriorWindMult
        yawRotationSpeed = baseYawRotationSpeed * s.settings.InteriorWindMult
    end
    
    return true  -- Weather updated
end

local function onCellChange(cell)
    currentCellsGroup = getCellsAround(cell)
    updateWeatherSettings(cell)
    cleanUpLanterns()
    prepareLanternSearch()
end

local function onUpdate(dt)
    if dt <= 0 then return end
    
    local cell = player.cell
    if cell ~= currentCell then
        currentCell = cell
        onCellChange(cell)
    end

    -- Update weather settings periodically (once per second)
    weatherCheckTimer = weatherCheckTimer - dt
    if weatherCheckTimer <= 0 then
        updateWeatherSettings(cell)
        weatherCheckTimer = weatherCheckInterval
    end

    findLanternsDeferredStep()
    animateLanterns(dt)
end

return {
    engineHandlers = {
        onUpdate = onUpdate
    },
    eventHandlers = {
        CellChange = onCellChange,
        [PLAYER_EVENT_RAYCAST_RESULT] = onRaycastResult,
    }
}
