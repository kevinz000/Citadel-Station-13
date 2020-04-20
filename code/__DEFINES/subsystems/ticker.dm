/// We use an arrivals shuttle to bring people to the station
#define ARRIVALS_METHOD_SHTUTLE			"shuttle"
/// We use a gateway to spawn people into the station.
#define ARRIVALS_METHOD_GATEWAY			"gateway"

/// We use an emergency shuttle to end the round
#define EVACUATION_METHOD_SHUTTLE		"shuttle"
/// We use a gateway to end the round
#define EVACUATION_METHOD_GATEWAY		"gateway"

// Evacuation stages
/// No evacuation occuring
#define EVACUATION_NOT_IN_PROGRESS				0
/// Evacuation travelling to station/calibrating/whatever
#define EVACUATION_TRANSITING_STATION			1
/// Evacuation at station, charging engines/whatever
#define EVACUATION_CHARGING						2
/// Evacuation moving to centcom/whatever
#define EVACUATION_TRANSITING_ENDGAME			3
/// Evacuation complete, round should be over
#define EVACUATION_COMPLETE						4
