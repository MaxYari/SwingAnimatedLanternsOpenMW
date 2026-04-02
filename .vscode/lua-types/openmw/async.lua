
--- @class TimerCallback

--- @class Callback

--- @class openmw_async
local async = {}

--- @param name string
--- @param func function
--- @return TimerCallback
function async:registerTimerCallback(name, func) end

--- @param delay number simulation seconds
--- @param callback TimerCallback
--- @param arg? any
function async:newSimulationTimer(delay, callback, arg) end

--- @param delay number game seconds
--- @param callback TimerCallback
--- @param arg? any
function async:newGameTimer(delay, callback, arg) end

--- @param delay number simulation seconds
--- @param func function
function async:newUnsavableSimulationTimer(delay, func) end

--- @param delay number game seconds
--- @param func function
function async:newUnsavableGameTimer(delay, func) end

--- @param func function
--- @return Callback
function async:callback(func) end

return async
