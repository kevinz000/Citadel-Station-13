/**
  * Overmap datum
  *
  * All access/modifications MUST be in procs
  * All variables MUSt be private
  * This makes it possible to move into C++ later
  */
/datum/overmap
	/// Are we initialized?
	PRIVATE_VAR(initialized) = FALSE
	/// Our objects
	PRIVATE_VAR(list/overmap_object/objects)
	/// Our size in x
	PRIVATE_VAR(size_x)
	/// Our size in y
	PRIVATE_VAR(size_y)
	/// Our grid distance multiplier factor. Higher values reduce memory usage but make collision detections more costly.
	PRIVATE_VAR(grid_multiplier)
	/// Our array grid size in x
	PRIVATE_VAR(array_size_x)
	/// Our array grid size in y
	PRIVATE_VAR(array_size_y)
	/// Our grid. 2 dimensional list[x][y] = lazylist(elements) OR singular element
	PRIVATE_VAR(grid)

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
