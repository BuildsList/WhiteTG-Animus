/*
/proc/createRandomZlevel()
	if(awaydestinations.len)	//crude, but it saves another var!
		return

	var/list/potentialRandomZlevels = list()
	world << "<span class='boldannounce'>Searching for away missions...</span>"
	var/list/Lines = file2list("config/awaymissionconfig.txt")
	if(!Lines.len)	return
	for (var/t in Lines)
		if (!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
	//	var/value = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))
		//	value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if (!name)
			continue

		potentialRandomZlevels.Add(t)


	if(potentialRandomZlevels.len)
		world << "<span class='boldannounce'>Loading away mission...</span>"

		var/map = pick(potentialRandomZlevels)
		var/file = file(map)
		if(isfile(file))
			maploader.load_map(file)
			world.log << "away mission loaded: [map]"

		map_transition_config.Add(AWAY_MISSION_LIST)

		for(var/obj/effect/landmark/L in landmarks_list)
			if (L.name != "awaystart")
				continue
			awaydestinations.Add(L)

		world << "<span class='boldannounce'>Away mission loaded.</span>"

	else
		world << "<span class='boldannounce'>No away missions found.</span>"
		return
*/

/proc/createRandomZlevel()
	if(awaydestinations.len)	//crude, but it saves another var!
		return

	var/list/potentialRandomZlevels = list(
		'_maps/RandomZLevels/blackmarketpackers.dmm',
		'_maps/RandomZLevels/spacebattle.dmm',
		'_maps/RandomZLevels/beach.dmm',
		'_maps/RandomZLevels/Academy.dmm',
		'_maps/RandomZLevels/wildwest.dmm',
		'_maps/RandomZLevels/challenge.dmm',
		'_maps/RandomZLevels/spacehotel.dmm',
		'_maps/RandomZLevels/centcomAway.dmm',
		'_maps/RandomZLevels/moonoutpost19.dmm',
		'_maps/RandomZLevels/undergroundoutpost45.dmm',
		'_maps/RandomZLevels/caves.dmm',
		)


	world << "<span class='boldannounce'>Loading away mission...</span>"

	var/map = pick(potentialRandomZlevels)
	maploader.load_map(map)
	world.log << "away mission loaded: [map]"

	map_transition_config.Add(AWAY_MISSION_LIST)

	for(var/obj/effect/landmark/L in landmarks_list)
		if (L.name != "awaystart")
			continue
		awaydestinations.Add(L)

	world << "<span class='boldannounce'>Away mission loaded.</span>"
