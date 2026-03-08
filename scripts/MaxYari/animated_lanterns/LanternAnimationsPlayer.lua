local mp = 'scripts/MaxYari/animated_lanterns/'

local nearby = require('openmw.nearby')
local util = require('openmw.util')
local core = require('openmw.core')
local nearby = require('openmw.nearby')

local s = require(mp .. 'settings_player')

local PLAYER_EVENT_RAYCAST_REQUEST = "LanternRaycastRequest"
local PLAYER_EVENT_RAYCAST_RESULT = "LanternRaycastResult"

local function onRaycastRequest(data)
    -- data.lantern is a GameObject
    local lantern = data.lantern
    local bbox = data.lantern:getBoundingBox()
    local from = bbox.center
    local to = from - util.vector3(0, 0, bbox.halfSize.z + 10)
    local rayRes = nearby.castRay(from, to, { ignore = lantern, collisionType = nearby.COLLISION_TYPE.World + nearby.COLLISION_TYPE.HeightMap + nearby.COLLISION_TYPE.Door })
    local shouldInit = not rayRes or not rayRes.hit
    -- print("Raycast result for lantern", lantern.recordId, "Should init:", shouldInit)
    core.sendGlobalEvent(PLAYER_EVENT_RAYCAST_RESULT, { lantern = lantern, shouldInit = shouldInit })
end

return {
    eventHandlers = {
        [PLAYER_EVENT_RAYCAST_REQUEST] = onRaycastRequest,
    }
}
