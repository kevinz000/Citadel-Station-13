/**
 * Mains pipes, including 2 way, 3 way, and 4 ways.
 *
 * Connect layers together without intermixing
 */

ATMOS_MAPPING_COLORS(/obj/machinery/atmospherics/pipe/mains, "mains")
ATMOS_MAPPING_COLORS(/obj/machinery/atmospherics/pipe/mains3, "mains3")
ATMOS_MAPPING_COLORS(/obj/machinery/atmospherics/pipe/mains44, "mains4")

#warn implement main pipes

/obj/machinery/atmospherics/pipe/mains

	device_type = BINARY

/obj/machinery/atmospherics/pipe/mains3

	device_type = TRINARY

/obj/machinery/atmospherics/pipe/mains4

	device_type = QUATERNARY
