//Defines for atom layers and planes
//KEEP THESE IN A NICE ACSCENDING ORDER, PLEASE

// This file is organized by plane followed by the layers that will be used by objects on said plane. Misc things go below the main section.

/////////////////// UNDERLAY BACKDROPS /////////////
/// Void plane
#define PLANE_VOID -100
/// Clickcatcher plane aka what captures clicks if you click on a black spot of the screen
#define CLICKCATCHER_PLANE -99

/////////////////// GAME WORLD /////////////////////

#define PLANE_SPACE -95
#define PLANE_SPACE_RENDER_TARGET "*PLANE_SPACE"
#define PLANE_SPACE_PARALLAX -90
#define PLANE_SPACE_PARALLAX_RENDER_TARGET "*PLANE_SPACE_PARALLAX"

#define SPACE_LAYER 1.8

#define OPENSPACE_LAYER 17 //Openspace layer over all
#define OPENSPACE_PLANE -8 //Openspace plane below all turfs
#define OPENSPACE_RENDER_TARGET "*OPENSPACE"
#define OPENSPACE_BACKDROP_PLANE -7 //Black square just over openspace plane to guaranteed cover all in openspace turf
#define OPENSPACE_BACKDROP_RENDER_TARGET "*OPENSPACE_BACKDROP"

#define FLOOR_PLANE -6
#define FLOOR_PLANE_RENDER_TARGET "*FLOOR_PLANE"

/// Turf rendering plane, all turfs should render into this.
#define TURF_PLANE -5
#define TURF_RENDER_TARGET "*TURF_SUBRENDER"

#define GAME_PLANE -1
#define GAME_PLANE_RENDER_TARGET "*GAME_PLANE"

#define BLACKNESS_PLANE 0 //To keep from conflicts with SEE_BLACKNESS internals
#define BLACKNESS_PLANE_RENDER_TARGET "*BLACKNESS_PLANE"

#define EMISSIVE_BLOCKER_PLANE 12
#define EMISSIVE_BLOCKER_LAYER 12
#define EMISSIVE_BLOCKER_RENDER_TARGET "*EMISSIVE_BLOCKER_PLANE"

#define EMISSIVE_PLANE 13
#define EMISSIVE_LAYER 13
#define EMISSIVE_RENDER_TARGET "*EMISSIVE_PLANE"

#define EMISSIVE_UNBLOCKABLE_PLANE 14
#define EMISSIVE_UNBLOCKABLE_LAYER 14
#define EMISSIVE_UNBLOCKABLE_RENDER_TARGET "*EMISSIVE_UNBLOCKABLE_PLANE"

#define LIGHTING_PLANE 15
#define LIGHTING_LAYER 15
#define LIGHTING_RENDER_TARGET "*LIGHT_PLANE"

#define ABOVE_LIGHTING_PLANE 16
#define ABOVE_LIGHTING_LAYER 16
#define ABOVE_LIGHTING_RENDER_TARGET "*ABOVE_LIGHTING_PLANE"

#define CAMERA_STATIC_PLANE 19
#define CAMERA_STATIC_LAYER 19
#define CAMERA_STATIC_RENDER_TARGET "*CAMERA_STATIC_PLANE"

#define FULLSCREEN_PLANE 20
#define FLASH_LAYER 20
#define FULLSCREEN_LAYER 20.1
#define UI_DAMAGE_LAYER 20.2
#define BLIND_LAYER 20.3
#define CRIT_LAYER 20.4
#define CURSE_LAYER 20.5
#define FULLSCREEN_RENDER_TARGET "*FULLSCREEN_PLANE"

/// Game rendering plane, all game world (like lighting, floors, mobs, people, objects, things, not HUDs or eye effects or anything) planes should draw onto this one.
#define GAME_RENDERING_PLANE 50
#define GAME_RENDERING_TARGET "*GAME_RENDER"

/////////////////// HUD ////////////////////////////

/// HUD plane, all general HUD elements should be on this plane.
#define HUD_PLANE 60
#define HUD_LAYER 21
#define HUD_RENDER_TARGET "*HUD_PLANE"

#define VOLUMETRIC_STORAGE_BOX_PLANE 70
#define VOLUMETRIC_STORAGE_BOX_LAYER 23
#define VOLUMETRIC_STORAGE_BOX_RENDER_TARGET "*VOLUME_STORAGE_BOX_PLANE"

#define VOLUMETRIC_STORAGE_ITEM_PLANE 71
#define VOLUMETRIC_STORAGE_ITEM_LAYER 24
#define VOLUMETRIC_STORAGE_ITEM_RENDER_TARGET "*VOLUME_STORAGE_ITEM_PLANE"

#define ABOVE_HUD_PLANE 80
#define ABOVE_HUD_LAYER 25
#define ABOVE_HUD_RENDER_TARGET "*ABOVE_HUD_PLANE"

/// HUD rendering plane, all HUD elements should render onto this plane.
#define HUD_RENDERING_PLANE 95
#define HUD_RENDERING_TARGET "*HUD_RENDER"

/////////////////// SPLASHSCREEN ///////////////////
/// Splashscreen plane.
#define SPLASHSCREEN_PLANE 200
#define SPLASHSCREEN_RENDER_TARGET "*SPLASHSCREEN"

#define SPLASHSCREEN_LAYER 30

//////////////////// FINAL /////////////////////////
/// Final rendering plane, all other planes should draw onto this one via plane_masters and render_target/sources.
#define FINAL_RENDER_PLANE 100

//#define TURF_LAYER 2 //For easy recordkeeping; this is a byond define
#define MID_TURF_LAYER 2.02
#define HIGH_TURF_LAYER 2.03
#define TURF_PLATING_DECAL_LAYER 2.031
#define TURF_DECAL_LAYER 2.039 //Makes turf decals appear in DM how they will look inworld.
#define ABOVE_OPEN_TURF_LAYER 2.04
#define CLOSED_TURF_LAYER 2.05
#define BULLET_HOLE_LAYER 2.06
#define ABOVE_NORMAL_TURF_LAYER 2.08
#define LATTICE_LAYER 2.2
#define DISPOSAL_PIPE_LAYER 2.3
#define GAS_PIPE_HIDDEN_LAYER 2.35
#define WIRE_LAYER 2.4
#define WIRE_TERMINAL_LAYER 2.45
#define GAS_SCRUBBER_LAYER 2.46
#define GAS_PIPE_VISIBLE_LAYER 2.47
#define GAS_FILTER_LAYER 2.48
#define GAS_PUMP_LAYER 2.49
#define LOW_OBJ_LAYER 2.5
#define LOW_SIGIL_LAYER 2.52
#define SIGIL_LAYER 2.54
#define HIGH_SIGIL_LAYER 2.56

#define BELOW_OPEN_DOOR_LAYER 2.6
#define BLASTDOOR_LAYER 2.65
#define OPEN_DOOR_LAYER 2.7
#define DOOR_HELPER_LAYER 2.71 //keep this above OPEN_DOOR_LAYER
#define PROJECTILE_HIT_THRESHHOLD_LAYER 2.75 //projectiles won't hit objects at or below this layer if possible
#define TABLE_LAYER 2.8
#define TRAY_LAYER 2.85
#define BELOW_OBJ_LAYER 2.9
#define LOW_ITEM_LAYER 2.95
//#define OBJ_LAYER 3 //For easy recordkeeping; this is a byond define
#define CLOSED_BLASTDOOR_LAYER 3.05
#define CLOSED_DOOR_LAYER 3.1
#define CLOSED_FIREDOOR_LAYER 3.11
#define SHUTTER_LAYER 3.12 // HERE BE DRAGONS
#define ABOVE_OBJ_LAYER 3.2
#define ABOVE_WINDOW_LAYER 3.3
#define SIGN_LAYER 3.4
#define NOT_HIGH_OBJ_LAYER 3.5
#define HIGH_OBJ_LAYER 3.6

#define BELOW_MOB_LAYER 3.7
#define LYING_MOB_LAYER 3.8
#define MOB_LOWER_LAYER 3.95
//#define MOB_LAYER 4 //For easy recordkeeping; this is a byond define
#define MOB_UPPER_LAYER 4.05
#define ABOVE_MOB_LAYER 4.1
#define WALL_OBJ_LAYER 4.25
#define EDGED_TURF_LAYER 4.3
#define ON_EDGED_TURF_LAYER 4.35
#define LARGE_MOB_LAYER 4.4
#define ABOVE_ALL_MOB_LAYER 4.5

#define SPACEVINE_LAYER 4.8
#define SPACEVINE_MOB_LAYER 4.9
//#define FLY_LAYER 5 //For easy recordkeeping; this is a byond define
#define GASFIRE_LAYER 5.05
#define RIPPLE_LAYER 5.1

#define GHOST_LAYER 6
#define LOW_LANDMARK_LAYER 9
#define MID_LANDMARK_LAYER 9.1
#define HIGH_LANDMARK_LAYER 9.2
#define AREA_LAYER 10
#define MASSIVE_OBJ_LAYER 11
#define POINT_LAYER 12

#define CHAT_LAYER 12.1


