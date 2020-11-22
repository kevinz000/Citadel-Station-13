/// Are we using extools?
// #define OVERMAP_EXTOOLS_ENABLED

#ifdef OVERMAP_EXTOOLS_ENABLED
	#define OVERMAP_EXTOOLS_HOOK_CHECK var/static/warned=FALSE;if(!warned){warned=TRUE;stack_trace("WARNING: [THIS_PROC_NAME] wasn't hooked by extools properly while overmaps are in extools mode!"))}
#else
	#define OVERMAP_EXTOOLS_HOOK_CHECK
#endif

#define OVERMAP_MAXIMUM_SAFE_ELEMENTS 10000		// seriously 10000 lists is massive, never ever make more than that.

// Helpers
/// Gets the index of something based on its x and y and the size x/y of the overmap. WARNING: The very final upper edges must roll around, hence the < instead of <=.
#define OVERMAP_INDEX(x, y, size_x, size_y)							((((x >= 0) && (x < size_x)) && ((y >= 0) && (y < size_y)) && ((FLOOR(x, 1) + 1) * (FLOOR(y, 1) + 1))) || null)
#define OVERMAP_LIST_SIZE(size_x, size_y)							(size_x * size_y)
#define OVERMAP_WRAP(amount, max)									(abs(MODULUS(amount, max)))
