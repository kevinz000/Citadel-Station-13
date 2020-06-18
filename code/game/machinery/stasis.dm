/**
  * Stasis beds!
  * 
  * Hybrid open-top buckle-operated stasis units used to halt life processes without killing a patient for intensive manual reconstruction and surgery,
  * and used as a triage unit thanks to the slow trickle healing provided while a patient is buckled in.
  * 
  * Functionality:
  * Adjustable stasis from 0 to 100. Full, or 100% stasis halts all life functions until removal. Anywhere below halts (%+1)/100 of life ticks.
  *     Note: Non Life() processes will not consider the patient to be in stasis unless this is at 100%/full.
  * Dialysis - Remove reagents from blood into beaker
  * Healing - Slowish -3 across the board per second healing. This is based on Life ticks, so having stasis on will prevent this from happening.
  * Radiation purge - Removes 25 radiation per second from the patient.
  * Incapacitation purge - Removes 2 seconds of incapacitation effects per second on the patient.
  */
/obj/machinery/stasis_bed

