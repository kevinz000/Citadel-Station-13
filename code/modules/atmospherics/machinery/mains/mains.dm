/**
 * Mains type
 *
 * Connects layers without intermixing.
 *
 * NODE ORDER:
 * Always will be a multiple of 5n + (l - 1), where l is layer, and n is any number.
 */
/obj/machinery/atmospherics/mains
	/// Temporarily stores air while rebuilding pipeline. Index is layer
	var/list/datum/gas_mixture/temporary_airs
	/// Our volume per line.
	var/volume = 70
	/// The pipelines we belong to, if any. Index is layer.
	var/list/datum/pipeline/pipelines

	level = 1

	use_power = NO_POWER_USE
	can_unwrench = TRUE

	//Buckling
	can_buckle = TRUE
	buckle_requires_restraints = TRUE
	buckle_lying = -1

/obj/machinery/atmospherics/mains/InitAtmos()
	// For now, mains will ALWAYS hold max airs/pipelines
	temporary_airs = new /list(PIPE_LAYER_TOTAL)
	pipeliens = new /list(PIPE_LAYER_TOTAL)
	. = ..()
	var/turf/T = loc
	hide(T.intact)

/obj/machinery/atmospherics/mains/Teardown()
	for(var/i in 1 to pipelines.len)
		if(pipelines[i])
			QDEL_NULL(pipelines[i])

/obj/machinery/atmospherics/mains/Build()
	for(var/i in 1 to pipelines.len)
		if(!pipelines[i])
			var/datum/pipeline/PL = new
			pipelines[i] = PL
			PL.build_pipeline(src)

/obj/machinery/atmospherics/mains/DirectConnection(datum/pipeline/querying, obj/machinery/atmospherics/source)

/obj/machinery/atmospherics/mains/GetNodeIndex(dir, layer)


/obj/machinery/atmospherics/mains/ReleaseAirToTurf()
	for(var/i in 1 to temporary_airs.len)
		var/datum/gas_mixture/GM = temporary_airs[i]
		if(!GM)
			continue
		var/turf/T = loc
		T.assume_air(GM)
		air_update_turf()

/obj/machinery/atmospherics/mains/ReplacePipeline(datum/pipeline/old, datum/pipeline/replacing)
	var/index = pipelines.Find(old)
	if(!index)
		CRASH("Could not find pipeline to replace on [src] ([COORD(src)]). Old: [old] Replacing: [replacing]")
	pipelines[index] = replacing

/obj/machinery/atmospherics/mains/SetPipeline(datum/pipeline/setting, obj/machinery/atmospherics/source)
	pipelines[source.pipe_layer] = setting

/obj/machinery/atmospherics/mains/NullifyPipeline(datum/pipeline/removing)
	var/index = pipelines.Find(removing)
	if(!index)
		CRASH("Could not find pipeline to remove on [src] ([COORD(src)]). Removing: [removing]")
	pipelines[index] = null

/obj/machinery/atmospherics/mains/analyzer_act(mob/living/user, obj/item/I)
	user.visible_message("[user] has used the analyzer on [icon2html(icon, viewers(user))] [target].", "<span class='notice'>You use the analyzer on [icon2html(icon, user)] [target].</span>")
	for(var/i in 1 to pipelines.len)
		if(!pipelines[i])
			continue
		var/datum/pipeline/pipeline = pipelines[i]
		to_chat(user, "----- PIPELINE [i] -----")
		atmosanalyzer_scan(pipeline.air, user, src, FALSE)
	return TRUE

/obj/machinery/atmospherics/pipe/Destroy()
	ReleaseAirToTurf()
	if(air_temporary)
		QDEL_NULL(air_temporary)
	var/turf/T = loc
	for(var/obj/machinery/meter/meter in T)
		if(meter.target == src)
			var/obj/item/pipe_meter/PM = new (T)
			meter.transfer_fingerprints_to(PM)
			qdel(meter)
	return ..()

/obj/machinery/atmospherics/mains/update_alpha()
	alpha = invisibility ? 64 : 255

/obj/machinery/atmospherics/mains/ReturnPipelines()
	. = ..()
	for(var/i in 1 to pipelines.len)
		if(!pipelines[i])
			continue
		. += pipelines[i]

/obj/machinery/atmospherics/mains/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee" && damage_amount < 12)
		return 0
	. = ..()

/obj/machinery/atmospherics/pipe/attack_ghost(mob/dead/observer/O)
	. = ..()
	for(var/i in 1 to pipelines.len)
		if(!pipelines[i])
			continue
		var/datum/pipeline/pipeline = pipelines[i]
		to_chat(user, "----- PIPELINE [i] -----")
		atmosanalyzer_scan(pipeline.air, user, src, FALSE)
