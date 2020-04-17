/obj/item/organ/rock
	name = "rock"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "rock"
	force = 10		//fire extinguisher damage
	throw_range = 10
	throw_speed = 2
	throwforce = 15
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_ROCK
	// this is our cell variable. instead of having a cell however, as you can't initialize variables as a = in the object's definition, we are instead assigning it a typepath
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell/high

// New() is called when being created, but we don't want that because that's not as efficient (and we can't manage when that's called like with initialize)

// this is called during SSatoms Initialize(), or, if it's already past map initialization, the moment New() is called
/obj/item/organ/rock/Initialize(mapload)
	. = ..()		//calls parent's Initialize and sets the return value (the .) to whatever it returns, this is required for initialize to function properly
	// we take the typepath that's in cell and create a new cell
	if(ispath(cell))		//if it's a typepath (we shouldn't check for this actually but we'll do it anyways lol
		cell = new cell		//creates the cell using its typepath. if you just do cell = new, it will create it but not with the typepath we set
	// at this point the cell is made

// this proc will try to consume the amount, and return TRUE/FALSE depending on if it worked
/obj/item/organ/rock/proc/consume_charge(amount)
	if(!cell)	//if cell is considered FALSE, which includes if it doesn't exist
		return 0		//failed
	return cell.use(amount)		//cell.use returns TRUE/FALSE depends on if it could use the amount required


