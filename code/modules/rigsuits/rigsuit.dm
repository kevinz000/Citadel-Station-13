/**
 * Rigsuit control module a la baystation
 * Holds most of the data for rigsuits.
 * Pieces are attached via /datum/component/rig_piece
 *
 * Rig zones:
 * Zones consist of head, chest, left/right arms/legs, for a total of 6 zones.
 * They have no correlation to the actual rig pieces.
 */
/obj/item/rig
	name = "blank rigsuit control module"
	desc = "Coders fucked up, if you can see this."
	/// list of all attached components. Can be at init, a list of typepaths to spawn, or null.
	var/list/obj/item/rig_component/all_components
	/// list of all permanent components (cannot be detached). Can be at init, a list of typepaths to spawn, or null.
	var/list/obj/item/rig_component/permanent_components
	/// Current weight - updated by component attach/detach
	var/weight = 0
	/// Installed armor.
	var/obj/item/rig_component/armor/installed_armor
	/// Installed pressure shielding.
	var/obj/item/rig_component/pressure_shielding/installed_pressure_shielding
	/// Installed thermal protection.
	var/obj/item/rig_component/thermal_shielding/installed_thermal_shielding
	/// Suit types bitflag. Used for module can attach checks.
	var/suit_types = NONE
	/// List of components to generate at init. If set to = TRUE associative value, it'll be permanent.
	var/list/initial_components = list()
	/// Helmet. Typepath for init spawn.
	var/obj/item/clothing/head/rig/helmet = /obj/item/clothing/head/rig
	/// Chestpiece. Typepath for init spawn.
	var/obj/item/clothing/suit/rig/chestpiece = /obj/item/clothing/suit/rig
	/// Gauntlets. Typepath for init spawn.
	var/obj/item/clothing/gloves/rig/gauntlets = /obj/item/clothing/gloves/rig
	/// Boots. Typepath for init spawn.
	var/obj/item/clothing/shoes/rig/boots = /obj/item/clothing/shoes/rig

/obj/item/rig/Initialize(mapload)
	. = ..()
	generate_pieces()
	generate_components()
	initial_components = null
	update_weight()
	sync_all_pieces()

/obj/item/rig/Destroy()
	wipe_components()
	for(var/i in all_components)
		var/obj/item/rig_component/C = i
		detach_component(C, TRUE, TRUE)
	return ..()

/**
 * Generates all default pieces on a rigsuit.
 */
/obj/item/rig/proc/generate_pieces()
	if(ispath(helmet))
		helmet = new helmet(src, src)
	if(ispath(chestpiece))
		chestpiece = new chestpiece(src, src)
	if(ispath(gauntlets))
		gauntlets = new gauntlets(src, src)
	if(ispath(boots))
		boots = new boots(src, src)

/**
 * Returns a list of all installed rigsuit pieces.
 */
/obj/item/rig/proc/all_pieces()
	. = list()
	if(helmet)
		. += helmet
	if(chestpiece)
		. += chestpiece
	if(gauntlets)
		. += gauntlets
	if(boots)
		. += boots

/**
 * Syncs up all pieces with the installed armor/thermal/pressure modules
 */
/obj/item/rig/proc/sync_all_pieces()
	for(var/i in all_pieces())
		sync_piece(i)

/**
 * Syncs a specific piece with the installed armor/thermal/pressure modules
 */
