GLOBAL_LIST_INIT(cable_colors, list(
	"yellow" = "#ffff00",
	"green" = "#00aa00",
	"blue" = "#1919c8",
	"pink" = "#ff3cc8",
	"orange" = "#ff8000",
	"cyan" = "#00ffff",
	"white" = "#ffffff",
	"red" = "#ff0000"
	))

///////////////////////////////
//CABLE STRUCTURE
///////////////////////////////


////////////////////////////////
// Definitions
////////////////////////////////

/* Cable directions (d1 and d2)


  9   1   5
	\ | /
  8 - 0 - 4
	/ | \
  10  2   6

If d1 = 0 and d2 = 0, there's no cable
If d1 = 0 and d2 = dir, it's a O-X cable, getting from the center of the tile to dir (knot cable)
If d1 = dir1 and d2 = dir2, it's a full X-X cable, getting from dir1 to dir2
By design, d1 is the smallest direction and d2 is the highest
*/

/obj/structure/cable
	name = "power cable"
	desc = "A flexible, superconducting insulated cable for heavy-duty power transfer."
	icon = 'icons/obj/power_cond/cables.dmi'
	icon_state = "0-1"
	level = 1 //is underfloor
	plane = ABOVE_WALL_PLANE
	layer = WIRE_LAYER //Above hidden pipes, GAS_PIPE_HIDDEN_LAYER
	anchored = TRUE
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	var/d1 = 0   // cable direction 1 (see above)
	var/d2 = 1   // cable direction 2 (see above)
	/// The powernet we're part of.
	var/datum/powernet/powernet

	var/cable_color = "red"
	color = "#ff0000"

/obj/structure/cable/yellow
	cable_color = "yellow"
	color = "#ffff00"

/obj/structure/cable/green
	cable_color = "green"
	color = "#00aa00"

/obj/structure/cable/blue
	cable_color = "blue"
	color = "#1919c8"

/obj/structure/cable/pink
	cable_color = "pink"
	color = "#ff3cc8"

/obj/structure/cable/orange
	cable_color = "orange"
	color = "#ff8000"

/obj/structure/cable/cyan
	cable_color = "cyan"
	color = "#00ffff"

/obj/structure/cable/white
	cable_color = "white"
	color = "#ffffff"

// the power cable object
/obj/structure/cable/Initialize(mapload, param_color, _d1, _d2)
	. = ..()

	if(isnull(_d1) || isnull(_d2))
		// ensure d1 & d2 reflect the icon_state for entering and exiting cable
		var/dash = findtext(icon_state, "-")
		d1 = text2num(copytext(icon_state, 1, dash))
		d2 = text2num(copytext(icon_state, dash + length(icon_state[dash])))
	else
		d1 = _d1
		d2 = _d2

	if(dir != SOUTH)
		var/angle_to_turn = dir2angle(dir)
		if(angle_to_turn == 0 || angle_to_turn == 180)
			angle_to_turn += 180
		// direct dir set instead of setDir intentional
		dir = SOUTH
		if(d1)
			d1 = turn(d1, angle_to_turn)
		if(d2)
			d2 = turn(d2, angle_to_turn)
		if(d1 > d2)
			var/temp = d2
			d2 = d1
			d1 = temp

	var/turf/T = get_turf(src)			// hide if turf is not intact
	if(level==1)
		hide(T.intact)
	GLOB.cable_list += src //add it to the global cable list

	var/list/cable_colors = GLOB.cable_colors
	cable_color = param_color || cable_color || pick(cable_colors)
	if(cable_colors[cable_color])
		cable_color = cable_colors[cable_color]
	update_icon()

	if(!mapload)		// if we're made during mapload, SSmachines will build us. otherwise..
		SmartJoin()

/obj/structure/cable/Destroy()					// called when a cable is deleted
	Disconnect()
	GLOB.cable_list -= src							//remove it from global cable list
	return ..()									// then go ahead and delete the cable

/obj/structure/cable/deconstruct(disassembled = TRUE, mob/user)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = loc
		if(T)
			var/obj/item/cable_coil/C = new(T, d1? 2 : 1, cable_color)
			transfer_fingerprints_to(C)
			if(user)
				C.add_fingerprint(user)
	qdel(src)

///////////////////////////////////
// General procedures
///////////////////////////////////

//If underfloor, hide the cable
/obj/structure/cable/hide(i)

	if(level == 1 && isturf(loc))
		invisibility = i ? INVISIBILITY_MAXIMUM : 0
	update_icon()

/obj/structure/cable/update_icon_state()
	icon_state = "[d1]-[d2]"
	color = null
	add_atom_colour(cable_color, FIXED_COLOUR_PRIORITY)

/obj/structure/cable/proc/handlecable(obj/item/W, mob/user, params)
	var/turf/T = get_turf(src)
	if(T.intact)
		return
	if(istype(W, /obj/item/wirecutters))
		if (shock(user, 50))
			return
		user.visible_message("[user] cuts the cable.", "<span class='notice'>You cut the cable.</span>")
		investigate_log("was cut by [key_name(usr)] in [AREACOORD(src)]", INVESTIGATE_WIRES)
		deconstruct(user = user)
		return

	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = W
		if (coil.get_amount() < 1)
			to_chat(user, "<span class='warning'>Not enough cable!</span>")
			return
		coil.cable_join(src, user)

	else if(istype(W, /obj/item/twohanded/rcl))
		var/obj/item/twohanded/rcl/R = W
		if(R.loaded)
			R.loaded.cable_join(src, user)
			R.is_empty(user)

	else if(istype(W, /obj/item/multitool))
		if(powernet && (powernet.avail > 0))		// is it powered?
			to_chat(user, "<span class='danger'>[DisplayPower(powernet.avail)] in power network.</span>")
		else
			to_chat(user, "<span class='danger'>The cable is not powered.</span>")
		shock(user, 5, 0.2)

	src.add_fingerprint(user)

// Items usable on a cable :
//   - Wirecutters : cut it duh !
//   - Cable coil : merge cables
//   - Multitool : get the power currently passing through the cable
//
/obj/structure/cable/attackby(obj/item/W, mob/user, params)
	handlecable(W, user, params)

// shock the user with probability prb
/obj/structure/cable/proc/shock(mob/user, prb, siemens_coeff = 1)
	if(!prob(prb))
		return 0
	if (electrocute_mob(user, powernet, src, siemens_coeff))
		do_sparks(5, TRUE, src)
		return 1
	else
		return 0

/obj/structure/cable/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

////////////////////////////////////////////
// Power related
///////////////////////////////////////////

// All power generation handled in add_avail()
// Machines should use add_load(), surplus(), avail()
// Non-machines should use add_delayedload(), delayed_surplus(), newavail()

/obj/structure/cable/proc/add_avail(amount)
	if(powernet)
		powernet.newavail += amount

/obj/structure/cable/proc/add_load(amount)
	if(powernet)
		powernet.load += amount

/obj/structure/cable/proc/surplus()
	if(powernet)
		return clamp(powernet.avail-powernet.load, 0, powernet.avail)
	else
		return 0

/obj/structure/cable/proc/avail(amount)
	if(powernet)
		return amount ? powernet.avail >= amount : powernet.avail
	else
		return 0

/obj/structure/cable/proc/add_delayedload(amount)
	if(powernet)
		powernet.delayedload += amount

/obj/structure/cable/proc/delayed_surplus()
	if(powernet)
		return clamp(powernet.newavail - powernet.delayedload, 0, powernet.newavail)
	else
		return 0

/obj/structure/cable/proc/newavail()
	if(powernet)
		return powernet.newavail
	else
		return 0

/**
  * (Re)builds our power network.
  */
/obj/structure/cable/proc/Rebuild(datum/powernet/old)
	if(powernet)
		if(powernet != old)		// someone/something already rebuilt us. yes, the null check is important so it doesn't refuse to rebuild even if it's null.
			return
		// else, get rid of our powernet
		QDEL_NULL(powernet)
	var/datum/powernet/new_powernet = new
	net_powernet.build_network(src)

/**
  * Queues ourselves for rebuild on the next server tick.
  */
/obj/structure/cable/proc/QueueRebuild()
	addtimer(CALLBACK(src, .proc/Rebuild, powernet), 0)		// We WOULD do TIMER_UNIQUE here, but the "hashing" function for it is uh, quite expensive.

/**
  * Joins connected networks.
  * Unlike rebuilds, this doesn't forcefully destroy the old network - if we're just joining a network, there's no need to.
  */
/obj/structure/cable/proc/SmartJoin()
	var/list/structure/cable/cables = network_expansion()		// we only care about cables
	// if there's no cables we can't be smart
	if(!length(cables))
		Rebuild()
		return
	// else
	// if we're connected to multiple, a single build action will connect us all anyways so
	var/obj/structure/cable/C = cables[1]
	if(C.powernet)
		C.powernet.propagate(src, C)
	else	// something happened and there's nothing to join. this could be us being made at the same time as other cables and none of the reuild timers have fired.
		// in which case, just go with a dumb rebuild
		Rebuild()
	// either way, we have to have a powernet.
	ASSERT(powernet)

/**
  * Returns all cables we are connected to.
  * A list is passed in to grab machines we can connect to, to save a proccall.
  */
/obj/structure/cable/proc/network_expansion(list/machines = list())
	. = list()
	var/node = is_node()
	for(var/obj/structure/cable/C in loc)
		if((C.d1 == d1) || (C.d2 == d2))
			. += C
	// easy stuff ontop is done, hard part.
	var/turf/other
	// 3 dir vars
	var/turned
	var/northsouth
	var/eastwest
	if(d1) // sometimes, d1 doesn't exist/we are a node/knot
		other = get_step(src, d1)
		if(other)
			turned = turn(d1, 180)
			for(var/obj/structure/cable/C in other)
				if((C.d1 == turned) || (C.d2 == turned))
					. += C
		if(d1 & (d1 - 1))		// if we are diagonal, we get to have fun
			// Now comes the downright obnoxious part: Cables are quirky and whereever they "touch" they can connect
			// This means we have to do some special checks - we can't just do the turn check and call it a day.
			northsouth = d1 & (NORTH|SOUTH)
			eastwest = d1 & (EAST|WEST)
			// updown = d1 & (UP|DOWN)		HAHA NO - we're not playing 3d chess.
			var/turf/NST = get_step(src, northsouth)
			var/turf/EWT = get_step(src, eastwest)
			var/valid_diag_dir
			if(NST)
				valid_diag_dir = turn(northsouth, 180) | eastwest
				for(var/obj/structure/cable/C in NST)
					if((C.d1 == valid_diag_dir) || (C.d2 == valid_diag_dir))
						. += C
			if(EWT)
				valid_diag_dir = turn(eastwest, 180) | northsouth
				for(var/obj/structure/cable/C in EWT)
					if((C.d1 == valid_diag_dir) || (C.d2 == valid_diag_dir))
						. += C
	else		// if we are, pick up machines.
		for(var/obj/machinery/power/node in loc)
			machines |= node	// bah, duplicates.
	// we always have d2
	other = get_step(src, d2)
	if(!other)	// edge of map
		return
	turned = turn(d2, 180)
	for(var/obj/structure/cable/C in other)
		if((C.d1 == turned) || (C.d2 == turned))
			. += C
	// ditto - FUN diagonal handling. Check above.
	if(d2 & (d2 - 1))
		northsouth = d2 & (NORTH|SOUTH)
		eastwest = d2 & (EAST|WEST)
		var/turf/NST = get_step(src, northsouth)
		var/turf/EWT = get_step(src, eastwest)
		var/valid_diag_dir
		if(NST)
			valid_diag_dir = turn(northsouth, 180) | eastwest
			for(var/obj/structure/cable/C in NST)
				if((C.d1 == valid_diag_dir) || (C.d2 == valid_diag_dir))
					. += C
		if(EWT)
			valid_diag_dir = turn(eastwest, 180) | northsouth
			for(var/obj/structure/cable/C in EWT)
				if((C.d1 == valid_diag_dir) || (C.d2 == valid_diag_dir))
					. += C

/**
  * Disconnects us from our powernet.
  * If we are being moved or something, we NEED to move right after this is called, or we'll be connected again on the next tick.
  * Also tells machines on us to queue for a reconnect.
  * Although a powernet might "pick up" the machine during its rebuild, if there aren't any we will have lingering references/orphaned machines without this queue rebuild on the machine itself.
  * To emphasize this, this proc will move this cable to nullspace by default.
  */
/obj/structure/cable/proc/Disconnect(nullspace = TRUE)
	var/list/obj/machinery/power/machines = list()
	var/list/obj/structure/cable/cables = network_expansion(machines)
	for(var/i in cables)
		var/obj/structure/cable/C = i
		C.QueueRebuild()
	for(var/i in machines)
		var/obj/machinery/power/P = i
		P.QueueReconnect()
	// get us out of our powernet
	powernet?.cables -= src
	powernet = null
	if(nullspace)
		moveToNullspace()

/**
  * Sets our d1 and d2.
  */
/obj/structure/cable/proc/set_directions(nd1, nd2)
	if((nd1 == d1) && (nd2 == d2))
		return
	ASSERT(nd2)			// we always have a second dir
	Disconnect(FALSE)
	d1 = nd1
	d2 = nd2
	QueueRebuild()

///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////

////////////////////////////////
// Definitions
////////////////////////////////


/obj/item/stack/cable_coil
	name = "cable coil"
	custom_price = PRICE_CHEAP_AS_FREE
	gender = NEUTER //That's a cable coil sounds better than that's some cable coils
	icon = 'icons/obj/power.dmi'
	icon_state = "coil"
	item_state = "coil"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	max_amount = MAXCOIL
	amount = MAXCOIL
	merge_type = /obj/item/stack/cable_coil // This is here to let its children merge between themselves
	color = "red"
	desc = "A coil of insulated power cable."
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=10, /datum/material/glass=5)
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined", "flogged")
	singular_name = "cable piece"
	full_w_class = WEIGHT_CLASS_SMALL
	grind_results = list(/datum/reagent/copper = 2) //2 copper per cable in the coil
	usesound = 'sound/items/deconstruct.ogg'
	used_skills = list(/datum/skill/level/job/wiring)

/obj/item/stack/cable_coil/cyborg
	is_cyborg = 1
	custom_materials = null
	cost = 1

/obj/item/stack/cable_coil/cyborg/attack_self(mob/user)
	var/cable_color = input(user,"Pick a cable color.","Cable Color") in list("red","yellow","green","blue","pink","orange","cyan","white")
	color = cable_color
	update_icon()

/obj/item/stack/cable_coil/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in get_turf(user))
		user.visible_message("<span class='suicide'>[user] is making a noose with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	else
		user.visible_message("<span class='suicide'>[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return(OXYLOSS)

/obj/item/stack/cable_coil/Initialize(mapload, new_amount = null)
	. = ..()
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()

///////////////////////////////////
// General procedures
///////////////////////////////////


//you can use wires to heal robotics
/obj/item/stack/cable_coil/attack(mob/living/carbon/human/H, mob/user)
	if(!istype(H))
		return ..()

	var/obj/item/bodypart/affecting = H.get_bodypart(check_zone(user.zone_selected))
	if(affecting && affecting.status == BODYPART_ROBOTIC)
		if(user == H)
			user.visible_message("<span class='notice'>[user] starts to fix some of the wires in [H]'s [affecting.name].</span>", "<span class='notice'>You start fixing some of the wires in [H]'s [affecting.name].</span>")
			if(!do_mob(user, H, 50))
				return
		if(item_heal_robotic(H, user, 0, 15))
			use(1)
		return
	else
		return ..()


/obj/item/stack/cable_coil/update_icon()
	icon_state = "[initial(item_state)][amount < 3 ? amount : ""]"
	name = "cable [amount < 3 ? "piece" : "coil"]"

/obj/item/stack/cable_coil/attack_hand(mob/user)
	. = ..()
	if(istype(., /obj/item/stack/cabl_coil))
		var/obj/item/stack/cable_coil/new_cable = .
		new_cable.color = color
		new_cable.update_icon()

/obj/item/stack/cable_coil/attack_self(mob/user)
	if(amount < 15)
		to_chat(user, "<span class='notice'>You don't have enough cable coil to make restraints out of them</span>")
		return
	to_chat(user, "<span class='notice'>You start making some cable restraints.</span>")
	if(!do_after(user, 30, TRUE, user, TRUE) || !use(15))
		to_chat(user, "<span class='notice'>You fail to make cable restraints, you need to be standing still to do it</span>")
		return
	var/obj/item/restraints/handcuffs/cable/result = new(get_turf(user))
	user.put_in_hands(result)
	result.color = color
	to_chat(user, "<span class='notice'>You make some restraints out of cable</span>")

//add cables to the stack
/obj/item/stack/cable_coil/proc/give(extra)
	if(amount + extra > max_amount)
		amount = max_amount
	else
		amount += extra
	update_icon()

///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

// called when cable_coil is clicked on a turf
/obj/item/stack/cable_coil/proc/place_turf(turf/T, mob/user, dirnew)
	if(!isturf(user.loc))
		return

	if(!isturf(T) || T.intact || !T.can_have_cabling())
		to_chat(user, "<span class='warning'>You can only lay cables on catwalks and plating!</span>")
		return

	if(get_amount() < 1) // Out of cable
		to_chat(user, "<span class='warning'>There is no cable left!</span>")
		return

	if(get_dist(T,user) > 1) // Too far
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return

	var/dirn
	if(!dirnew) //If we weren't given a direction, come up with one! (Called as null from catwalk.dm and floor.dm)
		if(user.loc == T)
			dirn = user.dir //If laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(T, user)
	else
		dirn = dirnew

	for(var/obj/structure/cable/LC in T)
		if(LC.d2 == dirn && LC.d1 == 0)
			to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
			return

	var/obj/structure/cable/C = new(T, color, 0, dirn)
	C.add_fingerprint(user)

	use(1)

	if(C.shock(user, 50))
		if(prob(50)) //fail
			new /obj/item/stack/cable_coil(get_turf(C), 1, C.color)
			C.deconstruct()

	return C

// called when cable_coil is click on an installed obj/cable
// or click on a turf that already contains a "node" cable
/obj/item/stack/cable_coil/proc/cable_join(obj/structure/cable/C, mob/user, showerror = TRUE, forceddir)
	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = C.loc

	if(!isturf(T) || T.intact)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return


	if(U == T && !forceddir) //if clicked on the turf we're standing on and a direction wasn't supplied, try to put a cable in the direction we're facing
		place_turf(T,user)
		return

	var/dirn = get_dir(C, user)

	// one end of the clicked cable is pointing towards us and no direction was supplied
	if((C.d1 == dirn || C.d2 == dirn) && !forceddir)
		if(!U.can_have_cabling())						//checking if it's a plating or catwalk
			if (showerror)
				to_chat(user, "<span class='warning'>You can only lay cables on catwalks and plating!</span>")
			return
		if(U.intact)						//can't place a cable if it's a plating with a tile on it
			to_chat(user, "<span class='warning'>You can't lay cable there unless the floor tiles are removed!</span>")
			return
		else
			// cable is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked cable on our tile

			var/fdirn = turn(dirn, 180)		// the opposite direction

			for(var/obj/structure/cable/LC in U)		// check to make sure there's not a cable there already
				if(LC.d1 == fdirn || LC.d2 == fdirn)
					if (showerror)
						to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
					return

			var/obj/structure/cable/NC = new(U, color, 0, fdirn)
			NC.add_fingerprint(user)

			use(1)

			if (NC.shock(user, 50))
				if (prob(50)) //fail
					NC.deconstruct()
			return

	// exisiting cable doesn't point at our position or we have a supplied direction, so see if it's a stub
	else if(C.d1 == 0)
							// if so, make it a full cable pointing from it's old direction to our dirn
		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn


		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2


		for(var/obj/structure/cable/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				if (showerror)
					to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")

				return

		C.set_cable_directions(nd1, nd2)
		C.cable_color = color
		C.update_icon()
		C.add_fingerprint(user)

		use(1)

		if (C.shock(user, 50))
			if (prob(50)) //fail
				C.deconstruct()
				return

//////////////////////////////
// Misc.
/////////////////////////////

/obj/item/stack/cable_coil/red
	color = "red"

/obj/item/stack/cable_coil/yellow
	color = "yellow"

/obj/item/stack/cable_coil/blue
	color = "blue"

/obj/item/stack/cable_coil/green
	color = "green"

/obj/item/stack/cable_coil/pink
	color = "#ff3ccd"

/obj/item/stack/cable_coil/orange
	color = "#ff8000"

/obj/item/stack/cable_coil/cyan
	color = "cyan"

/obj/item/stack/cable_coil/white
	color = "white"

/obj/item/stack/cable_coil/random
	color = "#ffffff"

/obj/item/stack/cable_coil/random/Initialize(mapload, new_amount = null, param_color = null)
	. = ..()
	var/list/cable_colors = GLOB.cable_colors
	color = pick(cable_colors)

/obj/item/stack/cable_coil/random/five
	amount = 5

/obj/item/stack/cable_coil/cut
	amount = null
	icon_state = "coil2"

/obj/item/stack/cable_coil/cut/Initialize(mapload)
	. = ..()
	if(!amount)
		amount = rand(1,2)
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()

/obj/item/stack/cable_coil/cut/red
	color = "red"

/obj/item/stack/cable_coil/cut/yellow
	color = "yellow"

/obj/item/stack/cable_coil/cut/blue
	color = "blue"

/obj/item/stack/cable_coil/cut/green
	color = "green"

/obj/item/stack/cable_coil/cut/pink
	color = "#ff3ccd"
/obj/item/stack/cable_coil/cut/orange
	color = "#ff8000"

/obj/item/stack/cable_coil/cut/cyan
	color = "cyan"

/obj/item/stack/cable_coil/cut/white
	color = "white"

/obj/item/stack/cable_coil/cut/random
	color = "#ffffff"

/obj/item/stack/cable_coil/cut/random/Initialize(mapload, new_amount = null, param_color = null)
	. = ..()
	var/list/cable_colors = GLOB.cable_colors
	color = pick(cable_colors)

