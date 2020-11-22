/**
  * Overmap datum
  *
  * All access/modifications MUST be in procs
  * All variables MUSt be private
  * This makes it possible to move into C++ later
  */
/datum/overmap
	/// Are we initialized?
	VAR_PRIVATE/initialized = FALSE
	/// Our objects
	VAR_PRIVATE/list/overmap_object/objects
	/// Our size in x
	VAR_PRIVATE/size_x
	/// Our size in y
	VAR_PRIVATE/size_y
	/// Our array grid array size
	VAR_PRIVATE/array_size
	/// Our grid. sparse grid system, [index] = lazylist(elements) OR singular element OR null. index is calculated using OVERMAP_INDEX(x, y, sizex, sizey)
	VAR_PRIVATE/grid

/**
  * Initializes the overmap to a certain size.
  */
/datum/overmap/proc/Initialize(array_size_x, array_size_y, grid_multiplier)
	OVERMAP_EXTOOLS_HOOK_CHECK
	if(initialized)
		CRASH("Attempted to re-initialize overmap.");
	var/total_size = array_size_x * array_size_y
	if(total_size > OVERMAP_SAFE_ARRAY_MAXIMUM_ELEMENTS)
		CRASH("[total_size] ([array_size_x]x[array_size_y]) is over the defined limit of [OVERMAP_SAFE_ARRAY_MAXIMUM_ELEMENTS]. Aborting overmap initialization.")
	grid = list()
	grid.len = src.array_size_x = array_size_x
	src.array_size_y = array_size_y
	var/list/L
	for(var/x in grid)
		grid[x] = L = list()
		L.len = array_size_y
	initialized = TRUE
