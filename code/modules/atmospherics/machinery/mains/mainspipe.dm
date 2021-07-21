/**
 * Mains pipes, including 2 way, 3 way, and 4 ways.
 *
 * Connect layers together without intermixing
 */

ATMOS_MAPPING_COLORS(/obj/machinery/atmospherics/pipe/mains)
ATMOS_MAPPING_COLORS(/obj/machinery/atmospherics/pipe/mains3)
ATMOS_MAPPING_COLORS(/obj/machinery/atmospherics/pipe/mains4)

/obj/machinery/atmospherics/pipe/mains
	name = "mains pipe"
	desc = "A massive pipe that connects every pipe layer at once, without intermixing them."
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "mains"
	pipe_flags = PIPE_ALL_LAYER | PIPE_CARDINAL_AUTONORMALIZE
	device_type = BINARY

/obj/machinery/atmospherics/pipe/mains/GetNodeIndex(dir, layer)
	if(dir == src.dir)
		. = 2
	else
		. = 1
	if(pipe_flags & PIPE_ALL_LAYER)
		. *= layer

/obj/machinery/atmospherics/pipe/mains/DirectConnection(datum/pipeline/querying, obj/machinery/atmospherics/source)
	if(!source)
		CRASH("Mains pipe could not find source during pipeline expansion")
	return list(source)

/obj/machinery/atmospherics/pipe/mains3
	name = "mains manifold"
	desc = "A massive pipe that connects every pipe layer at once, without intermixing them."
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "mains3"
	pipe_flags = PIPE_ALL_LAYER
	device_type = TRINARY

/obj/machinery/atmospherics/pipe/mains4
	name = "mains 4-way manifold"
	desc = "A massive pipe that connects every pipe layer at once, without intermixing them."
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "mains4"
	pipe_flags = PIPE_ALL_LAYER
	device_type = QUATERNARY


/obj/machinery/atmospherics/component/quaternary/GetNodeIndex(dir, layer)
	switch(dir)
		if(NORTH)
			. = 1
		if(SOUTH)
			. = 3
		if(EAST)
			. = 2
		if(WEST)
			. = 4
	if(pipe_flags & PIPE_ALL_LAYER)
		. *= layer
