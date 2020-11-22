/**
  * Overmap object datum
  * 
  * All variables MUST be private
  * All field access MUST be procs
  * This makes it possible to move into C++ later
  */
/datum/overmap_object
	// Location
	/// What overmap we're on
	VAR_PRIVATE/datum/overmap/host
	VAR_PRIVATE/x
	VAR_PRIVATE/y

	// Physics
	/// Per second
	VAR_PRIVATE/speed
	/// Counterclockwise from north
	VAR_PRIVATE/angle
	// These two are centered on ourselves
	/// x hitbox
	VAR_PRIVATE/bound_x = 1
	/// y hitbox
	VAR_PRIVATE/bound_y = 1

/datum/overmap_object/New(datum/overmap/host, x, y, bound_x, bound_y)
	ASSERT(istype(host))
	ASSERT(!isnull(x))
	ASSERT(!isnull(y))
	set_bound_x(bound_x || src.bound_x)
	set_bound_y(bound_y || src.bound_y)
	set_overmap_and_move_to(host, x, y)

/datum/overmap_object/vv_get_var(var_name)
	. = ..()
	switch(var_name)
		if(NAMEOF(src, x))
			return get_x()
		if(NAMEOF(src, y))
			return get_y()
		if(NAMEOF(src, host))
			return get_overmap()
		if(NAMEOF(src, speed))
			return get_speed()
		if(NAMEOF(src, angle))
			return get_angle()
		if(NAMEOF(src, bound_x))
			return get_bound_x()
		if(NAMEOF(src, bound_y))
			return get_bound_y()

/datum/overmap_object/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, host))
			return set_overmap_and_move_to(var_value, get_x(), get_y())
		if(NAMEOF(src, x))
			return set_x(var_value)
		if(NAMEOF(src, y))
			return set_y(var_value)
		if(NAMEOF(src, speed))
			return set_speed(var_value)
		if(NAMEOF(src, angle))
			return set_angle(var_value)
		if(NAMEOF(src, bound_x))
			return set_bound_x(var_value)
		if(NAMEOF(src, bound_y))
			return set_bound_y(var_value)

/**
  * Gets our speed in units/second
  */
/datum/overmap_object/proc/get_speed()
	OVERMAP_EXTOOLS_HOOK_CHECK
	return speed

/**
  * Sets our speed in units/second
  */
/datum/overmap_object/proc/set_speed(new_speed)
	OVERMAP_EXTOOLS_HOOK_CHECK
	ASSERT(isnum(new_speed))
	speed = new_speed

/**
  * Gets our angle
  */
/datum/overmap_object/proc/get_angle()
	OVERMAP_EXTOOLS_HOOK_CHECK
	return angle

/**
  * Sets our angle
  */
/datum/overmap_object/proc/set_angle(new_angle)
	OVERMAP_EXTOOLS_HOOK_CHECK
	ASSERT(isnum(new_angle))
	angle = new_angle

/**
  * Gets our overmap
  */
/datum/overmap_object/proc/get_overmap()
	OVERMAP_EXTOOLS_HOOK_CHECK
	return host

/**
  * Sets our overmap and moves us to a certain location on it.
  */
/datum/overmap_object/proc/set_overmap_and_move_to(datum/overmap/new_map, new_x, new_y)
	OVERMAP_EXTOOLS_HOOK_CHECK
	host?.

/**
  * Gets our x coordinate in units
  */
/datum/overmap_object/proc/get_x()
	OVERMAP_EXTOOLS_HOOK_CHECK
	return x

/**
  * Gets our y coordinate in units
  */
/datum/overmap_object/proc/get_y()
	OVERMAP_EXTOOLS_HOOK_CHECK
	return y

/**
  * Sets our x coordinate in units
  */
/datum/overmap_object/proc/set_x(new_x, host_initiated)
	OVERMAP_EXTOOLS_HOOK_CHECK
	if(host_initiated)
		x = new_x
		return
	host?.

/**
  * Sets our y coordinate in units
  */
/datum/overmap_object/proc/set_y(new_y, host_initiated)
	OVERMAP_EXTOOLS_HOOK_CHECK
	if(host_initiated)
		y = new_y
		return
	host?.

/**
  * Gets our bound x
  */
/datum/overmap_object/proc/get_bound_x()
	OVERMAP_EXTOOLS_HOOK_CHECK
	return bound_x

/**
  * Gets our bound y
  */
/datum/overmap_object/proc/get_bound_y()
	OVERMAP_EXTOOLS_HOOK_CHECK
	return bound_y

/**
  * Sets our bound x
  */
/datum/overmap_object/proc/set_bound_x(new_x)
	OVERMAP_EXTOOLS_HOOK_CHECK
	ASSERT(isnum(new_x))
	bound_x = new_x
	host?.

/**
  * Sets our bound y
  */
/datum/overmap_object/proc/set_bound_y(new_y)
	OVERMAP_EXTOOLS_HOOK_CHECK
	ASSERT(isnum(new_y))
	bound_y = new_y
	host?.

/**
  * Checks what's intersecting us
  */
/datum/overmap_object/proc/get_intersecting()
	OVERMAP_EXTOOLS_HOOK_CHECK
	return host.get_intersecting(src)
