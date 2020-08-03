/**
  * Applies the specified amount of aim instability to this mob
  */
/mob/living/proc/ApplyAimInstability(amount)
	if(!(combat_flags & COMBAT_FLAG_AIM_INSTABILITY))
		return
	aim_instability += amount

/**
  * Gets our aim instability
  */
/mob/living/proc/GetAimInstability()
	return aim_instability * aim_instability_mod

/**
  * Updates our aim instability, decaying it by the amount needed since last decay.
  */
/mob/living/proc/DecayAimInstability()
	var/time = world.time - aim_instability_last
	aim_instability_last = world.time
	if(time < 0)
		return
	var/linear = AIM_INSTABILITY_DECAY_LINEAR * time
	var/decay_factor = (SEND_SIGNAL(src, COMSIG_COMBAT_MODE_CHECK) & COMBAT_MODE_INACTIVE)? AIM_INSTABILITY_DECAY_NORMAL : AIM_INSTABILITY_DECAY_COMBAT
	aim_instabiltiy = max(0, (aim_instability * (NUM_E ** (decay_factor * time))) - linear)
