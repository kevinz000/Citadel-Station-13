// So much of atmospherics.dm was used solely by components, so separating this makes things all a lot cleaner.
// On top of that, now people can add component-speciic procs/vars if they want!

/obj/machinery/atmospherics/component
	/// Welded vents/scrubbers
	var/welded = FALSE
	// Air movement calculations
	/// Maximum power rating - maximum power it can draw for operations in watts.
	var/power_rating = ATMOSMECH_POWER_RATING
	/// Current power rating - defaults to max
	var/power_setting = ATMOSMECH_POWER_RATING
	/// Max operating pressure - cannot pressurize above this, but can accept above this
	var/max_pressure = ATMOSMECH_PUMP_PRESSURE
	/// Max operating rate - cannot pump faster than this (L/s)
	var/max_rate = ATMOSMECH_PUMP_RATE
	/// Efficiency multiplier
	var/power_efficiency = 1
	/// Minimum volume to move per second before it gives up
	var/futile_rate = ATMOSMECH_FUTILE_PUMP_RATE
	/// Below this in moles, anything left is instantly moved. This ensures you can't require infinite power to drain something.
	var/moles_to_instant_pump = ATMOSMECH_INSTANT_PUMP_MOLES
	/// Below this in pressure, anything left is instantly moved. This ensures you can't require infinite power to drain something.
	var/pressure_to_instant_pump = ATMOSMECH_INSTANT_PUMP_PRESSURE
	/// Pipelines this belongs to
	var/list/datum/pipeline/pipelines
	/// Gas mixtures we contain
	var/list/datum/gas_mixture/airs
	/// Volume of each of our airs
	var/volume = 200

	var/welded = FALSE //Used on pumps and scrubbers
	var/showpipe = FALSE
	var/shift_underlay_only = TRUE //Layering only shifts underlay?

/obj/machinery/atmospherics/component/AtmosInit()
	pipelines = new /list(device_type)
	airs = new /list(device_type)
	for(var/i in 1 to device_type)
		airs[i] = new /datum/gas_mixture(volume)
	return ..()

// Iconnery

/obj/machinery/atmospherics/component/proc/update_icon_nopipes()
	return

/obj/machinery/atmospherics/component/update_icon()
	update_icon_nopipes()

	underlays.Cut()

	var/turf/T = loc
	if(level == 2 || (istype(T) && !T.intact))
		showpipe = TRUE
		plane = ABOVE_WALL_PLANE
	else
		showpipe = FALSE
		plane = FLOOR_PLANE

	if(!showpipe)
		return //no need to update the pipes if they aren't showing

	var/connected = 0 //Direction bitset

	for(var/i in 1 to device_type) //adds intact pieces
		if(nodes[i])
			var/obj/machinery/atmospherics/node = nodes[i]
			var/image/img = get_pipe_underlay("pipe_intact", get_dir(src, node), node.pipe_color)
			underlays += img
			connected |= img.dir

	for(var/direction in GLOB.cardinals)
		if((initialize_directions & direction) && !(connected & direction))
			underlays += get_pipe_underlay("pipe_exposed", direction)

	if(!shift_underlay_only)
		PIPE_LAYER_SHIFT(src, pipe_layer)

/obj/machinery/atmospherics/component/proc/get_pipe_underlay(state, dir, color = null)
	if(color)
		. = getpipeimage('icons/obj/atmospherics/component/binary_devices.dmi', state, dir, color, pipe_layer = shift_underlay_only ? pipe_layer : 2)
	else
		. = getpipeimage('icons/obj/atmospherics/component/binary_devices.dmi', state, dir, pipe_layer = shift_underlay_only ? pipe_layer : 2)

// Pipenet stuff; housekeeping

/obj/machinery/atmospherics/component/nullifyNode(i)
	if(nodes[i])
		nullifyPipenet(parents[i])
		QDEL_NULL(airs[i])
	..()

/obj/machinery/atmospherics/component/on_construction()
	..()
	update_parents()

/obj/machinery/atmospherics/component/build_network()
	for(var/i in 1 to device_type)
		if(!parents[i])
			parents[i] = new /datum/pipeline()
			var/datum/pipeline/P = parents[i]
			P.build_pipeline(src)

/obj/machinery/atmospherics/component/proc/nullifyPipenet(datum/pipeline/reference)
	if(!reference)
		CRASH("nullifyPipenet(null) called by [type] on [COORD(src)]")
	var/i = parents.Find(reference)
	reference.other_airs -= airs[i]
	reference.other_atmosmch -= src
	parents[i] = null

/obj/machinery/atmospherics/component/returnPipenetAir(datum/pipeline/reference)
	return airs[parents.Find(reference)]

/obj/machinery/atmospherics/component/pipeline_expansion(datum/pipeline/reference)
	if(reference)
		return list(nodes[parents.Find(reference)])
	return ..()

/obj/machinery/atmospherics/component/setPipenet(datum/pipeline/reference, obj/machinery/atmospherics/A)
	parents[nodes.Find(A)] = reference

/obj/machinery/atmospherics/component/returnPipenet(obj/machinery/atmospherics/A = nodes[1]) //returns parents[1] if called without argument
	return parents[nodes.Find(A)]

/obj/machinery/atmospherics/component/replacePipenet(datum/pipeline/Old, datum/pipeline/New)
	parents[parents.Find(Old)] = New

/obj/machinery/atmospherics/component/unsafe_pressure_release(var/mob/user, var/pressures)
	..()

	var/turf/T = get_turf(src)
	if(T)
		//Remove the gas from airs and assume it
		var/datum/gas_mixture/environment = T.return_air()
		var/lost = null
		var/times_lost = 0
		for(var/i in 1 to device_type)
			var/datum/gas_mixture/air = airs[i]
			lost += pressures*environment.return_volume()/(air.return_temperature() * R_IDEAL_GAS_EQUATION)
			times_lost++
		var/shared_loss = lost/times_lost

		for(var/i in 1 to device_type)
			var/datum/gas_mixture/air = airs[i]
			T.assume_air_moles(air, shared_loss)
		air_update_turf(1)

/obj/machinery/atmospherics/component/proc/safe_input(var/title, var/text, var/default_set)
	var/new_value = input(usr,text,title,default_set) as num
	if(usr.canUseTopic(src))
		return new_value
	return default_set

// Helpers

/obj/machinery/atmospherics/component/proc/update_parents()
	for(var/i in 1 to device_type)
		var/datum/pipeline/parent = parents[i]
		if(!parent)
			stack_trace("Component is missing a pipenet! Rebuilding...")
			SSair.add_to_rebuild_queue(src)
		parent.update = 1

/obj/machinery/atmospherics/component/returnPipenets()
	. = list()
	for(var/i in 1 to device_type)
		. += returnPipenet(nodes[i])


// UI Stuff


/obj/machinery/atmospherics/component/ui_status(mob/user)
	if(allowed(user))
		return ..()
	to_chat(user, "<span class='danger'>Access denied.</span>")
	return UI_CLOSE

/obj/machinery/atmospherics/component/attack_ghost(mob/dead/observer/O)
	. = ..()
	atmosanalyzer_scan(airs, O, src, FALSE)

// Tool acts


/obj/machinery/atmospherics/component/analyzer_act(mob/living/user, obj/item/I)
	atmosanalyzer_scan(airs, user, src)
	return TRUE
