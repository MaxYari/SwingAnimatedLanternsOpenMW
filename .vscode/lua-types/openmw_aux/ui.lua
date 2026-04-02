--- @class openmw_aux_ui
local auxUi = {}

--- @param layout table
--- @return table copied layout
function auxUi.deepLayoutCopy(layout) end

--- @param elementOrLayout any Element or layout table
function auxUi.deepUpdate(elementOrLayout) end

--- @param elementOrLayout any Element or layout table
function auxUi.deepDestroy(elementOrLayout) end

return auxUi
