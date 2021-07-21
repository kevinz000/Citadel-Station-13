/**
 * Multiz up/down pipes
 */

ATMOS_MAPPING_FULL(/obj/machinery/atmospherics/pipe/up, "up1")
ATMOS_MAPPING_FULL(/obj/machinery/atmospherics/pipe/down, "down1")
ATMOS_MAPPING_MINIMAL(/obj/machinery/atmospherics/pipe/multiz_deck, "multiz_pipe")

#warn implement

/**
 * One side goes up
 */
/obj/machinery/atmospherics/pipe/up

/**
 * One side goes down
 */
/obj/machinery/atmoshperics/pipe/down

/**
 * Joins every layer to both up and down, without mixing layers.
 */
/obj/machinery/atmospherics/pipe/multiz_deck
	name = "multi deck pipe adapter"
	desc = "An adapter which allows pipes to connect to other pipenets on different decks."
	icon_state = "multiz_pipe"
	icon = 'icons/obj/atmos.dmi'
	device_type = QUATERNARY



/obj/machinery/atmospherics/pipe/simple/multiz/update_icon()
	. = ..()
	cut_overlays() //This adds the overlay showing it's a multiz pipe. This should go above turfs and such
	var/image/multiz_overlay_node = new(src) //If we have a firing state, light em up!
	multiz_overlay_node.icon = 'icons/obj/atmos.dmi'
	multiz_overlay_node.icon_state = "multiz_pipe"
	multiz_overlay_node.layer = HIGH_OBJ_LAYER
	add_overlay(multiz_overlay_node)

///Attempts to locate a multiz pipe that's above us, if it finds one it merges us into its pipenet
/obj/machinery/atmospherics/pipe/simple/multiz/DirectConnection(datum/pipeline/querying, obj/machinery/atmospherics/source)
	. = ..()
	var/turf/T = get_turf(src)
	var/obj/machinery/atmospherics/pipe/simple/multiz/above = locate(/obj/machinery/atmospherics/pipe/simple/multiz) in(SSmapping.get_turf_above(T))
	var/obj/machinery/atmospherics/pipe/simple/multiz/below = locate(/obj/machinery/atmospherics/pipe/simple/multiz) in(SSmapping.get_turf_below(T))
	if(below)
		. |= below.DirectConnection(querying, source)
	if(above)
		. |= above.DirectConnection(querying, source)
	. -= src
		below.pipeline_expansion() //If we've got one below us, force it to add us on facebook
	if(above)
		nodes += above
		above.nodes += src //Two way travel :)
	return ..()
