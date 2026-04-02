
--- @class CAMERA_MODE_ENUM
--- @field Static number
--- @field FirstPerson number
--- @field ThirdPerson number
--- @field Vanity number
--- @field Preview number

--- @class openmw_camera
--- @field MODE CAMERA_MODE_ENUM
local camera = {}

--- @return number MODE value
function camera.getMode() end
--- @return number|nil MODE value
function camera.getQueuedMode() end
--- @param mode number MODE value
--- @param force? boolean
function camera.setMode(mode, force) end

--- @param val boolean
function camera.allowCharacterDeferredRotation(val) end
--- @param val boolean
function camera.showCrosshair(val) end

--- @return Vector3
function camera.getTrackedPosition() end
--- @return Vector3
function camera.getPosition() end
--- @return number radians
function camera.getPitch() end
--- @param val number
function camera.setPitch(val) end
--- @return number radians
function camera.getYaw() end
--- @param val number
function camera.setYaw(val) end
--- @return number radians
function camera.getRoll() end
--- @param val number
function camera.setRoll(val) end

--- @return number
function camera.getExtraPitch() end
--- @param val number
function camera.setExtraPitch(val) end
--- @return number
function camera.getExtraYaw() end
--- @param val number
function camera.setExtraYaw(val) end
--- @return number
function camera.getExtraRoll() end
--- @param val number
function camera.setExtraRoll(val) end

--- @param pos Vector3
function camera.setStaticPosition(pos) end

--- @return Vector3
function camera.getFirstPersonOffset() end
--- @param v Vector3
function camera.setFirstPersonOffset(v) end

--- @return Vector3
function camera.getFocalPreferredOffset() end
--- @param v Vector3
function camera.setFocalPreferredOffset(v) end
--- @return number
function camera.getThirdPersonDistance() end
--- @param d number
function camera.setPreferredThirdPersonDistance(d) end
--- @return number
function camera.getFocalTransitionSpeed() end
--- @param speed number
function camera.setFocalTransitionSpeed(speed) end
function camera.instantTransition() end

--- @return number COLLISION_TYPE value
function camera.getCollisionType() end
--- @param ct number COLLISION_TYPE value
function camera.setCollisionType(ct) end

--- @return number radians
function camera.getBaseFieldOfView() end
--- @return number radians
function camera.getFieldOfView() end
--- @param fov number radians
function camera.setFieldOfView(fov) end

--- @return number
function camera.getBaseViewDistance() end
--- @return number
function camera.getViewDistance() end
--- @param d number
function camera.setViewDistance(d) end

--- @return Transform
function camera.getViewTransform() end
--- @param v Vector2
--- @return Vector3
function camera.viewportToWorldVector(v) end
--- @param v Vector3
--- @return Vector2
function camera.worldToViewportVector(v) end

return camera
