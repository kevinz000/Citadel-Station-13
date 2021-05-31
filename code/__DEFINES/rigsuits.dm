// Rig zones
#define RIG_ZONE_HEAD	"head"
#define RIG_ZONE_CHEST	"chest"
#define RIG_ZONE_L_ARM	"l_arm"
#define RIG_ZONE_R_ARM	"r_arm"
#define RIG_ZONE_L_LEG	"l_leg"
#define RIG_ZONE_R_LEG	"r_leg"

// Rig piece types - only one of each type should exist on a given rig.
// This is a bitfield
/// Head - RIG_ZONE_HEAD translates to this
#define RIG_PIECE_HEAD		(1<<0)
/// Suit - RIG_ZONE_CHEST translates to this
#define RIG_PIECE_SUIT		(1<<1)
/// Gauntlets - RIG_ZONE_L/R_ARM translates to this
#define RIG_PIECE_GAUNTLETS	(1<<2)
/// Boots - RIG_ZONE_L/R_LEG translates to this
#define RIG_PIECE_BOOTS		(1<<3)

// Global list lookup for rig zone to piece bitflag
GLOBAL_LIST_INIT(rig_zone_lookup, list(
	RIG_ZONE_HEAD = RIG_PIECE_HEAD,
	RIG_ZONE_CHEST = RIG_PIECE_SUIT,
	RIG_ZONE_L_ARM = RIG_PIECE_GAUNTLETS,
	RIG_ZONE_R_ARM = RIG_PIECE_GAUNTLETS,
	RIG_ZONE_L_LEG = RIG_PIECE_BOOTS,
	RIG_ZONE_R_LEG = RIG_PIECE_BOOTS
))

// Weight

// Weight amounts on modules/armor/exception
/// No weight, why is this a define.
#define RIGSUIT_WEIGHT_NONE			0
/// Low weight items
#define RIGSUIT_WEIGHT_LOW			10
/// Medium weight items
#define RIGSUIT_WEIGHT_MEDIUM		30
/// High weight items
#define RIGSUIT_WEIGHT_HIGH			50
/// Extremely bulky items
#define RIGSUIT_WEIGHT_EXTREME		70

// Weight thresholds
/// Threshold at which the user is slowed down
#define RIGSUIT_WEIGHT_SLOWDOWN_THRESHOLD	50
/// Divisor for slowdown per weight post threshold
#define RIGSUIT_WEIGHT_SLOWDOWN_DIVISOR		50

// Component conflict types - bitfield.
// Armor, thermal, and pressure modules are never conflicting, as there can only be one.
