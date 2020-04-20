/**
  * # Map Module Datums
  *
  * Map modules are datums for more complicated code handling of specific map features than what simple varedits can provide.
  *
  * This datum is mostly meant for stuff like map functions that require regular subsystem processing, special initialization requirements,
  * special "endgame" requirements (like overriding using an emergency shuttle), etc etc.
  *
  */
/datum/map_module
	/// Whether or not we require processing. If we don't, SSmapping will apply SS_NO_FIRE at init.
	var/requires_processing = FALSE

/// Called right before maploading in LoadWorld() begins.
/datum/map_module/proc/before_mapload()
	return

/// Called right after maploading finishes from LoadWorld(), before atom initialization.
/datum/map_module/proc/after_mapload()
	return

/// Called on SSatoms initialization finish.
/datum/map_module/proc/after_atoms_init()
	return

/// Called on roundstart, after roundstart.
/datum/map_module/proc/on_roundstart()
	return

/// Called by SSmapping every second.
/datum/map_module/process()
	return


