/**
 * Rigsuit control module a la baystation
 * Holds most of the data for rigsuits.
 * Pieces are attached via /datum/component/rig_piece
 */
/obj/item/rig
	name = "blank rigsuit control module"
	desc = "Coders fucked up, if you can see this."
	/// list of all attached components
	var/list/obj/item/rig_component/all_components
	/// list of all permanent components (cannot be detached)
	var/list/obj/item/rig_component/permanent_components
	/// Current weight - updated by component attach/detach
	var/weight = 0
	/// Installed armor.
	var/obj/item/rig_component/armor/installed_armor
	/// Installed pressure shielding.
	var/obj/item/rig_component/pressure_shielding/installed_pressure_shielding
	/// Installed thermal protection.
	var/obj/item/rig_component/thermal_shielding/installed_thermal_shielding

/obj/item/rig/Initialize(mapload)
	. = ..()

/obj/item/rig/Destroy()
	for(var/i in all_components)
		var/obj/item/rig_component/C = i
		detach_component(C, TRUE, TRUE)
	return ..()

/**
 * Attachs a component.
 * Will forceMove said component to ourselves regardless of their location.
 *
 * @params
 * C - component to attach
 * force - ignore all can attach safety checks
 * del_conflicting - if forcing attach, conflicting modules will be deleted instead of dropped
 * unremovable - force component to be permanent/internal.
 * default_module - TRUE if it's being attached as part of rig control module Initialize()
 */
/obj/item/rig/proc/attach_component(obj/item/rig_component/C, force = FALSE, del_conflicting = TRUE, unremovable = FALSE, default_module = FALSE)
	var/list/obj/item/rig_component/conflicting = check_module_conflicts(C)
	if(!force && !C.can_attach(src) || conflicting.len)
		return FALSE
	all_components += C
	if(unremovable || C.internal)
		permanent_components += C
	C.on_attach(src, default_module)
	for(var/i in conflicting)
		var/obj/item/rig_component/C = i
		detach_component(C, TRUE, del_conflicting)

/**
 * Detaches a component.
 *
 * @params
 * C - component to detach
 * force - ignore all can_detach safety checks on the module
 * delete - delete detached module instead of dropping
 */
/obj/item/rig/proc/detach_component(obj/item/rig_component/C, force = FALSE, delete = FALSE)
	if(!force && !C.can_detach(src))
		return FALSE
	all_components -= C
	permanent_components -= C
	C.on_detach(src)
	if(delete)
		qdel(C)
	else
		C.forceMove(drop_location())

/**
 * Checks for any modules that are conflicting on the current suit with one about to be attached.
 *
 * @return A list of all modules that conflict. Empty if none.
 */
/obj/item/rig/proc/check_module_conflicts(obj/item/rig_component/C)
	. = list()
	var/theirs = C.conflicts_with
	for(var/i in all_components)
		var/obj/item/rig_component/C = i
		if(theirs & C.conflicts_with)
			. += C

/**
 * Updates rig installed armor.
 */
/obj/item/rig/proc/update_armor_module()

/**
 * Updates rig installed pressure module.
 */
/obj/item/rig/proc/update_pressure_module()

/**
 * Updates rig installed thermal module.
 */
/obj/item/rig/proc/update_thermal_module()
