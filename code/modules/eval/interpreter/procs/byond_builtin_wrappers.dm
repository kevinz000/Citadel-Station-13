// How all of these work will be:
// Their first argument is the interpreter calling them.
// Their second argument is the list of arguments.
// Why am I doing this? Because otherwise named arguments won't work right
// ALL OF THESE MUST BE PREFIXED *EXACTLY* BY __EVAL__!
#define RUNTIME(msg) CRASH("[copytext(THIS_PROC_TYPE, 9)]: [msg]")
#define PROCDEF(byond_procname) \
/datum/runtime_eval/interpreter/INITIALIZE_PROCMAP(){ \
	. = ..(); \
	procmap[#byond_procname]=/proc/__EVAL__##byond_procname; \
}; \
/proc/__EVAL__##byond_procname(datum/runtime_eval/interpreter/interpreter, list/arguments)
#define GET_USR interpreter.variables["usr"]
#define GET_DOT interpreter.variables["."]
#define ARG(n) arguments[n]

PROCDEF(REGEX_QUOTE)
	return REGEX_QUOTE[ARG(1)]

PROCDEF(REGEX_QUOTE_REPLACEMENT)
	return REGEX_QUOTE_REPLACEMENT(ARG(1))

PROCDEF(abs)
	return abs(ARG(1))

PROCDEF(addtext)
	return jointext(arguments,"")

PROCDEF(alert)
	arguments.len = 6
	return alert(usr = ARG(1) || GET_USR, ARG(2), ARG(3), ARG(4) || "Ok", ARG(5), ARG(6))

PROCDEF(animate)
	animate(arglist(arguments))

PROCDEF(arccos)
	return arccos(ARG(1))

PROCDEF(arcsin)
	return arcsin(ARG(1))

PROCDEF(arctan)
	return arctan(ARG(1))

PROCDEF(arglist)
	CRASH("arglist is not allowed in runtime eval")

PROCDEF(ascii2text)
	return ascii2text(ARG(1))

PROCDEF(block)
	return block(ARG(1), ARG(2))

PROCDEF(bounds)
	return bounds(arglist(arguments))



#undef RUNTIME
#undef PROCDEF
#undef GET_USR
#undef GET_DOT
#undef ARG
