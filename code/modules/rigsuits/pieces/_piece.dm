/**
 * Base definitions for rig pieces go in here.
 */
///////////////////////////////////////////////////
/obj/item/clothing/head/rig
	name = "rig helmet"
	desc = "A helmet that's part of a rigsuit."

	/// The rig that it belongs to.
	var/obj/item/rig/host

/obj/item/clothing/head/rig/Initialize(mapload, obj/item/rig/rig)
	. = ..()
	host = rig

/obj/item/clothing/head/rig/Destroy()
	host = null
	return ..()

/obj/item/clothing/suit/rig
	name = "rig chestpiece"
	desc = "A chestpiece that's part of a rigsuit."

	/// The rig that it belongs to.
	var/obj/item/rig/host

/obj/item/clothing/suit/rig/Initialize(mapload, obj/item/rig/rig)
	. = ..()
	host = rig

/obj/item/clothing/suit/rig/Destroy()
	host = null
	return ..()

/obj/item/clothing/gloves/rig
	name = "rig gauntlets"
	desc = "A pair of gauntlets that's part of a rigsuit."

	/// The rig that it belongs to.
	var/obj/item/rig/host

/obj/item/clothing/gloves/rig/Initialize(mapload, obj/item/rig/rig)
	. = ..()
	host = rig

/obj/item/clothing/gloves/rig/Destroy()
	host = null
	return ..()

/obj/item/clothing/shoes/rig
	name = "rig boots"
	desc = "A pair of boots that's part of a rigsuit."

	/// The rig that it belongs to.
	var/obj/item/rig/host

/obj/item/clothing/shoes/rig/Initialize(mapload, obj/item/rig/rig)
	. = ..()
	host = rig

/obj/item/clothing/shoes/rig/Destroy()
	host = null
	return ..()
