--- @class openmw_aux_calendar
--- @field monthCount number
--- @field daysInYear number
--- @field daysInWeek number
local auxCalendar = {}

--- @param t? {year?:number, month?:number, day?:number, hour?:number, min?:number, sec?:number}
--- @return number timestamp
function auxCalendar.gameTime(t) end

--- @param format? string strftime-like format or '*t' for table
--- @param timestamp? number default current time
--- @return string|table
function auxCalendar.formatGameTime(format, timestamp) end

--- @param monthIndex number
--- @return number
function auxCalendar.daysInMonth(monthIndex) end

--- @param monthIndex number
--- @return string
function auxCalendar.monthName(monthIndex) end

--- @param monthIndex number
--- @return string
function auxCalendar.monthNameInGenitive(monthIndex) end

--- @param dayIndex number
--- @return string
function auxCalendar.weekdayName(dayIndex) end

return auxCalendar
