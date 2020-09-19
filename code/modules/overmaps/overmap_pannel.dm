#define MAP_TYPE_SHIP "SHIP"
#define MAP_TYPE_STATION "STATION"
#define MAP_TYPE_ASTEROID "ASTEROID"
#define MAP_TYPE_MISC "MISC"

#define MAP_ALIGNMENT_NT "NT"
#define MAP_ALIGNMENT_SYNDIE "SYNDIE"
#define MAP_ALIGNMENT_NEUTRAL "NEUTRAL"
GLOBAL_DATUM_INIT(datum/overmap_pannel, omap_debugbus, new)
/**
  * Overmap pannel class
  * only used for #debug-bus right now.
  */
/datum/overmap_pannel
	/// JSON of ships ({"shipID": list(X, Y, ROT(0, 360)}) last seen to stop meowtagame. this acts as the fallback if live man data didn't send (optimizon)
	var/list/map_ships = list()
	/// JSON of map clutter (asteroid, station etc...) same format as ships BUT with acurate* location.
	var/list/map_static = list() //should i merge this into one?
	/// metainfo of the ship/ast/rock. DOES NOT INCLUDE POSITION DATA. only update once visible mayhaps?
	/// ex: { ID: {TYPE, ALIGNMENT, NAME, DESC}
	///  "shipID": {MAP_TYPE_SHIP, MAP_ALIGNMENT_NT, "NSV DEBUGBUS", "This is the ship"}, 
	///  "clutterID": {MAP_TYPE_ASTEROID, MAP_ALIGNMENT_NEUTRAL, "XYZ123", ""},
	///  "shipID": {MAP_TYPE_SHIP, MAP_ALIGNMENT_SYNDIE, "SSV Syndicats", "evil tator ship"}
	/// }
	var/list/meta_info = list()

	/// Live data of the map (seen ship locations and other things)
	/// ex: {{"shipID": list(X, Y, ROT(0, 360))}, {"some_rockID": list(32, 51, 45)}}
	var/list/live_map_data = list()

	var/map_size = list(255, 255)
	var/simulating_already = FALSE

/datum/overmap_pannel/ui_state(mob/user) //DEBUG ONLY!!
	return GLOB.default_state

/datum/overmap_pannel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvermapPannel")
		ui.open()

/datum/overmap_pannel/ui_data(mob/user)
	. = list()
	.["map_data"] = live_map_data //muh based optimization.

/datum/overmap_pannel/ui_static_data(mob/user)
	. = list()
	.["map_ships"] = map_ships
	.["map_static"] = map_static
	.["meta_info"] = meta_info
	.["map_size"] = map_size

/datum/overmap_pannel/ui_act(action, params)
	switch(action)
		if("move")
			//do magic
			. = TRUE
		if("simulate")
			//param should return us some dats
			if(params["map_data"])
				live_map_data = params["map_data"]
			if(params["map_ships"])
				map_ships = params["map_ships"]
			if(params["map_static"])
				map_static = params["map_static"]
			if(params["meta_info"])
				meta_info = params["meta_info"]
		if("simulate_lazy")
			if(simulating_already)
				return //do not doublecall
			INVOKE_ASYNC(src, .proc/doSimulation())
			. = TRUE
			
/datum/overmap_pannel/proc/doSimulation()
	if(simulating_already)
		return //do not doublecall
	simulating_already = TRUE
	live_map_data = list()
	map_ships = list("ship-main" = list(113, 133, 0), "clownshit-1" = list(113, 116, 0), "ship-debugbus-1" = list(100, 133, 280))
	map_static = list("station-ss13" = list(113, 112, 0), "station-ks13" = list(100, 130, 0)) //wtf station with rotation???
	meta_info = list(
		"ship-main" = list(MAP_TYPE_SHIP, MAP_ALIGNMENT_NT, "NSV DEBUGBUS", "does this shit work? NOPE"),
		"clownshit-1" = list(MAP_TYPE_SHIP, MAP_ALIGNMENT_NEUTRAL, "AST HONKBUS", "honk dot ogg"),
		"ship-debugbus-1" = list(MAP_TYPE_SHIP, MAP_ALIGNMENT_SYNDIE, "Syndie Ship", "evil!"),
		"station-ss13" = list(MAP_TYPE_STATION, MAP_ALIGNMENT_NT, "Space Station 13", "THE ss13."),
		"station-ks13" = list(MAP_TYPE_STATION, MAP_ALIGNMENT_NEUTRAL, "KS 13", "This does not exist. Please re-calibrate your sensors.")
	)
	sleep(20)
	INVOKE_ASYNC(src, .proc/moveObject("ship-main", list(150, 133))) //wizardry included (moving and shit)
	sleep(20)
	INVOKE_ASYNC(src, .proc/moveObject("ship-debugbus-1", list(140, 129))) //wizardry included (moving and shit)
	simulating_already = FALSE

/datum/overmap_pannel/proc/moveObject(id, list/position, ship = TRUE, est_arrival = 40) //this does not call update staticdata
	live_map_data[id] = position
	if(ship)
		map_ships[id] = position
	else
		to_chat(world, "did you seriusly fucking move a station. WHAT THE FUCK???")
		map_static[id] = position

/client/verb/overmap_debugbus()
	set name = "Overmap Devtools&trade;"
	var/mob/user = src && src.mob
	if(!user)
		return
	if(!GLOB.omap_debugbus)
		to_chat(user, "AAAAAA OMAP DID NOT INITIALIZE!!!")
		return
	GLOB.omap_debugbus.ui_interact(user)

/datum/overmap_pannel/admin
	var/doesnotwork = TRUE
