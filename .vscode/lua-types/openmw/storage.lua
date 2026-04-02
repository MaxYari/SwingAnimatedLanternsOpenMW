
--- @class LIFE_TIME_ENUM
--- @field Persistent number 0
--- @field GameSession number 1
--- @field Temporary number 2

--- @class StorageSection
local StorageSection = {}
--- @param key string
--- @return any
function StorageSection:get(key) end
--- @param key string
--- @return any deep copy
function StorageSection:getCopy(key) end
--- @param key string
--- @param value any
function StorageSection:set(key, value) end
--- @param callback Callback
function StorageSection:subscribe(callback) end
--- @return table
function StorageSection:asTable() end
--- @param values? table
function StorageSection:reset(values) end
--- @param lifetime number LIFE_TIME value
function StorageSection:setLifeTime(lifetime) end
--- @deprecated use setLifeTime(LIFE_TIME.Temporary)
function StorageSection:removeOnExit() end

--- @class openmw_storage
--- @field LIFE_TIME LIFE_TIME_ENUM
local storage = {}

--- @param sectionName string
--- @return StorageSection
function storage.globalSection(sectionName) end

--- @param sectionName string
--- @return StorageSection
function storage.playerSection(sectionName) end

--- @return table
function storage.allGlobalSections() end

--- @return table
function storage.allPlayerSections() end

return storage
