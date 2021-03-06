var/list/admin_datums = list()

/datum/admins
	var/rank			= "Temporary Admin"
	var/client/owner	= null
	var/rights = 0
	var/fakekey			= null

	var/datum/marked_datum

	var/admincaster_screen = 0	//TODO: remove all these 5 variables, they are completly unacceptable
	var/datum/newscaster/feed_message/admincaster_feed_message = new /datum/newscaster/feed_message
	var/datum/newscaster/wanted_message/admincaster_wanted_message = new /datum/newscaster/wanted_message
	var/datum/newscaster/feed_channel/admincaster_feed_channel = new /datum/newscaster/feed_channel
	var/admin_signature

/datum/admins/New(initial_rank = "Temporary Admin", initial_rights = 0, ckey)
	if(!ckey)
		throw EXCEPTION("Admin datum created without a ckey")
		qdel(src)
		return
	rank = initial_rank
	rights = initial_rights
	admin_signature = "Nanotrasen Officer #[rand(0,9)][rand(0,9)][rand(0,9)]"
	admin_datums[ckey] = src

/datum/admins/proc/associate(client/C)
	if(istype(C))
		owner = C
		owner.holder = src
		owner.add_admin_verbs()	//TODO
		owner.verbs -= /client/proc/readmin
		admins |= C

/datum/admins/proc/disassociate()
	if(owner)
		admins -= owner
		owner.remove_admin_verbs()
		owner.deadmin_holder = owner.holder
		owner.holder = null

/datum/admins/proc/check_if_greater_rights_than_holder(datum/admins/other)
	if(!other)
		return 1 //they have no rights
	if(rights == 65535)
		return 1 //we have all the rights
	if(src == other)
		return 1 //you always have more rights than yourself
	if(rights != other.rights)
		if( (rights & other.rights) == other.rights )
			return 1 //we have all the rights they have and more
	return 0

/datum/admins/proc/reassociate()
	if(owner)
		admins += owner
		owner.holder = src
		owner.deadmin_holder = null
		owner.add_admin_verbs()


/*
checks if usr is an admin with at least ONE of the flags in rights_required. (Note, they don't need all the flags)
if rights_required == 0, then it simply checks if they are an admin.
if it doesn't return 1 and show_msg=1 it will prints a message explaining why the check has failed
generally it would be used like so:

proc/admin_proc()
	if(!check_rights(R_ADMIN)) return
	world << "you have enough rights!"

NOTE: It checks usr by default. Supply the "user" argument if you wish to check for a specific mob.
*/
/proc/check_rights(rights_required, show_msg=1)
	if(usr && usr.client)
		if (check_rights_for(usr.client, rights_required))
			return 1
		else
			if(show_msg)
				usr << "<font color='red'>Error: You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")].</font>"
	return 0

//probably a bit iffy - will hopefully figure out a better solution
/proc/check_if_greater_rights_than(client/other)
	if(usr && usr.client)
		if(usr.client.holder)
			if(!other || !other.holder)
				return 1
			return usr.client.holder.check_if_greater_rights_than_holder(other.holder)
	return 0

/client/proc/deadmin()
	if(holder)
		holder.disassociate()
		//qdel(holder)
	return 1

//This proc checks whether subject has at least ONE of the rights specified in rights_required.
/proc/check_rights_for(client/subject, rights_required)
	if(subject && subject.holder)
		if(rights_required && !(rights_required & subject.holder.rights))
			return 0
		return 1
	return 0