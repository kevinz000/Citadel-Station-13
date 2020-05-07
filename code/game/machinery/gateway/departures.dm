/obj/machinery/gateway/center/big/departures
	name = "Departures Gateway"

/obj/machinery/gateway/center/big/departures/Initialize(mapload)
	if(mapload)
		if(!SSticker.departures_gateway)
			SSticker.departures_gateway = src
		else
			stack_trace("Departures gateway conflicted.")
	return ..()
