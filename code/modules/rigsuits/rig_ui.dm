/**
 * RIG UI static data
 */
/obj/item/rig/ui_static_data(mob/user)
	. = ..()
	// Integrals
	.["integral_armor"] = installed_armor?.rig_ui_data(user)
	.["integral_thermal"] = installed_thermal_shielding?.rig_ui_data(user)
	.["integral_pressure"] = installed_pressure_shielding?.rig_ui_data(user)
	// Regular modules
	var/list/modulelist = list()
	for(var/obj/item/rig_component/module/M in modules)
		var/ref = REF(M)
		modulelist += ref
		.[ref] = M.rig_ui_data(user)

/**
 * RIG UI data
 */
/obj/item/rig/ui_data(mob/user)
	. = ..()

/**
 * RIG UI status
 */
/obj/item/rig/ui_status(mob/user)
	var/control_flags = get_control_flags(user)
	if(!(control_flags & RIG_CONTROL_UI_VIEW))
		return UI_CLOSE
	if(!(control_flags & RIG_CONTROL_UI_USE))
		return UI_UPDATE
	return UI_INTERACTIVE


/**
 * RIG UI act
 */
/obj/item/rig/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/control_flags = get_control_flags(usr)
	if(!(control_flags & RIG_CONTROL_UI_USE))
		return TRUE
	if(params["module"])
		if(!(control_flags & RIG_CONTROL_USE_MODULES))
			return TRUE
		var/obj/item/rig_component/module/M = locate(params["module"]) in modules
		if(!M)
			return TRUE
		M.rig_ui_act(action, params))
		return TRUE
