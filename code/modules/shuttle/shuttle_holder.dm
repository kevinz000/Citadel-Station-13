/**
  * Object that "holds" a shuttle.
  * Used for shuttle piloting in "realspace" and crashing because
  * moving an entire area 10 times a second is a little
  * CPU-murdering, eh?
  */
/obj/structure/shuttle_holder
	name = "Shuttle"
	desc = "OH GOD OH F-"
	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE
	/// Our mobile docking port/shuttle
	var/obj/docking_port/mobile/shuttle
	/// Rotation in degrees
	var/rotation = 0

/obj/structure/shuttle_holder/Initialize(mapload, obj/docking_port/mobile/shuttle/our_shuttle)
	shuttle = our_shuttle
	. = ..()
	sync()

/obj/structure/shuttle_holder/proc/set_position(atom/location, rotation_degrees)
	rotation = rotation_degrees
	forceMove(location)
	updateTransform()

/**
  * Syncs us with our host shuttle.
  */
/obj/structure/shuttle_holder/proc/sync()
	ASSERT(shuttle)
	sync_visuals()

/**
  * Syncs our visuals with our host shuttle.
  */
/obj/structure/shuttle_holder/proc/sync_visuals()
	vis_contents = shuttle.return_turfs()

/**
  * Update transform and make sure we're turned the right way.
  */
/obj/structure/shuttle_holder/proc/updateTransform()
	var/matrix/M = matrix()
	M.Turn(rotation)
	transform = M
