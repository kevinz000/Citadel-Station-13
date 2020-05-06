/datum/lathe_queue_item
	var/design_id
	var/user_keyname

/datum/lathe_queue_item/New(design_id, user_keyname)
	src.design_id = design_id
	src.user_keyname = user_keyname

/**
  * Lathe machinery.
  *
  * Machines that print parts with raw materials and chemicals. Has build queues.
  */
/obj/machinery/lathe
	name = "lathe"
	desc = "Coders breaking shit again, this shouldn't exist!"
	density = TRUE
	icon_state = "autolathe"
	circuit = /obj/item/circuitboard/machine/lathe
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	layer = BELOW_OBJ_LAYER

	/// Build queue. design id = number of times to build.
	var/list/build_queue
	/// Max items in queue
	var/max_queue_items = 100
	/// Timerid for current build operation
	var/build_timerid
	/// Are we currently lathing?
	var/building = FALSE
	/// What are we currently building?
	var/datum/lathe_queue_item/currently_building
	/// Allowed materials to be inserted and used.
	var/list/allowed_materials = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/gold,
		/datum/material/silver,
		/datum/material/diamond,
		/datum/material/uranium,
		/datum/material/plasma,
		/datum/material/bluespace,
		/datum/material/bananium,
		/datum/material/titanium,
		/datum/material/runite,
		/datum/material/plastic,
		/datum/material/adamantine,
		/datum/material/mythril
		)
	/// Coefficient (multiplier) for material and reagent costs.
	var/efficiency_coefficient = 1
	/// Lathe flags
	var/lathe_flags = CAN_HANDLE_REAGENTS | CAN_HANDLE_MATERIALS
	/// Allowed build types
	var/build_types = NONE
	/// Allowed queue amounts
	var/list/allowed_queue_amounts = list(1, 5, 10)

/obj/machinery/lathe/Initialize(mapload)
	if(lathe_flags & CAN_HANDLE_MATERIALS)
		AddComponent(/datum/component/material_container, allowed_materials, _show_on_examine=TRUE, _after_insert=CALLBACK(src, .proc/AfterMaterialInsert))
	if(lathe_flags & CAN_HANDLE_REAGENTS)
		create_reagents(1000)
	return ..()

/**
  * Returns a list of design ids we can print.
  */
/obj/machinery/lathe/proc/return_designs()
	return list()

/**
  * Adds a design to our build queue.
  *
  * @params
  * datum/design - design to add, can also be text ID.
  */
/obj/machinery/lathe/proc/add_to_queue(datum/design/design, amount = 1, autostart = TRUE, mob/user)
	if(istype(design))
		design = design.id
	for(var/i in 1 to amount)
		if(length(build_queue) >= min(max_queue_items, 500))		// safety check.
			break
		build_queue += new /datum/lathe_queue_item(design, key_name(user))
	if(autostart)
		start_building()

/**
  * Removes the nth entry of the build queue.
  */
/obj/machinery/lathe/proc/remove_queue_index(index)
	if(!ISINRANGE(index, 1, length(build_queue)))
		return
	build_queue.Cut(index, index+1)

/**
  * Clears the build queue.
  */
/obj/machinery/lathe/proc/clear_queue()
	build_queue = null
	stop_building()

/**
  * Stops processing the build queue.
  */
/obj/machinery/lathe/proc/stop_building()
	if(!building)
		return
	say("Stopped processing queue.")
	if(build_timerid)
		deltimer(build_timerid)
		build_timerid = null
	building = FALSE
	update_icon()

/**
  * Starts processing the build queue.
  */
/obj/machinery/lathe/proc/start_building()
	if(building)
		return
	say("Started processing queue.")
	building = TRUE
	update_icon()
	check_queue_next()

/**
  * Checks the next item in queue. If unable to continue, stop building, else, refresh the build timer.
  */
/obj/machinery/lathe/proc/check_queue_next()
	if(!building)
		stop_building()
		return FALSE
	if(!length(build_queue))
		stop_building()
		return FALSE
	var/datum/lathe_queue_item/head_item = build_queue[1]
	var/datum/design/head = SSresearch.design_by_id(head_item.design_id)
	if(!check_can_print(head, TRUE))
		stop_building()
		return FALSE
	if(head_item != currently_building)
		currently_building = head_item
		if(build_timerid)
			deltimer(build_timerid)
			build_timerid = null
		addtimer(CALLBACK(src, .proc/finish_current_item), time_to_build(head))
	return TRUE

/**
  * Finish building the current item.
  */
/obj/machinery/lathe/proc/finish_current_item()
	var/datum/lathe_queue_item/head_item = currently_building
	var/datum/design/head = SSresearch.design_by_id(head_item.design_id)
	currently_building = null
	build_timerid = null
	if(!check_can_print(head, TRUE))
		investigate_log("Failed finishing design [head.name]([head.id]), queued by [head_item.user_keyname].")
		stop_building()
		return
	investigate_log("Lathed design [head.name]([head.id]), queued by [head_item.user_keyname].")
	#warn build item and use resources here, possibly with a new do_build() proc.
	check_queue_next()

/**
  * Check if we can print a design. Design must be a direct datum reference.
  */
/obj/machinery/lathe/proc/check_can_print(datum/design/D, say_error = FALSE)
	if(!istype(D))
		if(say_error)
			say("Encountered an invalid design.")
		return FALSE
	if(!(D.id in return_designs()))
		if(say_error)
			say("Design datacore error.")
		return FALSE
	if(!(D.build_type & build_types))
		if(say_error)
			say("Design not compatible with lathe.")
		return FALSE
	var/list/req_mat = get_material_cost(D)
	var/list/req_reag = get_reagent_cost(D)
	if(!has_materials(req_mat))
		if(say_error)
			say("Insufficient materials to continue construction.")
		return FALSE
	if(!has_reagents(req_reag))
		if(say_error)
			say("Insufficient reagents to continue construction.")
		return FALSE
	return TRUE

/**
  * Get a user friendly readout string of the materials we need to print an item.
  */
/obj/machinery/lathe/proc/design_cost_readout_string(datum/design/D)
	return resources_to_string(D.materials, D.reagents)s

/**
  * Process a list of materials/reagents.
  */
/obj/machinery/lathe/proc/resources_to_string(list/materials, list/reagents)
	. = list()
	for(var/ref in materials)
		var/datum/material/M = SSmaterials.GetMaterialRef(ref)
		. += "[materials[ref]] cm<sup>3</sup> of [M.name]"
	for(var/path in reagents)
		var/datum/reagent/R = path
		. += "[materials[path]] units of [initial(R.name)]"
	return english_list(.)

/**
  * Gets the reagents needed to print a design, taking into account efficiency_coefficient. Returns list(reagent typepath = value).
  */
/obj/machinery/lathe/proc/get_reagent_cost(datum/design/D)
	. = list()
	for(var/reagent in D.reagents)
		.[reagent] = D.reagents[reagent] * efficiency_coefficieny

/**
  * Gets the materials needed to print a design, taking into account efficiency_coefficient. Returns list(material ref = value).
  */
/obj/machinery/lathe/proc/get_material_cost(datum/design/D)
	. = list()
	for(var/ref in D.materials)
		.[ref] = D.materials[ref] * efficiency_coefficient

/**
  * Get amount of time to build a design.
  */
/obj/machinery/lathe/proc/time_to_build(datum/design/D)
	return D.base_build_speed

/obj/machinery/lathe/ui_static_data(mob/user)
	. = list()
	.["categories"] = list()
	.["designs"] = list()
	for(var/id in return_designs())
		var/datum/design/D = SSresearch.design_by_id(id)
		LAZYINITLIST(.["categories"][D.category])
		.["categories"][D.category] += D.id
		var/list/design_reagents = list()		//we have to do this since we can't send every reagent by name as static data.
		for(var/path in D.reagents)
			var/datum/reagent/R = path
			design_reagents[initial(R.name)] = D.reagents[path]
		.["designs"][D.id] = list("materials" = D.materials, "name" = D.name)
	.["materials"] = list()
	for(var/ref in allowed_materials)
		var/datum/material/M = SSmaterials.GetMaterialRef(ref)
		.["materials"] = list("name" = M.name)
	.["allowed_queue_amounts"] = allowed_queue_amounts

/obj/machinery/lathe/ui_data(mob/user)
	. = list()
	.["queue"] = list()
	for(var/id in build_queue)
		var/datum/design/D = SSresearch.design_by_id(id)
		.["queue"] += D.id
	.["available_materials"] = list()
	var/list/materials = available_materials()
	for(var/ref in materials)
		.["available_materials"][ref] = materials[ref]
	var/list/materials = available_reagents()
	.["available_reagents"] = list()
	for(var/path in reagents)
		var/datum/reagent/R = path
		.["available_reagents"][initial(R.name)] = reagents[path]
	if(.["building"] = building)
		.["current_item"] = currently_building.id
		.["time_left"] = timeleft(build_timerid)

/obj/machinery/lathe/proc/available_materials()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	. = list()
	for(var/ref in materials.materials)
		.[ref] = materials.materials[ref]

/obj/machinery/lathe/proc/use_materials(list/materials)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	return materials.use_materials(materials)

/obj/machinery/lathe/proc/has_materials(list/materials)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	return materials.has_materials(materials)

/obj/machinery/lathe/proc/available_reagents()


/obj/machinery/lathe/proc/use_reagents(list/reagents)


/obj/machinery/lathe/proc/has_reagents(list/reagents)

/obj/machinery/lathe/ui_act(action, params)
	if(. = ..())
		return
	switch(action)
		if("remove_queue_item")
			remove_queue_index(params["index"])
		if("clear_queue")
			clear_queue()
		if("queue")
			var/datum/design/D = SSresearch.design_by_id(params["id"])
			if(!D)
				return
			var/amount = text2num(params["amount"])
			if(!(amount in allowed_queue_amounts))
				message_admins("[usr] attempted to print an invalid amount from [src]([COORD(src)]).")
				log_admin("[usr] attempted to print an invalid amount from [src]([COORD(src)]).")
				return
			if(!check_can_print(D))
				message_admins("[usr] attempted to print an unavailable design from [src]([COORD(src)]).")
				log_admin("[usr] attempted to print an unavailable design from [src]([COORD(src)]).")
				return
			add_to_queue(D, amount)
		if("build_now")
			var/datum/design/D = SSresearch.design_by_id(params["id"])
			if(!D)
				return
			if(!check_can_print(D))
				message_admins("[usr] attempted to print an unavailable design.")
				log_admin("[usr] attempted to print an unavailable design.")
				return
			add_to_queue_front(D)
		if("eject_material")
			user_try_eject_material(params["material"], text2num(params["sheets"]))
		if("purge_reagent")
			user_try_purge_reagent(params["reagent"], text2num(params["amount"])
		if("start_building")
			start_building()
		if("stop_building")
			stop_building()

/obj/machinery/lathe/power_change()
	. = ..()
	if(stat & NOPOWER)
		if(building)
			say("Power lost to fabrication system.")
			stop_building()

/obj/machinery/lathe/ui_interact(mob/user, ui_key = "lathe", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "lathe", name, 700, 900, master_ui, state)
		ui.open()

/obj/machinery/lathe/autolathe
	name = "autolathe"
	desc = "It produces items using raw materials."
	lathe_flags = CAN_HANDLE_MATERIALS
	circuit = /obj/item/circuitboard/machine/lathe/autolathe
	build_types = AUTOLATHE

	var/hacked = FALSE
	var/hackable = TRUE
	var/disabled = 0
	var/shocked = FALSE
	var/hack_wire
	var/disable_wire
	var/shock_wire

	var/datum/techweb/stored_research = /datum/techweb/specialized/autounlocking/autolathe

/obj/machinery/lathe/autolathe/Initialize()
	wires = new /datum/wires/autolathe(src)
	stored_research = new stored_research
	matching_designs = list()

/obj/machinery/lathe/autolathe/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/lathe/autolathe/ui_interact(mob/user)
	. = ..()
	if(!is_operational())
		return

	if(shocked && !(stat & NOPOWER))
		shock(user,50)

	var/dat

	switch(screen)
		if(AUTOLATHE_MAIN_MENU)
			dat = main_win(user)
		if(AUTOLATHE_CATEGORY_MENU)
			dat = category_win(user,selected_category)
		if(AUTOLATHE_SEARCH_MENU)
			dat = search_win(user)

	var/datum/browser/popup = new(user, name, name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/lathe/autolathe/on_deconstruction()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()

/obj/machinery/lathe/autolathe/attackby(obj/item/O, mob/user, params)
	if (busy)
		to_chat(user, "<span class=\"alert\">The autolathe is busy. Please wait for completion of previous operation.</span>")
		return TRUE

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", O))
		updateUsrDialog()
		return TRUE

	if(default_deconstruction_crowbar(O))
		return TRUE

	if(panel_open && is_wire_tool(O))
		wires.interact(user)
		return TRUE

	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()

	if(stat)
		return TRUE

	if(istype(O, /obj/item/disk/design_disk))
		user.visible_message("[user] begins to load \the [O] in \the [src]...",
			"You begin to load a design from \the [O]...",
			"You hear the chatter of a floppy drive.")
		busy = TRUE
		var/obj/item/disk/design_disk/D = O
		if(do_after(user, 14.4, target = src))
			for(var/B in D.blueprints)
				if(B)
					stored_research.add_design(B)
		busy = FALSE
		return TRUE

	return ..()

/obj/machinery/lathe/autolathe/proc/AfterMaterialInsert(obj/item/item_inserted, id_inserted, amount_inserted)
	if(istype(item_inserted, /obj/item/stack/ore/bluespace_crystal))
		use_power(MINERAL_MATERIAL_AMOUNT / 10)
	else if(item_inserted.custom_materials?.len && item_inserted.custom_materials[SSmaterials.GetMaterialRef(/datum/material/glass)])
		flick("autolathe_r",src)//plays glass insertion animation by default otherwise
	else
		flick("autolathe_o",src)//plays metal insertion animation

		use_power(min(1000, amount_inserted / 100))
	updateUsrDialog()

/obj/machinery/lathe/autolathe/Topic(href, href_list)
	if(..())
		return
	if (!busy)
		if(href_list["make"])

			/////////////////
			//href protection
			being_built = stored_research.isDesignResearchedID(href_list["make"])
			if(!being_built)
				return

			var/multiplier = text2num(href_list["multiplier"])
			var/is_stack = ispath(being_built.build_path, /obj/item/stack)
			multiplier = clamp(multiplier,1,50)

			/////////////////

			var/coeff = (is_stack ? 1 : prod_coeff) //stacks are unaffected by production coefficient
			var/total_amount = 0

			for(var/MAT in being_built.materials)
				total_amount += being_built.materials[MAT]

			var/power = max(2000, (total_amount)*multiplier/5) //Change this to use all materials

			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

			var/list/materials_used = list()
			var/list/custom_materials = list() //These will apply their material effect, This should usually only be one.

			for(var/MAT in being_built.materials)
				var/datum/material/used_material = MAT
				var/amount_needed = being_built.materials[MAT] * coeff * multiplier
				if(istext(used_material)) //This means its a category
					var/list/list_to_show = list()
					for(var/i in SSmaterials.materials_by_category[used_material])
						if(materials.materials[i] > 0)
							list_to_show += i

					used_material = input("Choose [used_material]", "Custom Material") as null|anything in list_to_show
					if(!used_material)
						return //Didn't pick any material, so you can't build shit either.
					custom_materials[used_material] += amount_needed

				materials_used[used_material] = amount_needed

			if(materials.has_materials(materials_used))
				busy = TRUE
				use_power(power)
				icon_state = "autolathe_n"
				var/time = is_stack ? 32 : 32*coeff*multiplier
				addtimer(CALLBACK(src, .proc/make_item, power, materials_used, custom_materials, multiplier, coeff, is_stack), time)
			else
				to_chat(usr, "<span class=\"alert\">Not enough materials for this operation.</span>")

/obj/machinery/lathe/autolathe/proc/make_item(power, var/list/materials_used, var/list/picked_materials, multiplier, coeff, is_stack)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/atom/A = drop_location()
	use_power(power)
	materials.use_materials(materials_used)

	if(is_stack)
		var/obj/item/stack/N = new being_built.build_path(A, multiplier)
		N.update_icon()
		N.autolathe_crafted(src)
	else
		for(var/i=1, i<=multiplier, i++)
			var/obj/item/new_item = new being_built.build_path(A)
			new_item.autolathe_crafted(src)

			if(length(picked_materials))
				new_item.set_custom_materials(picked_materials, 1 / multiplier) //Ensure we get the non multiplied amount

	icon_state = "autolathe"
	busy = FALSE
	updateDialog()

/obj/machinery/lathe/autolathe/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/matter_bin/MB in component_parts)
		T += MB.rating*75000
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.max_amount = T
	T=1.2
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T -= M.rating*0.2
	prod_coeff = min(1,max(0,T)) // Coeff going 1 -> 0,8 -> 0,6 -> 0,4

/obj/machinery/lathe/autolathe/examine(mob/user)
	. += ..()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Storing up to <b>[materials.max_amount]</b> material units.<br>Material consumption at <b>[prod_coeff*100]%</b>.</span>"

/obj/machinery/lathe/autolathe/proc/reset(wire)
	switch(wire)
		if(WIRE_HACK)
			if(!wires.is_cut(wire))
				adjust_hacked(FALSE)
		if(WIRE_SHOCK)
			if(!wires.is_cut(wire))
				shocked = FALSE
		if(WIRE_DISABLE)
			if(!wires.is_cut(wire))
				disabled = FALSE

/obj/machinery/lathe/autolathe/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7, TRUE))
		return TRUE
	else
		return FALSE

/obj/machinery/lathe/autolathe/proc/adjust_hacked(state)
	hacked = state
	if(!hackable && hacked)
		return
	for(var/id in SSresearch.techweb_designs)
		var/datum/design/D = SSresearch.design_by_id(id)
		if((D.build_type & AUTOLATHE) && ("hacked" in D.category))
			if(hacked)
				stored_research.add_design(D)
			else
				stored_research.remove_design(D)

/obj/machinery/lathe/autolathe/hacked/Initialize()
	. = ..()
	adjust_hacked(TRUE)

/obj/machinery/lathe/autolathe/secure
	name = "secured autolathe"
	desc = "An autolathe reprogrammed with security protocols to prevent hacking."
	hackable = FALSE
	circuit = /obj/item/circuitboard/machine/lathe/autolathe/secure
	stored_research = /datum/techweb/specialized/autounlocking/autolathe/public

/obj/machinery/lathe/autolathe/toy
	name = "autoylathe"
	desc = "It produces toys using plastic, metal and glass."
	circuit = /obj/item/circuitboard/machine/lathe/autolathe/toy
	build_types = AUTOYLATHE

	stored_research = /datum/techweb/specialized/autounlocking/autolathe/toy
	allowed_materials = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/plastic
		)

/obj/machinery/lathe/autolathe/toy/hacked/Initialize()
	. = ..()
	adjust_hacked(TRUE)
