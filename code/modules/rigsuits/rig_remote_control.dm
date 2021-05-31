/**
 * RIGSUIT REMOTE CONTROL
 *
 * Remote control will generally involve one of the following:
 * - If the controller is something like a carded AI, which is physically in the rigsuit, their view will be directly jacked into it with necessary UI to function. It's like as if they're controlling the host.
 * - If the controller is not, like a malf AI hacking a RIG, their view will pop up on a TGUI screen. A toggle will be provided to redirect their movement/clicks. This is highly experimental.
 */

/**
 * Gets the control flags of a user.
 */
/obj/item/rig/proc/get_control_flags(mob/M)
	if(!fakeuser && (M == user))
		return user_control_flags
	if(M in remote_controllers)
		return remote_controllers[M]
	return NONE
