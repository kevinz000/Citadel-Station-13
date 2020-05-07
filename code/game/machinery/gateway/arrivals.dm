/obj/machinery/gateway/center/big/arrivals
	name = "Arrivals Gateway"
	var/arrivals_shutoff_timerid

/obj/machinery/gateway/center/big/arrivals/Initialize(mapload)
	if(mapload)
		if(!SSticker.arrivals_gateway)
			SSticker.arrivals_gateway = src
		else
			stack_trace("Arrivals gateway conflicted.")
	return ..()

/obj/machinery/gateway/center/big/arrivals/after_teleport_receive(atom/movable/AM)
	if(arrivals_shutoff_timerid)
		deltimer(arrivals_shutoff_timerid)
	set_state(GATEWAY_STATE_ON)
	arrivals_shutoff_timerid = addtimer(CALLBACK(src, .proc/set_state, GATEWAY_STATE_OFF), 10 SECONDS, flags = TIMER_STOPPABLE)
