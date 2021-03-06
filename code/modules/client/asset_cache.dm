/*
Asset cache quick users guide:

Make a datum at the bottom of this file with your assets for your thing.
The simple subsystem will most like be of use for most cases.
Then call get_asset_datum() with the type of the datum you created and store the return
Then call .send(client) on that stored return value.

You can set verify to TRUE if you want send() to sleep until the client has the assets.
*/


// Amount of time(ds) MAX to send per asset, if this get exceeded we cancel the sleeping.
// This is doubled for the first asset, then added per asset after
#define ASSET_CACHE_SEND_TIMEOUT 7

//When sending mutiple assets, how many before we give the client a quaint little sending resources message
#define ASSET_CACHE_TELL_CLIENT_AMOUNT 8

/client
	var/list/cache = list() // List of all assets sent to this client by the asset cache.
	var/list/completed_asset_jobs = list() // List of all completed jobs, awaiting acknowledgement.
	var/list/sending = list()
	var/last_asset_job = 0 // Last job done.

//This proc sends the asset to the client, but only if it needs it.
//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset(var/client/client, var/asset_name, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	if(client.cache.Find(asset_name) || client.sending.Find(asset_name))
		return 0

	client << browse_rsc(SSasset.cache[asset_name], asset_name)
	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if (client)
			client.cache += asset_name
		return 1
	if (!client)
		return 0

	client.sending |= asset_name
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = (ASSET_CACHE_SEND_TIMEOUT * client.sending.len) + ASSET_CACHE_SEND_TIMEOUT
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= asset_name
		client.cache |= asset_name
		client.completed_asset_jobs -= job

	return 1

//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset_list(var/client/client, var/list/asset_list, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	var/list/unreceived = asset_list - (client.cache + client.sending)
	if(!unreceived || !unreceived.len)
		return 0
	if (unreceived.len >= ASSET_CACHE_TELL_CLIENT_AMOUNT)
		client << "Sending Resources..."
	for(var/asset in unreceived)
		if (asset in SSasset.cache)
			client << browse_rsc(SSasset.cache[asset], asset)

	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if (client)
			client.cache += unreceived
		return 1
	if (!client)
		return 0
	client.sending |= unreceived
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = ASSET_CACHE_SEND_TIMEOUT * client.sending.len
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= unreceived
		client.cache |= unreceived
		client.completed_asset_jobs -= job

	return 1

//This proc will download the files without clogging up the browse() queue, used for passively sending files on connection start.
//The proc calls procs that sleep for long times.
/proc/getFilesSlow(var/client/client, var/list/files, var/register_asset = TRUE)
	for(var/file in files)
		if (!client)
			break
		if (register_asset)
			register_asset(file,files[file])
		send_asset(client,file)
		sleep(-1) //queuing calls like this too quickly can cause issues in some client versions

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//if it's an icon or something be careful, you'll have to copy it before further use.
/proc/register_asset(var/asset_name, var/asset)
	SSasset.cache[asset_name] = asset

//These datums are used to populate the asset cache, the proc "register()" does this.

//all of our asset datums, used for referring to these later
/var/global/list/asset_datums = list()

//get a assetdatum or make a new one
/proc/get_asset_datum(var/type)
	if (!(type in asset_datums))
		return new type()
	return asset_datums[type]

/datum/asset/New()
	asset_datums[type] = src

/datum/asset/proc/register()
	return

/datum/asset/proc/send(client)
	return

//If you don't need anything complicated.
/datum/asset/simple
	var/assets = list()
	var/verify = FALSE

/datum/asset/simple/register()
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])
/datum/asset/simple/send(client)
	send_asset_list(client,assets,verify)


//DEFINITIONS FOR ASSET DATUMS START HERE.


/datum/asset/simple/pda
	assets = list(
		"pda_atmos.png"			= 'icons/pda_icons/pda_atmos.png',
		"pda_back.png"			= 'icons/pda_icons/pda_back.png',
		"pda_bell.png"			= 'icons/pda_icons/pda_bell.png',
		"pda_blank.png"			= 'icons/pda_icons/pda_blank.png',
		"pda_boom.png"			= 'icons/pda_icons/pda_boom.png',
		"pda_bucket.png"		= 'icons/pda_icons/pda_bucket.png',
		"pda_medbot.png"		= 'icons/pda_icons/pda_medbot.png',
		"pda_floorbot.png"		= 'icons/pda_icons/pda_floorbot.png',
		"pda_cleanbot.png"		= 'icons/pda_icons/pda_cleanbot.png',
		"pda_crate.png"			= 'icons/pda_icons/pda_crate.png',
		"pda_cuffs.png"			= 'icons/pda_icons/pda_cuffs.png',
		"pda_eject.png"			= 'icons/pda_icons/pda_eject.png',
		"pda_exit.png"			= 'icons/pda_icons/pda_exit.png',
		"pda_flashlight.png"	= 'icons/pda_icons/pda_flashlight.png',
		"pda_honk.png"			= 'icons/pda_icons/pda_honk.png',
		"pda_mail.png"			= 'icons/pda_icons/pda_mail.png',
		"pda_medical.png"		= 'icons/pda_icons/pda_medical.png',
		"pda_menu.png"			= 'icons/pda_icons/pda_menu.png',
		"pda_mule.png"			= 'icons/pda_icons/pda_mule.png',
		"pda_notes.png"			= 'icons/pda_icons/pda_notes.png',
		"pda_power.png"			= 'icons/pda_icons/pda_power.png',
		"pda_rdoor.png"			= 'icons/pda_icons/pda_rdoor.png',
		"pda_reagent.png"		= 'icons/pda_icons/pda_reagent.png',
		"pda_refresh.png"		= 'icons/pda_icons/pda_refresh.png',
		"pda_scanner.png"		= 'icons/pda_icons/pda_scanner.png',
		"pda_signaler.png"		= 'icons/pda_icons/pda_signaler.png',
		"pda_status.png"		= 'icons/pda_icons/pda_status.png'
	)

/datum/asset/simple/paper
	assets = list(
		"large_stamp-clown.png" = 'icons/stamp_icons/large_stamp-clown.png',
		"large_stamp-deny.png" = 'icons/stamp_icons/large_stamp-deny.png',
		"large_stamp-ok.png" = 'icons/stamp_icons/large_stamp-ok.png',
		"large_stamp-hop.png" = 'icons/stamp_icons/large_stamp-hop.png',
		"large_stamp-cmo.png" = 'icons/stamp_icons/large_stamp-cmo.png',
		"large_stamp-ce.png" = 'icons/stamp_icons/large_stamp-ce.png',
		"large_stamp-hos.png" = 'icons/stamp_icons/large_stamp-hos.png',
		"large_stamp-rd.png" = 'icons/stamp_icons/large_stamp-rd.png',
		"large_stamp-cap.png" = 'icons/stamp_icons/large_stamp-cap.png',
		"large_stamp-qm.png" = 'icons/stamp_icons/large_stamp-qm.png',
		"large_stamp-law.png" = 'icons/stamp_icons/large_stamp-law.png'
	)

//Registers HTML Interface assets.
/datum/asset/HTML_interface/register()
	for(var/path in typesof(/datum/html_interface))
		var/datum/html_interface/hi = new path()
		hi.registerResources()

/datum/asset/nanoui

	    //////  //  //  //////  //  //    //  //    //    //  //  //////  //  //  //////
	   //      //  //  //      // //     /// //   ////   /// //  //  //  //  //    //
	  ////    //  //  //      ////      //////  //  //  //////  //  //  //  //    //
	 //      //  //  //      // //     // ///  //////  // ///  //  //  //  //    //
	//      //////  //////  //  //    //  //  //  //  //  //  //////  //////  //////

	var/list/common = list(
		"c_charging.gif"			= 'nano/images/c_charging.gif',
		"c_discharging.gif"			= 'nano/images/c_discharging.gif',
		"c_max.gif"					= 'nano/images/c_max.gif',
		"nanomapBackground.png"		= 'nano/images/nanomapBackground.png',
		"nanomap_z1.png"			= 'nano/images/nanomap_z1.png',
		"uiBackground-Syndicate.png"= 'nano/images/uiBackground-Syndicate.png',
		"uiBackground.png"			= 'nano/images/uiBackground.png',
		"uiBasicBackground.png"		= 'nano/images/uiBasicBackground.png',
		"uiIcons16.png"				= 'nano/images/uiIcons16.png',
		"uiIcons16Green.png"		= 'nano/images/uiIcons16Green.png',
		"uiIcons16Red.png"			= 'nano/images/uiIcons16Red.png',
		"uiIcons24.png"				= 'nano/images/uiIcons24.png',
		"uiLinkPendingIcon.gif"		= 'nano/images/uiLinkPendingIcon.gif',
		"uiMaskBackground.png"		= 'nano/images/uiMaskBackground.png',
		"uiNoticeBackground.jpg"	= 'nano/images/uiNoticeBackground.jpg',
		"uiTitleFluff-Syndicate.png"= 'nano/images/uiTitleFluff-Syndicate.png',
		"uiTitleFluff.png"			= 'nano/images/uiTitleFluff.png',
		"layout_basic.css"			= 'nano/layouts/layout_basic.css',
		"layout_basic.tmpl"			= 'nano/layouts/layout_basic.tmpl',
		"layout_default.css"		= 'nano/layouts/layout_default.css',
		"layout_default.tmpl"		= 'nano/layouts/layout_default.tmpl',
		"doT.js"					= 'nano/scripts/doT.js',
		"jquery-ui.js"				= 'nano/scripts/jquery-ui.js',
		"jquery.js"					= 'nano/scripts/jquery.js',
		"nano_base_callbacks.js"	= 'nano/scripts/nano_base_callbacks.js',
		"nano_base_helpers.js"		= 'nano/scripts/nano_base_helpers.js',
		"nano_config.js"			= 'nano/scripts/nano_config.js',
		"nano_state.js"				= 'nano/scripts/nano_state.js',
		"nano_state_default.js"		= 'nano/scripts/nano_state_default.js',
		"nano_state_manager.js"		= 'nano/scripts/nano_state_manager.js',
		"nano_template.js"			= 'nano/scripts/nano_template.js',
		"nano_update.js"			= 'nano/scripts/nano_update.js',
		"nano_utility.js"			= 'nano/scripts/nano_utility.js',
		"icons.css"					= 'nano/styles/icons.css',
		"normalize.css"					= 'nano/styles/normalize.css',
		"shared.css"				= 'nano/styles/shared.css'
		)

	var/list/uncommon_files = list(
		"air_alarm.tmpl"			= 'nano/interfaces/air_alarm.tmpl',
		"airlock_electronics.tmpl"	= 'nano/interfaces/airlock_electronics.tmpl',
		"apc.tmpl"					= 'nano/interfaces/apc.tmpl',
		"atmos_filter.tmpl"			= 'nano/interfaces/atmos_filter.tmpl',
		"atmos_mixer.tmpl"			= 'nano/interfaces/atmos_mixer.tmpl',
		"atmos_pump.tmpl"			= 'nano/interfaces/atmos_pump.tmpl',
		"canister.tmpl"				= 'nano/interfaces/canister.tmpl',
		"chem_dispenser.tmpl"		= 'nano/interfaces/chem_dispenser.tmpl',
		"chem_heater.tmpl"			= 'nano/interfaces/chem_heater.tmpl',
		"cryo.tmpl"					= 'nano/interfaces/cryo.tmpl',
		"smes.tmpl"					= 'nano/interfaces/smes.tmpl',
		"solar_control.tmpl" 		= 'nano/interfaces/solar_control.tmpl',
		"space_heater.tmpl" 		= 'nano/interfaces/space_heater.tmpl',
		"tanks.tmpl"				= 'nano/interfaces/tanks.tmpl'
		)

/datum/asset/nanoui/register()
	for(var/filename in common)
		register_asset(filename, common[filename])
	for (var/filename in uncommon_files)
		register_asset(filename, uncommon_files[filename])

/datum/asset/nanoui/send(client, uncommon)
	if(!islist(uncommon))
		uncommon = list(uncommon)

	send_asset_list(client, uncommon)
	send_asset_list(client, common)
