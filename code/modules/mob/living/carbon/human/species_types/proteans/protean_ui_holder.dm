#define UPGRADE_1 (1<<0)
#warn todo: upgrades and move the flag to somewhere safe.

/datum/protean_holder
	/// Us! The mob owning this.
	var/mob/living/carbon/protean = null
	/// Upgrades we have (bflag)
	var/upgrades = NONE

/datum/protean_holder/New(mob/living/carbon/nyanite)
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
	.["name"] = nyanite.real_name

/datum/protean_holder/ui_act(action, list/params)
	. = ..()
	if(!.)
		return

/datum/protean_holder/proc/upgrade1()
	return "dosomething here"
