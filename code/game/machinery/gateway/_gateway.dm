/obj/machinery/gateway
	name = "gateway"
	desc = "A mysterious gateway built by unknown hands, it allows for faster than light travel to far-flung locations."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "null"
	density = FALSE
	active_power_usage = 0
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/gateway/throw_at()
	return

/obj/machinery/gateway/forceMove(atom/destination)
	cleanup()
	. = ..()
	if(!build())
		CRASH("Hey some idiot forceMove'd [src] and it was unable to rebuild in the new location, this will cause problems!")

/obj/machinery/gateway/center
	icon = 'icons/obj/machines/gateway96x96.dmi'
	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE
	/// Are we active?
	var/state = GATEWAY_OFF
	/// Outer ring pieces, including receivers.
	var/list/obj/machinery/gateway/ring/ring_pieces = list()
	/// Receiving teleporting pieces
	var/list/obj/machinery/gateway/ring/receiver/ring_receivers = list()
	/// The size of our center, as radius. 1 is 1x1, 2 is 3x3, 3 is 5x5, so on.
	var/center_size = 1

/obj/machinery/gateway/center/Initialize(mapload)
	build()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/gateway/center/LateInitialize()
	init_autobuild? autobuild() : partcheck()

/obj/machinery/gateway/center/Destroy()
	cleanup()
	return ..()

/obj/machinery/gateway/center/proc/cleanup()
	QDEL_LIST(ring_pieces)
	ring_receivers = list()

/obj/machinery/gateway/center/proc/get_receiving_turfs()
	. = list()
	for(var/i in ring_receivers)
		var/obj/machinery/gateway/ring/receiver/R = i
		if(R.loc)
			. += R.loc

#define CHECK_TURF(turf) \
	if(!turf){ \
		cleanup(); \
		CRASH("Invalid turf or out of bounds of world, autobuild proc stopped."); \
	} \
	else if(locate(/obj/machinery/gateway) in T){ \
		cleanup(); \
		CRASH("Gateway location conflicting, autobuild proc stopped."); \
	}
/obj/machinery/gateway/center/proc/build()
	cleanup()		//just in case
	ring_pieces = list()
	ring_receivers = list()
	// Check all turfs
	for(var/turf/T in range(src, center_size))
		if(locate(/obj/machinery/gateway) in T)
			CRASH("Gateway location conflicting, autobuild proc stopped.")
	var/list/turfs_ring = list()
	var/list/turfs_entrance = list()
	var/radius = center_size - 1
	var/turf/T
	for(var/xcrd in x - radius to x + radius)
		turfs_entrance += (T = locate(xcrd, y - center_size, z))
		CHECK_TURF(T)
	for(var/xcrd in x - center_size to x + center_size)
		turfs_ring += (T = locate(xcrd, y + center_size, z))
		CHECK_TURF(T)
	for(var/ycrd in y - radius to y + radius)
		turfs_ring += (T = locate(x - center_size, ycrd, z))
		CHECK_TURF(T)
		turfs_ring += (T = locate(x + center_size, ycrd, z))
		CHECK_TURF(T)
	var/obj/machinery/gateway/ring/R
	for(var/i in turfs_ring)
		R = new /obj/machinery/gateway/ring(i)
		ring_pieces += R
		R.parent = src
	for(var/i in turfs_entrance)
		R = new /obj/machinery/gateway/ring/receiver(i)
		ring_pieces += R
		ring_receivers += R
		R.parent = src
	set_bound_size()
	update_transform()
#undef CHECK_TURF

/obj/machinery/gateway/center/proc/set_state(new_state)
	state = new_state
	update_icon()

/obj/machinery/gateway/center/update_icon_state()
	switch(state)
		if(GATEWAY_OFF)
			icon_state = "off"
		if(GATEWAY_ON)
			icon_state = "on"

/obj/machinery/gateway/center/proc/set_bound_size()
	bound_width = bound_height = (((center_size - 1) * 2) + 1) * world.icon_size + world.icon_size * 2
	bound_x = bound_y = -((center_size - 1) * world.icon_size)

/obj/machinery/gateway/center/proc/update_transform()
	pixel_x = pixel_y = -((center_size - 1) * world.icon_size)
	var/factor = ((((center_size - 1) * 2) + 1) * world.icon_size + world.icon_size * 2) / 96		// 96 is our .dmi icon size
	transform = matrix(factor, 0, 0, 0, factor, 0)

/obj/machinery/gateway/center/Bumped(atom/movable/AM)
	. = ..()
	try_teleport(AM)

/obj/machinery/gateway/center/proc/try_teleport(atom/movable/AM)
	var/obj/machinery/gateway/center/C = get_destination_gateway(AM)
	if(!C)
		return
	return teleport_sequence(AM, C)

/obj/machinery/gateway/center/proc/get_destination_gateway(atom/movable/AM)
	return

/obj/machinery/gateway/center/proc/after_teleport_receive(atom/movable/AM)
	return

/obj/machinery/gateway/center/proc/can_teleport_receive(atom/movable/AM)
	return TRUE

/obj/machinery/gateway/center/proc/can_teleport_send(atom/movable/AM)
	return TRUE

/obj/machinery/gateway/center/proc/before_teleport_send(atom/movable/AM)
	return

/obj/machinery/gateway/center/proc/before_teleport_receive(atom/movable/AM)
	return

/obj/machinery/gateway/center/proc/after_teleport_send(atom/movable/AM)
	return

/obj/machinery/gateway/center/proc/teleport_sequence(atom/movable/AM, obj/machinery/gateway/center/other)
	if(!other)
		return FALSE
	. = other.can_teleport_receive(AM)
	if(!.)
		return
	// before moving
	before_teleport_send(AM)
	other.before_teleport_receive(AM)
	// move them
	var/list/turf/valid = other.get_receiving_turfs()
	var/turf/T = SAFEPICK(valid)
	if(!T)
		. = FALSE
		CRASH("[src] was unable to send [AM] to [other] due to no receiving turfs being returned by the destination! This is bad!")
	AM.forceMove(T)
	after_teleport_send(AM)
	other.after_teleport_receive(AM)

/**
  * Handles ring piece deletion. Really shouldn't happen outside of singularity memes.
  */
/obj/machinery/gateway/center/proc/handle_ring_deletion(obj/machinery/gateway/ring/R)
	ring_pieces -= R
	ring_receivers -= R

/obj/machinery/gateway/center/big
	center_size = 2

/obj/machinery/gateway/ring
	density = TRUE
	/// Our center "parent" gateway.
	var/obj/structure/gateway/center/parent

/obj/machinery/gateway/ring/receiver
	density = FALSE

/obj/machinery/gateway/ring/Destroy()
	parent.ring_piece_deleted(src)
	parent = null
	return ..()

/**
  * Actual away mission station/away gates.
  */
/obj/machinery/gateway/center/away_mission


GLOBAL_DATUM(the_station_gateway, /obj/machinery/gateway/center/away_mission/station)
/obj/machinery/gateway/center/away_mission/station
	/// The gateway on the away misison
	var/obj/machinery/gateway/center/away_mission/away/awaygate
	/// world.time at which we can be activated by players
	var/activation_lockout_until = 0

/obj/machinery/gateway/center/away_mission/station/Initialize(mapload)
	if(!GLOB.the_station_gateway)
		GLOB.the_station_gateway = src
	awaygate = locate()
	activation_lockout_until = SSticker.round_start_time + CONFIG_GET(number/gateway_delay)
	return ..()

/obj/machinery/gateway/center/away_mission/away
	/// Is this calibrated? If so new adventurers will go to this gate instead of being strewn around the map.
	var/calibrated = FALSE
	/// Random spawns for noncalibrated mode.
	var/list/obj/effect/landmark/randomspawns

/obj/machinery/gateway/center/away_mission/away/Initialize(mapload)
	randomspawns = GLOB.awaydestinations
	return ..()

/obj/machinery/gateway/center/away_mission/away/get_destination_gateway(atom/movable/AM)
	return GLOB.the_station_gateway

/obj/machinery/gateway/center/away_mission/away/get_receiving_turfs()
	if(!length(randomspawns))
		return ..()
	. = list()
	for(var/i in randomspawns)
		. += get_turf(i)



GLOBAL_DATUM(the_gateway, /obj/machinery/gateway/centerstation)
	var/list/obj/effect/landmark/randomspawns = list()
	var/calibrated = TRUE


/obj/machinery/gateway/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!detect())
		return
	if(!active)
		toggleon(user)
		return
	toggleoff()

/obj/machinery/gateway/proc/toggleon(mob/user)
	return FALSE

/obj/machinery/gateway/centerstation/Destroy()
	if(GLOB.the_gateway == src)
		GLOB.the_gateway = null
	return ..()

//this is da important part wot makes things go
/obj/machinery/gateway/centerstation
	density = TRUE
	icon_state = "offcenter"
	use_power = IDLE_POWER_USE

	//warping vars
	var/wait = 0				//this just grabs world.time at world start
	var/obj/machinery/gateway/centeraway/awaygate = null
	can_link = TRUE

/obj/machinery/gateway/centerstation/update_icon_state()
	icon_state = active ? "oncenter" : "offcenter"

/obj/machinery/gateway/centerstation/process()
	if((stat & (NOPOWER)) && use_power)
		if(active)
			toggleoff()
		return

	if(active)
		use_power(5000)

/obj/machinery/gateway/centerstation/toggleon(mob/user)
	if(!detect())
		return
	if(!powered())
		return
	if(!awaygate)
		to_chat(user, "<span class='notice'>Error: No destination found.</span>")
		return
	if(world.time < wait)
		to_chat(user, "<span class='notice'>Error: Warpspace triangulation in progress. Estimated time to completion: [DisplayTimeText(wait - world.time)].</span>")
		return

	for(var/obj/machinery/gateway/G in linked)
		G.active = 1
		G.update_icon()
	active = 1
	update_icon()

//okay, here's the good teleporting stuff
/obj/machinery/gateway/centerstation/Bumped(atom/movable/AM)
	if(!active)
		return
	if(!detect())
		return
	if(!awaygate || QDELETED(awaygate))
		return

	if(awaygate.calibrated)
		AM.forceMove(get_step(awaygate.loc, SOUTH))
		AM.setDir(SOUTH)
		if (ismob(AM))
			var/mob/M = AM
			if (M.client)
				M.client.move_delay = max(world.time + 5, M.client.move_delay)
		return
	else
		var/obj/effect/landmark/dest = pick(randomspawns)
		if(dest)
			AM.forceMove(get_turf(dest))
			AM.setDir(SOUTH)
			use_power(5000)
		return

/obj/machinery/gateway/centeraway/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/multitool))
		if(calibrated)
			to_chat(user, "\black The gate is already calibrated, there is no work for you to do here.")
			return
		else
			to_chat(user, "<span class='boldnotice'>Recalibration successful!</span>: \black This gate's systems have been fine tuned.  Travel to this gate will now be on target.")
			calibrated = TRUE
			return

/////////////////////////////////////Away////////////////////////


/obj/machinery/gateway/centeraway
	density = TRUE
	icon_state = "offcenter"
	use_power = NO_POWER_USE
	var/obj/machinery/gateway/centerstation/stationgate = null
	can_link = TRUE


/obj/machinery/gateway/centeraway/Initialize()
	. = ..()
	update_icon()
	stationgate = locate(/obj/machinery/gateway/centerstation)


/obj/machinery/gateway/centeraway/update_icon_state()
	icon_state = active ? "oncenter" : "offcenter"

/obj/machinery/gateway/centeraway/toggleon(mob/user)
	if(!detect())
		return
	if(!stationgate)
		to_chat(user, "<span class='notice'>Error: No destination found.</span>")
		return

/obj/machinery/gateway/centeraway/proc/check_exile_implant(mob/living/L)
	for(var/obj/item/implant/exile/E in L.implants)//Checking that there is an exile implant
		to_chat(L, "\black The station gate has detected your exile implant and is blocking your entry.")
		return TRUE
	return FALSE

/obj/machinery/gateway/centeraway/Bumped(atom/movable/AM)
	if(!detect())
		return
	if(!active)
		return
	if(!stationgate || QDELETED(stationgate))
		return
	if(isliving(AM))
		if(check_exile_implant(AM))
			return
	else
		for(var/mob/living/L in AM.contents)
			if(check_exile_implant(L))
				say("Rejecting [AM]: Exile implant detected in contained lifeform.")
				return
	if(AM.has_buckled_mobs())
		for(var/mob/living/L in AM.buckled_mobs)
			if(check_exile_implant(L))
				say("Rejecting [AM]: Exile implant detected in close proximity lifeform.")
				return
	AM.forceMove(get_step(stationgate.loc, SOUTH))
	AM.setDir(SOUTH)
	if (ismob(AM))
		var/mob/M = AM
		if (M.client)
			M.client.move_delay = max(world.time + 5, M.client.move_delay)


/obj/machinery/gateway/centeraway/admin
	desc = "A mysterious gateway built by unknown hands, this one seems more compact."

/obj/machinery/gateway/centeraway/admin/Initialize()
	. = ..()
	if(stationgate && !stationgate.awaygate)
		stationgate.awaygate = src

/obj/machinery/gateway/centeraway/admin/detect()
	return TRUE


/obj/item/paper/fluff/gateway
	info = "Congratulations,<br><br>Your station has been selected to carry out the Gateway Project.<br><br>The equipment will be shipped to you at the start of the next quarter.<br> You are to prepare a secure location to house the equipment as outlined in the attached documents.<br><br>--Nanotrasen Blue Space Research"
	name = "Confidential Correspondence, Pg 1"
