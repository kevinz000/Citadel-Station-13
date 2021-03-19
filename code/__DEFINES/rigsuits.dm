// Rig zones
#define RIG_ZONE_HEAD	"head"
#define RIG_ZONE_CHEST	"chest"
#define RIG_ZONE_L_ARM	"l_arm"
#define RIG_ZONE_R_ARM	"r_arm"
#define RIG_ZONE_L_LEG	"l_leg"
#define RIG_ZONE_R_LEG	"r_leg"

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
