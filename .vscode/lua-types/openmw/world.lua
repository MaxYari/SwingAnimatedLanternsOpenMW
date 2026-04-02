
--- @class VFXModule
local VFXModule = {}
--- @param model string
--- @param position Vector3
--- @param options? {mwMagicVfx:boolean, particleTextureOverride:string, scale:number, useAmbientLight:boolean, loop:boolean, vfxId:string}
function VFXModule.spawn(model, position, options) end
--- @param vfxId string
function VFXModule.remove(vfxId) end

--- @class openmw_world
--- @field activeActors GameObject[]
--- @field players GameObject[]
--- @field cells Cell[]
--- @field mwscript MWScriptFunctions
--- @field vfx VFXModule
local world = {}

--- @param name string
--- @return Cell
function world.getCellByName(name) end

--- @param id string
--- @return Cell
function world.getCellById(id) end

--- @param gridX number
--- @param gridY number
--- @param cellOrName? any
--- @return Cell
function world.getExteriorCell(gridX, gridY, cellOrName) end

--- @return number
function world.getSimulationTime() end
--- @return number
function world.getSimulationTimeScale() end
--- @param scale number
function world.setSimulationTimeScale(scale) end
--- @return number
function world.getGameTime() end
--- @return number
function world.getGameTimeScale() end
--- @param ratio number
function world.setGameTimeScale(ratio) end
--- @param hours number
function world.advanceTime(hours) end

--- @return boolean
function world.isWorldPaused() end
--- @param tag? string
function world.pause(tag) end
--- @param tag? string
function world.unpause(tag) end
--- @return table
function world.getPausedTags() end

--- @param formId string
--- @return GameObject
function world.getObjectByFormId(formId) end

--- @param recordId string
--- @param count? number
--- @return GameObject
function world.createObject(recordId, count) end

--- @param record any
--- @return any
function world.createRecord(record) end

return world
