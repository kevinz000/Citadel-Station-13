/datum/protean_holder
	/// The tgui
	var/datum/tgui/ui = null
	/// Us!
	var/mob/living/carbon/protean = null
	/// Installed programs
	var/list/programs = list()

/datum/proteean_holder/New(mob/living/carbon/nyanite)
	protean = nyanite
