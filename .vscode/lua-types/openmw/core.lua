
--- @class ObjectOwner
--- @field recordId string
--- @field factionId string|nil
--- @field factionRank number|nil

--- @class PathGridPoint
--- @field position Vector3
--- @field edges number[]

--- @class PathGrid
--- @field graph PathGridPoint[]

--- @class Cell
--- @field name string
--- @field displayName string
--- @field id string
--- @field region string
--- @field isExterior boolean
--- @field isQuasiExterior boolean
--- @field gridX number
--- @field gridY number
--- @field worldSpaceId string
--- @field hasWater boolean
--- @field waterLevel number
--- @field hasSky boolean
--- @field pathGrid PathGrid|nil
local Cell = {}
--- @param tag string
--- @return boolean
function Cell:hasTag(tag) end
--- @param other Cell
--- @return boolean
function Cell:isInSameSpace(other) end
--- @param type any optional
--- @return GameObject[]
function Cell:getAll(type) end

--- @class Inventory
local Inventory = {}
--- @param recordId string
--- @return number
function Inventory:countOf(recordId) end
--- @param type any optional
--- @return GameObject[]
function Inventory:getAll(type) end
--- @param recordId string
--- @return GameObject|nil
function Inventory:find(recordId) end
--- @return boolean
function Inventory:isResolved() end
function Inventory:resolve() end
--- @param recordId string
--- @return GameObject[]
function Inventory:findAll(recordId) end

--- @class GameObject
--- @field id string
--- @field contentFile number
--- @field enabled boolean
--- @field position Vector3
--- @field scale number
--- @field rotation Transform
--- @field startingCell Cell
--- @field startingPosition Vector3
--- @field startingRotation Transform
--- @field owner ObjectOwner
--- @field cell Cell|nil
--- @field parentContainer GameObject|nil
--- @field type any
--- @field count number
--- @field recordId string
--- @field globalVariable string|nil
local GameObject = {}
--- @return boolean
function GameObject:isValid() end
--- @param name string
--- @param data any
function GameObject:sendEvent(name, data) end
--- @param actor GameObject
function GameObject:activateBy(actor) end
--- @param path string
function GameObject:addScript(path) end
--- @param path string
--- @return boolean
function GameObject:hasScript(path) end
--- @param path string
function GameObject:removeScript(path) end
--- @param scale number
function GameObject:setScale(scale) end
--- @param cellName string
--- @param pos Vector3
--- @param options? {rotation: Transform, onGround: boolean}
function GameObject:teleport(cellName, pos, options) end
--- @param inventory Inventory
function GameObject:moveInto(inventory) end
--- @param keepInventory? boolean
function GameObject:remove(keepInventory) end
--- @param count number
--- @return GameObject
function GameObject:split(count) end
--- @return Box
function GameObject:getBoundingBox() end

--- @class MagicEffectWithParams
--- @field id number EFFECT_TYPE value
--- @field range number RANGE value
--- @field area number
--- @field duration number
--- @field minMagnitude number
--- @field maxMagnitude number
--- @field affectedAttribute number|nil
--- @field affectedSkill number|nil

--- @class SpellRecord
--- @field id string
--- @field name string
--- @field type number SPELL_TYPE value
--- @field cost number
--- @field flags table
--- @field effects MagicEffectWithParams[]

--- @class EnchantmentRecord
--- @field id string
--- @field type number ENCHANTMENT_TYPE value
--- @field cost number
--- @field charge number
--- @field autocalc boolean
--- @field effects MagicEffectWithParams[]

--- @class MagicEffectRecord
--- @field id number EFFECT_TYPE value
--- @field name string
--- @field school number
--- @field baseCost number
--- @field flags table
--- @field color Color
--- @field particle string
--- @field castingStatic string
--- @field hitStatic string
--- @field areaStatic string
--- @field boltStatic string
--- @field castingSound string
--- @field hitSound string
--- @field areaSound string
--- @field boltSound string

--- @class ActiveEffect
--- @field id number
--- @field affectedAttribute number|nil
--- @field affectedSkill number|nil
--- @field magnitude number
--- @field duration number
--- @field durationLeft number

--- @class ActiveSpellEffect
--- @field id number
--- @field affectedSkill number|nil
--- @field affectedAttribute number|nil
--- @field duration number
--- @field durationLeft number
--- @field magnitude number
--- @field minMagnitude number
--- @field maxMagnitude number

--- @class ActiveSpell
--- @field id string
--- @field name string
--- @field effects ActiveSpellEffect[]

--- @class SoundRecord
--- @field id string
--- @field fileName string
--- @field volume number
--- @field minRange number
--- @field maxRange number

--- @class AttributeRecord
--- @field id string
--- @field name string
--- @field description string

--- @class MagicSchoolData
--- @field id number
--- @field name string
--- @field description string
--- @field skill SkillRecord

--- @class SkillRecord
--- @field id string
--- @field name string
--- @field description string
--- @field school number|nil
--- @field attribute string
--- @field specialization number 0=Combat 1=Magic 2=Stealth
--- @field actions table
--- @field skillGain number[]

--- @class DialogueInfoCondition
--- @field type number CONDITION_TYPE
--- @field operator number CONDITION_OPERATOR
--- @field value any

--- @class DialogueRecordInfo
--- @field id string
--- @field text string
--- @field resultScript string
--- @field questName boolean
--- @field questFinished boolean
--- @field questRestart boolean
--- @field actor string
--- @field actorRace string
--- @field actorClass string
--- @field actorFaction string
--- @field actorFactionRank number
--- @field cell string
--- @field playerFaction string
--- @field dispositionMin number
--- @field gender string|nil
--- @field conditions DialogueInfoCondition[]

--- @class DialogueRecord
--- @field id string
--- @field type string
--- @field infos DialogueRecordInfo[]

--- @class RegionSoundRef
--- @field sound string
--- @field chance number

--- @class RegionRecord
--- @field id string
--- @field name string
--- @field mapColor Color
--- @field sleepList string
--- @field sounds RegionSoundRef[]
--- @field weatherProbabilities table

--- @class FactionRank
--- @field name string
--- @field primarySkillValue number
--- @field factionReaction number
--- @field attributeValues number[]
--- @field reputation number

--- @class FactionRecord
--- @field id string
--- @field name string
--- @field ranks FactionRank[]
--- @field reactions table
--- @field attributes string[]
--- @field skills string[]
--- @field hidden boolean

--- @class MWScriptRecord
--- @field id string
--- @field text string

--- @class WeatherRecord
--- @field id string
--- @field name string
--- @field glareView number
--- @field isStorm boolean
--- @field rainEffect string
--- @field rainSpeed number
--- @field windSpeed number
--- @field cloudSpeed number
--- @field ambientLoopSound string
--- @field particleEffect string

--- @class MWScriptVariables : table

--- @class MWScript
--- @field recordId string
--- @field object GameObject
--- @field player GameObject
--- @field isRunning boolean
--- @field variables MWScriptVariables

--- @class MWScriptFunctions
local MWScriptFunctions = {}
--- @param object GameObject
--- @param player? GameObject
--- @return MWScript|nil
function MWScriptFunctions.getLocalScript(object, player) end
--- @param player? GameObject
--- @return MWScriptVariables
function MWScriptFunctions.getGlobalVariables(player) end
--- @param recordId string
--- @param player? GameObject
--- @return MWScript|nil
function MWScriptFunctions.getGlobalScript(recordId, player) end

--- @class ContentFiles
local ContentFiles = {}
--- @return string[]
function ContentFiles.list() end
--- @param name string
--- @return number|nil
function ContentFiles.indexOf(name) end
--- @param name string
--- @return boolean
function ContentFiles.has(name) end

--- @class MagicModule
--- @field ENCHANTMENT_TYPE {CastOnce:number, WhenStrikes:number, WhenUsed:number, ConstantEffect:number}
--- @field RANGE {Self:number, Touch:number, Target:number}
--- @field SPELL_TYPE {Spell:number, Ability:number, Blight:number, Disease:number, Curse:number, Power:number}
--- @field EFFECT_TYPE table All ~135 effect ID constants
--- @field spells {records: SpellRecord[]}
--- @field effects {records: MagicEffectRecord[]}
--- @field enchantments {records: EnchantmentRecord[]}

--- @class SoundModule
--- @field records SoundRecord[]
local SoundModule = {}
--- @return boolean
function SoundModule.isEnabled() end
--- @param object GameObject
--- @param soundId string
--- @param options? {loop:boolean, volume:number, pitch:number, offset:number}
function SoundModule.playSound3d(object, soundId, options) end
--- @param object GameObject
--- @param soundPath string
--- @param options? {loop:boolean, volume:number, pitch:number, offset:number}
function SoundModule.playSoundFile3d(object, soundPath, options) end
--- @param object GameObject
--- @param soundId string
function SoundModule.stopSound3d(object, soundId) end
--- @param object GameObject
--- @param soundPath string
function SoundModule.stopSoundFile3d(object, soundPath) end
--- @param object GameObject
--- @param soundId string
--- @return boolean
function SoundModule.isSoundPlaying(object, soundId) end
--- @param object GameObject
--- @param soundPath string
--- @return boolean
function SoundModule.isSoundFilePlaying(object, soundPath) end
--- @param object GameObject
--- @param soundPath string
--- @param text? string
function SoundModule.say(object, soundPath, text) end
--- @param object GameObject
function SoundModule.stopSay(object) end
--- @param object GameObject
--- @return boolean
function SoundModule.isSayActive(object) end

--- @class StatsModule
--- @field Attribute {records: AttributeRecord[], record: fun(id:any):AttributeRecord}
--- @field Skill {records: SkillRecord[], record: fun(id:any):SkillRecord, magicSchools: fun():MagicSchoolData[]}

--- @class DialogueModule
--- @field journal {records: DialogueRecord[]}
--- @field topic {records: DialogueRecord[]}
--- @field voice {records: DialogueRecord[]}
--- @field greeting {records: DialogueRecord[]}
--- @field persuasion {records: DialogueRecord[]}
--- @field CONDITION_OPERATOR {Equal:number, NotEqual:number, Greater:number, GreaterOrEqual:number, Less:number, LessOrEqual:number}
--- @field CONDITION_TYPE table

--- @class WeatherModule
--- @field records WeatherRecord[]
local WeatherModule = {}
--- @param player? GameObject
--- @return WeatherRecord|nil
function WeatherModule.getCurrent(player) end
--- @param player? GameObject
--- @return WeatherRecord|nil
function WeatherModule.getNext(player) end
--- @param player? GameObject
--- @return number
function WeatherModule.getTransition(player) end
--- @param player GameObject
--- @param weatherId string
function WeatherModule.changeWeather(player, weatherId) end
--- @param player? GameObject
--- @return Vector3
function WeatherModule.getCurrentSunLightDirection(player) end
--- @param player? GameObject
--- @return number
function WeatherModule.getCurrentSunVisibility(player) end
--- @param player? GameObject
--- @return number
function WeatherModule.getCurrentSunPercentage(player) end
--- @param player? GameObject
--- @return number
function WeatherModule.getCurrentWindSpeed(player) end
--- @param player? GameObject
--- @return Vector3
function WeatherModule.getCurrentStormDirection(player) end

--- @class LandModule
local LandModule = {}
--- @param pos Vector3
--- @return number
function LandModule.getHeightAt(pos) end
--- @param pos Vector3
--- @return string
function LandModule.getTextureAt(pos) end

--- @class RegionsModule
--- @field records RegionRecord[]

--- @class FactionsModule
--- @field records FactionRecord[]

--- @class MWScriptsModule
--- @field records MWScriptRecord[]

--- @class openmw_core
--- @field API_REVISION number
--- @field contentFiles ContentFiles
--- @field magic MagicModule
--- @field sound SoundModule
--- @field stats StatsModule
--- @field dialogue DialogueModule
--- @field weather WeatherModule
--- @field land LandModule
--- @field regions RegionsModule
--- @field factions FactionsModule
--- @field mwscripts MWScriptsModule
local core = {}

function core.quit() end

--- @param name string
--- @param data any
function core.sendGlobalEvent(name, data) end

--- @return number
function core.getSimulationTime() end
--- @return number
function core.getSimulationTimeScale() end
--- @return number
function core.getGameTime() end
--- @return number
function core.getGameTimeScale() end
--- @return boolean
function core.isWorldPaused() end
--- @return number
function core.getRealTime() end
--- @return number
function core.getRealFrameDuration() end

--- @param name string
--- @return any
function core.getGMST(name) end

--- @return number 0-100
function core.getGameDifficulty() end

--- @param context string
--- @return fun(key:string, params?:table):string
function core.l10n(context) end

--- @param fileName string
--- @param formId integer
--- @return string
function core.getFormId(fileName, formId) end

return core
