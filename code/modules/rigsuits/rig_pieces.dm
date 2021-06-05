/**
 * Initializes pieces
 */
/obj/item/rig/proc/initialize_pieces()

/**
 * Destroys all pieces for garbage collection
 */
/obj/item/rig/proc/wipe_pieces()

/**
 * Resolves something into the rig piece component it has.
 * Returns null if it's not part of us
 */
/obj/item/rig/proc/resolve_piece_component(datum/component/rig_piece/I)
	if(istype(I))
		return piece_components[I]? I : null
	return rig_pieces[I]

/**
 * Adds a rig piece
 */
/obj/item/rig/proc/add_piece(obj/item/I, component_path = /datum/component/rig_piece)

/**
 * Deploys a piece
 *
 * @params
 * - P - what to deploy, either the item or the component
 * - force - knock off what they're wearing
 * - harder - knock off what they're wearing even if it's nodrop
 * - seal_immediately - seal immediately if rig is activated
 */
/obj/item/rig/proc/deploy(datum/component/rig_piece/P, force = FALSE, harder = FALSE, seal_immediately = FALSE)
	P = resolve_piece_component(P)
	if(!P)
		CRASH("Attempted to deploy an invalid piece.")
	var/obj/item/I = P.parent

/**
 * Attempts to deploy a piece.
 */
/obj/item/rig/proc/try_deploy(obj/item/I, force = FALSE, harder = FALSE, seal_immediately = FALSE)
	P = resolve_piece_component(P)
	if(!P)
		CRASH("ATtempted to deploy an invalid piece.")
	return deploy(I, force, harder, seal_immediately)

/**
 * Retracts a piece. Ignores nodrop. Unseals immediately.
 *
 * @params
 * - P - what to retract, either the item or the component
 */
/obj/item/rig/proc/retract(

/**
 * Attempts to retract a piece. Will attempt to unseal it if it's sealed first.
 *
 * @params
 * - P - what to retract, either the item or the component
 * - unseal_immediately - bypass unseal delay
 */
/obj/item/rig/proc/try_retract

/**
 * Seals a piece
 */

/**
 * Unseals a piece
 */

/**
 * Attempts to seal a piece. Blocking call.
 */

/**
 * Attempts to unseal a piece. Blocking call.
 */
