--- @class openmw_aux_time
--- @field second number 1
--- @field minute number 60
--- @field hour number 3600
--- @field day number 86400
--- @field GameTime string 'GameTime'
--- @field SimulationTime string 'SimulationTime'
local auxTime = {}

--- @param name string
--- @param fn function
--- @return TimerCallback
function auxTime.registerTimerCallback(name, fn) end

--- @param delay number
--- @param callback TimerCallback
--- @param callbackArg? any
function auxTime.newGameTimer(delay, callback, callbackArg) end

--- @param delay number
--- @param callback TimerCallback
--- @param callbackArg? any
function auxTime.newSimulationTimer(delay, callback, callbackArg) end

--- @param fn function
--- @param period number seconds
--- @param options? {initialDelay?:number, type?:string}
--- @return function stop function
function auxTime.runRepeatedly(fn, period, options) end

return auxTime
