
--- @class PRIORITY_ENUM
--- @field Default number 0
--- @field WeaponLowerBody number 1
--- @field SneakIdleLowerBody number 2
--- @field SwimIdle number 3
--- @field Jump number 4
--- @field Movement number 5
--- @field Hit number 6
--- @field Weapon number 7
--- @field Block number 8
--- @field Knockdown number 9
--- @field Torch number 10
--- @field Storm number 11
--- @field Death number 12
--- @field Scripted number 13

--- @class BLEND_MASK_ENUM
--- @field LowerBody number 1
--- @field Torso number 2
--- @field LeftArm number 4
--- @field RightArm number 8
--- @field UpperBody number 14
--- @field All number 15

--- @class BONE_GROUP_ENUM
--- @field LowerBody number 1
--- @field Torso number 2
--- @field LeftArm number 3
--- @field RightArm number 4

--- @class PlayBlendedOptions
--- @field priority? number|table PRIORITY value or table mapping BONE_GROUP -> PRIORITY
--- @field blendMask? number BLEND_MASK value
--- @field autoDisable? boolean
--- @field speed? number
--- @field startKey? string
--- @field stopKey? string
--- @field forceLoop? boolean
--- @field skip? boolean set true to prevent playback (in AnimationController handlers)

--- @class openmw_animation
--- @field PRIORITY PRIORITY_ENUM
--- @field BLEND_MASK BLEND_MASK_ENUM
--- @field BONE_GROUP BONE_GROUP_ENUM
local anim = {}

--- @param obj GameObject
--- @return boolean
function anim.hasAnimation(obj) end

--- @param obj GameObject
function anim.skipAnimationThisFrame(obj) end

--- @param obj GameObject
--- @param key string
--- @return number|nil
function anim.getTextKeyTime(obj, key) end

--- @param obj GameObject
--- @param groupName string
--- @return boolean
function anim.isPlaying(obj, groupName) end

--- @param obj GameObject
--- @param groupName string
--- @return number|nil
function anim.getCurrentTime(obj, groupName) end

--- @param obj GameObject
--- @param groupName string
--- @return boolean
function anim.isLoopingAnimation(obj, groupName) end

--- @param obj GameObject
--- @param groupName string
--- @return number|nil 0-1
function anim.getCompletion(obj, groupName) end

--- @param obj GameObject
--- @param groupName string
--- @return number
function anim.getLoopCount(obj, groupName) end

--- @param obj GameObject
--- @param groupName string
--- @return number
function anim.getSpeed(obj, groupName) end

--- @param obj GameObject
--- @param boneGroup number BONE_GROUP value
--- @return string|nil
function anim.getActiveGroup(obj, boneGroup) end

--- @param obj GameObject
--- @param groupName string
--- @return boolean
function anim.hasGroup(obj, groupName) end

--- @param obj GameObject
--- @param boneName string
--- @return boolean
function anim.hasBone(obj, boneName) end

--- @param obj GameObject
--- @param groupName string
function anim.cancel(obj, groupName) end

--- @param obj GameObject
--- @param groupName string
--- @param val boolean
function anim.setLoopingEnabled(obj, groupName, val) end

--- @param obj GameObject
--- @param groupName string
--- @param speed number
function anim.setSpeed(obj, groupName, speed) end

--- @param obj GameObject
--- @param forceIdle boolean
function anim.clearAnimationQueue(obj, forceIdle) end

--- @param obj GameObject
--- @param groupName string
--- @param options? PlayBlendedOptions
function anim.playBlended(obj, groupName, options) end

--- @param obj GameObject
--- @param groupName string
--- @param options? PlayBlendedOptions
function anim.playQueued(obj, groupName, options) end

--- @param obj GameObject
--- @param model string
--- @param options? {loop:boolean, boneName:string, particleTextureOverride:string, vfxId:string}
function anim.addVfx(obj, model, options) end

--- @param obj GameObject
--- @param vfxId string
function anim.removeVfx(obj, vfxId) end

--- @param obj GameObject
function anim.removeAllVfx(obj) end

return anim
