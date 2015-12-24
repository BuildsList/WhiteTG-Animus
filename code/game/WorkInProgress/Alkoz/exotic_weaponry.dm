/obj/item/weapon/melee/chainsword
	name = "chainsword"
	desc = "Purge the alien!"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "sawsord-idle"
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("bashed", "smacked")
	item_state = "swordchain"
	slot_flags = SLOT_BELT
	var/icon_on = "sawsord-active"
	var/icon_off = "sawsord-idle"
	var/on = 0
	var/force_on = 75
	var/force_off = 15
	var/hitsound_on = 'sound/weapons/chainsawhit.ogg'
	var/hitsound_off = 'sound/weapons/bladeslice.ogg'

	var/list/battle_cries = list("FOR THE EMPRAAAH!",
									 "Burn the heretic. Kill the mutant. Purge the unclean!",
									 "Cowards die in shame!",
									 "Cleanse, Purge, KILL!",
									 "The Emperor guides my blade!",
									 "NONE CAN WITHSTAND OUR FAITH!")

	New()
		icon_state = icon_off
		force = force_off

	attack_self(mob/living/user)
		if(on)
			icon_state = icon_off
			force = force_off
			hitsound = 'sound/weapons/bladeslice.ogg'
			user.visible_message("[user] turns the [src] off", "<span class='notice'>You turn the [src] off.</span>")
			attack_verb = list("bashed", "smacked")
			hitsound = hitsound_off
		else
			icon_state = icon_on
			force = force_on
			user.visible_message("[user] starts the [src]!", "<span class='notice'>You start the [src].</span>")
			attack_verb = list("sawed", "cut", "hacked", "carved", "cleaved", "butchered", "felled", "timbered")
			hitsound = hitsound_on

		on = !on


	attack(mob/M, mob/living/carbon/human/user)
		if(on)
			if(M.lying)
				M.gib()
				user.visible_message("<font color = 'red' size = '3'>[user] shouts, <b>\"<font size='4'>[pick(battle_cries)]</font>\"</b></font>")
		..()

/obj/item/weapon/melee/chainsword/chaplain
	force_on = 20
	force_off = 15

	battle_cries = list("¬ зловещем мраке далекого будущего есть лишь война.","¬ темноте все равны; спасаются все кто это принял.",
	"≈динственным благом является знание, а единственным злом Ц невежество",
	"√де бы мы ни были Ч мы в нужном месте и в нужное время","ѕусть галактика горит огнЄм!","∆изнь ничто, смерть Ч прозрение.",
	"ЌедалЄкий ум Ч чистый ум.","—трах убивает веру.")