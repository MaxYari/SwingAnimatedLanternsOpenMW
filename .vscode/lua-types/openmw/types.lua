
--- @class DynamicStat
--- @field base number
--- @field current number
--- @field modifier number

--- @class AttributeStat
--- @field base number
--- @field damage number
--- @field modified number
--- @field modifier number

--- @class SkillStat
--- @field base number
--- @field damage number
--- @field modified number
--- @field modifier number
--- @field progress number

--- @class AIStat
--- @field base number
--- @field modified number

--- @class LevelStat
--- @field current number
--- @field progress number

--- @class ReputationStat
--- @field modified number

--- @class DynamicStats
--- @field health fun(obj:GameObject):DynamicStat
--- @field magicka fun(obj:GameObject):DynamicStat
--- @field fatigue fun(obj:GameObject):DynamicStat

--- @class AttributeStats
--- @field strength fun(obj:GameObject):AttributeStat
--- @field intelligence fun(obj:GameObject):AttributeStat
--- @field willpower fun(obj:GameObject):AttributeStat
--- @field agility fun(obj:GameObject):AttributeStat
--- @field speed fun(obj:GameObject):AttributeStat
--- @field endurance fun(obj:GameObject):AttributeStat
--- @field personality fun(obj:GameObject):AttributeStat
--- @field luck fun(obj:GameObject):AttributeStat

--- @class AIStats
--- @field alarm fun(obj:GameObject):AIStat
--- @field fight fun(obj:GameObject):AIStat
--- @field flee fun(obj:GameObject):AIStat
--- @field hello fun(obj:GameObject):AIStat

--- @class NpcSkillStats
--- @field block fun(obj:GameObject):SkillStat
--- @field armorer fun(obj:GameObject):SkillStat
--- @field mediumarmor fun(obj:GameObject):SkillStat
--- @field heavyarmor fun(obj:GameObject):SkillStat
--- @field bluntweapon fun(obj:GameObject):SkillStat
--- @field longblade fun(obj:GameObject):SkillStat
--- @field axe fun(obj:GameObject):SkillStat
--- @field spear fun(obj:GameObject):SkillStat
--- @field athletics fun(obj:GameObject):SkillStat
--- @field enchant fun(obj:GameObject):SkillStat
--- @field destruction fun(obj:GameObject):SkillStat
--- @field alteration fun(obj:GameObject):SkillStat
--- @field illusion fun(obj:GameObject):SkillStat
--- @field conjuration fun(obj:GameObject):SkillStat
--- @field mysticism fun(obj:GameObject):SkillStat
--- @field restoration fun(obj:GameObject):SkillStat
--- @field alchemy fun(obj:GameObject):SkillStat
--- @field unarmored fun(obj:GameObject):SkillStat
--- @field security fun(obj:GameObject):SkillStat
--- @field sneak fun(obj:GameObject):SkillStat
--- @field acrobatics fun(obj:GameObject):SkillStat
--- @field lightarmor fun(obj:GameObject):SkillStat
--- @field shortblade fun(obj:GameObject):SkillStat
--- @field marksman fun(obj:GameObject):SkillStat
--- @field merchantile fun(obj:GameObject):SkillStat
--- @field speechcraft fun(obj:GameObject):SkillStat
--- @field handtohand fun(obj:GameObject):SkillStat

--- @class ActorStatsModule
--- @field dynamic DynamicStats
--- @field attributes AttributeStats
--- @field ai AIStats
--- @field level fun(obj:GameObject):LevelStat

--- @class NpcStatsModule : ActorStatsModule
--- @field skills NpcSkillStats
--- @field reputation fun(obj:GameObject):ReputationStat

--- @class ActorActiveEffects
local ActorActiveEffects = {}
--- @param effectType number
--- @param attribute? number
--- @param skill? number
--- @return ActiveEffect
function ActorActiveEffects:getEffect(effectType, attribute, skill) end
--- @param effectType number
--- @param attribute? number
--- @param skill? number
function ActorActiveEffects:remove(effectType, attribute, skill) end
--- @param effectType number
--- @param attribute? number
--- @param skill? number
--- @param params table
function ActorActiveEffects:set(effectType, attribute, skill, params) end
--- @param effectType number
--- @param attribute? number
--- @param skill? number
--- @param params table
function ActorActiveEffects:modify(effectType, attribute, skill, params) end

--- @class ActorActiveSpells
local ActorActiveSpells = {}
--- @param spellId string
--- @return boolean
function ActorActiveSpells:isSpellActive(spellId) end
--- @param activeSpell ActiveSpell
function ActorActiveSpells:remove(activeSpell) end
--- @param params table
function ActorActiveSpells:add(params) end

--- @class ActorSpells
local ActorSpells = {}
--- @param spellId string
function ActorSpells:add(spellId) end
--- @param spellId string
function ActorSpells:remove(spellId) end
function ActorSpells:clear() end
--- @param spellId string
--- @return boolean
function ActorSpells:canUsePower(spellId) end

--- @class EQUIPMENT_SLOT_TYPE
--- @field Helmet number
--- @field Cuirass number
--- @field Greaves number
--- @field LeftPauldron number
--- @field RightPauldron number
--- @field LeftGauntlet number
--- @field RightGauntlet number
--- @field Boots number
--- @field Shirt number
--- @field Pants number
--- @field Skirt number
--- @field Robe number
--- @field LeftRing number
--- @field RightRing number
--- @field Amulet number
--- @field Belt number
--- @field CarriedRight number
--- @field CarriedLeft number
--- @field Ammunition number

--- @class STANCE_TYPE
--- @field Nothing number
--- @field Weapon number
--- @field Spell number

--- @class ActorType
--- @field EQUIPMENT_SLOT EQUIPMENT_SLOT_TYPE
--- @field STANCE STANCE_TYPE
--- @field stats ActorStatsModule
local ActorType = {}
--- @param obj GameObject
--- @return boolean
function ActorType.objectIsInstance(obj) end
--- @param obj GameObject
--- @return number
function ActorType.getEncumbrance(obj) end
--- @param obj GameObject
--- @return number
function ActorType.getCapacity(obj) end
--- @param obj GameObject
--- @return number
function ActorType.getBarterGold(obj) end
--- @param obj GameObject
--- @param val number
function ActorType.setBarterGold(obj, val) end
--- @param obj GameObject
--- @return boolean
function ActorType.isDead(obj) end
--- @param obj GameObject
--- @return boolean
function ActorType.isDeathFinished(obj) end
--- @param obj GameObject
--- @return boolean
function ActorType.isInActorsProcessingRange(obj) end
--- @param obj GameObject
--- @return Inventory
function ActorType.inventory(obj) end
--- @param obj GameObject
--- @return boolean
function ActorType.canMove(obj) end
--- @param obj GameObject
--- @return number
function ActorType.getRunSpeed(obj) end
--- @param obj GameObject
--- @return number
function ActorType.getWalkSpeed(obj) end
--- @param obj GameObject
--- @return number
function ActorType.getCurrentSpeed(obj) end
--- @param obj GameObject
--- @return boolean
function ActorType.isOnGround(obj) end
--- @param obj GameObject
--- @return boolean
function ActorType.isSwimming(obj) end
--- @param obj GameObject
--- @return number STANCE value
function ActorType.getStance(obj) end
--- @param obj GameObject
--- @param stance number
function ActorType.setStance(obj, stance) end
--- @param obj GameObject
--- @param recordId string
--- @return boolean
function ActorType.hasEquipped(obj, recordId) end
--- @param obj GameObject
--- @return table equipment slot -> GameObject
function ActorType.getEquipment(obj) end
--- @param obj GameObject
--- @param equipment table
function ActorType.setEquipment(obj, equipment) end
--- @param obj GameObject
--- @return SpellRecord|nil
function ActorType.getSelectedSpell(obj) end
--- @param obj GameObject
--- @param spellId string
function ActorType.setSelectedSpell(obj, spellId) end
--- @param obj GameObject
function ActorType.clearSelectedCastable(obj) end
--- @param obj GameObject
--- @return GameObject|nil
function ActorType.getSelectedEnchantedItem(obj) end
--- @param obj GameObject
--- @param item GameObject
function ActorType.setSelectedEnchantedItem(obj, item) end
--- @param obj GameObject
--- @return ActorActiveEffects
function ActorType.activeEffects(obj) end
--- @param obj GameObject
--- @return ActorActiveSpells
function ActorType.activeSpells(obj) end
--- @param obj GameObject
--- @return ActorSpells
function ActorType.spells(obj) end
--- @param obj GameObject
--- @return table
function ActorType.getPathfindingAgentBounds(obj) end

--- @class ItemData
--- @field condition number
--- @field enchantmentCharge number
--- @field soul string

--- @class ItemType
local ItemType = {}
--- @param obj GameObject
--- @return boolean
function ItemType.objectIsInstance(obj) end
--- @param obj GameObject
--- @return boolean
function ItemType.isRestocking(obj) end
--- @param obj GameObject
--- @return boolean
function ItemType.isCarriable(obj) end
--- @param obj GameObject
--- @return ItemData
function ItemType.itemData(obj) end

--- @class TravelDestination
--- @field cellId string
--- @field position Vector3
--- @field rotation Vector3

--- @class CreatureRecord
--- @field id string
--- @field name string
--- @field model string
--- @field mwscript string|nil
--- @field type number
--- @field baseGold number
--- @field attack table[]
--- @field attributes table
--- @field walks boolean
--- @field swims boolean
--- @field flies boolean
--- @field essential boolean
--- @field respawn boolean
--- @field hasWeapon boolean
--- @field bloodType number
--- @field servicesOffered table
--- @field travelDestinations TravelDestination[]

--- @class CREATURE_TYPE
--- @field Creatures number
--- @field Daedra number
--- @field Undead number
--- @field Humanoid number

--- @class CreatureTypeModule
--- @field TYPE CREATURE_TYPE
--- @field records CreatureRecord[]
local CreatureTypeModule = {}
--- @param obj GameObject
--- @return boolean
function CreatureTypeModule.objectIsInstance(obj) end
--- @param obj any
--- @return CreatureRecord
function CreatureTypeModule.record(obj) end
--- @param template table
--- @return CreatureRecord
function CreatureTypeModule.createRecordDraft(template) end

--- @class ClassRecord
--- @field id string
--- @field name string
--- @field attributes string[]
--- @field majorSkills string[]
--- @field minorSkills string[]
--- @field description string
--- @field isPlayable boolean
--- @field specialization number

--- @class GenderedNumber
--- @field male number
--- @field female number

--- @class RaceRecord
--- @field id string
--- @field name string
--- @field description string
--- @field skills table[]
--- @field spells string[]
--- @field isPlayable boolean
--- @field isBeast boolean
--- @field height GenderedNumber
--- @field weight GenderedNumber
--- @field attributes table

--- @class NpcRecord
--- @field id string
--- @field name string
--- @field model string
--- @field mwscript string|nil
--- @field race string
--- @field class string
--- @field faction string|nil
--- @field hair string
--- @field head string
--- @field isMale boolean
--- @field baseGold number
--- @field attributes table
--- @field skills table
--- @field servicesOffered table
--- @field travelDestinations TravelDestination[]
--- @field essential boolean
--- @field respawn boolean

--- @class NpcTypeModule
--- @field stats NpcStatsModule
--- @field records NpcRecord[]
local NpcTypeModule = {}
--- @param obj GameObject
--- @return boolean
function NpcTypeModule.objectIsInstance(obj) end
--- @param obj any
--- @return NpcRecord
function NpcTypeModule.record(obj) end
--- @param template table
--- @return NpcRecord
function NpcTypeModule.createRecordDraft(template) end
--- @param obj GameObject
--- @return string[]
function NpcTypeModule.getFactions(obj) end
--- @param obj GameObject
--- @param factionId string
--- @return number|nil
function NpcTypeModule.getFactionRank(obj, factionId) end
--- @param obj GameObject
--- @param factionId string
--- @param rank number
function NpcTypeModule.setFactionRank(obj, factionId, rank) end
--- @param obj GameObject
--- @param factionId string
--- @param delta number
function NpcTypeModule.modifyFactionRank(obj, factionId, delta) end
--- @param obj GameObject
--- @param factionId string
function NpcTypeModule.joinFaction(obj, factionId) end
--- @param obj GameObject
--- @param factionId string
function NpcTypeModule.leaveFaction(obj, factionId) end
--- @param obj GameObject
--- @param factionId string
--- @return number
function NpcTypeModule.getFactionReputation(obj, factionId) end
--- @param obj GameObject
--- @param factionId string
--- @param val number
function NpcTypeModule.setFactionReputation(obj, factionId, val) end
--- @param obj GameObject
--- @param factionId string
--- @param delta number
function NpcTypeModule.modifyFactionReputation(obj, factionId, delta) end
--- @param obj GameObject
--- @param factionId string
function NpcTypeModule.expel(obj, factionId) end
--- @param obj GameObject
--- @param factionId string
function NpcTypeModule.clearExpelled(obj, factionId) end
--- @param obj GameObject
--- @param factionId string
--- @return boolean
function NpcTypeModule.isExpelled(obj, factionId) end
--- @param obj GameObject
--- @param player? GameObject
--- @return number
function NpcTypeModule.getDisposition(obj, player) end
--- @param obj GameObject
--- @param player? GameObject
--- @return number
function NpcTypeModule.getBaseDisposition(obj, player) end
--- @param obj GameObject
--- @param player GameObject
--- @param val number
function NpcTypeModule.setBaseDisposition(obj, player, val) end
--- @param obj GameObject
--- @param player GameObject
--- @param delta number
function NpcTypeModule.modifyBaseDisposition(obj, player, delta) end
--- @param obj GameObject
--- @return boolean
function NpcTypeModule.isWerewolf(obj) end
--- @param obj GameObject
--- @param val boolean
function NpcTypeModule.setWerewolf(obj, val) end

--- @class PLAYERQuest
--- @field id string
--- @field stage number
--- @field started boolean
--- @field finished boolean
local PLAYERQuest = {}
--- @param stage number
--- @param actor? GameObject
function PLAYERQuest:addJournalEntry(stage, actor) end

--- @class PlayerJournalTextEntry
--- @field text string
--- @field questId string
--- @field day number
--- @field month number
--- @field dayOfMonth number
--- @field id string

--- @class PlayerJournalTopicEntry
--- @field text string
--- @field actor string
--- @field id string

--- @class PlayerJournalTopic
--- @field id string
--- @field name string
--- @field entries PlayerJournalTopicEntry[]

--- @class PlayerJournal
--- @field journalTextEntries PlayerJournalTextEntry[]
--- @field topics PlayerJournalTopic[]

--- @class BirthSignRecord
--- @field id string
--- @field name string
--- @field description string
--- @field texture string
--- @field spells string[]

--- @class OFFENSE_TYPE_IDS
--- @field Theft number
--- @field Assault number
--- @field Murder number
--- @field Trespassing number
--- @field SleepingInOwnedBed number
--- @field Pickpocket number

--- @class PLAYER_CONTROL_SWITCH
--- @field Controls number
--- @field Fighting number
--- @field Jumping number
--- @field Looking number
--- @field Magic number
--- @field ViewMode number
--- @field VanityMode number

--- @class PlayerTypeModule
--- @field OFFENSE_TYPE OFFENSE_TYPE_IDS
--- @field CONTROL_SWITCH PLAYER_CONTROL_SWITCH
--- @field birthSigns BirthSignRecord[]
local PlayerTypeModule = {}
--- @param obj GameObject
--- @return boolean
function PlayerTypeModule.objectIsInstance(obj) end
--- @param obj GameObject
--- @return number
function PlayerTypeModule.getCrimeLevel(obj) end
--- @param obj GameObject
--- @param val number
function PlayerTypeModule.setCrimeLevel(obj, val) end
--- @param obj GameObject
--- @return boolean
function PlayerTypeModule.isCharGenFinished(obj) end
--- @param obj GameObject
--- @return boolean
function PlayerTypeModule.isTeleportingEnabled(obj) end
--- @param obj GameObject
--- @param val boolean
function PlayerTypeModule.setTeleportingEnabled(obj, val) end
--- @param obj GameObject
--- @return table<string,PLAYERQuest>
function PlayerTypeModule.quests(obj) end
--- @param obj GameObject
--- @return PlayerJournal
function PlayerTypeModule.journal(obj) end
--- @param obj GameObject
--- @param topicId string
function PlayerTypeModule.addTopic(obj, topicId) end
--- @param obj GameObject
--- @param switch number
--- @return boolean
function PlayerTypeModule.getControlSwitch(obj, switch) end
--- @param obj GameObject
--- @param switch number
--- @param val boolean
function PlayerTypeModule.setControlSwitch(obj, switch, val) end
--- @param obj GameObject
--- @return string
function PlayerTypeModule.getBirthSign(obj) end
--- @param obj GameObject
--- @param id string
function PlayerTypeModule.setBirthSign(obj, id) end
--- @param obj GameObject
--- @param name string
--- @param data any
function PlayerTypeModule.sendMenuEvent(obj, name, data) end

--- @class LOCKABLEType
local LOCKABLEType = {}
--- @param obj GameObject
--- @return boolean
function LOCKABLEType.objectIsInstance(obj) end
--- @param obj GameObject
--- @return any
function LOCKABLEType.getKeyRecord(obj) end
--- @param obj GameObject
--- @param rec any
function LOCKABLEType.setKeyRecord(obj, rec) end
--- @param obj GameObject
--- @return SpellRecord|nil
function LOCKABLEType.getTrapSpell(obj) end
--- @param obj GameObject
--- @param spell SpellRecord
function LOCKABLEType.setTrapSpell(obj, spell) end
--- @param obj GameObject
--- @return number
function LOCKABLEType.getLockLevel(obj) end
--- @param obj GameObject
--- @return boolean
function LOCKABLEType.isLocked(obj) end
--- @param obj GameObject
--- @param level number
function LOCKABLEType.lock(obj, level) end
--- @param obj GameObject
function LOCKABLEType.unlock(obj) end

--- @class DoorSTATE
--- @field Idle number
--- @field Opening number
--- @field Closing number

--- @class DoorRecord
--- @field id string
--- @field name string
--- @field model string
--- @field mwscript string|nil
--- @field openSound string
--- @field closeSound string

--- @class DoorTypeModule
--- @field STATE DoorSTATE
--- @field records DoorRecord[]
local DoorTypeModule = {}
--- @param obj GameObject
--- @return boolean
function DoorTypeModule.objectIsInstance(obj) end
--- @param obj any
--- @return DoorRecord
function DoorTypeModule.record(obj) end
--- @param template table
--- @return DoorRecord
function DoorTypeModule.createRecordDraft(template) end
--- @param obj GameObject
--- @return boolean
function DoorTypeModule.isTeleport(obj) end
--- @param obj GameObject
--- @return Vector3
function DoorTypeModule.destPosition(obj) end
--- @param obj GameObject
--- @return Transform
function DoorTypeModule.destRotation(obj) end
--- @param obj GameObject
--- @return Cell
function DoorTypeModule.destCell(obj) end
--- @param obj GameObject
--- @return number DoorSTATE value
function DoorTypeModule.getDoorState(obj) end
--- @param obj GameObject
--- @return boolean
function DoorTypeModule.isOpen(obj) end
--- @param obj GameObject
--- @return boolean
function DoorTypeModule.isClosed(obj) end
--- @param obj GameObject
--- @param openState? boolean
function DoorTypeModule.activateDoor(obj, openState) end

--- @class ArmorRecord
--- @field id string
--- @field name string
--- @field model string
--- @field icon string
--- @field mwscript string|nil
--- @field type number
--- @field weight number
--- @field value number
--- @field health number
--- @field enchantment string|nil
--- @field enchantmentPoints number
--- @field armorType number
--- @field baseArmor number

--- @class BookRecord
--- @field id string
--- @field name string
--- @field model string
--- @field icon string
--- @field mwscript string|nil
--- @field text string
--- @field weight number
--- @field value number
--- @field enchantment string|nil
--- @field enchantmentPoints number
--- @field isScroll boolean
--- @field skill string|nil

--- @class WeaponRecord
--- @field id string
--- @field name string
--- @field model string
--- @field icon string
--- @field mwscript string|nil
--- @field type number
--- @field weight number
--- @field value number
--- @field health number
--- @field speed number
--- @field reach number
--- @field enchantment string|nil
--- @field enchantmentPoints number
--- @field chopMin number
--- @field chopMax number
--- @field slashMin number
--- @field slashMax number
--- @field thrustMin number
--- @field thrustMax number
--- @field isMagical boolean
--- @field isSilver boolean

--- @class WEAPON_TYPE
--- @field ShortBladeOneHand number
--- @field LongBladeOneHand number
--- @field LongBladeTwoHand number
--- @field BluntOneHand number
--- @field BluntTwoClose number
--- @field BluntTwoWide number
--- @field SpearTwoWide number
--- @field AxeOneHand number
--- @field AxeTwoHand number
--- @field MarksmanBow number
--- @field MarksmanCrossbow number
--- @field MarksmanThrown number
--- @field Arrow number
--- @field Bolt number

--- @class WeaponTypeModule
--- @field TYPE WEAPON_TYPE
--- @field records WeaponRecord[]
local WeaponTypeModule = {}
--- @param obj GameObject
--- @return boolean
function WeaponTypeModule.objectIsInstance(obj) end
--- @param obj any
--- @return WeaponRecord
function WeaponTypeModule.record(obj) end
--- @param template table
--- @return WeaponRecord
function WeaponTypeModule.createRecordDraft(template) end

--- @class LightRecord
--- @field id string
--- @field name string
--- @field model string
--- @field icon string
--- @field mwscript string|nil
--- @field weight number
--- @field value number
--- @field duration number
--- @field radius number
--- @field color Color
--- @field isCarriable boolean
--- @field isDynamic boolean
--- @field isFire boolean
--- @field isFlicker boolean
--- @field isOffByDefault boolean
--- @field sound string

--- @class ContainerRecord
--- @field id string
--- @field name string
--- @field model string
--- @field mwscript string|nil
--- @field weight number
--- @field isOrganic boolean
--- @field isRespawn boolean

--- @class ContainerTypeModule
--- @field records ContainerRecord[]
local ContainerTypeModule = {}
--- @param obj GameObject
--- @return boolean
function ContainerTypeModule.objectIsInstance(obj) end
--- @param obj any
--- @return ContainerRecord
function ContainerTypeModule.record(obj) end
--- @param template table
--- @return ContainerRecord
function ContainerTypeModule.createRecordDraft(template) end
--- @param obj GameObject
--- @return Inventory
function ContainerTypeModule.content(obj) end
--- @param obj GameObject
--- @return Inventory
function ContainerTypeModule.inventory(obj) end
--- @param obj GameObject
--- @return number
function ContainerTypeModule.getEncumbrance(obj) end
--- @param obj GameObject
--- @return number
function ContainerTypeModule.getCapacity(obj) end

--- @class StaticRecord
--- @field id string
--- @field model string

--- @class LevelledListItem
--- @field id string
--- @field level number

--- @class CreatureLevelledListRecord
--- @field id string
--- @field chanceNone number
--- @field calculateFromAllLevels boolean
--- @field creatures LevelledListItem[]
local CreatureLevelledListRecord = {}
--- @param maxLevel number
--- @return string
function CreatureLevelledListRecord:getRandomId(maxLevel) end

--- @class openmw_types
--- @field Actor ActorType
--- @field Item ItemType
--- @field Creature CreatureTypeModule
--- @field NPC NpcTypeModule
--- @field Player PlayerTypeModule
--- @field LOCKABLE LOCKABLEType
--- @field Door DoorTypeModule
--- @field Armor {TYPE:table, records:ArmorRecord[], objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):ArmorRecord, createRecordDraft:fun(t:table):ArmorRecord}
--- @field Book {records:BookRecord[], objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):BookRecord, createRecordDraft:fun(t:table):BookRecord}
--- @field Weapon WeaponTypeModule
--- @field Clothing {TYPE:table, records:table[], objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):table, createRecordDraft:fun(t:table):table}
--- @field Ingredient {records:table[], objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):table}
--- @field Light {records:LightRecord[], objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):LightRecord, createRecordDraft:fun(t:table):LightRecord}
--- @field Miscellaneous {records:table[], objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):table, createRecordDraft:fun(t:table):table}
--- @field Potion {records:table[], objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):table, createRecordDraft:fun(t:table):table}
--- @field Apparatus {TYPE:table, records:table[], objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):table}
--- @field Lockpick {records:table[], objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):table}
--- @field Probe {records:table[], objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):table}
--- @field Repair {records:table[], objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):table}
--- @field Activator {records:table[], objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):table, createRecordDraft:fun(t:table):table}
--- @field Container ContainerTypeModule
--- @field Static {records:StaticRecord[], objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):StaticRecord, createRecordDraft:fun(t:table):StaticRecord}
--- @field LevelledCreature {records:CreatureLevelledListRecord[], objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):CreatureLevelledListRecord}
--- @field ESM4Door {objectIsInstance:fun(obj:GameObject):boolean, isTeleport:fun(obj:GameObject):boolean, destPosition:fun(obj:GameObject):Vector3, destRotation:fun(obj:GameObject):Transform, destCell:fun(obj:GameObject):Cell, record:fun(obj:any):table, records:table[]}
--- @field ESM4Terminal {objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):table, records:table[]}
--- @field ESM4Activator {objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):table, records:table[]}
--- @field ESM4Armor {objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):table, records:table[]}
--- @field ESM4Book {objectIsInstance:fun(obj:GameObject):boolean, record:fun(obj:any):table, records:table[]}
local types = {}

return types
