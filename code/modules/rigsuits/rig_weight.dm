/**
 * Updates the rigsuit's weight.
 */
/obj/item/rig/proc/update_weight()
	var/old = weight
	weight = innate_weight
	for(var/i in all_components)
		var/obj/item/rig_component/C = i
		weight += C.weight
	if(old != weight)
		update_slowdown()
