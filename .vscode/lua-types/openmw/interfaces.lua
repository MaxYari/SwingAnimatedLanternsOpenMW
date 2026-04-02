
--- @class AttackSourceTypes
--- @field Magic string 'magic'
--- @field Melee string 'melee'
--- @field Ranged string 'ranged'
--- @field Unspecified string 'unspecified'

--- @class AttackInfo
--- @field damage table {health?:number, fatigue?:number, magicka?:number}
--- @field strength number 0-1
--- @field successful boolean
--- @field sourceType string AttackSourceTypes value
--- @field type number|nil ATTACK_TYPE (Chop/Slash/Thrust)
--- @field attacker GameObject|nil
--- @field weapon GameObject|nil
--- @field ammo string|nil record ID
--- @field hitPos Vector3|nil

--- @class AIPackage
--- @field type string 'Combat'|'Pursue'|'Follow'|'Escort'|'Wander'|'Travel'
--- @field target GameObject|nil
--- @field sideWithTarget boolean
--- @field destPosition Vector3
--- @field distance number|nil
--- @field duration number|nil
--- @field idle table|nil
--- @field isRepeat boolean

--- @class AnimationEndedInfo
--- @field time number
--- @field completion number
--- @field startKey string
--- @field stopKey string

--- @class SkillLevelUpOptions
--- @field skillIncreaseValue number
--- @field levelUpProgress number
--- @field levelUpAttribute string
--- @field levelUpAttributeIncreaseValue number
--- @field levelUpSpecialization string
--- @field levelUpSpecializationIncreaseValue number

--- @class SKILL_USE_TYPES_ENUM
--- @field Armor_HitByOpponent number 0
--- @field Block_Success number 0
--- @field Spellcast_Success number 0
--- @field Weapon_SuccessfulHit number 0
--- @field Alchemy_CreatePotion number 0
--- @field Alchemy_UseIngredient number 1
--- @field Enchant_Recharge number 0
--- @field Enchant_UseMagicItem number 1
--- @field Enchant_CreateMagicItem number 2
--- @field Enchant_CastOnStrike number 3
--- @field Acrobatics_Jump number 0
--- @field Acrobatics_Fall number 1
--- @field Mercantile_Success number 0
--- @field Security_DisarmTrap number 0
--- @field Security_PickLock number 1
--- @field Sneak_AvoidNotice number 0
--- @field Sneak_PickPocket number 1
--- @field Speechcraft_Success number 0
--- @field Speechcraft_Fail number 1
--- @field Armorer_Repair number 0
--- @field Athletics_RunOneSecond number 0
--- @field Athletics_SwimOneSecond number 1

--- @class SKILL_INCREASE_SOURCES_ENUM
--- @field Book string 'book'
--- @field Usage string 'usage'
--- @field Trainer string 'trainer'
--- @field Jail string 'jail'

--- @class CommitCrimeOutputs
--- @field wasCrimeSeen boolean

--- @class I_Activation
--- @field version number
local I_Activation = {}
--- @param obj GameObject
--- @param handler fun(object:GameObject, actor:GameObject):boolean|nil
function I_Activation.addHandlerForObject(obj, handler) end
--- @param type any type from openmw.types
--- @param handler fun(object:GameObject, actor:GameObject):boolean|nil
function I_Activation.addHandlerForType(type, handler) end

--- @class I_AI
--- @field version number
local I_AI = {}
--- @return AIPackage|nil
function I_AI.getActivePackage() end
--- @return boolean
function I_AI.isFleeing() end
--- @param options {type:string, target?:GameObject, cancelOther?:boolean, destPosition?:Vector3, duration?:number, distance?:number, idle?:table, isRepeat?:boolean}
function I_AI.startPackage(options) end
--- @param filterCallback fun(package:AIPackage):boolean
function I_AI.filterPackages(filterCallback) end
--- @param callback fun(package:AIPackage)
function I_AI.forEachPackage(callback) end
--- @param packageType? string
function I_AI.removePackages(packageType) end
--- @param packageType string
--- @return GameObject|nil
function I_AI.getActiveTarget(packageType) end
--- @param packageType string
--- @return GameObject[]
function I_AI.getTargets(packageType) end

--- @class I_AnimationController
--- @field version number
local I_AnimationController = {}
--- @param groupname string
--- @param options PlayBlendedOptions
function I_AnimationController.playBlendedAnimation(groupname, options) end
--- @param handler fun(groupname:string, options:PlayBlendedOptions):boolean|nil
function I_AnimationController.addPlayBlendedAnimationHandler(handler) end
--- @param handler fun(groupname:string, info:AnimationEndedInfo):boolean|nil
function I_AnimationController.addAnimationEndedHandler(handler) end
--- @param groupname string|nil empty string = all animations
--- @param handler fun(groupname:string, key:string):boolean|nil
function I_AnimationController.addTextKeyHandler(groupname, handler) end

--- @class I_Camera
--- @field version number
local I_Camera = {}
--- @return number MODE value
function I_Camera.getPrimaryMode() end
--- @return number
function I_Camera.getBaseThirdPersonDistance() end
--- @param v number
function I_Camera.setBaseThirdPersonDistance(v) end
--- @return number
function I_Camera.getTargetThirdPersonDistance() end
--- @return boolean
function I_Camera.isModeControlEnabled() end
--- @param tag? string
function I_Camera.disableModeControl(tag) end
--- @param tag? string
function I_Camera.enableModeControl(tag) end
--- @return boolean
function I_Camera.isStandingPreviewEnabled() end
--- @param tag? string
function I_Camera.disableStandingPreview(tag) end
--- @param tag? string
function I_Camera.enableStandingPreview(tag) end
--- @return boolean
function I_Camera.isHeadBobbingEnabled() end
--- @param tag? string
function I_Camera.disableHeadBobbing(tag) end
--- @param tag? string
function I_Camera.enableHeadBobbing(tag) end
--- @return boolean
function I_Camera.isZoomEnabled() end
--- @param tag? string
function I_Camera.disableZoom(tag) end
--- @param tag? string
function I_Camera.enableZoom(tag) end
--- @return boolean
function I_Camera.isThirdPersonOffsetControlEnabled() end
--- @param tag? string
function I_Camera.disableThirdPersonOffsetControl(tag) end
--- @param tag? string
function I_Camera.enableThirdPersonOffsetControl(tag) end

--- @class I_Combat
--- @field version number
--- @field ATTACK_SOURCE_TYPES AttackSourceTypes
local I_Combat = {}
--- @param handler fun(attackInfo:AttackInfo):boolean|nil
function I_Combat.addOnHitHandler(handler) end
--- @param damage number
--- @param actor? GameObject
--- @return number
function I_Combat.adjustDamageForArmor(damage, actor) end
--- @param attack AttackInfo
--- @param defendant? GameObject
function I_Combat.adjustDamageForDifficulty(attack, defendant) end
--- @param attack AttackInfo
function I_Combat.applyArmor(attack) end
--- @param actor? GameObject
--- @return number
function I_Combat.getArmorRating(actor) end
--- @param item GameObject
--- @return string|nil
function I_Combat.getArmorSkill(item) end
--- @param item GameObject
--- @param actor? GameObject
--- @return number
function I_Combat.getSkillAdjustedArmorRating(item, actor) end
--- @param item GameObject
--- @param actor? GameObject
--- @return number
function I_Combat.getEffectiveArmorRating(item, actor) end
--- @param position Vector3
function I_Combat.spawnBloodEffect(position) end
--- @param attackInfo AttackInfo
function I_Combat.onHit(attackInfo) end
--- @param actor? GameObject
--- @return GameObject|nil
function I_Combat.pickRandomArmor(actor) end

--- @class MWUITemplates
--- @field padding table
--- @field interval table
--- @field borders table
--- @field box table
--- @field boxTransparent table
--- @field boxSolid table
--- @field verticalLine table
--- @field horizontalLine table
--- @field bordersThick table
--- @field boxThick table
--- @field boxTransparentThick table
--- @field boxSolidThick table
--- @field verticalLineThick table
--- @field horizontalLineThick table
--- @field textNormal table
--- @field textHeader table
--- @field textParagraph table
--- @field textEditLine table
--- @field textEditBox table
--- @field disabled table

--- @class I_MWUI
--- @field version number
--- @field templates MWUITemplates

--- @class I_Settings
--- @field version number
local I_Settings = {}
--- @param options {key:string, l10n:string, name:string, description?:string}
function I_Settings.registerPage(options) end
--- @param options {key:string, page:string, l10n:string, name:string, description?:string, order?:number, permanentStorage:boolean, settings:table[]}
function I_Settings.registerGroup(options) end
--- @param groupKey string
--- @param settingKey string
--- @param argument any
function I_Settings.updateRendererArgument(groupKey, settingKey, argument) end
--- @param name string
--- @param renderer fun(value:any, set:fun(v:any), argument:any):table
function I_Settings.registerRenderer(name, renderer) end

--- @class I_UI
--- @field version number
--- @field MODE table read-only map of mode strings
--- @field WINDOW table read-only map of window names
--- @field modes string[] current mode stack (read-only)
local I_UI = {}
--- @return string|nil
function I_UI.getMode() end
--- @param mode? string
--- @param options? {windows:string[], target:GameObject}
function I_UI.setMode(mode, options) end
--- @param mode string
--- @param options? {windows:string[], target:GameObject}
function I_UI.addMode(mode, options) end
--- @param mode string
function I_UI.removeMode(mode) end
--- @param mode string
--- @return string[]
function I_UI.getWindowsForMode(mode) end
--- @param windowName string
--- @param showFn fun(arg:any)
--- @param hideFn fun()
function I_UI.registerWindow(windowName, showFn, hideFn) end
--- @param val boolean
function I_UI.setHudVisibility(val) end
--- @return boolean
function I_UI.isHudVisible() end
--- @param windowName string
--- @return boolean
function I_UI.isWindowVisible(windowName) end
--- @param mode string
--- @param shouldPause boolean
function I_UI.setPauseOnMode(mode, shouldPause) end
--- @param message string
--- @param options? table
function I_UI.showInteractiveMessage(message, options) end

--- @class I_ItemUsage
--- @field version number
local I_ItemUsage = {}
--- @param obj GameObject
--- @param handler fun(object:GameObject, actor:GameObject, options:{force:boolean}):boolean|nil
function I_ItemUsage.addHandlerForObject(obj, handler) end
--- @param type any type from openmw.types
--- @param handler fun(object:GameObject, actor:GameObject, options:{force:boolean}):boolean|nil
function I_ItemUsage.addHandlerForType(type, handler) end

--- @class I_SkillProgression
--- @field version number
--- @field SKILL_USE_TYPES SKILL_USE_TYPES_ENUM
--- @field SKILL_INCREASE_SOURCES SKILL_INCREASE_SOURCES_ENUM
local I_SkillProgression = {}
--- @param handler fun(skillid:string, options:{skillGain:number, useType:number, scale?:number}):boolean|nil
function I_SkillProgression.addSkillUsedHandler(handler) end
--- @param handler fun(skillid:string, source:string, options:SkillLevelUpOptions):boolean|nil
function I_SkillProgression.addSkillLevelUpHandler(handler) end
--- @param skillid string
--- @param options {skillGain?:number, useType?:number, scale?:number}
function I_SkillProgression.skillUsed(skillid, options) end
--- @param skillid string
--- @param source string SKILL_INCREASE_SOURCES value
function I_SkillProgression.skillLevelUp(skillid, source) end
--- @param skillid string
--- @return number
function I_SkillProgression.getSkillProgressRequirement(skillid) end
--- @param skillid string
--- @param source string
--- @return SkillLevelUpOptions
function I_SkillProgression.getSkillLevelUpOptions(skillid, source) end

--- @class I_Crimes
--- @field version number
local I_Crimes = {}
--- @param player GameObject
--- @param options {type:number, victim?:GameObject, faction?:string, arg?:number, victimAware?:boolean}
--- @return CommitCrimeOutputs
function I_Crimes.commitCrime(player, options) end

--- @class openmw_interfaces
--- @field Activation I_Activation
--- @field AI I_AI
--- @field AnimationController I_AnimationController
--- @field Camera I_Camera
--- @field Combat I_Combat
--- @field MWUI I_MWUI
--- @field Settings I_Settings
--- @field UI I_UI
--- @field ItemUsage I_ItemUsage
--- @field SkillProgression I_SkillProgression
--- @field Crimes I_Crimes
local interfaces = {}

return interfaces
