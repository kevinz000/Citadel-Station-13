// Overmap objects

/// We are not instantiated
#define OVERMAP_OBJECT_NOT_INSTANTIATED 0
/// We are currently instantiating
#define OVERMAP_OBJECT_INSTANTIATING 1
/// We are instantiated and in world
#define OVERMAP_OBJECT_INSTANTIATED 2

/// We are a virtual object with no presence in the physical game world
#define OVERMAP_OBJECT_VIRTUAL 0
/// We are a shuttle, which exists either docked or in dynamic transit.
#define OVERMAP_OBJECT_SHUTTLE 1
/// We are a physical z-level
#define OVERMAP_OBJECT_ZLEVEL 2
/// We are a specific area in the world that is not a shuttle but also not a whole zlevel
#define OVERMAP_OBJECT_AREA 3
