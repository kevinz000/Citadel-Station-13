/**
 * Base type of anything that physically exists on an overmap, from projectiles to ships to planets.
 */
/datum/overmap_object
	/// Icon state of this object. Must be in reference to one of the preset/asset files for overmaps, otherwise it won't be sent to the UI. The sprite will be centered.
	var/icon_state = "unknown"
	/// Is this object tile bound? If true, it occupies one overmap tile and only one overmap tile.
	var/tile_bound = FALSE
	/// Width, in tiles, for collision detection. Ignored if tile bound.
	var/size_x = 0.5
	/// Height, in tiles, for collision detection. Ignored if tile bound.
	var/size_y = 0.5


/**
 * Do we represent something in the BYOND world?
 */
/datum/overmap_object/proc/is_physical()
	return OVERMAP_OBJECT_VIRTUAL

/**
 * Assuming we do represent something in the BYOND world, are we loaded in?
 */
/datum/overmap_object/proc/map_instantiated()
	return OVERMAP_OBJECT_NOT_INSTANTIATED

/**
 * Get our physical representation.
 *
 * The return value of this should be determined by what is_physical() returns.
 * If we are a shuttle, this gets our docking port.
 * If we are an area, this returns our area.
 * If we are a zlevel this returns a space_level datum.
 */
/datum/overmap_object/proc/get_physical_space()
	CRASH("Attempted to get the physical manifestation of a virtual overmap object.")

/**
 * Overmap object that corrosponds to non-hitscan projectiles.
 */
/datum/overmap_object/projectile

/**
 * Overmap object that corrosponds to an overmap shuttle.
 */
/datum/overmap_object/shuttle
	/// Our physical shuttle, if it exists
	var/obj/docking_port/mobile/overmap/shuttle

/datum/overmap_object/shuttle/is_physical()
	return TRUE

/datum/overmap_object/shuttle/map_instantiated()
	return TRUE
