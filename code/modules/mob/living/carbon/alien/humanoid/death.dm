/mob/living/carbon/alien/humanoid/death(gibbed)
	if(stat == DEAD)	return
	if(healths)			healths.icon_state = "health6"
	stat = DEAD

	if(!gibbed)
		playsound(loc, 'sound/voice/hiss6.ogg', 80, 1, 1)
		visible_message("<span class='name'>[src]</span> lets out a waning guttural screech, green blood bubbling from its maw...")
		update_canmove()
		update_icons()
		status_flags |=CANPUSH

	tod = worldtime2text() //weasellos time of death patch
	if(mind) 	mind.store_memory("Time of death: [tod]", 0)

	return ..(gibbed)
