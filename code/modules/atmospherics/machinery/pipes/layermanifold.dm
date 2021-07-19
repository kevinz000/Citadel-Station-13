/obj/machinery/atmospherics/pipe/layer_manifold
	name = "layer adaptor"
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifoldlayer"
	desc = "A special pipe to bridge pipe layers with."
	dir = SOUTH
	initialize_directions = NORTH|SOUTH
	pipe_flags = PIPE_ALL_LAYER | PIPE_DEFAULT_LAYER_ONLY | PIPE_CARDINAL_AUTONORMALIZE
	pipe_layer = PIPE_LAYER_DEFAULT
	device_type = 0
	volume = 260
	construction_type = /obj/item/pipe/binary
	pipe_state = "manifoldlayer"
	var/list/front_nodes
	var/list/back_nodes

/obj/machinery/atmospherics/pipe/layer_manifold/Initialize()
	front_nodes = list()
	back_nodes = list()
	icon_state = "manifoldlayer_center"
	return ..()

/obj/machinery/atmospherics/pipe/layer_manifold/Destroy()
	nullifyAllNodes()
	return ..()

/obj/machinery/atmospherics/pipe/layer_manifold/proc/nullifyAllNodes()
	var/list/obj/machinery/atmospherics/needs_nullifying = get_all_connected_nodes()
	front_nodes = null
	back_nodes = null
	nodes = list()
	for(var/obj/machinery/atmospherics/A in needs_nullifying)
		A.disconnect(src)
		SSair.add_to_rebuild_queue(A)

/obj/machinery/atmospherics/pipe/layer_manifold/proc/get_all_connected_nodes()
	return front_nodes + back_nodes + nodes

/obj/machinery/atmospherics/pipe/layer_manifold/update_icon()	//HEAVILY WIP FOR UPDATE ICONS!!
	cut_overlays()
	layer = initial(layer) + (PIPE_LAYER_MAX * PIPE_LAYER_LCHANGE)	//This is above everything else.

	for(var/node in front_nodes)
		add_attached_images(node)
	for(var/node in back_nodes)
		add_attached_images(node)

	update_alpha()

/obj/machinery/atmospherics/pipe/layer_manifold/proc/add_attached_images(obj/machinery/atmospherics/A)
	if(!A)
		return
	if(istype(A, /obj/machinery/atmospherics/pipe/layer_manifold))
		for(var/i in PIPE_LAYER_MIN to PIPE_LAYER_MAX)
			add_attached_image(get_dir(src, A), i)
			return
	add_attached_image(get_dir(src, A), A.pipe_layer, A.pipe_color)

/obj/machinery/atmospherics/pipe/layer_manifold/proc/add_attached_image(p_dir, p_layer, p_color = null)
	var/image/I

	if(p_color)
		I = getpipeimage(icon, "pipe", p_dir, p_color, pipe_layer = pipe_layer)
	else
		I = getpipeimage(icon, "pipe", p_dir, pipe_layer = pipe_layer)

	I.layer = layer - 0.01
	PIPE_LAYER_SHIFT(I, p_layer)
	add_overlay(I)

/obj/machinery/atmospherics/pipe/layer_manifold/SetInitDirections()
	switch(dir)
		if(NORTH || SOUTH)
			initialize_directions = NORTH|SOUTH
		if(EAST || WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/layer_manifold/isConnectable(obj/machinery/atmospherics/target, given_layer)
	if(!given_layer)
		return TRUE
	. = ..()

/obj/machinery/atmospherics/pipe/layer_manifold/proc/findAllConnections()
	front_nodes = list()
	back_nodes = list()
	var/list/new_nodes = list()
	for(var/iter in PIPE_LAYER_MIN to PIPE_LAYER_MAX)
		var/obj/machinery/atmospherics/foundfront = findConnecting(dir, iter)
		var/obj/machinery/atmospherics/foundback = findConnecting(turn(dir, 180), iter)
		front_nodes += foundfront
		back_nodes += foundback
		if(foundfront && !QDELETED(foundfront))
			new_nodes += foundfront
		if(foundback && !QDELETED(foundback))
			new_nodes += foundback
	update_icon()
	return new_nodes

/obj/machinery/atmospherics/pipe/layer_manifold/atmosinit()
	normalize_cardinal_directions()
	findAllConnections()
	var/turf/T = loc			// hide if turf is not intact
	hide(T.intact)

/obj/machinery/atmospherics/pipe/layer_manifold/setPipingLayer()
	pipe_layer = PIPE_LAYER_DEFAULT

/obj/machinery/atmospherics/pipe/layer_manifold/pipeline_expansion()
	return get_all_connected_nodes()

/obj/machinery/atmospherics/pipe/layer_manifold/disconnect(obj/machinery/atmospherics/reference)
	if(istype(reference, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = reference
		P.destroy_network()
	while(reference in get_all_connected_nodes())
		if(reference in nodes)
			var/i = nodes.Find(reference)
			nodes[i] = null
		if(reference in front_nodes)
			var/i = front_nodes.Find(reference)
			front_nodes[i] = null
		if(reference in back_nodes)
			var/i = back_nodes.Find(reference)
			back_nodes[i] = null
	update_icon()

/obj/machinery/atmospherics/pipe/layer_manifold/relaymove(mob/living/user, dir)
	if(initialize_directions & dir)
		return ..()
	if((NORTH|EAST) & dir)
		user.ventcrawl_layer = clamp(user.ventcrawl_layer + 1, PIPE_LAYER_MIN, PIPE_LAYER_MAX)
	if((SOUTH|WEST) & dir)
		user.ventcrawl_layer = clamp(user.ventcrawl_layer - 1, PIPE_LAYER_MIN, PIPE_LAYER_MAX)
	to_chat(user, "You align yourself with the [user.ventcrawl_layer]\th output.")
