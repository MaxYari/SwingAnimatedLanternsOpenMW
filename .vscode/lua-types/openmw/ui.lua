
--- @class UI_TYPE_ENUM
--- @field Widget string
--- @field Text string
--- @field TextEdit string
--- @field Window string
--- @field Image string
--- @field Flex string
--- @field Container string

--- @class UI_ALIGNMENT_ENUM
--- @field Start number 0
--- @field Center number 1
--- @field End number 2

--- @class UI_CONSOLE_COLOR_ENUM
--- @field Default any
--- @field Error any
--- @field Success any
--- @field Info any

--- @class TextureResource
--- @field path string
--- @field offset Vector2
--- @field size Vector2

--- @class Layer
--- @field name string
--- @field size Vector2

--- @class LayersModule
local LayersModule = {}
--- @param name string
--- @return number
function LayersModule.indexOf(name) end
--- @param name string
--- @param layerDef {name:string, isMenu:boolean}
function LayersModule.insertAfter(name, layerDef) end
--- @param name string
--- @param layerDef {name:string, isMenu:boolean}
function LayersModule.insertBefore(name, layerDef) end

--- @class Content
local Content = {}
--- @param index number
--- @param layout table
function Content:insert(index, layout) end
--- @param layout table
function Content:add(layout) end
--- @param name string
--- @return number
function Content:indexOf(name) end

--- @class Element
--- @field layout table
local Element = {}
function Element:update() end
function Element:destroy() end

--- @class MouseEvent
--- @field position Vector2
--- @field offset Vector2
--- @field button number

--- @class openmw_ui
--- @field TYPE UI_TYPE_ENUM
--- @field ALIGNMENT UI_ALIGNMENT_ENUM
--- @field CONSOLE_COLOR UI_CONSOLE_COLOR_ENUM
--- @field layers LayersModule
local ui = {}

--- @param text string
--- @param options? {duration:number}
function ui.showMessage(text, options) end

--- @param text string
--- @param color any CONSOLE_COLOR value
function ui.printToConsole(text, color) end

--- @param mode string
function ui.setConsoleMode(mode) end

--- @param obj GameObject
function ui.setConsoleSelectedObject(obj) end

--- @return Vector2
function ui.screenSize() end

--- @param items table[]
--- @return Content
function ui.content(items) end

--- @param layout table
--- @return Element
function ui.create(layout) end

--- @param page table
function ui.registerSettingsPage(page) end

--- @param page table
function ui.removeSettingsPage(page) end

function ui.updateAll() end

--- @param options {path:string, offset?:Vector2, size?:Vector2}
--- @return TextureResource
function ui.texture(options) end

return ui
