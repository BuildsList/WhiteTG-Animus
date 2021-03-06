var/datum/configuration/config = null
var/datum/protected_configuration/protected_config = null

var/host = null
var/join_motd = null
var/station_name = null
var/game_version = "/tg/ Station 13"
var/changelog_hash = ""

var/ooc_allowed = 1	// used with admin verbs to disable ooc - not a config option apparently
var/looc_allowed = 1
var/dooc_allowed = 1
var/abandon_allowed = 1
var/enter_allowed = 1
var/guests_allowed = 1
var/shuttle_frozen = 0
var/shuttle_left = 0
var/tinted_weldhelh = 1


// Debug is used exactly once (in living.dm) but is commented out in a lot of places.  It is not set anywhere and only checked.
// Debug2 is used in conjunction with a lot of admin verbs and therefore is actually legit.
var/Debug = 0	// global debug switch
var/Debug2 = 0

//Server API key
var/global/comms_key = "default_pwd"
var/global/comms_allowed = 0 //By default, the server does not allow messages to be sent to it, unless the key is strong enough (this is to prevent misconfigured servers from becoming vulnerable)


//This was a define, but I changed it to a variable so it can be changed in-game.(kept the all-caps definition because... code...) -Errorage
var/MAX_EX_DEVESTATION_RANGE = 3
var/MAX_EX_HEAVY_RANGE = 7
var/MAX_EX_LIGHT_RANGE = 14
var/MAX_EX_FLASH_RANGE = 14
var/MAX_EX_FLAME_RANGE = 14

