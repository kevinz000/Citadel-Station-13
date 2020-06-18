/**
  * Runtime eval interpreter. Each instance of this holds things like variables, permissions, etc.
  */
/datum/runtime_eval/interpreter
	/// Local variables, key = value
	var/list/variables = list()

/datum/runtime_eval/interpreter/New()
	HardReset()

/**
  * Completely resets the state of the interpreter.
  */
/datum/runtime_eval/interpreter/proc/HardReset()
	variables = list()

/**
  * Called before each interpreter run of a new block of code.
  */
/datum/runtime_eval/interpreter/proc/SoftReset()
	variables["."] = null
	variables["usr"] = null
	ProcReset()

/**
  * Called before each proccall.
  */
/datum/runtime_eval/interpreter/proc/ProcReset()
	variables -= "src"
