/**
 * Base type of rig components.
 */
/obj/item/rig_component
	/// Currently attached rig. Set by rig attach/detach procs.
	var/obj/item/rig/host
	/// Weight of this component
	var/weight = RIGSUIT_WEIGHT_NONE
	/// Allowed suit types, flags.
	var/allowed_suit_types = ALL
	/// Is this component considered an "abstract component" aka unremovable, can't be used in other suits.
	var/internal = FALSE
	/// Conflict type - this is a bitflag. If any other component has anything in this, there's a conflict.
	var/conflicts_with = NONE

/**
 * Called when being attached to a suit.
 *
 * @return Whether or not we should attach
 */
/obj/item/rig_component/proc/can_attach(obj/item/rig/rig)
	return (rig.suit_types & allowed_suit_types) && !internal

/**
 * Checks if we can be detached.
 *
 * @return Whether or not we can be detached
 */
/obj/item/rig_component/proc/can_detach(obj/item/rig/rig)
	return !internal && !(src in rig.permanent_modules)

/**
 * Called when attached to a suit.
 *
 * @params
 * * rig - The control module being attached into
 * * rig_creation - Being created and attached as part of default modules.
 */
/obj/item/rig_component/proc/on_attach(obj/item/rig/rig, rig_creation = FALSE)
	if(!rig_creation)
		rig.update_weight()

/**
 * Called when detached from a suit.
 *
 * @params
 * * rig - The control module being attached into
 */
/obj/item/rig_component/proc/on_detach(obj/item/rig/rig)
	if(!rig_creation)
		rig.update_weight()
