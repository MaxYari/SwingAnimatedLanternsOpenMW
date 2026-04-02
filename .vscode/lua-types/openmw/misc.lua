-- openmw.vfs, openmw.ambient, openmw.postprocessing, openmw.debug, openmw.menu, openmw.markup

--- @class FileHandle
--- @field fileName string
local FileHandle = {}
--- @return boolean
function FileHandle:close() end
--- @param ... string|number format strings
--- @return string|number
function FileHandle:read(...) end
--- @param whence? string "set"|"cur"|"end"
--- @param offset? number
--- @return number|nil
function FileHandle:seek(whence, offset) end
--- @return function
function FileHandle:lines() end

--- @class openmw_vfs
local vfs = {}
--- @param fileName string
--- @return boolean
function vfs.fileExists(fileName) end
--- @param fileName string
--- @return FileHandle|nil, string|nil
function vfs.open(fileName) end
--- @param fileName string
--- @return function
function vfs.lines(fileName) end
--- @param prefix string
--- @return function
function vfs.pathsWithPrefix(prefix) end
--- @param handle any
--- @return string|nil "file"|"closed file"|nil
function vfs.type(handle) end

--- @class openmw_ambient
local ambient = {}
--- @param soundId string
--- @param options? {loop:boolean, volume:number, pitch:number}
function ambient.playSound(soundId, options) end
--- @param path string
--- @param options? {loop:boolean, volume:number, pitch:number}
function ambient.playSoundFile(path, options) end
--- @param soundId string
function ambient.stopSound(soundId) end
--- @param path string
function ambient.stopSoundFile(path) end
--- @param soundId string
--- @return boolean
function ambient.isSoundPlaying(soundId) end
--- @param path string
--- @return boolean
function ambient.isSoundFilePlaying(path) end
--- @param path string
--- @param options? {fadeOut:number}
function ambient.streamMusic(path, options) end
function ambient.stopMusic() end
--- @return boolean
function ambient.isMusicPlaying() end
--- @param path string
--- @param text? string
function ambient.say(path, text) end
function ambient.stopSay() end
--- @return boolean
function ambient.isSayActive() end

--- @class Shader
--- @field name string
--- @field description string
--- @field author string
--- @field version string
local Shader = {}
--- @param index? number
function Shader:enable(index) end
function Shader:disable() end
--- @return boolean
function Shader:isEnabled() end
--- @param name string
--- @param val boolean
function Shader:setBool(name, val) end
--- @param name string
--- @param val number
function Shader:setInt(name, val) end
--- @param name string
--- @param val number
function Shader:setFloat(name, val) end
--- @param name string
--- @param val Vector2
function Shader:setVector2(name, val) end
--- @param name string
--- @param val Vector3
function Shader:setVector3(name, val) end
--- @param name string
--- @param val Vector4
function Shader:setVector4(name, val) end
--- @param name string
--- @param arr number[]
function Shader:setIntArray(name, arr) end
--- @param name string
--- @param arr number[]
function Shader:setFloatArray(name, arr) end

--- @class openmw_postprocessing
local postprocessing = {}
--- @param name string
--- @return Shader
function postprocessing.load(name) end
--- @return Shader[]
function postprocessing.getChain() end

--- @class RENDER_MODE_ENUM
--- @field CollisionDebug number
--- @field Wireframe number
--- @field Pathgrid number
--- @field Water number
--- @field Scene number
--- @field NavMesh number
--- @field ActorsPaths number
--- @field RecastMesh number

--- @class NAV_MESH_RENDER_MODE_ENUM
--- @field AreaType number
--- @field UpdateFrequency number

--- @class openmw_debug
--- @field RENDER_MODE RENDER_MODE_ENUM
--- @field NAV_MESH_RENDER_MODE NAV_MESH_RENDER_MODE_ENUM
local debug = {}
--- @param mode number
function debug.toggleRenderMode(mode) end
function debug.toggleGodMode() end
--- @return boolean
function debug.isGodMode() end
function debug.toggleAI() end
--- @return boolean
function debug.isAIEnabled() end
function debug.toggleCollision() end
--- @return boolean
function debug.isCollisionEnabled() end
function debug.toggleMWScript() end
--- @return boolean
function debug.isMWScriptEnabled() end
function debug.reloadLua() end
--- @param mode number
function debug.setNavMeshRenderMode(mode) end
--- @param val boolean
function debug.setShaderHotReloadEnabled(val) end
function debug.triggerShaderReload() end

--- @class SaveInfo
--- @field description string
--- @field playerName string
--- @field playerLevel number
--- @field timePlayed number
--- @field creationTime number
--- @field contentFiles string[]

--- @class MENU_STATE_ENUM
--- @field NoGame number
--- @field Running number
--- @field Ended number

--- @class openmw_menu
--- @field STATE MENU_STATE_ENUM
local menu = {}
--- @return number STATE value
function menu.getState() end
function menu.newGame() end
--- @param path string
function menu.loadGame(path) end
--- @param path string
function menu.deleteGame(path) end
--- @return string
function menu.getCurrentSaveDir() end
--- @param description string
--- @param screenshot? any
function menu.saveGame(description, screenshot) end
--- @param saveDir string
--- @return SaveInfo[]
function menu.getSaves(saveDir) end
--- @return SaveInfo[]
function menu.getAllSaves() end
function menu.quit() end

--- @class openmw_markup
local markup = {}
--- @param inputData string
--- @return any
function markup.decodeYaml(inputData) end
--- @param fileName string
--- @return any
function markup.loadYaml(fileName) end

return markup
