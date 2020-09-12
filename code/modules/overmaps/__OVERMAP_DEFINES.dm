/// Are we using extools?
// #define OVERMAP_EXTOOLS_ENABLED

#ifdef OVERMAP_EXTOOLS_ENABLED
	#define OVERMAP_EXTOOLS_HOOK_CHECK var/static/warned=FALSE;if(!warned){warned=TRUE;stack_trace("WARNING: [THIS_PROC_NAME] wasn't hooked by extools properly while overmaps are in extools mode!"))}
#else
	#define OVERMAP_EXTOOLS_HOOK_CHECK
#endif

#define OVERMAP_MAXIMUM_SAFE_ELEMENTS 10000		// seriously 10000 lists is massive, never ever make more than that.
