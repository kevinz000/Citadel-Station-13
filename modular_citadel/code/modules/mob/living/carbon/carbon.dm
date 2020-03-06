/mob/living/carbon
	var/lastmousedir
	var/wrongdirmovedelay
	var/combatmessagecooldown

	//oh no vore time
	var/voremode = FALSE

mob/living/carbon/proc/toggle_vore_mode()
	voremode = !voremode
	var/obj/screen/voretoggle/T = locate() in hud_used?.static_inventory
	T?.update_icon_state()
	if(combatmode)
		return FALSE //let's not override the main draw of the game these days
	SEND_SIGNAL(src, COMSIG_VORE_TOGGLED, src, voremode)
	return TRUE

/mob/living/carbon/Move(atom/newloc, direct = 0)
	var/currentdirection = dir
	. = ..()
	wrongdirmovedelay = FALSE
	if(IS_COMBAT_ACTIVE(src) && client && lastmousedir)
		if(lastmousedir != dir)
			wrongdirmovedelay = TRUE
			setDir(lastmousedir, ismousemovement = TRUE)

/mob/living/carbon/onMouseMove(object, location, control, params)
	if(!combatmode)
		return
	mouse_face_atom(object)
	lastmousedir = dir
