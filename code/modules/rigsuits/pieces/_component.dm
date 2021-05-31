/**
 * Componentized rig pieces.
 *
 * Should only be added to items.
 * **CURRENTLY DOES NOT SUPPORT DETACHING/SWAPPING**.
 */
/datum/component/rig_piece
	can_transfer = FALSE		// hahaha no.
	/// Our host rig piece, if it exists.
	var/obj/item/rig/rig
	/// Should we get armor, pressure, thermal shielding etc transferred to us. Used to ensure no stacking if we ever get uniform rigs.
	var/apply_armor = FALSE
	/// Separate cycle delay - time needed to fully seal a piece on deploy, separate from rig's innate activation/deactivation delays
	var/cycle_delay = 0
	/// Piece type bitflag - each rig can only have one of each type.
	var/piece_type = NONE

/datum/component/rig_piece/Initialize(..., obj/item/rig/rig, apply_armor, cycle_delay, piece_type)
	. = ..()
	if(. & COMPONENT_INCOMPATIBLE)
		return
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if(!istype(rig))
		return COMPONENT_INCOMPATIBLE		// if you're an admin bussing, go learn how to do this properly with a rig proc, and stop fucking about.
	if(!isnull(apply_armor))
		src.apply_armor = apply_armor
	if(!isnull(cycle_delay))
		src.cycle_delay = cycle_delay
	if(!isnull(piece_type))
		src.piece_type = piece_type
	var/obj/item/I = parent
	I.resistance_flags |= (ACID_PROOF | INDESTRUCTIBLE | FIRE_PROOF)	// rig damage is handled separately.
	RegisterToRig(rig)

/datum/component/rig_piece/Destroy()
	UnregisterFromRig()
	return ..()

/**
 * Sets us up with a rig
 */
/datum/component/rig_piece/proc/RegisterToRig(obj/item/rig/rig)


/**
 * Cleans us up from a rig. Never use outside of deletion, rig-swapping isn't supported yet.
 */
/datum/component/rig_piece/proc/UnregisterFromRig(obj/item/rig/rig)


/datum/component/rig_piece/head
	apply_armor = TRUE
	piece_type = RIG_PIECE_HEAD

/datum/component/rig_piece/suit
	apply_armor = TRUE
	piece_type = RIG_PIECE_SUIT

/datum/component/rig_piece/gauntlets
	apply_armor = TRUE
	piece_type = RIG_PIECE_GAUNTLETS

/datum/component/rig_piece/boots
	apply_armor = TRUE
	piece_type = RIG_PIECE_BOOTS

