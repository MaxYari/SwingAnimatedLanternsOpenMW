
--- @class ATTACK_TYPE_ENUM
--- @field NoAttack number
--- @field Any number
--- @field Chop number
--- @field Slash number
--- @field Thrust number

--- @class ActorControls
--- @field movement number -1 to 1 (backward/forward)
--- @field sideMovement number -1 to 1 (left/right)
--- @field yawChange number radians per frame
--- @field pitchChange number radians per frame
--- @field run boolean
--- @field sneak boolean
--- @field jump boolean
--- @field use number ATTACK_TYPE value

--- @class openmw_self : GameObject
--- @field object GameObject
--- @field controls ActorControls
--- @field ATTACK_TYPE ATTACK_TYPE_ENUM
local selfModule = {}

--- @return boolean
function selfModule:isActive() end

--- @param val boolean
function selfModule:enableAI(val) end

return selfModule
