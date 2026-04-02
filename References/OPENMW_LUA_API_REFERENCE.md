# OpenMW Lua API Reference

Compiled from OpenMW source code. Covers the full Lua scripting API as of the master branch.

---

## Table of Contents

1. [Overview](#overview)
2. [Script Types and Contexts](#script-types-and-contexts)
3. [.omwscripts Format](#omwscripts-format)
4. [Engine Handlers](#engine-handlers)
5. [Events System](#events-system)
6. [API Packages](#api-packages)
   - [openmw.core](#openmwcore)
   - [openmw.world](#openmwworld)
   - [openmw.types](#openmwtypes)
   - [openmw.util](#openmwutil)
   - [openmw.nearby](#openmwnearby)
   - [openmw.self](#openmwself)
   - [openmw.async](#openmwasync)
   - [openmw.animation](#openmwanimation)
   - [openmw.storage](#openmwstorage)
   - [openmw.camera](#openmwcamera)
   - [openmw.input](#openmwinput)
   - [openmw.ui](#openmwui)
   - [openmw.vfs](#openmwvfs)
   - [openmw.ambient](#openmwambient)
   - [openmw.postprocessing](#openmwpostprocessing)
   - [openmw.debug](#openmwdebug)
   - [openmw.menu](#openmwmenu)
   - [openmw.markup](#openmwmarkup)
   - [openmw.interfaces](#openmwinterfaces)
7. [Auxiliary Packages](#auxiliary-packages)
   - [openmw_aux.time](#openmw_auxtime)
   - [openmw_aux.util](#openmw_auxutil)
   - [openmw_aux.calendar](#openmw_auxcalendar)
   - [openmw_aux.ui](#openmw_auxui)
8. [UI System In Depth](#ui-system-in-depth)
9. [AI Packages](#ai-packages)
10. [Save/Load and Serializable Data](#saveload-and-serializable-data)
11. [Interfaces System](#interfaces-system)

---

## Overview

OpenMW uses **Lua 5.1** (with some 5.2/5.3 extensions) for scripting. Scripts run in a sandboxed environment — no `io`, `os`, `debug`, `package`, or `dofile`/`loadfile` access. Use `openmw.vfs` for file access.

### Key Concepts

- Scripts are registered via `.omwscripts` files placed in data directories
- Each script runs in a specific **context** (global, local, player, menu, load)
- Scripts can communicate via **events** and **interfaces**
- Persistent data is stored via `openmw.storage`
- Timers are managed via `openmw.async`
- All API packages are loaded with `require('openmw.packagename')`

### Multiplayer Mental Model

- **Local scripts** = client-side (run on each player's machine)
- **Global scripts** = server-side (one instance for the whole world)

---

## Script Types and Contexts

| Context | Description |
|---------|-------------|
| `global` | Global scripts — run once for the whole world. Can access `openmw.world`, `openmw.types`, etc. |
| `local` | Local scripts — attached to a specific game object (actor, item, etc.) |
| `player` | Player scripts — attached to the player object specifically |
| `menu` | Menu scripts — run in the main menu, can access `openmw.menu` |
| `load` | Load scripts — run at game load time only |

Scripts declare their context in the header comment or `.omwscripts` file.

---

## .omwscripts Format

```
# Comments start with '#'
GLOBAL: scripts/myglobal.lua
PLAYER: scripts/myplayer.lua

# Attach to specific record types:
LOCAL[type:NPC]: scripts/mynpc.lua

# Attach by record ID:
LOCAL[recordId:fargoth]: scripts/fargoth.lua

# Attach to all objects of given type in specific cell:
LOCAL[type:Creature, cell:Seyda Neen]: scripts/test.lua
```

Supported attachment filters: `type:NPC`, `type:Creature`, `type:Player`, `type:Container`, `type:Door`, `type:Activator`, `type:Item`, `recordId:<id>`.

---

## Engine Handlers

Engine handlers are functions defined at the top level of a script. OpenMW calls them automatically.

### Universal Handlers (all contexts)

```lua
-- Called every frame. dt = time since last frame (seconds).
function onUpdate(dt) end

-- Called when saving the game. Return a serializable table.
function onSave()
    return { myData = 42 }
end

-- Called when loading a saved game.
function onLoad(data)
    -- data is what was returned by onSave
end
```

### Global Script Handlers

```lua
function onInit() end          -- Called once when script is first created
function onUpdate(dt) end
function onSave() return {} end
function onLoad(data) end

-- Event handlers table
local myHandlers = {}
function myHandlers.MyEventName(data)
    print('Got event:', data.value)
end
return { eventHandlers = myHandlers }
```

### Local Script Handlers

```lua
function onInit() end
function onUpdate(dt) end
function onSave() return {} end
function onLoad(data) end
function onActive() end         -- Object becomes active (enters processing range)
function onInactive() end       -- Object becomes inactive
function onActivated(actor) end -- Object was activated by actor
function onTeleported() end     -- Object was teleported
function onConsume(potion) end  -- Actor consumed a potion (player-attached local scripts)
function onDeath() end          -- Actor died

return { eventHandlers = {} }
```

### Player Script Handlers

All local script handlers plus:

```lua
function onKeyPress(key) end       -- key: KeyboardEvent
function onKeyRelease(key) end
function onTouchPress(touch) end   -- touch: TouchEvent
function onTouchRelease(touch) end
function onTouchMove(touch) end
function onInputAction(id) end     -- id: input.ACTION value
function onConsume(potion) end
function onDeath() end
```

### Menu Script Handlers

```lua
function onInit() end
function onSave() return {} end    -- Only called when quitting
function onLoad(data) end
function onUpdate(dt) end
function onStateChanged() end      -- Game state changed (running/menu/ended)
function onUiModeChanged(arg) end  -- arg: { old, new, arg }

return { eventHandlers = {} }
```

### Load Script Handlers

```lua
-- Called when game is being loaded (before the actual load)
function onInterfaceOverride(base) end
```

---

## Events System

### Sending Events

```lua
-- Send to all global scripts
core.sendGlobalEvent('EventName', { key = value })

-- Send to scripts on a specific object
someObject:sendEvent('EventName', { key = value })

-- Send from menu script to player scripts
-- Use: types.Player.sendMenuEvent(player, 'EventName', data)
```

### Receiving Events

```lua
local handlers = {}

function handlers.MyEvent(data)
    print('received:', data.value)
end

return { eventHandlers = handlers }
```

### Built-in Events (sent by the engine)

#### Object Events (local/player scripts)

| Event | Data | Description |
|-------|------|-------------|
| `DialogueResponse` | `{ topic, actor, response }` | Dialogue choice made |
| `Died` | `{ attacker }` | Actor died |
| `StartAIPackage` | `{ type }` | AI package started |
| `RemoveAIPackages` | `{ type }` | AI packages removed |
| `UseItem` | `{ item, actor }` | Item used |
| `ModifyStat` | `{ stat, value }` | Stat modified |
| `AddVfx` | `{ model, loop, vfxId, ... }` | VFX added |
| `PlaySound3d` | `{ sound, loop, ... }` | 3D sound played |
| `BreakInvisibility` | `{}` | Invisibility broken |
| `Unequip` | `{ item }` | Item unequipped |
| `Hit` | `{ object, damage, ... }` | Actor hit |
| `ModifyItemCondition` | `{ item, value }` | Item condition modified |
| `ShowMessage` | `{ message }` | Message shown |
| `UiModeChanged` | `{ old, new, arg }` | UI mode changed |
| `AddUiMode` | `{ mode }` | UI mode added |
| `SetUiMode` | `{ mode }` | UI mode set |

#### World Events (global scripts)

| Event | Data | Description |
|-------|------|-------------|
| `Pause` | `{ tag }` | Pause the world |
| `Unpause` | `{ tag }` | Unpause the world |
| `SetGameTimeScale` | `{ scale }` | Set game time scale |
| `SetSimulationTimeScale` | `{ scale }` | Set simulation time scale |
| `SpawnVfx` | `{ model, position, options }` | Spawn VFX in world |
| `PlaySound3d` | `{ sound, position, ... }` | Play 3D sound |
| `ConsumeItem` | `{ item, actor }` | Consume item |
| `Lock` | `{ object, level }` | Lock object |
| `Unlock` | `{ object }` | Unlock object |

---

## API Packages

---

### openmw.core

**Contexts:** global, menu, local, player, load

```lua
local core = require('openmw.core')
```

#### Global Functions and Fields

```lua
core.API_REVISION          -- number: API revision number
core.quit()                -- Quit the game
core.sendGlobalEvent(name, data)  -- Send event to all global scripts

-- Time functions
core.getSimulationTime()      -- Simulation seconds since game start
core.getSimulationTimeScale() -- Simulation time speed relative to real time
core.getGameTime()            -- Game time in seconds
core.getGameTimeScale()       -- Game time scale relative to simulation time
core.isWorldPaused()          -- boolean
core.getRealTime()            -- Real time in seconds since process start
core.getRealFrameDuration()   -- Real frame duration in seconds

-- Game settings
core.getGMST(name)            -- Get game setting value (string/number/boolean)
core.getGameDifficulty()      -- Number 0-100 (0=easiest, 100=hardest)

-- Localization
core.l10n(context)            -- Returns a localization function for given context
-- Usage: local l = core.l10n('MyMod'); l('key', {param=val})

-- Content files
core.contentFiles.list()         -- Returns list of content file names
core.contentFiles.indexOf(name)  -- Returns index or nil
core.contentFiles.has(name)      -- Returns boolean

-- FormId
core.getFormId(fileName, formId) -- Returns a string FormId
```

#### GameObject Type

```lua
-- Fields (read-only unless noted)
obj.id               -- string: unique runtime identifier
obj.contentFile      -- number: index of content file
obj.enabled          -- boolean (read-only)
obj.position         -- util.Vector3
obj.scale            -- number
obj.rotation         -- util.Transform
obj.startingCell     -- Cell
obj.startingPosition -- util.Vector3
obj.startingRotation -- util.Transform
obj.owner            -- ObjectOwner
obj.cell             -- Cell or nil
obj.parentContainer  -- GameObject or nil (if in container)
obj.type             -- string: the object type name
obj.count            -- number: stack count
obj.recordId         -- string: record ID
obj.globalVariable   -- string or nil: global MWScript variable

-- Methods
obj:isValid()                -- Returns false if object was deleted
obj:sendEvent(name, data)    -- Send event to scripts on this object
obj:activateBy(actor)        -- Activate this object by given actor
obj:addScript(path)          -- Add a Lua script to this object
obj:hasScript(path)          -- Returns boolean
obj:removeScript(path)       -- Remove a script from this object
obj:setScale(scale)          -- Set scale
obj:teleport(cellName, pos, options)  -- options: {rotation, onGround}
obj:moveInto(inventory)      -- Move into a container/inventory
obj:remove(keepInventory)    -- Remove from world
obj:split(count)             -- Split stack, returns new object
obj:getBoundingBox()         -- Returns util.Box
```

#### ObjectOwner

```lua
owner.recordId    -- string: NPC/faction record ID
owner.factionId   -- string or nil
owner.factionRank -- number or nil
```

#### Cell Type

```lua
cell.name          -- string
cell.displayName   -- string
cell.id            -- string: unique cell ID
cell.region        -- string: region record ID
cell.isExterior    -- boolean
cell.isQuasiExterior -- boolean
cell.gridX         -- number (exterior cells only)
cell.gridY         -- number (exterior cells only)
cell.worldSpaceId  -- string
cell.hasWater      -- boolean
cell.waterLevel    -- number
cell.hasSky        -- boolean
cell.pathGrid      -- PathGrid or nil

-- Methods
cell:hasTag(tag)            -- boolean: check cell tag
cell:isInSameSpace(other)   -- boolean: same world space
cell:getAll(type)           -- ObjectList of all objects; type filter optional
```

#### PathGrid and PathGridPoint

```lua
-- PathGrid
pathGrid.graph   -- list of PathGridPoint

-- PathGridPoint
point.position   -- util.Vector3
point.edges      -- list<number>: indices of connected points
```

#### Inventory Type

```lua
inv:countOf(recordId)     -- number: count of items with this record ID
inv:getAll(type)          -- ObjectList: all items, optional type filter
inv:find(recordId)        -- GameObject or nil: find first matching item
inv:resolve()             -- Resolve levelled items (global scripts only)
inv:isResolved()          -- boolean
inv:findAll(recordId)     -- ObjectList: all matching items
```

#### Land

```lua
core.land.getHeightAt(pos)      -- number: terrain height at position
core.land.getTextureAt(pos)     -- string: texture record ID at position
```

#### Magic

```lua
-- Enums
core.magic.ENCHANTMENT_TYPE     -- CastOnce, WhenStrikes, WhenUsed, ConstantEffect
core.magic.RANGE                -- Self, Touch, Target
core.magic.SPELL_TYPE           -- Spell, Ability, Blight, Disease, Curse, Power

-- Effect IDs (core.magic.EFFECT_TYPE)
-- Full list: WaterBreathing, SwiftSwim, WaterWalking, Shield, FireShield,
-- LightningShield, FrostShield, Burden, Feather, Jump, Levitate, SlowFall,
-- Lock, Open, FireDamage, ShockDamage, FrostDamage, DrainAttribute,
-- DrainHealth, DrainMagicka, DrainFatigue, DrainSkill, DamageAttribute,
-- DamageHealth, DamageMagicka, DamageFatigue, DamageSkill, Poison,
-- WeaknessToFire, WeaknessToFrost, WeaknessToShock, WeaknessToMagicka,
-- WeaknessToCommonDisease, WeaknessToBlightDisease, WeaknessToCorprusDisease,
-- WeaknessToPoison, WeaknessToNormalWeapons, DisintegrateWeapon,
-- DisintegrateArmor, Invisibility, Chameleon, Light, Sanctuary, NightEye,
-- Charm, Paralyze, Silence, Blind, Sound, CalmHumanoid, CalmCreature,
-- FrenzyHumanoid, FrenzyCreature, DemoralizeHumanoid, DemoralizeCreature,
-- RallyHumanoid, RallyCreature, Dispel, Soultrap, Telekinesis, Mark,
-- Recall, DivineIntervention, AlmsiviIntervention, DetectAnimal,
-- DetectEnchantment, DetectKey, SpellAbsorption, Reflect, CureCommonDisease,
-- CureBlightDisease, CureCorprusDisease, CurePoison, CureParalyzation,
-- RestoreAttribute, RestoreHealth, RestoreMagicka, RestoreFatigue,
-- RestoreSkill, FortifyAttribute, FortifyHealth, FortifyMagicka,
-- FortifyFatigue, FortifySkill, FortifyMaximumMagicka, AbsorbAttribute,
-- AbsorbHealth, AbsorbMagicka, AbsorbFatigue, AbsorbSkill, ResistFire,
-- ResistFrost, ResistShock, ResistMagicka, ResistCommonDisease,
-- ResistBlightDisease, ResistCorprusDisease, ResistPoison,
-- ResistNormalWeapons, ResistParalysis, RemoveCurse, TurnUndead,
-- SummonScamp, SummonClannfear, SummonDaedroth, SummonDremora,
-- SummonAncestralGhost, SummonSkeletalMinion, SummonBonewalker,
-- SummonGreaterBonewalker, SummonBonelord, SummonWingedTwilight,
-- SummonHunger, SummonGoldensaint, SummonFlameAtronach,
-- SummonFrostAtronach, SummonStormAtronach, FortifyAttackBonus,
-- CommandCreature, CommandHumanoid, BoundDagger, BoundLongsword,
-- BoundMace, BoundBattle Axe, BoundSpear, BoundLongbow, ExtraSpell,
-- BoundCuirass, BoundHelm, BoundBoots, BoundShield, BoundGloves,
-- Corprus, Vampirism, SummonCenturionSphere, SunDamage, StuntedMagicka,
-- SummonFabricant, SummonWolf, SummonBear, SummonBonewolf, SummonCreature04,
-- SummonCreature05

-- Records
core.magic.spells.records           -- List of SpellRecord
core.magic.effects.records          -- List of MagicEffectRecord
core.magic.enchantments.records     -- List of EnchantmentRecord
```

##### SpellRecord

```lua
spell.id            -- string
spell.name          -- string
spell.type          -- SPELL_TYPE value
spell.cost          -- number
spell.flags         -- table
spell.effects       -- list of MagicEffectWithParams
```

##### MagicEffectRecord

```lua
effect.id             -- EFFECT_TYPE value
effect.name           -- string
effect.school         -- number (magic school index)
effect.baseCost       -- number
effect.flags          -- table
effect.color          -- util.Color
effect.particle       -- string: particle texture
effect.castingStatic  -- string: static record ID
effect.hitStatic      -- string
effect.areaStatic     -- string
effect.boltStatic     -- string
effect.castingSound   -- string: sound ID
effect.hitSound       -- string
effect.areaSound      -- string
effect.boltSound      -- string
```

##### EnchantmentRecord

```lua
enchantment.id       -- string
enchantment.type     -- ENCHANTMENT_TYPE value
enchantment.cost     -- number
enchantment.charge   -- number
enchantment.autocalc -- boolean
enchantment.effects  -- list of MagicEffectWithParams
```

##### MagicEffectWithParams

```lua
effect.id        -- EFFECT_TYPE value
effect.range     -- RANGE value
effect.area      -- number
effect.duration  -- number
effect.minMagnitude -- number
effect.maxMagnitude -- number
effect.affectedAttribute -- number or nil
effect.affectedSkill     -- number or nil
```

##### ActiveSpell / ActiveSpellEffect

```lua
-- ActiveSpell
spell.id          -- string
spell.name        -- string
spell.effects     -- list of ActiveSpellEffect

-- ActiveSpellEffect
eff.id            -- EFFECT_TYPE value
eff.affectedSkill -- number or nil
eff.affectedAttribute -- number or nil
eff.duration      -- number
eff.durationLeft  -- number
eff.magnitude     -- number
eff.minMagnitude  -- number
eff.maxMagnitude  -- number
```

#### Sound

```lua
core.sound.isEnabled()   -- boolean

-- 3D sounds
core.sound.playSound3d(object, soundId, options)
  -- options: { loop, volume, pitch, offset }
core.sound.playSoundFile3d(object, soundPath, options)
core.sound.stopSound3d(object, soundId)
core.sound.stopSoundFile3d(object, soundPath)
core.sound.isSoundPlaying(object, soundId)      -- boolean
core.sound.isSoundFilePlaying(object, soundPath) -- boolean

-- Say
core.sound.say(object, soundPath, text)
core.sound.stopSay(object)
core.sound.isSayActive(object)   -- boolean

-- Records
core.sound.records   -- List of SoundRecord
-- SoundRecord: id, fileName, volume, minRange, maxRange
```

#### Stats

```lua
-- Attributes
core.stats.Attribute.records  -- list of AttributeRecord
core.stats.Attribute.record(id)  -- AttributeRecord by name or index

-- AttributeRecord
attr.id          -- string e.g. "strength"
attr.name        -- string localized
attr.description -- string

-- Skills
core.stats.Skill.records     -- list of SkillRecord
core.stats.Skill.record(id)  -- SkillRecord by name or index

-- SkillRecord
skill.id              -- string e.g. "longblade"
skill.name            -- string
skill.description     -- string
skill.school          -- number: magic school index (or nil)
skill.attribute       -- string: governing attribute id
skill.specialization  -- number: 0=Combat, 1=Magic, 2=Stealth
skill.actions         -- table: use types and experience gains

-- MagicSchoolData
core.stats.Skill.magicSchools()   -- list of MagicSchoolData
-- MagicSchoolData: id, name, description, skill (SkillRecord)
```

#### Dialogue

```lua
core.dialogue.journal.records    -- list of DialogueRecord (type=Journal)
core.dialogue.topic.records      -- list of DialogueRecord (type=Topic)
core.dialogue.voice.records      -- list
core.dialogue.greeting.records   -- list
core.dialogue.persuasion.records -- list

-- DialogueRecord
rec.id      -- string
rec.type    -- string
rec.infos   -- list of DialogueRecordInfo

-- DialogueRecordInfo (extensive filter fields)
info.id              -- string
info.text            -- string (dialogue text)
info.resultScript    -- string (MWScript result)
info.questName       -- boolean
info.questFinished   -- boolean
info.questRestart    -- boolean
info.actor           -- string: actor ID filter
info.actorRace       -- string
info.actorClass      -- string
info.actorFaction    -- string
info.actorFactionRank -- number
info.cell            -- string
info.playerFaction   -- string
info.dispositionMin  -- number
info.gender          -- string or nil
info.conditions      -- list of DialogueInfoCondition

-- DialogueInfoCondition
cond.type        -- CONDITION_TYPE value
cond.operator    -- CONDITION_OPERATOR value
cond.value       -- string or number
-- CONDITION_OPERATOR: Equal, NotEqual, Greater, GreaterOrEqual, Less, LessOrEqual
-- CONDITION_TYPE includes: Faction, FactionRank, FactionReaction, Global, Item,
--   Local, NextPcRank, NotFaction, NotId, NotRace, NotCell, NotClass,
--   NotLocal, PcExpelled, PcCommonDisease, PcBlightDisease, PcCorprus,
--   PcVampire, PcLycanthropy, PcWerewolf, PcSexFemale, Dead, Id, Reputation,
--   Health, PCReputation, PCLevel, PCHealthPercent, PCMagicka, PCFatigue,
--   CreatureTarget, FriendHit, Fight, Hello, Alarm, Flee, ShouldAttack,
--   Werewolf, PcWerewolf, and more
```

#### Regions

```lua
core.regions.records  -- list of RegionRecord

-- RegionRecord
region.id                  -- string
region.name                -- string
region.mapColor            -- util.Color
region.sleepList           -- string: levelled list ID
region.sounds              -- list of RegionSoundRef
region.weatherProbabilities -- table: weatherId -> probability

-- RegionSoundRef
ref.sound    -- string: sound ID
ref.chance   -- number
```

#### Factions

```lua
core.factions.records  -- list of FactionRecord

-- FactionRecord
faction.id          -- string
faction.name        -- string
faction.ranks       -- list of FactionRank
faction.reactions   -- table: factionId -> reaction number
faction.attributes  -- list of 2 attribute IDs
faction.skills      -- list of skill IDs
faction.hidden      -- boolean

-- FactionRank
rank.name              -- string
rank.primarySkillValue -- number
rank.factionReaction   -- number
rank.attributeValues   -- list of 2 numbers
rank.reputation        -- number
```

#### MWScripts

```lua
core.mwscripts.records  -- list of MWScriptRecord

-- MWScriptRecord
rec.id    -- string
rec.text  -- string: script source
```

#### Weather

```lua
-- Records
core.weather.records   -- list of WeatherRecord

-- Queries
core.weather.getCurrent(player)      -- WeatherRecord or nil
core.weather.getNext(player)         -- WeatherRecord or nil
core.weather.getTransition(player)   -- number [0-1]: blend factor
core.weather.changeWeather(player, weatherId)  -- change weather

-- Current state
core.weather.getCurrentSunLightDirection(player)  -- util.Vector3
core.weather.getCurrentSunVisibility(player)      -- number
core.weather.getCurrentSunPercentage(player)      -- number
core.weather.getCurrentWindSpeed(player)          -- number
core.weather.getCurrentStormDirection(player)     -- util.Vector3

-- WeatherRecord (extensive)
w.id                     -- string
w.name                   -- string
w.glareView              -- number
w.isStorm                -- boolean
w.rainEffect             -- string
w.rainSpeed              -- number
w.rainDiameter           -- number
w.rainMinHeight          -- number
w.rainMaxHeight          -- number
w.rainThreshold          -- number
w.windSpeed              -- number
w.cloudSpeed             -- number
w.ambientLoopSound       -- string
w.particleEffect         -- string
w.threshold              -- number
-- Color fields: ambientColor, fogColor, skyColor, sunColor, landFogDepth, sunDiscColor
-- Each is a TimeOfDayInterpolatorColor with: sunrise, day, sunset, night values
-- Scalar fields: glareView, fogDepth, etc. are TimeOfDayInterpolatorFloat
```

---

### openmw.world

**Contexts:** global only

```lua
local world = require('openmw.world')
```

```lua
-- Fields
world.activeActors   -- ObjectList: all active actors
world.players        -- ObjectList: all players (currently 1)
world.cells          -- list of all Cell objects
world.mwscript       -- MWScriptFunctions

-- Cell access
world.getCellByName(name)                    -- Cell
world.getCellById(id)                        -- Cell
world.getExteriorCell(gridX, gridY, refCell) -- Cell

-- Time
world.getSimulationTime()           -- number
world.getSimulationTimeScale()      -- number
world.setSimulationTimeScale(scale)
world.getGameTime()                 -- number
world.getGameTimeScale()            -- number
world.setGameTimeScale(ratio)
world.advanceTime(hours)            -- Advance time (weather, AI, not regen)

-- Pause
world.isWorldPaused()         -- boolean
world.pause(tag)              -- Pause with optional tag
world.unpause(tag)            -- Unpause (tag must match)
world.getPausedTags()         -- table of current pause tags

-- Objects
world.getObjectByFormId(formId)   -- GameObject
world.createObject(recordId, count)  -- GameObject (disabled, needs teleport)
world.createRecord(record)        -- Creates custom record, returns typed record

-- VFX
world.vfx.spawn(model, position, options)
  -- options: mwMagicVfx, particleTextureOverride, scale, useAmbientLight, loop, vfxId
world.vfx.remove(vfxId)

-- MWScript
world.mwscript.getLocalScript(object, player)
world.mwscript.getGlobalVariables(player)  -- MWScriptVariables (mutable table)
world.mwscript.getGlobalScript(recordId, player)
-- MWScript: { recordId, object, player, isRunning, variables }
```

Supported record types for `world.createRecord`:
ActivatorRecord, ArmorRecord, BookRecord, ClothingRecord, ContainerRecord, CreatureRecord, DoorRecord, LightRecord, MiscellaneousRecord, NpcRecord, PotionRecord, StaticRecord, WeaponRecord

---

### openmw.types

**Contexts:** global, menu, local, player, load

```lua
local types = require('openmw.types')
```

#### Actor (common for Creature, NPC, Player)

```lua
-- Stats access
types.Actor.stats.dynamic.health(obj)    -- DynamicStat
types.Actor.stats.dynamic.magicka(obj)   -- DynamicStat
types.Actor.stats.dynamic.fatigue(obj)   -- DynamicStat
types.Actor.stats.attributes.strength(obj) -- AttributeStat
-- ... all attributes: intelligence, willpower, agility, speed, endurance, personality, luck
types.Actor.stats.ai.alarm(obj)          -- AIStat
types.Actor.stats.ai.fight(obj)
types.Actor.stats.ai.flee(obj)
types.Actor.stats.ai.hello(obj)
types.Actor.stats.level(obj)             -- LevelStat
types.Actor.stats.reputation(obj)        -- ReputationStat (NPC only)

-- Stat types
-- DynamicStat: { base, current, modifier } (all settable)
-- AttributeStat: { base, damage, modified (=base-damage+modifier), modifier }
-- SkillStat: { base, damage, modified, modifier, progress }
-- AIStat: { base, modified } (settable)
-- LevelStat: { current, progress } (read-only)
-- ReputationStat: { modified } (settable)

-- Physical
types.Actor.getEncumbrance(obj)    -- number: current carry weight
types.Actor.getCapacity(obj)       -- number: max carry weight
types.Actor.getBarterGold(obj)     -- number
types.Actor.setBarterGold(obj, val)
types.Actor.isDead(obj)            -- boolean
types.Actor.isDeathFinished(obj)   -- boolean
types.Actor.getPathfindingAgentBounds(obj) -- AgentBounds
types.Actor.isInActorsProcessingRange(obj) -- boolean

-- Movement
types.Actor.canMove(obj)           -- boolean
types.Actor.getRunSpeed(obj)       -- number
types.Actor.getWalkSpeed(obj)      -- number
types.Actor.getCurrentSpeed(obj)   -- number
types.Actor.isOnGround(obj)        -- boolean
types.Actor.isSwimming(obj)        -- boolean
types.Actor.getStance(obj)         -- STANCE value
types.Actor.setStance(obj, stance)

-- Equipment
types.Actor.hasEquipped(obj, recordId)  -- boolean
types.Actor.getEquipment(obj)           -- table: EQUIPMENT_SLOT -> GameObject
types.Actor.setEquipment(obj, table)    -- set equipment
types.Actor.getSelectedSpell(obj)       -- SpellRecord or nil
types.Actor.setSelectedSpell(obj, spellId)
types.Actor.clearSelectedCastable(obj)
types.Actor.getSelectedEnchantedItem(obj)  -- GameObject or nil
types.Actor.setSelectedEnchantedItem(obj, item)

-- Inventory
types.Actor.inventory(obj)   -- Inventory

-- Effects and spells
types.Actor.activeEffects(obj)  -- ActorActiveEffects
types.Actor.activeSpells(obj)   -- ActorActiveSpells
types.Actor.spells(obj)         -- ActorSpells

-- Check type
types.Actor.objectIsInstance(obj)  -- boolean

-- EQUIPMENT_SLOT enum
types.Actor.EQUIPMENT_SLOT.Helmet
types.Actor.EQUIPMENT_SLOT.Cuirass
types.Actor.EQUIPMENT_SLOT.Greaves
types.Actor.EQUIPMENT_SLOT.LeftPauldron
types.Actor.EQUIPMENT_SLOT.RightPauldron
types.Actor.EQUIPMENT_SLOT.LeftGauntlet
types.Actor.EQUIPMENT_SLOT.RightGauntlet
types.Actor.EQUIPMENT_SLOT.Boots
types.Actor.EQUIPMENT_SLOT.Shirt
types.Actor.EQUIPMENT_SLOT.Pants
types.Actor.EQUIPMENT_SLOT.Skirt
types.Actor.EQUIPMENT_SLOT.Robe
types.Actor.EQUIPMENT_SLOT.LeftRing
types.Actor.EQUIPMENT_SLOT.RightRing
types.Actor.EQUIPMENT_SLOT.Amulet
types.Actor.EQUIPMENT_SLOT.Belt
types.Actor.EQUIPMENT_SLOT.CarriedRight
types.Actor.EQUIPMENT_SLOT.CarriedLeft
types.Actor.EQUIPMENT_SLOT.Ammunition

-- STANCE enum
types.Actor.STANCE.Nothing
types.Actor.STANCE.Weapon
types.Actor.STANCE.Spell
```

##### ActorActiveEffects

```lua
local effects = types.Actor.activeEffects(actor)
-- Iterable: for id, effect in pairs(effects) do ... end
effects:getEffect(effectType, attribute, skill)  -- ActiveEffect or nil
effects:remove(effectType, attribute, skill)      -- global scripts only
effects:set(effectType, attribute, skill, params) -- set effect
effects:modify(effectType, attribute, skill, params) -- modify effect

-- ActiveEffect: { id, affectedAttribute, affectedSkill, magnitude, duration, durationLeft }
```

##### ActorActiveSpells

```lua
local spells = types.Actor.activeSpells(actor)
-- Iterable
spells:isSpellActive(spellId)  -- boolean
spells:remove(activeSpell)
spells:add(params)
-- params: { id, name, effects=[{id,magnitude,duration,...}], source, sourceItem }
```

##### ActorSpells

```lua
local spells = types.Actor.spells(actor)
-- Iterable
spells:add(spellId)       -- global scripts only
spells:remove(spellId)    -- global scripts only
spells:clear()            -- global scripts only
spells:canUsePower(spellId) -- boolean
```

#### NpcStats

```lua
-- NPC-specific stats
types.NPC.stats.skills.longblade(obj)  -- SkillStat
-- All skills: block, armorer, mediumarmor, heavyarmor, bluntweapon, longblade,
--   axe, spear, athletics, enchant, destruction, alteration, illusion,
--   conjuration, mysticism, restoration, alchemy, unarmored, security,
--   sneak, acrobatics, lightarmor, shortblade, marksman, merchantile,
--   speechcraft, handtohand

types.NPC.stats.reputation(obj)  -- ReputationStat
```

#### Item

```lua
types.Item.objectIsInstance(obj)     -- boolean
types.Item.isRestocking(obj)         -- boolean: in container that restocks
types.Item.isCarriable(obj)          -- boolean
types.Item.itemData(obj)             -- ItemData

-- ItemData
data.condition          -- number (settable)
data.enchantmentCharge  -- number (settable)
data.soul               -- string: soul creature record ID (settable)
```

#### Creature

```lua
types.Creature.objectIsInstance(obj)  -- boolean
types.Creature.TYPE.Creatures   -- 0
types.Creature.TYPE.Daedra      -- 1
types.Creature.TYPE.Undead      -- 2
types.Creature.TYPE.Humanoid    -- 3

types.Creature.record(obj)        -- CreatureRecord
types.Creature.records            -- list of all CreatureRecord
types.Creature.createRecordDraft(template) -- CreatureRecord (not in DB)
-- Must call world.createRecord to add to DB

-- CreatureRecord fields
rec.id                   -- string
rec.name                 -- string
rec.model                -- string: VFS path
rec.mwscript             -- string or nil
rec.type                 -- Creature.TYPE value
rec.baseGold             -- number
rec.attack               -- list of {min, max} tables (3 attack types)
rec.attributes           -- table: attributeId -> value
rec.walks                -- boolean
rec.swims                -- boolean
rec.flies                -- boolean
rec.essential            -- boolean
rec.respawn              -- boolean
rec.hasWeapon            -- boolean
rec.bloodType            -- number
rec.servicesOffered      -- table: serviceId -> boolean
rec.travelDestinations   -- list of TravelDestination
rec.aiSettings           -- AISettings table
```

#### NPC

```lua
types.NPC.objectIsInstance(obj)  -- boolean

-- Faction methods
types.NPC.getFactions(obj)        -- list of faction IDs
types.NPC.getFactionRank(obj, factionId)   -- number or nil
types.NPC.setFactionRank(obj, factionId, rank)
types.NPC.modifyFactionRank(obj, factionId, delta)
types.NPC.joinFaction(obj, factionId)
types.NPC.leaveFaction(obj, factionId)
types.NPC.getFactionReputation(obj, factionId)  -- number
types.NPC.setFactionReputation(obj, factionId, val)
types.NPC.modifyFactionReputation(obj, factionId, delta)
types.NPC.expel(obj, factionId)
types.NPC.clearExpelled(obj, factionId)
types.NPC.isExpelled(obj, factionId)  -- boolean

-- Disposition
types.NPC.getDisposition(obj, player)      -- number: effective disposition
types.NPC.getBaseDisposition(obj, player)  -- number
types.NPC.setBaseDisposition(obj, player, val)
types.NPC.modifyBaseDisposition(obj, player, delta)

-- Werewolf
types.NPC.isWerewolf(obj)       -- boolean
types.NPC.setWerewolf(obj, val) -- global scripts only

-- Records
types.NPC.record(obj)        -- NpcRecord
types.NPC.records            -- list
types.NPC.createRecordDraft(template)

-- NpcRecord fields
rec.id            -- string
rec.name          -- string
rec.model         -- string
rec.mwscript      -- string or nil
rec.race          -- string: race record ID
rec.class         -- string: class record ID
rec.faction       -- string or nil
rec.hair          -- string: head mesh ID
rec.head          -- string: head texture ID
rec.isMale        -- boolean
rec.baseGold      -- number
rec.attributes    -- table: attributeId -> value
rec.skills        -- table: skillId -> value
rec.servicesOffered -- table
rec.travelDestinations -- list of TravelDestination
rec.aiSettings    -- table
rec.essential     -- boolean
rec.respawn       -- boolean

-- ClassRecord
rec.id              -- string
rec.name            -- string
rec.attributes      -- list of 2 attribute IDs
rec.majorSkills     -- list of 5 skill IDs
rec.minorSkills     -- list of 5 skill IDs
rec.description     -- string
rec.isPlayable      -- boolean
rec.specialization  -- number: 0=Combat, 1=Magic, 2=Stealth

-- RaceRecord
rec.id          -- string
rec.name        -- string
rec.description -- string
rec.skills      -- list of {id, value} bonus tables
rec.spells      -- list of spell IDs
rec.isPlayable  -- boolean
rec.isBeast     -- boolean
rec.height      -- GenderedNumber { male, female }
rec.weight      -- GenderedNumber
rec.attributes  -- table: attributeId -> GenderedNumber { male, female }

-- TravelDestination
dest.cellId   -- string
dest.position -- util.Vector3
dest.rotation -- util.Vector3 (Euler angles)
```

#### Player (PLAYER)

```lua
types.Player.objectIsInstance(obj)  -- boolean

-- Crime
types.Player.getCrimeLevel(obj)   -- number
types.Player.setCrimeLevel(obj, val)
types.Player.OFFENSE_TYPE.Theft
types.Player.OFFENSE_TYPE.Assault
types.Player.OFFENSE_TYPE.Murder
types.Player.OFFENSE_TYPE.Trespassing
types.Player.OFFENSE_TYPE.SleepingInOwnedBed
types.Player.OFFENSE_TYPE.Pickpocket

-- Character generation / teleport
types.Player.isCharGenFinished(obj)        -- boolean
types.Player.isTeleportingEnabled(obj)     -- boolean
types.Player.setTeleportingEnabled(obj, val)

-- Quests
types.Player.quests(obj)       -- PlayerQuests interface
-- quest = quests[questId]
-- quest.id, quest.stage (settable), quest.started, quest.finished
-- quest:addJournalEntry(stage, actor)

-- Journal
types.Player.journal(obj)      -- PlayerJournal
-- journal.journalTextEntries   -- list of PlayerJournalTextEntry
-- journal.topics               -- list of PlayerJournalTopic

-- Topics / Dialogue
types.Player.addTopic(obj, topicId)

-- Control switches
types.Player.getControlSwitch(obj, switch)  -- boolean
types.Player.setControlSwitch(obj, switch, val)
types.Player.CONTROL_SWITCH.Controls
types.Player.CONTROL_SWITCH.Fighting
types.Player.CONTROL_SWITCH.Jumping
types.Player.CONTROL_SWITCH.Looking
types.Player.CONTROL_SWITCH.Magic
types.Player.CONTROL_SWITCH.ViewMode
types.Player.CONTROL_SWITCH.VanityMode

-- Birth signs
types.Player.getBirthSign(obj)          -- string: birth sign record ID
types.Player.setBirthSign(obj, id)
types.Player.birthSigns                 -- list of BirthSignRecord

-- Menu events (sends event to menu scripts)
types.Player.sendMenuEvent(obj, name, data)

-- PlayerJournalTextEntry
entry.text        -- string
entry.questId     -- string
entry.day, entry.month, entry.dayOfMonth  -- numbers
entry.id          -- string

-- PlayerJournalTopic
topic.id      -- string
topic.name    -- string
topic.entries -- list of PlayerJournalTopicEntry

-- PlayerJournalTopicEntry
entry.text   -- string
entry.actor  -- string: actor record ID
entry.id     -- string

-- BirthSignRecord
sign.id          -- string
sign.name        -- string
sign.description -- string
sign.texture     -- string: VFS path
sign.spells      -- list of spell IDs
```

#### Armor

```lua
types.Armor.objectIsInstance(obj)
types.Armor.TYPE.Helmet, Cuirass, LPauldron, RPauldron, Greaves, Boots,
             LGauntlet, RGauntlet, Shield, LBracer, RBracer
types.Armor.record(obj)   -- ArmorRecord
types.Armor.records       -- list
types.Armor.createRecordDraft(template)

-- ArmorRecord
rec.id, rec.name, rec.model, rec.icon, rec.mwscript
rec.type        -- Armor.TYPE value
rec.weight      -- number
rec.value       -- number
rec.health      -- number
rec.enchantment -- string or nil
rec.enchantmentPoints -- number
rec.armorType   -- number
rec.baseArmor   -- number
```

#### Book

```lua
types.Book.objectIsInstance(obj)
types.Book.record(obj)   -- BookRecord
types.Book.records
types.Book.createRecordDraft(template)

-- BookRecord
rec.id, rec.name, rec.model, rec.icon, rec.mwscript
rec.text         -- string: book contents
rec.weight       -- number
rec.value        -- number
rec.enchantment  -- string or nil
rec.enchantmentPoints -- number
rec.isScroll     -- boolean
rec.skill        -- string or nil: skill ID for skill books
```

#### Clothing

```lua
types.Clothing.objectIsInstance(obj)
types.Clothing.TYPE.Amulet, Belt, LGlove, Pants, RGlove, Ring, Robe, Shirt, Shoes, Skirt
types.Clothing.record(obj)
types.Clothing.records
types.Clothing.createRecordDraft(template)

-- ClothingRecord: id, name, model, icon, mwscript, type, weight, value, enchantment, enchantmentPoints
```

#### Ingredient

```lua
types.Ingredient.objectIsInstance(obj)
types.Ingredient.record(obj)
types.Ingredient.records

-- IngredientRecord: id, name, model, icon, mwscript, weight, value
-- effects: list of { id, affectedAttribute, affectedSkill }
```

#### LOCKABLE (Door, Container)

```lua
-- Interface shared by Door and Container
types.LOCKABLE.objectIsInstance(obj)
types.LOCKABLE.getKeyRecord(obj)       -- MiscellaneousRecord or nil
types.LOCKABLE.setKeyRecord(obj, rec)
types.LOCKABLE.getTrapSpell(obj)       -- SpellRecord or nil
types.LOCKABLE.setTrapSpell(obj, rec)
types.LOCKABLE.getLockLevel(obj)       -- number
types.LOCKABLE.isLocked(obj)           -- boolean
types.LOCKABLE.lock(obj, level)
types.LOCKABLE.unlock(obj)
```

#### Light

```lua
types.Light.objectIsInstance(obj)
types.Light.record(obj)
types.Light.records
types.Light.createRecordDraft(template)

-- LightRecord
rec.id, rec.name, rec.model, rec.icon, rec.mwscript
rec.weight, rec.value
rec.duration      -- number: burn time in seconds
rec.radius        -- number
rec.color         -- util.Color
rec.isCarriable   -- boolean
rec.isDynamic     -- boolean
rec.isFire        -- boolean
rec.isFlicker     -- boolean
rec.isFlickerSlow -- boolean
rec.isNegative    -- boolean
rec.isOffByDefault -- boolean
rec.isPulse       -- boolean
rec.isPulseSlow   -- boolean
rec.sound         -- string: sound ID
```

#### Miscellaneous

```lua
types.Miscellaneous.objectIsInstance(obj)
types.Miscellaneous.record(obj)
types.Miscellaneous.records
types.Miscellaneous.createRecordDraft(template)

-- MiscellaneousRecord: id, name, model, icon, mwscript, weight, value, isKey
```

#### Potion

```lua
types.Potion.objectIsInstance(obj)
types.Potion.record(obj)
types.Potion.records
types.Potion.createRecordDraft(template)

-- PotionRecord: id, name, model, icon, mwscript, weight, value, autocalc, effects (list of MagicEffectWithParams)
```

#### Weapon

```lua
types.Weapon.objectIsInstance(obj)
types.Weapon.TYPE.ShortBladeOneHand, LongBladeOneHand, LongBladeTwoHand,
             BluntOneHand, BluntTwoClose, BluntTwoWide, SpearTwoWide,
             AxeOneHand, AxeTwoHand, MarksmanBow, MarksmanCrossbow,
             MarksmanThrown, Arrow, Bolt
types.Weapon.record(obj)
types.Weapon.records
types.Weapon.createRecordDraft(template)

-- WeaponRecord
rec.id, rec.name, rec.model, rec.icon, rec.mwscript
rec.type        -- Weapon.TYPE
rec.weight, rec.value, rec.health
rec.speed       -- number: attack speed
rec.reach       -- number
rec.enchantment -- string or nil
rec.enchantmentPoints -- number
rec.chopMin, rec.chopMax   -- numbers
rec.slashMin, rec.slashMax
rec.thrustMin, rec.thrustMax
rec.isMagical   -- boolean
rec.isSilver    -- boolean
```

#### Apparatus, Lockpick, Probe, Repair

```lua
-- Apparatus
types.Apparatus.TYPE.MortarPestle, Alembic, Calcinator, Retort
-- ApparatusRecord: id, name, model, icon, mwscript, weight, value, type, quality

-- Lockpick
-- LockpickRecord: id, name, model, icon, mwscript, weight, value, uses, quality

-- Probe
-- ProbeRecord: id, name, model, icon, mwscript, weight, value, uses, quality

-- Repair
-- RepairRecord: id, name, model, icon, mwscript, weight, value, uses, quality
```

#### Activator

```lua
types.Activator.objectIsInstance(obj)
types.Activator.record(obj)
types.Activator.records
types.Activator.createRecordDraft(template)
-- ActivatorRecord: id, name, model, mwscript
```

#### Container

```lua
types.Container.objectIsInstance(obj)
types.Container.content(obj)     -- Inventory (items inside)
types.Container.inventory(obj)   -- same as content
types.Container.getEncumbrance(obj)  -- number
types.Container.getCapacity(obj)     -- number
types.Container.record(obj)
types.Container.records
types.Container.createRecordDraft(template)
-- ContainerRecord: id, name, model, mwscript, weight (capacity), isOrganic, isRespawn
```

#### Door

```lua
types.Door.objectIsInstance(obj)
types.Door.STATE.Idle, Opening, Closing
types.Door.record(obj)
types.Door.records
types.Door.createRecordDraft(template)

-- Door-specific methods
types.Door.isTeleport(obj)      -- boolean
types.Door.destPosition(obj)    -- util.Vector3 (teleport doors only)
types.Door.destRotation(obj)    -- util.Transform
types.Door.destCell(obj)        -- Cell
types.Door.getDoorState(obj)    -- Door.STATE
types.Door.isOpen(obj)          -- boolean
types.Door.isClosed(obj)        -- boolean
types.Door.activateDoor(obj, openState)  -- open/close; global or self only

-- DoorRecord: id, name, model, mwscript, openSound, closeSound
-- Also inherits LOCKABLE interface
```

#### Static

```lua
types.Static.objectIsInstance(obj)
types.Static.record(obj)
types.Static.records
types.Static.createRecordDraft(template)
-- StaticRecord: id, model
```

#### CreatureLevelledList

```lua
types.LevelledCreature.objectIsInstance(obj)
types.LevelledCreature.record(obj)
types.LevelledCreature.records

-- CreatureLevelledListRecord
rec.id                        -- string
rec.chanceNone                -- number [0-1]
rec.calculateFromAllLevels    -- boolean
rec.creatures                 -- list of LevelledListItem
rec:getRandomId(maxLevel)     -- string: random creature ID

-- LevelledListItem: { id, level }
```

#### ESM4 Types (TES4/FO3/FNV/FO4/Skyrim formats)

```lua
-- Available ESM4 types (basic objectIsInstance, record, records):
types.ESM4Activator, types.ESM4Ammunition, types.ESM4Armor, types.ESM4Book,
types.ESM4Clothing, types.ESM4Flora, types.ESM4Ingredient, types.ESM4ItemMod,
types.ESM4Light, types.ESM4Miscellaneous, types.ESM4MovableStatic,
types.ESM4Potion, types.ESM4Static, types.ESM4StaticCollection, types.ESM4Weapon

-- ESM4Door (extends LOCKABLE)
types.ESM4Door.objectIsInstance(obj)
types.ESM4Door.isTeleport(obj), destPosition(obj), destRotation(obj), destCell(obj)
types.ESM4Door.record(obj), types.ESM4Door.records
-- ESM4DoorRecord: id, name, model, openSound (FormId), closeSound (FormId)

-- ESM4Terminal
types.ESM4Terminal.objectIsInstance(obj)
types.ESM4Terminal.record(obj), types.ESM4Terminal.records
-- ESM4TerminalRecord: id, editorId, name, model, text, resultText
```

---

### openmw.util

**Contexts:** global, menu, local, player, load

```lua
local util = require('openmw.util')
```

#### Utility Functions

```lua
util.round(x)                -- Round to nearest integer
util.remap(x, min1, max1, min2, max2)  -- Remap from one range to another
util.clamp(x, min, max)      -- Clamp value
util.normalizeAngle(angle)   -- Normalize to [-pi, pi]
util.makeReadOnly(table)     -- Returns read-only proxy
util.makeStrictReadOnly(table) -- Read-only + no new keys
util.loadCode(code, env)     -- Like load() but in sandbox

-- Bitwise (Lua 5.1 compatibility)
util.bitAnd(a, b)
util.bitOr(a, b)
util.bitXor(a, b)
util.bitNot(a)
```

#### Vector2

```lua
-- Constructor
util.vector2(x, y)

-- Fields
v.x, v.y

-- Methods
v:length()       -- magnitude
v:length2()      -- squared magnitude
v:normalize()    -- returns unit vector
v:rotate(angle)  -- rotate by angle in radians
v:dot(other)     -- dot product
v:emul(other)    -- component-wise multiply
v:ediv(other)    -- component-wise divide

-- Operators: +, -, *, / (scalar), ==
-- Swizzle: v.yx, v.xy, etc.
```

#### Vector3

```lua
-- Constructor
util.vector3(x, y, z)

-- Fields
v.x, v.y, v.z

-- Methods
v:length()
v:length2()
v:normalize()
v:dot(other)
v:cross(other)   -- cross product
v:emul(other)
v:ediv(other)

-- Operators: +, -, *, / (scalar), ==
-- Swizzle: any 2 or 3 component combination
```

#### Vector4

```lua
-- Constructor
util.vector4(x, y, z, w)

-- Fields
v.x, v.y, v.z, v.w

-- Methods: length, length2, normalize, dot, emul, ediv
-- Operators: +, -, *, / (scalar), ==
-- Swizzle supported
```

#### Box

```lua
-- Constructors
util.box(center, halfSize)   -- center: Vector3, halfSize: Vector3
util.box(transform)          -- from Transform

-- Fields
box.center    -- Vector3
box.halfSize  -- Vector3

-- Methods
box:transform(t)   -- Returns new Box transformed by Transform t
box:vertices()     -- Returns 8 Vector3 corners
```

#### Color

```lua
-- Constructors
util.color.rgba(r, g, b, a)       -- values 0.0-1.0
util.color.rgb(r, g, b)           -- alpha = 1.0
util.color.hex(str)               -- e.g. "FF0000" or "FF0000FF"
util.color.commaString(str)       -- e.g. "255, 0, 0" or "255, 0, 0, 255"

-- Fields
c.r, c.g, c.b, c.a   -- number 0.0-1.0

-- Methods
c:asRgba()    -- { r, g, b, a } with values 0-255
c:asRgb()     -- { r, g, b }
c:asHex()     -- string e.g. "FF0000FF"

-- Operators: ==
```

#### Transform

```lua
-- Constructors (via util.transform factory)
util.transform.identity
util.transform.move(v3)            -- translation
util.transform.scale(v3)           -- scale
util.transform.rotate(angle, axis) -- axis: Vector3
util.transform.rotateX(angle)
util.transform.rotateY(angle)
util.transform.rotateZ(angle)

-- Methods
t:inverse()           -- inverse transform
t:apply(v3)           -- apply to Vector3
t:getYaw()            -- number
t:getPitch()          -- number
t:getAnglesXZ()       -- pitch, yaw (two returns)
t:getAnglesZYX()      -- yaw, pitch, roll (three returns)

-- Operators: * (compose transforms), * (apply to Vector3)
```

---

### openmw.nearby

**Contexts:** local, player

```lua
local nearby = require('openmw.nearby')
```

```lua
-- Object lists (read-only, updated each frame)
nearby.activators   -- ObjectList
nearby.actors       -- ObjectList
nearby.containers   -- ObjectList
nearby.doors        -- ObjectList
nearby.items        -- ObjectList
nearby.players      -- ObjectList

nearby.getObjectByFormId(formId)  -- GameObject

-- Collision types
nearby.COLLISION_TYPE.World
nearby.COLLISION_TYPE.Door
nearby.COLLISION_TYPE.Actor
nearby.COLLISION_TYPE.HeightMap
nearby.COLLISION_TYPE.Projectile
nearby.COLLISION_TYPE.Water
nearby.COLLISION_TYPE.Default      -- World | Door | Actor | HeightMap
nearby.COLLISION_TYPE.AnyPhysical  -- all physical
nearby.COLLISION_TYPE.Camera
nearby.COLLISION_TYPE.VisualOnly

-- Ray casting
-- options: { ignore=obj, collisionType=COLLISION_TYPE, radius=number }
nearby.castRay(from, to, options)           -- RayCastingResult
nearby.castRenderingRay(from, to, options)  -- RayCastingResult (rendering geometry)
nearby.asyncCastRenderingRay(callback, from, to, options) -- async version

-- RayCastingResult
result.hit        -- boolean
result.hitPos     -- Vector3 or nil
result.hitNormal  -- Vector3 or nil
result.hitObject  -- GameObject or nil

-- Pathfinding
nearby.NAVIGATOR_FLAGS.Walk
nearby.NAVIGATOR_FLAGS.Swim
nearby.NAVIGATOR_FLAGS.OpenDoor
nearby.NAVIGATOR_FLAGS.UsePathgrid

nearby.COLLISION_SHAPE_TYPE.Aabb
nearby.COLLISION_SHAPE_TYPE.RotatingBox
nearby.COLLISION_SHAPE_TYPE.Cylinder

nearby.FIND_PATH_STATUS.Success
nearby.FIND_PATH_STATUS.PartialPath
nearby.FIND_PATH_STATUS.NavMeshNotFound
nearby.FIND_PATH_STATUS.StartPolygonNotFound
nearby.FIND_PATH_STATUS.EndPolygonNotFound
nearby.FIND_PATH_STATUS.TargetPolygonNotFound
nearby.FIND_PATH_STATUS.MoveAlongSurfaceFailed
nearby.FIND_PATH_STATUS.FindPathOverPolygonsFailed
nearby.FIND_PATH_STATUS.InitNavMeshQueryFailed
nearby.FIND_PATH_STATUS.FindStraightPathFailed

-- AgentBounds: { shapeType=COLLISION_SHAPE_TYPE, halfExtents=Vector3 }
-- AreaCosts: { swim, walk, door, pathgrid } (all numbers, default 1)
-- FindPathOptions: { agentBounds, areaCosts, destinationTolerance, flags }
-- NavMeshOptions: { agentBounds, flags }
-- FindNearestNavMeshPositionOptions: { agentBounds, flags, searchAreaHalfExtents }

nearby.findPath(source, destination, options)
  -- returns: status (FIND_PATH_STATUS), path (list of Vector3)

nearby.findRandomPointAroundCircle(position, maxRadius, options)
  -- returns: Vector3 or nil

nearby.castNavigationRay(from, to, options)
  -- returns: Vector3 or nil (navmesh-following path point)

nearby.findNearestNavMeshPosition(position, options)
  -- returns: Vector3 or nil
```

---

### openmw.self

**Contexts:** local, player

```lua
local self = require('openmw.self')
```

The `self` package extends `GameObject` with additional functionality for the attached object.

```lua
self.object      -- The GameObject this script is attached to
                 -- (same as `self` for most field access)

-- Object fields (same as GameObject)
self.position    -- Vector3
self.rotation    -- Transform
self.cell        -- Cell
self.recordId    -- string
-- etc.

-- Methods
self:isActive()   -- boolean: is in active processing range
self:enableAI(val) -- enable/disable AI for this actor

-- Actor controls (for actors only)
self.controls    -- ActorControls

-- ActorControls (for local actor scripts)
controls.movement       -- number: -1 to 1 (backward/forward)
controls.sideMovement   -- number: -1 to 1 (left/right)
controls.yawChange      -- number: rotation change in radians/frame
controls.pitchChange    -- number
controls.run            -- boolean
controls.sneak          -- boolean
controls.jump           -- boolean
controls.use            -- ATTACK_TYPE value

-- ATTACK_TYPE
self.ATTACK_TYPE.NoAttack
self.ATTACK_TYPE.Any
self.ATTACK_TYPE.Chop
self.ATTACK_TYPE.Slash
self.ATTACK_TYPE.Thrust
```

---

### openmw.async

**Contexts:** global, menu, local, player, load

```lua
local async = require('openmw.async')
```

```lua
-- Register a timer callback (saveable)
-- name must be unique within the script, func is called with (arg) when timer fires
local cb = async:registerTimerCallback(name, func)

-- Create saveable timers (require registered callbacks)
async:newSimulationTimer(delay, callback, arg)  -- fires after `delay` simulation seconds
async:newGameTimer(delay, callback, arg)        -- fires after `delay` game seconds

-- Create unsaveable timers (anonymous functions ok, but lost on save/load)
async:newUnsavableSimulationTimer(delay, func)
async:newUnsavableGameTimer(delay, func)

-- Create a callback wrapper (for use with UI events, etc.)
local cb = async:callback(func)
-- cb can be stored and called later; it runs in the script's context
```

#### Timer Notes

- Saveable timers survive save/load cycles
- `registerTimerCallback` must be called at script initialization (not inside handlers)
- The `name` must be unique per-script; same name in different scripts is fine
- Unsaveable timers are lost when the game is saved and loaded

---

### openmw.animation

**Contexts:** local, player

```lua
local anim = require('openmw.animation')
```

```lua
-- Priority levels
anim.PRIORITY.Default        -- 0
anim.PRIORITY.WeaponLowerBody -- 1
anim.PRIORITY.SneakIdleLowerBody -- 2
anim.PRIORITY.SwimIdle       -- 3
anim.PRIORITY.Jump           -- 4
anim.PRIORITY.Movement       -- 5
anim.PRIORITY.Hit            -- 6
anim.PRIORITY.Weapon         -- 7
anim.PRIORITY.Block          -- 8
anim.PRIORITY.Knockdown      -- 9
anim.PRIORITY.Torch          -- 10
anim.PRIORITY.Storm          -- 11
anim.PRIORITY.Death          -- 12
anim.PRIORITY.Scripted       -- 13

-- Blend masks (bitfield)
anim.BLEND_MASK.LowerBody   -- 1
anim.BLEND_MASK.Torso       -- 2
anim.BLEND_MASK.LeftArm     -- 4
anim.BLEND_MASK.RightArm    -- 8
anim.BLEND_MASK.UpperBody   -- 14 (Torso|LeftArm|RightArm)
anim.BLEND_MASK.All         -- 15

-- Bone groups
anim.BONE_GROUP.LowerBody   -- 1
anim.BONE_GROUP.Torso       -- 2
anim.BONE_GROUP.LeftArm     -- 3
anim.BONE_GROUP.RightArm    -- 4

-- Queries
anim.hasAnimation(obj)                   -- boolean: has animated mesh
anim.skipAnimationThisFrame(obj)         -- skip this frame's animation update
anim.getTextKeyTime(obj, key)            -- number or nil: time of text key in current anim
anim.isPlaying(obj, groupName)           -- boolean
anim.getCurrentTime(obj, groupName)      -- number or nil
anim.isLoopingAnimation(obj, groupName)  -- boolean
anim.getCompletion(obj, groupName)       -- number [0,1] or nil
anim.getLoopCount(obj, groupName)        -- number
anim.getSpeed(obj, groupName)            -- number
anim.getActiveGroup(obj, boneGroup)      -- string or nil
anim.hasGroup(obj, groupName)            -- boolean
anim.hasBone(obj, boneName)              -- boolean

-- Control
anim.cancel(obj, groupName)              -- stop animation group
anim.setLoopingEnabled(obj, groupName, val)
anim.setSpeed(obj, groupName, speed)
anim.clearAnimationQueue(obj, forceIdle) -- clear queued animations

-- Playing
-- options for playBlended: { priority, blendMask, autoDisable, speed, startKey, stopKey, forceLoop }
anim.playBlended(obj, groupName, options)

-- options for playQueued: same as playBlended
anim.playQueued(obj, groupName, options)

-- VFX on bones
anim.addVfx(obj, model, options)
  -- options: { loop, boneName, particleTextureOverride, vfxId }
anim.removeVfx(obj, vfxId)
anim.removeAllVfx(obj)
```

---

### openmw.storage

**Contexts:** global, menu, local, player, load

```lua
local storage = require('openmw.storage')
```

```lua
-- Lifetime constants
storage.LIFE_TIME.Persistent    -- 0: survives game exit, written to disk
storage.LIFE_TIME.GameSession   -- 1: survives save/load, lost on exit
storage.LIFE_TIME.Temporary     -- 2: lost on context reset

-- Section access
storage.globalSection(name)     -- StorageSection (any script can read; only global can write)
storage.playerSection(name)     -- StorageSection (player/menu scripts only)
storage.allGlobalSections()     -- table of all global sections (global scripts only)
storage.allPlayerSections()     -- table of all player sections

-- StorageSection methods
section:get(key)         -- any (tables are read-only)
section:getCopy(key)     -- any (tables are deep-copied)
section:set(key, value)  -- set value (global: global scripts only; player: player/menu only)
section:subscribe(callback)  -- callback(sectionName, changedKey) called on changes
section:asTable()        -- returns copy of all data as table
section:reset(values)    -- replace all values (values is optional)
section:setLifeTime(lifetime)  -- set LIFE_TIME
section:removeOnExit()   -- DEPRECATED: use setLifeTime(Temporary)
```

**Serializable types** (can be stored): nil, boolean, number, string, table (with string/number keys and serializable values). No functions, no userdata (no Vector3, etc.).

---

### openmw.camera

**Contexts:** player only

```lua
local camera = require('openmw.camera')
```

```lua
-- Camera modes
camera.MODE.Static
camera.MODE.FirstPerson
camera.MODE.ThirdPerson
camera.MODE.Vanity
camera.MODE.Preview

-- Mode control
camera.getMode()         -- MODE value
camera.getQueuedMode()   -- MODE or nil
camera.setMode(mode, force)  -- force: skip transition

-- Settings
camera.allowCharacterDeferredRotation(val)  -- boolean
camera.showCrosshair(val)

-- Position and orientation
camera.getTrackedPosition()   -- Vector3: position of tracked object
camera.getPosition()          -- Vector3: camera position
camera.getPitch()             -- number: radians
camera.setPitch(val)
camera.getYaw()               -- number: radians
camera.setYaw(val)
camera.getRoll()              -- number: radians
camera.setRoll(val)

-- Extra rotation (scripted offset)
camera.getExtraPitch()        -- number
camera.setExtraPitch(val)
camera.getExtraYaw()
camera.setExtraYaw(val)
camera.getExtraRoll()
camera.setExtraRoll(val)

-- Static mode
camera.setStaticPosition(pos)  -- Vector3

-- First person
camera.getFirstPersonOffset()      -- Vector3
camera.setFirstPersonOffset(v3)

-- Third person
camera.getFocalPreferredOffset()           -- Vector3
camera.setFocalPreferredOffset(v3)
camera.getThirdPersonDistance()            -- number
camera.setPreferredThirdPersonDistance(d)  -- number
camera.getFocalTransitionSpeed()           -- number
camera.setFocalTransitionSpeed(speed)
camera.instantTransition()                 -- skip current transition

-- Collision
camera.getCollisionType()           -- nearby.COLLISION_TYPE
camera.setCollisionType(ct)

-- Field of view
camera.getBaseFieldOfView()   -- number: radians (from settings)
camera.getFieldOfView()       -- number: current (may differ from base)
camera.setFieldOfView(fov)    -- override (reset with base value to undo)

-- View distance
camera.getBaseViewDistance()
camera.getViewDistance()
camera.setViewDistance(d)

-- View transform
camera.getViewTransform()     -- Transform: world-to-camera
camera.viewportToWorldVector(v2)   -- Vector3: direction from camera
camera.worldToViewportVector(v3)   -- Vector2: viewport position [0,1]
```

---

### openmw.input

**Contexts:** menu, player

```lua
local input = require('openmw.input')
```

```lua
-- State queries
input.isIdle()                      -- boolean: no input this frame
input.isKeyPressed(key)             -- boolean; key: KEY value
input.isControllerButtonPressed(btn) -- boolean; btn: CONTROLLER_BUTTON value
input.isShiftPressed()
input.isCtrlPressed()
input.isAltPressed()
input.isSuperPressed()
input.isMouseButtonPressed(btn)     -- boolean; btn: 1=left, 2=mid, 3=right

-- Mouse
input.getMouseMoveX()   -- number: pixels moved this frame
input.getMouseMoveY()

-- Controller axes
input.getAxisValue(axis)  -- number [-1, 1]; axis: CONTROLLER_AXIS

-- Key name
input.getKeyName(key)   -- string: human-readable key name

-- KEY enum (keyboard codes)
-- Letters: KEY.A through KEY.Z
-- Numbers: KEY._0 through KEY._9
-- Numpad: KEY.NP_0 through KEY.NP_9, KEY.NP_Divide, NP_Multiply, etc.
-- Function: KEY.F1 through KEY.F12
-- Special: KEY.Escape, KEY.Return, KEY.Space, KEY.Backspace, KEY.Tab,
--          KEY.CapsLock, KEY.ScrollLock, KEY.NumLock, KEY.PrintScreen, KEY.Pause
-- Modifiers: KEY.LeftShift, KEY.RightShift, KEY.LeftCtrl, KEY.RightCtrl,
--            KEY.LeftAlt, KEY.RightAlt, KEY.LeftSuper, KEY.RightSuper
-- Navigation: KEY.Left, KEY.Right, KEY.Up, KEY.Down,
--             KEY.Home, KEY.End, KEY.PageUp, KEY.PageDown,
--             KEY.Insert, KEY.Delete
-- Punctuation: KEY.Semicolon, KEY.Equals, KEY.LeftBracket, KEY.RightBracket,
--              KEY.Backslash, KEY.Comma, KEY.Period, KEY.Slash, KEY.Backquote,
--              KEY.Minus, KEY.Quote

-- CONTROLLER_BUTTON enum
input.CONTROLLER_BUTTON.A, B, X, Y
input.CONTROLLER_BUTTON.Back, Guide, Start
input.CONTROLLER_BUTTON.LeftStick, RightStick
input.CONTROLLER_BUTTON.LeftShoulder, RightShoulder
input.CONTROLLER_BUTTON.DPadUp, DPadDown, DPadLeft, DPadRight
input.CONTROLLER_BUTTON.Misc1, Paddle1, Paddle2, Paddle3, Paddle4, Touchpad

-- CONTROLLER_AXIS enum
input.CONTROLLER_AXIS.LeftX, LeftY, RightX, RightY
input.CONTROLLER_AXIS.TriggerLeft, TriggerRight

-- KeyboardEvent (passed to onKeyPress/onKeyRelease)
event.symbol     -- string: character
event.code       -- KEY value
event.withShift  -- boolean
event.withCtrl
event.withAlt
event.withSuper

-- TouchEvent (passed to onTouchPress/onTouchRelease/onTouchMove)
event.device    -- string
event.finger    -- number
event.position  -- Vector2: screen position [0,1]
event.pressure  -- number [0,1]

-- Actions API (new input binding system)
input.ACTION_TYPE.Boolean   -- on/off
input.ACTION_TYPE.Number    -- scalar
input.ACTION_TYPE.Range     -- axis

-- Register an action
input.registerAction({
    key = 'MyMod:MyAction',
    l10n = 'MyL10nContext',       -- localization context
    name = 'myActionName',        -- l10n key for display name
    description = 'myDesc',       -- l10n key
    type = input.ACTION_TYPE.Boolean,
    defaultValue = false,
})

-- Bind action to input
input.bindAction('MyMod:MyAction', trigger, value)

-- Register action handler
input.registerActionHandler('MyMod:MyAction', callback)

-- Query action values
input.getBooleanActionValue('MyMod:MyAction')  -- boolean
input.getNumberActionValue('MyMod:MyAction')   -- number
input.getRangeActionValue('MyMod:MyAction')    -- number

-- Actions and triggers maps
input.actions  -- map of registered actions
input.triggers -- map of registered triggers

-- Register custom trigger
input.registerTrigger({ key = 'MyMod:MyTrigger', l10n = ..., name = ..., description = ... })
input.registerTriggerHandler('MyMod:MyTrigger', callback)
input.activateTrigger('MyMod:MyTrigger', value)

-- Control switches (deprecated, use types.Player.setControlSwitch instead)
input.CONTROL_SWITCH.Controls, Fighting, Jumping, Looking, Magic, ViewMode, VanityMode
input.getControlSwitch(switch)   -- boolean (deprecated)
input.setControlSwitch(switch, val) -- (deprecated)
```

---

### openmw.ui

**Contexts:** menu, player

```lua
local ui = require('openmw.ui')
```

```lua
-- Widget types
ui.TYPE.Widget       -- base widget
ui.TYPE.Text         -- text label
ui.TYPE.TextEdit     -- editable text field
ui.TYPE.Window       -- window with title bar
ui.TYPE.Image        -- image
ui.TYPE.Flex         -- flex layout container
ui.TYPE.Container    -- simple container

-- Alignment
ui.ALIGNMENT.Start   -- 0
ui.ALIGNMENT.Center  -- 1
ui.ALIGNMENT.End     -- 2

-- Console colors
ui.CONSOLE_COLOR.Default
ui.CONSOLE_COLOR.Error
ui.CONSOLE_COLOR.Success
ui.CONSOLE_COLOR.Info

-- Display functions
ui.showMessage(text, options)     -- show HUD message; options: { duration }
ui.printToConsole(text, color)    -- print to in-game console
ui.setConsoleMode(mode)           -- set console mode string
ui.setConsoleSelectedObject(obj)  -- select object in console

-- Screen
ui.screenSize()    -- Vector2: current screen size in pixels

-- Content
ui.content(table)  -- create Content from array of layouts

-- Elements
ui.create(layout)  -- create UI element, returns Element

-- Update all UI
ui.updateAll()

-- Texture resource
ui.texture(options)  -- TextureResource
-- options: { path, offset=Vector2, size=Vector2 }

-- Settings page
ui.registerSettingsPage(page)
-- page: { name, searchHints, element } or { name, searchHints, l10n, searchHints }
ui.removeSettingsPage(page)
```

#### Layout Table

```lua
{
    type = ui.TYPE.Text,         -- widget type
    layer = 'HUD',               -- layer name (for root elements)
    name = 'myWidget',           -- name for lookup
    props = {                    -- widget properties
        text = 'Hello',
        textSize = 16,
        textColor = util.color.rgba(1, 1, 1, 1),
    },
    events = {                   -- event handlers (async callbacks)
        mouseClick = async:callback(function(event) end),
    },
    content = ui.content {       -- child widgets
        { type = ui.TYPE.Text, props = { text = 'child' } }
    },
    template = myTemplate,       -- optional template
    external = {},               -- external properties (for template systems)
    userData = {},               -- arbitrary data attached to widget
}
```

#### Widget Properties by Type

**Base Widget (all types inherit)**
```lua
position          -- Vector2: absolute position
size              -- Vector2
relativePosition  -- Vector2: [0,1] relative to parent
relativeSize      -- Vector2: [0,1] relative to parent
anchor            -- Vector2: pivot point [0,1]
visible           -- boolean
propagateEvents   -- boolean: pass events to parent
alpha             -- number [0,1]
inheritAlpha      -- boolean
```

**Text**
```lua
text              -- string
textSize          -- number (font size)
textColor         -- util.Color
autoSize          -- boolean: fit widget to text
multiline         -- boolean
wordWrap          -- boolean
textAlignH        -- ALIGNMENT value
textAlignV        -- ALIGNMENT value
textShadow        -- boolean
textShadowColor   -- util.Color
```

**TextEdit** (all Text props plus)
```lua
readOnly          -- boolean
-- Additional event: textChanged
```

**Image**
```lua
resource          -- TextureResource
tileH             -- boolean: tile horizontally
tileV             -- boolean: tile vertically
color             -- util.Color: tint
```

**Flex**
```lua
horizontal        -- boolean: row layout (default: false = column)
autoSize          -- boolean
align             -- ALIGNMENT: cross-axis alignment
arrange           -- ALIGNMENT: main-axis alignment
-- Children can have external props:
-- { grow=1 }     -- proportional growth
-- { stretch=1 }  -- stretch to fill
```

#### Widget Events

```lua
-- Mouse events (MouseEvent: { position, offset, button })
mouseClick
mouseDoubleClick
mousePress
mouseRelease
mouseMove

-- Keyboard events (KeyboardEvent)
keyPress
keyRelease

-- Focus
focusGain
focusLoss

-- Text input
textInput    -- string: the input character(s)

-- TextEdit only
textChanged  -- string: new text value
```

#### Layers

```lua
ui.layers.indexOf(name)         -- number: layer index
ui.layers.insertAfter(name, layerDef)   -- insert after named layer
ui.layers.insertBefore(name, layerDef)  -- insert before named layer
-- layerDef: { name, isMenu (boolean) }
-- Iterate: for i, layer in ipairs(ui.layers) do ... end
-- layer.name, layer.size (Vector2)
```

#### Element

```lua
element:update()    -- apply layout changes
element:destroy()   -- remove from screen
element.layout      -- the layout table (read/write)
```

#### Content

```lua
local c = ui.content { layout1, layout2 }
c:insert(index, layout)   -- insert at position
c:add(layout)             -- append
c:indexOf(name)           -- number: index by name
c[name]                   -- layout by name
c[index]                  -- layout by index
#c                         -- count
```

---

### openmw.vfs

**Contexts:** global, menu, local, player, load

```lua
local vfs = require('openmw.vfs')
```

```lua
vfs.fileExists(path)     -- boolean
vfs.open(path)           -- FileHandle or (nil, errorMsg)
vfs.lines(path)          -- iterator function (closes automatically)
vfs.pathsWithPrefix(prefix) -- iterator function for file paths
vfs.type(handle)         -- "file", "closed file", or nil

-- FileHandle
handle.fileName          -- string: VFS path
handle:close()           -- boolean or (nil, error)
handle:read(...)         -- read with format strings:
  -- "*a" or "*all" : read entire file as string
  -- "*l" or "*line": read next line (no newline)
  -- "*n" or "*number": read a number
  -- N (number): read N bytes
handle:seek(whence, offset)  -- number (new position) or (nil, error)
  -- whence: "set", "cur", "end"
handle:lines()           -- iterator for remaining lines
```

---

### openmw.ambient

**Contexts:** menu, player

```lua
local ambient = require('openmw.ambient')
```

```lua
-- Sounds (loop-able)
ambient.playSound(soundId, options)       -- options: { loop, volume, pitch }
ambient.playSoundFile(path, options)
ambient.stopSound(soundId)
ambient.stopSoundFile(path)
ambient.isSoundPlaying(soundId)    -- boolean
ambient.isSoundFilePlaying(path)   -- boolean

-- Music
ambient.streamMusic(path, options)    -- options: { fadeOut }
ambient.stopMusic()
ambient.isMusicPlaying()   -- boolean

-- Say (NPC voice)
ambient.say(path, text)    -- play voice file with subtitle text
ambient.stopSay()
ambient.isSayActive()      -- boolean
```

---

### openmw.postprocessing

**Contexts:** player only

```lua
local postprocessing = require('openmw.postprocessing')
```

```lua
postprocessing.load(name)   -- Shader: load shader by name
postprocessing.getChain()   -- list of currently active shaders

-- Shader methods
shader.name         -- string
shader.description  -- string
shader.author       -- string
shader.version      -- string

shader:enable(index)    -- enable at optional chain index
shader:disable()
shader:isEnabled()  -- boolean

-- Set uniform values
shader:setBool(name, val)
shader:setInt(name, val)
shader:setFloat(name, val)
shader:setVector2(name, v2)
shader:setVector3(name, v3)
shader:setVector4(name, v4)
shader:setIntArray(name, array)
shader:setFloatArray(name, array)
shader:setVector2Array(name, array)
shader:setVector3Array(name, array)
shader:setVector4Array(name, array)
```

---

### openmw.debug

**Contexts:** player only

```lua
local debug = require('openmw.debug')
```

```lua
-- Render modes
debug.RENDER_MODE.CollisionDebug
debug.RENDER_MODE.Wireframe
debug.RENDER_MODE.Pathgrid
debug.RENDER_MODE.Water
debug.RENDER_MODE.Scene
debug.RENDER_MODE.NavMesh
debug.RENDER_MODE.ActorsPaths
debug.RENDER_MODE.RecastMesh

debug.NAV_MESH_RENDER_MODE.AreaType
debug.NAV_MESH_RENDER_MODE.UpdateFrequency

-- Toggle functions
debug.toggleRenderMode(mode)
debug.toggleGodMode()
debug.isGodMode()           -- boolean
debug.toggleAI()
debug.isAIEnabled()         -- boolean
debug.toggleCollision()
debug.isCollisionEnabled()  -- boolean
debug.toggleMWScript()
debug.isMWScriptEnabled()   -- boolean

-- Reload scripts
debug.reloadLua()

-- NavMesh rendering
debug.setNavMeshRenderMode(mode)  -- NAV_MESH_RENDER_MODE value

-- Shader hot-reload
debug.setShaderHotReloadEnabled(val)
debug.triggerShaderReload()
```

---

### openmw.menu

**Contexts:** menu only

```lua
local menu = require('openmw.menu')
```

```lua
-- Game state
menu.STATE.NoGame    -- main menu, no game running
menu.STATE.Running   -- game is running
menu.STATE.Ended     -- game has ended

menu.getState()     -- STATE value

-- Game management
menu.newGame()
menu.loadGame(path)               -- path from SaveInfo
menu.deleteGame(path)
menu.getCurrentSaveDir()          -- string: path to current save dir
menu.saveGame(description, screenshot)  -- description=string, screenshot=optional texture
menu.getSaves(saveDir)            -- list of SaveInfo for given dir
menu.getAllSaves()                 -- list of all SaveInfo across all dirs
menu.quit()                       -- quit the game

-- SaveInfo
info.description    -- string
info.playerName     -- string
info.playerLevel    -- number
info.timePlayed     -- number: seconds
info.creationTime   -- number: unix timestamp
info.contentFiles   -- list of content file names
```

---

### openmw.markup

**Contexts:** global, menu, local, player, load

```lua
local markup = require('openmw.markup')
```

```lua
markup.decodeYaml(str)      -- any: parse YAML string to Lua value
markup.loadYaml(vfsPath)    -- any: load and parse YAML file from VFS

-- YAML limitations:
-- - YAML 1.2 format
-- - Map keys must be scalar (string/boolean/number)
-- - No YAML tags
-- - Quoted scalars = strings
-- - Numbers use float (Lua 5.1 has no integers)
-- - No circular references
```

---

### openmw.interfaces

**Contexts:** global, menu, local, player

```lua
local I = require('openmw.interfaces')
```

Provides access to built-in script interfaces. Each interface is defined by the built-in scripts and can be overridden by mods.

```lua
I.Activation       -- Activation handlers
I.AnimationController -- Animation control interface
I.AI               -- AI control interface
I.Camera           -- Camera interface
I.Combat           -- Combat interface
I.MWUI             -- Morrowind-style UI widgets
I.Settings         -- Settings page management
I.UI               -- UI mode management
I.ItemUsage        -- Item use handlers
I.SkillProgression -- Skill level-up handlers
I.Crimes           -- Crime system handlers
```

See [Interfaces System](#interfaces-system) for details on how to use them.

---

## Auxiliary Packages

---

### openmw_aux.time

**Contexts:** global, menu, local

```lua
local time = require('openmw_aux.time')
```

Convenience wrappers around `openmw.async` timers.

```lua
-- Constants
time.second  -- 1
time.minute  -- 60
time.hour    -- 3600
time.day     -- 86400

time.GameTime        -- 'GameTime'
time.SimulationTime  -- 'SimulationTime'

-- Wrappers
time.registerTimerCallback(name, fn)       -- same as async:registerTimerCallback
time.newGameTimer(delay, callback, arg)    -- same as async:newGameTimer
time.newSimulationTimer(delay, callback, arg)

-- Run a function repeatedly
local stopFn = time.runRepeatedly(fn, period, options)
-- options: { initialDelay, type }
--   initialDelay: delay before first call (default: random in [0, period])
--   type: time.GameTime or time.SimulationTime (default)
-- Returns: function to stop the repetition
stopFn()  -- call to stop

-- Example: call every 5 seconds
local stop = time.runRepeatedly(function()
    print('tick')
end, 5 * time.second)

-- Example: call every game day starting at midnight
local timeToMidnight = time.day - core.getGameTime() % time.day
time.runRepeatedly(fn, time.day, {
    initialDelay = timeToMidnight,
    type = time.GameTime
})
```

---

### openmw_aux.util

**Contexts:** global, menu, local

```lua
local aux_util = require('openmw_aux.util')
```

```lua
-- Print tables with content
aux_util.deepToString(value, maxDepth)  -- string (maxDepth default 1)

-- Array utilities
aux_util.findMinScore(array, scoreFn)
  -- scoreFn(element) returns nil/false or a number
  -- returns: element, score, index  (of minimum-score element)

aux_util.mapFilter(array, scoreFn)
  -- returns: filteredArray, scores

aux_util.mapFilterSort(array, scoreFn)
  -- Same as mapFilter but sorted ascending by score
  -- returns: sortedArray, sortedScores

-- Event handler utilities
aux_util.callEventHandlers(handlers, ...)
  -- Calls handlers in reverse order until one returns false
  -- returns: boolean (true if event was handled/stopped)

aux_util.callMultipleEventHandlers(handlers, ...)
  -- handlers: array of handler arrays
  -- returns: boolean

-- Table utilities
aux_util.shallowCopy(table)  -- new table with same key-value pairs

-- Example: find nearest NPC
local nearestNPC = aux_util.findMinScore(nearby.actors, function(actor)
    return actor.type == types.NPC and (self.position - actor.position):length()
end)
```

---

### openmw_aux.calendar

**Contexts:** global, menu, local

```lua
local calendar = require('openmw_aux.calendar')
```

```lua
-- Constants
calendar.monthCount   -- number of months in a year (12 for Morrowind)
calendar.daysInYear   -- total days (360 for Morrowind)
calendar.daysInWeek   -- number (7 for Morrowind)

-- Functions
calendar.daysInMonth(monthIndex)           -- number
calendar.monthName(monthIndex)             -- string (localized)
calendar.monthNameInGenitive(monthIndex)   -- string (localized, for some languages)
calendar.weekdayName(dayIndex)             -- string (localized)

-- Time conversion (like os.time for game time)
-- If table provided: { year, month, day, hour, min, sec } -> timestamp
-- If no args: returns current game time timestamp
calendar.gameTime()                        -- number: current game timestamp
calendar.gameTime({ year=427, month=1, day=1, hour=0 })  -- specific time

-- Date formatting (like os.date for game time)
-- Format strings: %Y=year, %m=month num, %d=day, %H=hour24, %M=min, %S=sec,
--   %I=hour12, %p=am/pm, %a=weekday abbr, %A=weekday full,
--   %b=month genitive, %B=month genitive full,
--   %c=full datetime, %x=date, %X=time HH:MM
-- format='*t' returns a table: { year, month, day, hour, min, sec, yday, wday }
calendar.formatGameTime(format, timestamp)  -- string or table
```

---

### openmw_aux.ui

**Contexts:** menu, player

```lua
local auxUi = require('openmw_aux.ui')
```

```lua
-- Deep copy a UI layout (including nested Content)
auxUi.deepLayoutCopy(layout)  -- table: copied layout

-- Recursively update all elements in a layout tree
auxUi.deepUpdate(elementOrLayout)

-- Recursively destroy all elements in a layout tree
auxUi.deepDestroy(elementOrLayout)
```

---

## UI System In Depth

### Layers

The UI system has named layers (drawn in order). Built-in layers include:
- `Windows` — game windows
- `HUD` — heads-up display
- `Notification` — messages and notifications
- `InputBlocker` — modal input blocker
- `Fade` — fade to/from black

To add a custom layer:
```lua
ui.layers.insertAfter('HUD', { name = 'MyLayer', isMenu = false })
```

### Creating UI Elements

```lua
local element = ui.create({
    layer = 'HUD',
    type = ui.TYPE.Flex,
    props = {
        horizontal = true,
        autoSize = true,
        position = util.vector2(100, 100),
    },
    content = ui.content {
        {
            type = ui.TYPE.Text,
            props = {
                text = 'Hello World',
                textSize = 20,
                textColor = util.color.rgb(1, 1, 1),
            }
        }
    }
})
```

### Updating UI

After modifying `element.layout`, call `element:update()` to apply changes:
```lua
element.layout.props.text = 'New text'
element:update()
```

### Templates

Templates define reusable widget structures with default props:
```lua
local myTemplate = {
    type = ui.TYPE.Flex,
    props = { horizontal = true },
    content = ui.content { ... },
}

-- Use template
local widget = {
    template = myTemplate,
    props = { position = util.vector2(0, 0) },
}
```

### Setting Pages

Register a settings page for the in-game settings menu:
```lua
ui.registerSettingsPage({
    name = 'My Mod Settings',
    searchHints = 'option1 option2',  -- space-separated search terms
    element = mySettingsElement,
})
```

Built-in setting renderers (via `I.Settings`):
- `textLine` — read-only text label
- `checkbox` — boolean toggle
- `number` — numeric input with optional min/max/step
- `select` — dropdown from options list
- `color` — color picker
- `inputBinding` — key/button binding

---

## AI Packages

AI packages control NPC behavior. Used via `types.Actor` interfaces.

### Combat
```lua
{ type = 'Combat', target = gameObject, cancelOther = true }
```

### Escort
```lua
{
    type = 'Escort',
    target = gameObject,
    destPosition = util.vector3(x, y, z),
    destCell = cell,          -- optional
    duration = 3600,          -- optional: game seconds
    isRepeat = false,
}
```

### Follow
```lua
{
    type = 'Follow',
    target = gameObject,
    destCell = cell,          -- optional destination
    duration = 3600,          -- optional
    destPosition = util.vector3(x, y, z),
    isRepeat = false,
}
```

### Pursue
```lua
{ type = 'Pursue', target = gameObject }
```

### Travel
```lua
{
    type = 'Travel',
    destPosition = util.vector3(x, y, z),
    isRepeat = false,
}
```

### Wander
```lua
{
    type = 'Wander',
    distance = 0,        -- wander radius in units
    duration = 0,        -- duration in game hours
    idle = { 0, 0, 0, 0, 0, 0, 0, 0 },  -- idle animation weights (8 values, 0-100)
    isRepeat = true,
}
```

---

## Save/Load and Serializable Data

### Serializable Types

Only these types can be stored in `onSave` returns or `storage`:
- `nil`
- `boolean`
- `number`
- `string`
- `table` (with string or integer keys, and serializable values)

**Not serializable:** functions, userdata (Vector2/3/4, Color, Transform, GameObject, Cell, etc.)

Convert non-serializable types before saving:
```lua
-- Save a position
function onSave()
    return {
        px = self.position.x,
        py = self.position.y,
        pz = self.position.z,
    }
end

-- Load it back
function onLoad(data)
    local pos = util.vector3(data.px, data.py, data.pz)
end
```

### onSave / onLoad Pattern

```lua
local myState = { counter = 0 }

function onSave()
    return myState  -- must be serializable
end

function onLoad(data)
    myState = data
end

function onInit()
    -- Called only once on first creation (no saved data)
    myState = { counter = 0 }
end
```

### Storage vs onSave

| Feature | onSave/onLoad | openmw.storage |
|---------|--------------|----------------|
| Scope | Per-script-instance | Global or player-wide |
| Persistence | Tied to object/game | Configurable lifetime |
| Access | Script-private | Any script can read global |
| Best for | Script instance state | Mod configuration, shared data |

---

## Interfaces System

Scripts can expose interfaces to other scripts using `interfaceName` and `interface` fields.

### Exposing an Interface

```lua
local myInterface = {}

function myInterface.doSomething(arg)
    print('doing something with', arg)
end

return {
    interfaceName = 'MyModInterface',
    interface = myInterface,
    -- Optional: handle when overridden by another mod
    onInterfaceOverride = function(base)
        -- base is the previous interface, wrap it if needed
    end,
}
```

### Using an Interface

```lua
local I = require('openmw.interfaces')
I.MyModInterface.doSomething('hello')
```

### Built-in Interfaces

#### I.Activation

**Context:** global. Intercept object activation before the engine handles it.

```lua
-- Add handler for a specific object instance
I.Activation.addHandlerForObject(obj, function(object, actor)
    -- return false to block default activation AND all other handlers for this object
    -- return nil/nothing to allow other handlers to run
end)

-- Add handler for all objects of a given type
I.Activation.addHandlerForType(types.Door, function(object, actor)
    -- called when any Door is activated
    -- return false to block further processing
end)
```

Handlers for a specific object run before handlers for its type. If any handler returns `false`, remaining handlers and the default engine behavior are skipped.

Events received: none (uses engine handler `onActivate`).

---

#### I.AI

**Context:** local (attached to an actor). Manage the AI package stack.

```lua
-- Package table fields:
-- { type, target, sideWithTarget, destPosition, distance, duration, idle, isRepeat }

I.AI.getActivePackage()          -- Package or nil: currently running package
I.AI.isFleeing()                 -- boolean: is actor currently fleeing

-- Start a new package (see AI Packages section for full options)
I.AI.startPackage({
    type = 'Combat',
    target = someActor,
    cancelOther = true,          -- optional, default true
})

I.AI.filterPackages(function(package)
    return package.type ~= 'Wander'  -- return false to remove the package
end)

I.AI.forEachPackage(function(package)
    -- iterate without removal
end)

I.AI.removePackages(packageType)  -- remove all packages of given type (nil = remove all)

I.AI.getActiveTarget(packageType)  -- GameObject or nil: target of active package if it matches type
I.AI.getTargets(packageType)       -- list of GameObjects: targets from all packages of given type
```

Events received: `StartAIPackage` → calls `startPackage(options)`, `RemoveAIPackages` → calls `removePackages(packageType)`.

---

#### I.AnimationController

**Context:** local (attached to an actor). Intercept and react to animation events.

```lua
-- Play an animation (goes through handlers first)
I.AnimationController.playBlendedAnimation(groupname, options)
-- options: same as anim.playBlended (priority, blendMask, speed, startKey, stopKey, etc.)
-- handlers can set options.skip = true to prevent the animation from playing

-- Add handler called before every playBlended call
I.AnimationController.addPlayBlendedAnimationHandler(function(groupname, options)
    -- Can modify options table in place
    -- return false to skip remaining handlers
    -- Set options.skip = true to prevent playback
end)

-- Add handler called when an animation group ends
I.AnimationController.addAnimationEndedHandler(function(groupname, info)
    -- info: { time, completion, startKey, stopKey }
    -- return false to skip remaining handlers
end)

-- Add handler for animation text key events
I.AnimationController.addTextKeyHandler(groupname, function(groupname, key)
    -- groupname: '' or nil = receive all text keys from any animation
    -- key: the text key string embedded in the animation
    -- return false to skip remaining handlers
end)
```

Events received: `AddVfx` → calls `anim.addVfx(self, data.model, data.options)`.

---

#### I.Camera

**Context:** player. Control the built-in camera behavior.

```lua
I.Camera.getPrimaryMode()           -- MODE.FirstPerson or MODE.ThirdPerson
I.Camera.getBaseThirdPersonDistance()   -- number: base zoom distance
I.Camera.setBaseThirdPersonDistance(v)  -- set base zoom distance
I.Camera.getTargetThirdPersonDistance() -- number: desired distance without obstacles

-- Mode control (toggle POV, vanity, etc.)
I.Camera.isModeControlEnabled()     -- boolean
I.Camera.disableModeControl(tag)    -- disable built-in POV toggle (with optional tag)
I.Camera.enableModeControl(tag)     -- undo disableModeControl (same tag)

-- Standing preview (auto-preview when standing still)
I.Camera.isStandingPreviewEnabled() -- boolean
I.Camera.disableStandingPreview(tag)
I.Camera.enableStandingPreview(tag)

-- Head bobbing
I.Camera.isHeadBobbingEnabled()     -- boolean
I.Camera.disableHeadBobbing(tag)
I.Camera.enableHeadBobbing(tag)

-- Zoom
I.Camera.isZoomEnabled()            -- boolean
I.Camera.disableZoom(tag)
I.Camera.enableZoom(tag)

-- Third person offset control
I.Camera.isThirdPersonOffsetControlEnabled() -- boolean
I.Camera.disableThirdPersonOffsetControl(tag)
I.Camera.enableThirdPersonOffsetControl(tag)
```

Tag system: multiple callers can disable the same feature with different tags. The feature stays disabled until all tags are re-enabled.

---

#### I.Combat

**Context:** local (attached to an actor). Handle incoming hits and armor calculations.

```lua
-- AttackInfo table fields:
-- { damage, strength, successful, sourceType, type, attacker, weapon, ammo, hitPos }
--   damage: table { health=N, fatigue=N, magicka=N }
--   strength: number [0,1]
--   successful: boolean
--   sourceType: I.Combat.ATTACK_SOURCE_TYPES value ('magic','melee','ranged','unspecified')
--   type: self.ATTACK_TYPE (optional, for melee: Chop/Slash/Thrust)
--   attacker: GameObject (optional)
--   weapon: GameObject (optional)
--   ammo: string record ID (optional)
--   hitPos: Vector3 (optional)

I.Combat.addOnHitHandler(function(attackInfo)
    -- Modify attackInfo.damage in place to change damage dealt
    -- return false to stop other handlers (and default behavior)
end)

-- Armor queries (read-only, used by engine for UI)
I.Combat.getArmorRating(actor)                    -- number: total armor rating
I.Combat.getArmorSkill(item)                      -- string: skill ID or nil
I.Combat.getSkillAdjustedArmorRating(item, actor) -- number
I.Combat.getEffectiveArmorRating(item, actor)     -- number (includes condition)

-- Armor application (side effects: wears armor, plays sound, progresses skill)
I.Combat.adjustDamageForArmor(damage, actor)      -- number: damage after armor
I.Combat.adjustDamageForDifficulty(attack, defendant) -- modifies attack in place
I.Combat.applyArmor(attack)                       -- full armor application

-- Helpers
I.Combat.spawnBloodEffect(position)               -- spawn blood VFX at position
I.Combat.pickRandomArmor(actor)                   -- random equipped armor piece or nil
I.Combat.onHit(attackInfo)                        -- trigger hit processing manually

I.Combat.ATTACK_SOURCE_TYPES.Magic      -- 'magic'
I.Combat.ATTACK_SOURCE_TYPES.Melee      -- 'melee'
I.Combat.ATTACK_SOURCE_TYPES.Ranged     -- 'ranged'
I.Combat.ATTACK_SOURCE_TYPES.Unspecified -- 'unspecified'
```

Events received: `Hit` → calls `I.Combat.onHit(data)`.

---

#### I.MWUI

**Context:** menu, player. Morrowind-style UI widget templates.

```lua
-- Access templates (all are openmw.ui#Template values):
I.MWUI.templates.padding          -- adds padding around content
I.MWUI.templates.interval         -- standard spacing

I.MWUI.templates.borders          -- rectangular borders (thin)
I.MWUI.templates.box              -- content wrapped in thin borders
I.MWUI.templates.boxTransparent   -- box with semi-transparent background
I.MWUI.templates.boxSolid         -- box with solid background
I.MWUI.templates.verticalLine     -- expanding vertical divider line
I.MWUI.templates.horizontalLine   -- expanding horizontal divider line

I.MWUI.templates.bordersThick     -- thick borders variant
I.MWUI.templates.boxThick
I.MWUI.templates.boxTransparentThick
I.MWUI.templates.boxSolidThick
I.MWUI.templates.verticalLineThick
I.MWUI.templates.horizontalLineThick

I.MWUI.templates.textNormal       -- standard "sand" colored text
I.MWUI.templates.textHeader       -- header white text
I.MWUI.templates.textParagraph    -- multiline "sand" text

I.MWUI.templates.textEditLine     -- single-line text input
I.MWUI.templates.textEditBox      -- multiline text input

I.MWUI.templates.disabled         -- shades children and makes them uninteractable
```

To override a template (affects all uses engine-wide):
```lua
local auxUi = require('openmw_aux.ui')
local myText = auxUi.deepLayoutCopy(I.MWUI.templates.textNormal)
myText.props.textSize = 20
I.MWUI.templates.textNormal = myText  -- shallow-copies back into the original
ui.updateAll()
```

---

#### I.Settings

**Context:** global, menu, player. Register settings pages shown in the in-game settings menu.

```lua
-- Register a page (top-level tab in settings)
I.Settings.registerPage({
    key = 'MyModPage',        -- unique identifier
    l10n = 'MyMod',           -- localization context
    name = 'pageNameKey',     -- l10n key for display name
    description = 'descKey',  -- l10n key (optional)
})

-- Register a settings group within a page
I.Settings.registerGroup({
    key = 'SettingsMyModGeneral',   -- unique; by convention starts with 'Settings'
    page = 'MyModPage',
    l10n = 'MyMod',
    name = 'generalGroupKey',
    description = 'groupDescKey',   -- optional
    order = 0,                      -- sort order within page (default 0)
    permanentStorage = false,       -- true = global storage, false = save-file storage
    settings = {
        {
            key = 'enabled',
            name = 'enabledKey',
            description = 'enabledDescKey',
            default = true,
            renderer = 'checkbox',
        },
        {
            key = 'volume',
            default = 1.0,
            renderer = 'number',
            name = 'volumeKey',
            argument = { min = 0.0, max = 2.0, step = 0.1 },
        },
        {
            key = 'mode',
            default = 'fast',
            renderer = 'select',
            name = 'modeKey',
            argument = { items = { 'slow', 'medium', 'fast' } },
        },
        {
            key = 'color',
            default = util.color.rgb(1, 0, 0),
            renderer = 'color',
            name = 'colorKey',
        },
        {
            key = 'jump',
            renderer = 'inputBinding',
            name = 'jumpKey',
            argument = { key = 'MyMod:JumpAction' },  -- registered input action
        },
    },
})

-- Change a renderer argument at runtime (e.g. update select items)
I.Settings.updateRendererArgument('SettingsMyModGeneral', 'mode', { items = { 'a', 'b' } })

-- Read settings values via storage:
local section = storage.playerSection('SettingsMyModGeneral')  -- permanentStorage=false
-- or:
local section = storage.globalSection('SettingsMyModGeneral')  -- permanentStorage=true
local val = section:get('enabled')

-- Register a custom renderer (menu scripts only)
I.Settings.registerRenderer('myRenderer', function(value, set, argument)
    return {
        type = ui.TYPE.TextEdit,
        props = { text = tostring(value), ... },
        events = { textChanged = async:callback(function(s) set(s) end) },
    }
end)
```

Built-in renderers: `textLine`, `checkbox`, `number`, `select`, `color`, `inputBinding`.

---

#### I.UI

**Context:** player. Manage the game's UI mode stack.

```lua
I.UI.MODE     -- read-only table of all mode strings (view with view(I.UI.MODE) in luap console)
I.UI.WINDOW   -- read-only table of all window name strings

I.UI.modes            -- read-only list: current mode stack
I.UI.getMode()        -- string or nil: topmost active mode

-- Drop all modes and set one
I.UI.setMode('Interface')
I.UI.setMode('Interface', { windows = {'Map'} })  -- show only specified windows
I.UI.setMode()        -- close all UI

-- Add mode without dropping others (stack push)
I.UI.addMode('Journal')
I.UI.addMode('Barter', { target = npcActor })

-- Remove a specific mode from the stack
I.UI.removeMode('Journal')

-- Window management
I.UI.getWindowsForMode(mode)  -- list of window names allowed in this mode
I.UI.registerWindow(windowName, showFn, hideFn)
  -- Override a built-in window (showFn(arg), hideFn() called by mode changes)

-- HUD visibility
I.UI.setHudVisibility(bool)
I.UI.isHudVisible()    -- boolean
I.UI.isWindowVisible(windowName)  -- boolean

-- Pause behavior
I.UI.setPauseOnMode(mode, shouldPause)  -- control whether a mode pauses the game

-- Interactive message box (modal, pauses game, single OK button)
I.UI.showInteractiveMessage(text, options)
```

Events received: `UiModeChanged` (plays book/scroll sounds), `AddUiMode` → `addMode`, `SetUiMode` → `setMode`.

---

#### I.ItemUsage

**Context:** global. Override item use behavior (drag-to-equip in inventory).

```lua
-- Add handler for a specific object instance
I.ItemUsage.addHandlerForObject(obj, function(object, actor, options)
    -- options: { force = boolean }
    -- return false to block default use and all other handlers
end)

-- Add handler for all objects of a given type
I.ItemUsage.addHandlerForType(types.Armor, function(object, actor, options)
    -- e.g. forbid equipping heavy armor:
    if types.Armor.record(object).weight > 30 then
        return false
    end
end)
```

Events received: `UseItem` → `useItem(data.object, data.actor, data.force)`.

Limitations: does not intercept MWScript actions, AI potion use, or quick-key actions.

---

#### I.SkillProgression

**Context:** player. Override skill use and level-up mechanics.

```lua
-- SKILL_USE_TYPES: maps use context to useType index (0-3)
I.SkillProgression.SKILL_USE_TYPES.Armor_HitByOpponent   -- 0
I.SkillProgression.SKILL_USE_TYPES.Block_Success          -- 0
I.SkillProgression.SKILL_USE_TYPES.Spellcast_Success      -- 0
I.SkillProgression.SKILL_USE_TYPES.Weapon_SuccessfulHit   -- 0
I.SkillProgression.SKILL_USE_TYPES.Alchemy_CreatePotion   -- 0
I.SkillProgression.SKILL_USE_TYPES.Alchemy_UseIngredient  -- 1
I.SkillProgression.SKILL_USE_TYPES.Enchant_Recharge       -- 0
I.SkillProgression.SKILL_USE_TYPES.Enchant_UseMagicItem   -- 1
I.SkillProgression.SKILL_USE_TYPES.Enchant_CreateMagicItem -- 2
I.SkillProgression.SKILL_USE_TYPES.Enchant_CastOnStrike   -- 3
I.SkillProgression.SKILL_USE_TYPES.Acrobatics_Jump        -- 0
I.SkillProgression.SKILL_USE_TYPES.Acrobatics_Fall        -- 1
I.SkillProgression.SKILL_USE_TYPES.Mercantile_Success     -- 0
I.SkillProgression.SKILL_USE_TYPES.Security_DisarmTrap    -- 0
I.SkillProgression.SKILL_USE_TYPES.Security_PickLock      -- 1
I.SkillProgression.SKILL_USE_TYPES.Sneak_AvoidNotice      -- 0
I.SkillProgression.SKILL_USE_TYPES.Sneak_PickPocket       -- 1
I.SkillProgression.SKILL_USE_TYPES.Speechcraft_Success    -- 0
I.SkillProgression.SKILL_USE_TYPES.Speechcraft_Fail       -- 1
I.SkillProgression.SKILL_USE_TYPES.Armorer_Repair         -- 0
I.SkillProgression.SKILL_USE_TYPES.Athletics_RunOneSecond -- 0
I.SkillProgression.SKILL_USE_TYPES.Athletics_SwimOneSecond -- 1

-- SKILL_INCREASE_SOURCES
I.SkillProgression.SKILL_INCREASE_SOURCES.Book     -- 'book'
I.SkillProgression.SKILL_INCREASE_SOURCES.Usage    -- 'usage'
I.SkillProgression.SKILL_INCREASE_SOURCES.Trainer  -- 'trainer'
I.SkillProgression.SKILL_INCREASE_SOURCES.Jail     -- 'jail' (causes skill decrease)

-- Handler for skill use (called when a skill is exercised)
I.SkillProgression.addSkillUsedHandler(function(skillid, options)
    -- options: { skillGain, useType, scale, ...any extra params from skillUsed }
    -- Modify options.skillGain to change XP gained
    -- return false to stop further handlers (including default progression)
end)

-- Handler for skill level-up
I.SkillProgression.addSkillLevelUpHandler(function(skillid, source, options)
    -- skillid: string e.g. 'longblade'
    -- source: SKILL_INCREASE_SOURCES value
    -- options table (modify in place):
    --   skillIncreaseValue         -- number: levels gained (default 1; -1 for jail)
    --   levelUpProgress            -- number: level-up progress gained
    --   levelUpAttribute           -- string: attribute to credit
    --   levelUpAttributeIncreaseValue -- number: attribute points for level-up screen
    --   levelUpSpecialization      -- string: specialization to credit
    --   levelUpSpecializationIncreaseValue -- number
    -- Set any field to nil to skip that mechanic
    -- return false to stop further handlers
end)

-- Trigger skill use manually
I.SkillProgression.skillUsed(skillid, {
    useType = I.SkillProgression.SKILL_USE_TYPES.Weapon_SuccessfulHit,
    scale = 1.0,    -- optional multiplier
    -- skillGain = 5 -- or provide skillGain directly
})

-- Trigger skill level-up manually
I.SkillProgression.skillLevelUp(skillid, source)

-- Compute XP required for next level
I.SkillProgression.getSkillProgressRequirement(skillid)  -- number

-- Build the options table for a level-up (for custom handler logic)
I.SkillProgression.getSkillLevelUpOptions(skillid, source)  -- table
```

---

#### I.Crimes

**Context:** global. Commit crimes programmatically.

```lua
-- Commit a crime as if done through game action
local result = I.Crimes.commitCrime(player, {
    type = types.Player.OFFENSE_TYPE.Theft,  -- required
    victim = npcObject,                       -- optional: NPC victim
    faction = 'thieves guild',                -- optional: faction string ID
    arg = 100,                                -- optional: bounty value for Theft
    victimAware = false,                      -- optional: was victim aware?
})
-- result.wasCrimeSeen  -- boolean: was the crime witnessed?

-- Can also be called via event:
core.sendGlobalEvent('CommitCrime', {
    player = player,
    type = types.Player.OFFENSE_TYPE.Assault,
    victim = npc,
})
```

---

## Practical Examples

### Global Script: Track all actors

```lua
local core = require('openmw.core')
local world = require('openmw.world')
local types = require('openmw.types')

local function onUpdate(dt)
    for _, actor in ipairs(world.activeActors) do
        if types.NPC.objectIsInstance(actor) then
            -- Process NPC
        end
    end
end
```

### Local Script: React to player activation

```lua
local self = require('openmw.self')
local core = require('openmw.core')

local function onActivated(actor)
    if actor == core.players[1] then
        self:sendEvent('PlayerActivatedMe', { object = self.object })
    end
end
```

### Player Script: Custom HUD

```lua
local ui = require('openmw.ui')
local util = require('openmw.util')
local async = require('openmw.async')

local element

local function createHUD()
    element = ui.create({
        layer = 'HUD',
        type = ui.TYPE.Text,
        props = {
            position = util.vector2(10, 10),
            text = 'Hello World',
            textSize = 16,
            textColor = util.color.rgb(1, 1, 1),
        }
    })
end

local function onInit()
    createHUD()
end
```

### Using Timers (Saveable)

```lua
local async = require('openmw.async')
local time = require('openmw_aux.time')

-- Register at script init time (not inside handlers!)
local myCallback = time.registerTimerCallback('myTimer', function(arg)
    print('Timer fired with arg:', arg)
end)

local function onInit()
    -- Fire after 5 game seconds
    time.newGameTimer(5 * time.second, myCallback, { data = 42 })
end

-- Repeating timer (unsaveable)
local stop
local function onInit()
    stop = time.runRepeatedly(function()
        -- runs every 10 simulation seconds
    end, 10 * time.second)
end
```

### Mod Settings Page

```lua
-- In a player or menu script:
local I = require('openmw.interfaces')
local storage = require('openmw.storage')
local async = require('openmw.async')

I.Settings.registerPage({
    key = 'MyMod',
    l10n = 'MyMod',
    name = 'pageName',
})

I.Settings.registerGroup({
    key = 'MyMod:Options',
    page = 'MyMod',
    l10n = 'MyMod',
    name = 'optionsGroup',
    settings = {
        { key = 'enabled', renderer = 'checkbox', name = 'enabled', default = true },
    }
})

local section = storage.globalSection('MyMod:Options')

local function isEnabled()
    return section:get('enabled')
end
```

### YAML Configuration

```lua
local markup = require('openmw.markup')
local vfs = require('openmw.vfs')

-- Load config from VFS
local config = markup.loadYaml('mymod/config.yaml')
-- config is now a Lua table

-- Or parse inline
local data = markup.decodeYaml([[
name: Test
value: 42
list:
  - item1
  - item2
]])
```

---

## Notes and Gotchas

1. **Script initialization order**: Register timer callbacks, interfaces, and settings at the top level of the script (not inside handlers or functions that might be called later).

2. **No `require` of other mods' scripts directly**: Use the interfaces system (`openmw.interfaces`) for cross-mod communication.

3. **Global scripts run once**: There is one global script instance for the entire game. Local scripts run per-object.

4. **Object validity**: Always check `obj:isValid()` if an object reference might have been deleted.

5. **Serialization**: `openmw.util` types (Vector3, Color, Transform) cannot be stored in `onSave` or `storage`. Convert to plain tables.

6. **Menu scripts limited access**: Menu scripts cannot access `openmw.world` or `openmw.types`. They can access `openmw.storage.globalSection` only while a game is running.

7. **Async callbacks**: UI event handlers must use `async:callback(fn)` to run in the script's context.

8. **Record IDs from ESM3**: String IDs from ESM3 content files (Morrowind.esm, etc.) are always **lower-cased**. IDs from dynamically created records or ESM4 files may not be.

9. **`world.createObject`**: Creates an object in the disabled state. Use `obj:teleport()` to place it in the world or `obj:moveInto()` for containers.

10. **Timer callbacks**: The `name` passed to `registerTimerCallback` must be the same across save/load cycles — it's used to look up the callback when a timer fires after loading.

11. **`nearby` lists**: Updated every frame but only contain objects in the active processing range around the player.

12. **Lua 5.1 base**: No integer type, no bitwise operators natively (use `util.bitAnd` etc.), no `goto`, limited `string` library.
