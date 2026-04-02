--- @class openmw_aux_util
local auxUtil = {}

--- @param value any
--- @param maxDepth? number default 1
--- @return string
function auxUtil.deepToString(value, maxDepth) end

--- @param array any[]
--- @param scoreFn fun(element:any):number|nil
--- @return any, number, number element, score, index
function auxUtil.findMinScore(array, scoreFn) end

--- @param array any[]
--- @param scoreFn fun(element:any):any
--- @return any[], any[] filtered array, scores
function auxUtil.mapFilter(array, scoreFn) end

--- @param array any[]
--- @param scoreFn fun(element:any):number|nil
--- @return any[], number[] sorted array, sorted scores
function auxUtil.mapFilterSort(array, scoreFn) end

--- @param handlers function[]|nil
--- @param ... any
--- @return boolean handled
function auxUtil.callEventHandlers(handlers, ...) end

--- @param handlers function[][]
--- @param ... any
--- @return boolean handled
function auxUtil.callMultipleEventHandlers(handlers, ...) end

--- @param t table
--- @return table shallow copy
function auxUtil.shallowCopy(t) end

return auxUtil
