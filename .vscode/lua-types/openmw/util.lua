
--- @class Vector2
--- @field x number
--- @field y number
local Vector2 = {}
--- @return number
function Vector2:length() end
--- @return number
function Vector2:length2() end
--- @return Vector2
function Vector2:normalize() end
--- @param angle number
--- @return Vector2
function Vector2:rotate(angle) end
--- @param other Vector2
--- @return number
function Vector2:dot(other) end
--- @param other Vector2
--- @return Vector2
function Vector2:emul(other) end
--- @param other Vector2
--- @return Vector2
function Vector2:ediv(other) end

--- @class Vector3
--- @field x number
--- @field y number
--- @field z number
local Vector3 = {}
--- @return number
function Vector3:length() end
--- @return number
function Vector3:length2() end
--- @return Vector3
function Vector3:normalize() end
--- @param other Vector3
--- @return number
function Vector3:dot(other) end
--- @param other Vector3
--- @return Vector3
function Vector3:cross(other) end
--- @param other Vector3
--- @return Vector3
function Vector3:emul(other) end
--- @param other Vector3
--- @return Vector3
function Vector3:ediv(other) end

--- @class Vector4
--- @field x number
--- @field y number
--- @field z number
--- @field w number
local Vector4 = {}
--- @return number
function Vector4:length() end
--- @return number
function Vector4:length2() end
--- @return Vector4
function Vector4:normalize() end
--- @param other Vector4
--- @return number
function Vector4:dot(other) end
--- @param other Vector4
--- @return Vector4
function Vector4:emul(other) end
--- @param other Vector4
--- @return Vector4
function Vector4:ediv(other) end

--- @class Color
--- @field r number 0.0-1.0
--- @field g number 0.0-1.0
--- @field b number 0.0-1.0
--- @field a number 0.0-1.0
local Color = {}
--- @return table
function Color:asRgba() end
--- @return table
function Color:asRgb() end
--- @return string
function Color:asHex() end

--- @class Transform
local Transform = {}
--- @return Transform
function Transform:inverse() end
--- @param v Vector3
--- @return Vector3
function Transform:apply(v) end
--- @return number
function Transform:getYaw() end
--- @return number
function Transform:getPitch() end
--- @return number, number
function Transform:getAnglesXZ() end
--- @return number, number, number
function Transform:getAnglesZYX() end

--- @class Box
--- @field center Vector3
--- @field halfSize Vector3
local Box = {}
--- @param t Transform
--- @return Box
function Box:transform(t) end
--- @return Vector3[]
function Box:vertices() end

--- @class ColorFactory
local ColorFactory = {}
--- @param r number
--- @param g number
--- @param b number
--- @param a number
--- @return Color
function ColorFactory.rgba(r, g, b, a) end
--- @param r number
--- @param g number
--- @param b number
--- @return Color
function ColorFactory.rgb(r, g, b) end
--- @param hex string e.g. "FF0000" or "FF0000FF"
--- @return Color
function ColorFactory.hex(hex) end
--- @param s string e.g. "255, 0, 0"
--- @return Color
function ColorFactory.commaString(s) end

--- @class TransformFactory
--- @field identity Transform
local TransformFactory = {}
--- @param v Vector3
--- @return Transform
function TransformFactory.move(v) end
--- @param v Vector3
--- @return Transform
function TransformFactory.scale(v) end
--- @param angle number
--- @param axis Vector3
--- @return Transform
function TransformFactory.rotate(angle, axis) end
--- @param angle number
--- @return Transform
function TransformFactory.rotateX(angle) end
--- @param angle number
--- @return Transform
function TransformFactory.rotateY(angle) end
--- @param angle number
--- @return Transform
function TransformFactory.rotateZ(angle) end

--- @class openmw_util
--- @field color ColorFactory
--- @field transform TransformFactory
local util = {}

--- @param x number
--- @return integer
function util.round(x) end

--- @param x number
--- @param min1 number
--- @param max1 number
--- @param min2 number
--- @param max2 number
--- @return number
function util.remap(x, min1, max1, min2, max2) end

--- @param x number
--- @param min number
--- @param max number
--- @return number
function util.clamp(x, min, max) end

--- @param angle number
--- @return number
function util.normalizeAngle(angle) end

--- @param t table
--- @return table
function util.makeReadOnly(t) end

--- @param t table
--- @return table
function util.makeStrictReadOnly(t) end

--- @param code string
--- @param env table
--- @return function
function util.loadCode(code, env) end

--- @param a integer
--- @param b integer
--- @return integer
function util.bitAnd(a, b) end

--- @param a integer
--- @param b integer
--- @return integer
function util.bitOr(a, b) end

--- @param a integer
--- @param b integer
--- @return integer
function util.bitXor(a, b) end

--- @param a integer
--- @return integer
function util.bitNot(a) end

--- @param x number
--- @param y number
--- @return Vector2
function util.vector2(x, y) end

--- @param x number
--- @param y number
--- @param z number
--- @return Vector3
function util.vector3(x, y, z) end

--- @param x number
--- @param y number
--- @param z number
--- @param w number
--- @return Vector4
function util.vector4(x, y, z, w) end

--- @param center Vector3
--- @param halfSize Vector3
--- @return Box
function util.box(center, halfSize) end

return util
