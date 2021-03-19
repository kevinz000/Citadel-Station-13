/**
 * Rig armor plating base.
 * Simply just for holding armor values/weight.
 * Rigsuits handle the actual attachment/calculation.
 */
/obj/item/rig_component/armor
	name = "unnamed armor module"
	desc = "Suspicious."
	/// Armor datum to apply to the rigsuit's pieces, for cases of user protection.
	var/datum/armor/user_protection = list("melee" = 10, "laser" = 10, "bullet" = 10, "energy" = 10, "bomb" = 10, "bio" = 100, "rad" = 10, "acid" = 100, "wound" = 10)
	/// Armor datum to apply for cases of rigsuit damage. If null, defaults to user_protection.
	var/datum/armor/rig_protection
	/// Module weight.
	var/weight = RIGSUIT_WEIGHT_NONE
	/// Siemens coefficient - conductivity. Defaults to fully nonconductive, more on that later in rigsuits.
	var/conductivity = 0

/obj/item/rig_component/armor/Initialize(mapload)
	. = ..()
	if(islist(user_protection))
		user_protection = getArmor(arglist(user_protection))
	if(islist(rig_protection))
		rig_protection = getArmor(arglist(rig_protection))
	if(!user_protection)
		user_protection = getArmor()
	if(!rig_protection)
		rig_protection = user_protection

/obj/item/rig_component/thermal_shielding/on_attach(obj/item/rig/rig, rig_creation = fALSE)
	rig.update_armor_module()

/**
 * Thermal shielding modules
 * Holds maximum shielding for clothing items in regards to cold and heat.
 */
/obj/item/rig_component/thermal_shielding
	name = "unnamed thermal module"
	desc = "Suspicious"
	/// Minimum cold protection temperature.
	var/cold_protection = SPACE_HELM_MIN_TEMP_PROTECT
	/// Maximum heat protection temperature
	var/heat_protection = SPACE_HELM_MAX_TEMP_PROTECT

/obj/item/rig_component/thermal_shielding/on_attach(obj/item/rig/rig, rig_creation = fALSE)
	rig.update_thermal_module()

/**
 * Pressure shielding, thickmaterial, etc.
 * Most of the time, rigs won't have this be able to be swapped out.
 */
/obj/item/rig_component/pressure_shielding
	name = "unnamed pressure module"
	desc = "Suspicious"
	/// Stops pressure damage
	var/pressure_immune = TRUE
	/// Allows internal usage
	var/allow_internals = TRUE
	/// Thickmaterial - blocks syringe guns and similar
	var/thick_material = TRUE
	/// Blocks gas smoke effect even if user isn't on internals
	var/block_gas_smoke_effect = TRUE

/obj/item/rig_component/pressure_shielding/on_attach(obj/item/rig/rig, rig_creation = fALSE)
	rig.update_pressure_module()
