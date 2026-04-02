
--- @class COLLISION_TYPE_ENUM
--- @field World number
--- @field Door number
--- @field Actor number
--- @field HeightMap number
--- @field Projectile number
--- @field Water number
--- @field Default number
--- @field AnyPhysical number
--- @field Camera number
--- @field VisualOnly number

--- @class NAVIGATOR_FLAGS_ENUM
--- @field Walk number
--- @field Swim number
--- @field OpenDoor number
--- @field UsePathgrid number

--- @class COLLISION_SHAPE_TYPE_ENUM
--- @field Aabb number
--- @field RotatingBox number
--- @field Cylinder number

--- @class FIND_PATH_STATUS_ENUM
--- @field Success number
--- @field PartialPath number
--- @field NavMeshNotFound number
--- @field StartPolygonNotFound number
--- @field EndPolygonNotFound number
--- @field TargetPolygonNotFound number
--- @field MoveAlongSurfaceFailed number
--- @field FindPathOverPolygonsFailed number
--- @field InitNavMeshQueryFailed number
--- @field FindStraightPathFailed number

--- @class RayCastingResult
--- @field hit boolean
--- @field hitPos Vector3|nil
--- @field hitNormal Vector3|nil
--- @field hitObject GameObject|nil

--- @class AgentBounds
--- @field shapeType number COLLISION_SHAPE_TYPE value
--- @field halfExtents Vector3

--- @class AreaCosts
--- @field swim number
--- @field walk number
--- @field door number
--- @field pathgrid number

--- @class FindPathOptions
--- @field agentBounds? AgentBounds
--- @field areaCosts? AreaCosts
--- @field destinationTolerance? number
--- @field flags? number NAVIGATOR_FLAGS

--- @class openmw_nearby
--- @field activators GameObject[]
--- @field actors GameObject[]
--- @field containers GameObject[]
--- @field doors GameObject[]
--- @field items GameObject[]
--- @field players GameObject[]
--- @field COLLISION_TYPE COLLISION_TYPE_ENUM
--- @field NAVIGATOR_FLAGS NAVIGATOR_FLAGS_ENUM
--- @field COLLISION_SHAPE_TYPE COLLISION_SHAPE_TYPE_ENUM
--- @field FIND_PATH_STATUS FIND_PATH_STATUS_ENUM
local nearby = {}

--- @param formId string
--- @return GameObject
function nearby.getObjectByFormId(formId) end

--- @param from Vector3
--- @param to Vector3
--- @param options? {ignore:GameObject, collisionType:number, radius:number}
--- @return RayCastingResult
function nearby.castRay(from, to, options) end

--- @param from Vector3
--- @param to Vector3
--- @param options? {ignore:GameObject}
--- @return RayCastingResult
function nearby.castRenderingRay(from, to, options) end

--- @param callback function
--- @param from Vector3
--- @param to Vector3
--- @param options? table
function nearby.asyncCastRenderingRay(callback, from, to, options) end

--- @param source Vector3
--- @param destination Vector3
--- @param options? FindPathOptions
--- @return number, Vector3[] status and path
function nearby.findPath(source, destination, options) end

--- @param position Vector3
--- @param maxRadius number
--- @param options? table
--- @return Vector3|nil
function nearby.findRandomPointAroundCircle(position, maxRadius, options) end

--- @param from Vector3
--- @param to Vector3
--- @param options? table
--- @return Vector3|nil
function nearby.castNavigationRay(from, to, options) end

--- @param position Vector3
--- @param options? table
--- @return Vector3|nil
function nearby.findNearestNavMeshPosition(position, options) end

return nearby
