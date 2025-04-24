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
	force = 5
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
	// Sound
	var/on_sound = 'sound/items/weapons/batonextend.ogg'
	/// Attack verbs when concealed (created on Initialize)
	attack_verb_simple = list("hit", "poked")
	homerun_ready = FALSE
	homerun_able = FALSE
	/// Attack verbs when extended (created on Initialize)
	var/list/attack_verb_on = list("smacked", "struck", "cracked", "beaten")

/obj/item/melee/baseball_bat/homerun/centcom/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/transforming, \
		force_on = force_on, \
		hitsound_on = hitsound, \
		w_class_on = WEIGHT_CLASS_HUGE, \
		clumsy_check = FALSE, \
		attack_verb_continuous_on = list("smacks", "strikes", "cracks", "beats"), \
		attack_verb_simple_on = list("smack", "strike", "crack", "beat"), \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/melee/baseball_bat/homerun/centcom/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	on = active
	if(user)
		balloon_alert(user, active ? "вытянуто" : "втянуто")
	if(on)
		inhand_icon_state = item_state_on
		icon_state = icon_state_on
		wound_bonus = wound_bonus_on
	else
		inhand_icon_state = initial(inhand_icon_state)
		icon_state = initial(icon_state)
		wound_bonus = initial(wound_bonus)
	playsound(src, on_sound, 50, TRUE)
	homerun_ready = on
	homerun_able = on
	// Update mob hand visuals
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_overlays()

	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/melee/baseball_bat/homerun/centcom/pickup(mob/living/user)
	. = ..()
	if(user.mind.centcom_role)
		return
	user.AdjustKnockdown(10 SECONDS, daze_amount = 3 SECONDS)
	user.Stun(5 SECONDS, TRUE)
	to_chat(user, span_userdanger("Это - оружие истинного правосудия. Тебе не дано обуздать его мощь."))
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.apply_damage(rand(force/2, force), BRUTE, H.get_active_hand())
	else
		user.adjustBruteLoss(rand(force/2, force))

/obj/item/melee/baseball_bat/homerun/centcom/attack(mob/living/target, mob/living/user)
	if(!on)
		target.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] тыкает [target.declent_ru(ACCUSATIVE)] с помощью [declent_ru(GENITIVE)]. К счастью, оно было выключено."), \
			span_warning("[capitalize(user.declent_ru(NOMINATIVE))] тыкает вас с помощью [declent_ru(GENITIVE)]. К счастью, оно было выключено."))
			return
	. = ..()
	if(on)
		homerun_ready = TRUE
