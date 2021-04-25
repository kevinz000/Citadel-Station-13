#define UPGRADE_1 (1<<0)
#warn todo: upgrades and move the flag to somewhere safe.

/datum/protean_holder
	/// Us! The mob owning this.
	var/mob/living/carbon/human/protean = null
	/// Upgrades we have (bflag)
	var/upgrades = NONE

/datum/protean_holder/New(mob/living/carbon/human/nyanite)
	if(!istype(nyanite))
		CRASH("Protean holder initialized with an invalid type! Object passed [nyanite].") //fuck you
	protean = nyanite

/datum/protean_holder/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "ProteanUI")
		ui.open()

/datum/protean_holder/ui_data()
	. = ..()

/datum/protean_holder/ui_static_data()
	. = ..()
	.["name"] = protean.real_name

/datum/protean_holder/ui_act(action, list/params)
	. = ..()
	if(!.)
		return
	switch(action)
		if("hhhhhh")
			protean.adjust_arousal(255, "/bin/horny", FALSE, TRUE)
			. = TRUE
		if("upgrade1_toggle")
			upgrade1()
			. = TRUE

/datum/protean_holder/proc/upgrade1()
	return "dosomething here"

//alt
// okay so for this, we need a datum for each ui holder
// which means 1 nyanite player = 5~? programs
/datum/protean_program
	var/name
	var/desc
	var/tgui_id

/datum/protean_program/medic
	name = "Healium"
	desc = "Pariatur eu magna consequat aute excepteur nisi dolore. Ullamco quis ex amet anim duis. Dolor ex velit deserunt sint ad anim."

/datum/protean_program/medic/ui_act(action, list/params)
	. = ..()
	if(!.)
		return


