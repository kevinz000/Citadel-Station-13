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
	movement_type = UNSTOPPABLE
	/// Our mobile docking port/shuttle
	var/obj/docking_port/mobile/shuttle

	/// Direction, currently only supports cardinals.
	var/rotation

	/// Velocity angle
	var/velocity_angle
	/// Velocity speed, in pixels per decisecond.
	var/velocity_speed

	// UH OH
	/// Allow collisions
	var/collisions = FALSE

/obj/structure/shuttle_holder/Initialize(mapload, obj/docking_port/mobile/our_shuttle)
	shuttle = our_shuttle
	. = ..()
	sync()

/obj/structure/shuttle_holder/Destroy()
	STOP_PROCESSING(SSprojectiles, src)
	return ..()

/**
  * Sets our position
  */
/obj/structure/shuttle_holder/proc/set_position(atom/location)
	forceMove(location)

/**
  * Sets our direction. Currently only supports cardinals
  */
/obj/structure/shuttle_holder/proc/set_rotation(degrees)
	degrees = SIMPLIFY_DEGREES(round(degrees, 90))
	rotation = angle2dir(degrees)
	updateTransform()

/**
  * Sets our velocity.
  */
/obj/structure/shuttle_holder/proc/set_velocity(vel_angle, vel_speed)
	velocity_angle = vel_angle
	velocity_speed = vel_speed
	update_velocity()

/**
  * Called on velocity being changed
  */
/obj/structure/shuttle_holder/proc/update_velocity()
	if(!velocity_speed)
		STOP_PROCESSING(SSprojectiles, src)
	else
		START_PROCESSING(SSprojectiles, src)

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
	M.Turn(dir2angle(rotation))
	transform = M

/obj/structure/shuttle_holder/process(wait)
	if(!velocity_speed || !isturf(loc))
		return PROCESS_KILL
	var/pixels = velocity_speed * ((SSprojectiles.flags & SS_TICKER)? (wait * world.tick_lag) : wait)
	pixelMove(pixels)

/**
  * On collision
  */
/obj/structure/shuttle_holder/proc/onCollision(atom/victim, turf/shuttle_turf_hit)
	if(isturf(victim))
		if(prob(70))
			victim.ex_act(2)
			shuttle_turf_hit.ex_act(2)
		else
			explosion(shuttle_turf_hit, heavy = 1, light = 3)
			explosion(victim, heavy = 2, light = 4)
	else if(isobj(victim))
		victim.ex_act(2)
	else if(ismob(victim))
		victim.ex_act(2)

/**
  * Moves us by x pixels.
  */
/obj/structure/shuttle_holder/proc/pixelMove(pixels)
	// no fancy trajectory datums like projectiles for now
	var/dx = sin(velocity_angle) * pixels
	var/dy = cos(velocity_angle) * pixels
	var/npx = pixel_x + dx
	var/npy = pixel_y + dy
	var/turf/T
	var/tx = loc.x
	var/ty = loc.y
	while(npx > (world.icon_size / 2))
		tx++
		npx -= world.icon_size
	while(npx < -(world.icon_size / 2))
		tx--
		npx += world.icon_size
	while(npy > (world.icon_size / 2))
		ty++
		npy -= world.icon_size
	while(npy < (world.icon_size / 2))
		ty--
		npy += world.icon_size
	T = locate(tx, ty, z)
	if(!T)
		return PROCESS_KILL
	var/px = (x - T.x) + pixel_x
	var/py = (y - T.y) + pixel_y
	var/safety = 10
	while(loc != T)
		if(safety-- == 0)
			CRASH("Attempted to move more than 10 times in one tick.")
		step_towards(src, T)
	pixel_x = px
	pixel_y = py
	animate(src, pixel_x = npx, pixel_y = npy, time = (SSprojectiles.flags & SS_TICKER)? (SSprojectiles.wait * world.tick_lag) : SSprojectiles.wait, flags = ANIMATION_END_NOW)

/obj/structure/shuttle_holder/Moved()
	. = ..()
	if(!collisions)
		return
	var/list/hitbox_turfs = collisionHitboxTurfs()
	for(var/turf/T in hitbox_turfs)
		if(isspaceturf(T))
			for(var/atom/A in T.contents)
				onCollision(A, hitbox_turfs[T])
			continue
		onCollision(T, hitbox_turfs[T])

/**
  * Get our collision. Returns a list of "real world" turf = shuttle turf
  */
/obj/structure/shuttle_holder/proc/collisionHitboxTurfs()


/**
  * Enables collisions
  */
/obj/structure/shuttle_holder/proc/enable_collisions()
	collisions = TRUE
