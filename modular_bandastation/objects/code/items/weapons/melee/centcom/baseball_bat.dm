/obj/item/melee/baseball_bat/homerun/centcom
	name = "Nanotrasen Fleet tactical bat"
	desc = "Выдвижная тактическая бита Центрального Командования Nanotrasen. \
	В официальных документах эта бита проходит под элегантным названием \"Высокоскоростная система доставки СРП\". \
	Выдаваясь только самым верным и эффективным офицерам Nanotrasen, это оружие является одновременно символом статуса \
	и инструментом высшего правосудия."
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL

	var/on = FALSE
	/// Force when concealed
	force = 0
	/// Force when extended
	var/force_on = 100
	var/wound_bonus_on = 100
	throwforce = 12
	wound_bonus = -50
	icon = 'modular_bandastation/objects/icons/obj/weapons/baseball_bat/baseball_bat_centcom.dmi'
	lefthand_file = 'modular_bandastation/objects/icons/obj/weapons/baseball_bat/baseball_bat_lefthand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/obj/weapons/baseball_bat/baseball_bat_righthand.dmi'
	/// Item state when concealed
	inhand_icon_state = "centcom_bat_0"
	/// Item state when extended
	var/item_state_on = "centcom_bat_1"
	/// Icon state when concealed
	icon_state = "centcom_bat_0"
	/// Icon state when extended
	var/icon_state_on = "centcom_bat_1"
	/// Sound to play when concealing or extending
	var/extend_sound = 'sound/items/weapons/batonextend.ogg'
	/// Attack verbs when concealed (created on Initialize)
	attack_verb_simple = list("hit", "poked")
	homerun_ready = TRUE
	/// Attack verbs when extended (created on Initialize)
	var/list/attack_verb_on = list("smacked", "struck", "cracked", "beaten")

/obj/item/melee/baseball_bat/homerun/centcom/pickup(mob/living/user)
	. = ..()
	if(!(user.mind.centcom_role))
		user.AdjustKnockdown(10 SECONDS, daze_amount = 3 SECONDS)
		user.Stun(5 SECONDS, TRUE)
		to_chat(user, span_userdanger("Это - оружие истинного правосудия. Тебе не дано обуздать его мощь."))
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(rand(force/2, force), BRUTE, H.get_active_hand())
		else
			user.adjustBruteLoss(rand(force/2, force))

/obj/item/melee/baseball_bat/homerun/centcom/attack_self(mob/user)
	on = !on

	if(on)
		to_chat(user, span_userdanger("Вы активировали [name] - время для правосудия!"))
		inhand_icon_state = item_state_on
		icon_state = icon_state_on
		w_class = WEIGHT_CLASS_HUGE
		force = force_on
		wound_bonus = wound_bonus_on
		attack_verb_simple = attack_verb_on
	else
		to_chat(user, span_notice("Вы деактивировали [name]."))
		inhand_icon_state = initial(inhand_icon_state)
		icon_state = initial(icon_state)
		w_class = initial(w_class)
		force = initial(force)
		wound_bonus = initial(wound_bonus)
		attack_verb_simple = initial(attack_verb_simple)

	homerun_able = on
	// Update mob hand visuals
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_overlays()
	playsound(loc, extend_sound, 50, TRUE)

/obj/item/melee/baseball_bat/homerun/centcom/attack(mob/living/target, mob/living/user)
	. = ..()
	homerun_ready = TRUE
