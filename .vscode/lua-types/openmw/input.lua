
--- @class KEY_ENUM
--- @field A number
--- @field B number
--- @field C number
--- @field D number
--- @field E number
--- @field F number
--- @field G number
--- @field H number
--- @field I number
--- @field J number
--- @field K number
--- @field L number
--- @field M number
--- @field N number
--- @field O number
--- @field P number
--- @field Q number
--- @field R number
--- @field S number
--- @field T number
--- @field U number
--- @field V number
--- @field W number
--- @field X number
--- @field Y number
--- @field Z number
--- @field _0 number
--- @field _1 number
--- @field _2 number
--- @field _3 number
--- @field _4 number
--- @field _5 number
--- @field _6 number
--- @field _7 number
--- @field _8 number
--- @field _9 number
--- @field NP_0 number
--- @field NP_1 number
--- @field NP_2 number
--- @field NP_3 number
--- @field NP_4 number
--- @field NP_5 number
--- @field NP_6 number
--- @field NP_7 number
--- @field NP_8 number
--- @field NP_9 number
--- @field F1 number
--- @field F2 number
--- @field F3 number
--- @field F4 number
--- @field F5 number
--- @field F6 number
--- @field F7 number
--- @field F8 number
--- @field F9 number
--- @field F10 number
--- @field F11 number
--- @field F12 number
--- @field Escape number
--- @field Return number
--- @field Space number
--- @field Backspace number
--- @field Tab number
--- @field CapsLock number
--- @field LeftShift number
--- @field RightShift number
--- @field LeftCtrl number
--- @field RightCtrl number
--- @field LeftAlt number
--- @field RightAlt number
--- @field LeftSuper number
--- @field RightSuper number
--- @field Left number
--- @field Right number
--- @field Up number
--- @field Down number
--- @field Home number
--- @field End number
--- @field PageUp number
--- @field PageDown number
--- @field Insert number
--- @field Delete number
--- @field Minus number
--- @field Equals number
--- @field Semicolon number
--- @field Comma number
--- @field Period number
--- @field Slash number
--- @field Backslash number
--- @field LeftBracket number
--- @field RightBracket number
--- @field Backquote number
--- @field Quote number

--- @class CONTROLLER_BUTTON_ENUM
--- @field A number
--- @field B number
--- @field X number
--- @field Y number
--- @field Back number
--- @field Guide number
--- @field Start number
--- @field LeftStick number
--- @field RightStick number
--- @field LeftShoulder number
--- @field RightShoulder number
--- @field DPadUp number
--- @field DPadDown number
--- @field DPadLeft number
--- @field DPadRight number
--- @field Misc1 number
--- @field Touchpad number

--- @class CONTROLLER_AXIS_ENUM
--- @field LeftX number
--- @field LeftY number
--- @field RightX number
--- @field RightY number
--- @field TriggerLeft number
--- @field TriggerRight number

--- @class ACTION_TYPE_ENUM
--- @field Boolean number
--- @field Number number
--- @field Range number

--- @class CONTROL_SWITCH_ENUM
--- @field Controls number
--- @field Fighting number
--- @field Jumping number
--- @field Looking number
--- @field Magic number
--- @field ViewMode number
--- @field VanityMode number

--- @class KeyboardEvent
--- @field symbol string
--- @field code number KEY value
--- @field withShift boolean
--- @field withCtrl boolean
--- @field withAlt boolean
--- @field withSuper boolean

--- @class TouchEvent
--- @field device string
--- @field finger number
--- @field position Vector2
--- @field pressure number

--- @class openmw_input
--- @field KEY KEY_ENUM
--- @field CONTROLLER_BUTTON CONTROLLER_BUTTON_ENUM
--- @field CONTROLLER_AXIS CONTROLLER_AXIS_ENUM
--- @field ACTION_TYPE ACTION_TYPE_ENUM
--- @field CONTROL_SWITCH CONTROL_SWITCH_ENUM
--- @field actions table
--- @field triggers table
local input = {}

--- @return boolean
function input.isIdle() end
--- @param key number KEY value
--- @return boolean
function input.isKeyPressed(key) end
--- @param btn number CONTROLLER_BUTTON value
--- @return boolean
function input.isControllerButtonPressed(btn) end
--- @return boolean
function input.isShiftPressed() end
--- @return boolean
function input.isCtrlPressed() end
--- @return boolean
function input.isAltPressed() end
--- @return boolean
function input.isSuperPressed() end
--- @param btn number 1=left 2=mid 3=right
--- @return boolean
function input.isMouseButtonPressed(btn) end
--- @return number pixels
function input.getMouseMoveX() end
--- @return number pixels
function input.getMouseMoveY() end
--- @param axis number CONTROLLER_AXIS value
--- @return number -1 to 1
function input.getAxisValue(axis) end
--- @param key number KEY value
--- @return string
function input.getKeyName(key) end

--- @param options {key:string, l10n:string, name:string, description:string, type:number, defaultValue:any}
function input.registerAction(options) end
--- @param actionKey string
--- @param trigger any
--- @param value any
function input.bindAction(actionKey, trigger, value) end
--- @param actionKey string
--- @param callback function
function input.registerActionHandler(actionKey, callback) end
--- @param actionKey string
--- @return boolean
function input.getBooleanActionValue(actionKey) end
--- @param actionKey string
--- @return number
function input.getNumberActionValue(actionKey) end
--- @param actionKey string
--- @return number
function input.getRangeActionValue(actionKey) end

--- @param options {key:string, l10n:string, name:string, description:string}
function input.registerTrigger(options) end
--- @param triggerKey string
--- @param callback function
function input.registerTriggerHandler(triggerKey, callback) end
--- @param triggerKey string
--- @param value any
function input.activateTrigger(triggerKey, value) end

--- @deprecated use types.Player.getControlSwitch
--- @param switch number
--- @return boolean
function input.getControlSwitch(switch) end
--- @deprecated use types.Player.setControlSwitch
--- @param switch number
--- @param val boolean
function input.setControlSwitch(switch, val) end

return input
