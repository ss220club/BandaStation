/obj/structure/shadowcocoon
	name = "теневой кокон"
	desc = "Нечто, окутанное воплощённой тьмой. По искажённой поверхности скользят глубокие тени."
	icon = 'modular_bandastation/shadow_demon/icons/effects.dmi'
	icon_state = "shadowcocoon"
	light_system = COMPLEX_LIGHT
	light_power = -4
	light_range = 6
	light_color = "#ddd6cf"
	max_integrity = 100
	anchored = TRUE
	/// Whether the cocoon lures victims with sounds.
	var/silent = TRUE
	/// Seconds since the last lure sound.
	var/time_since_last_hallucination = 0

/obj/structure/shadowcocoon/Initialize(mapload)
	. = ..()
	playsound(src, 'modular_bandastation/shadow_demon/sound/shadownode.ogg', 5, TRUE, -1)
	START_PROCESSING(SSobj, src)

/obj/structure/shadowcocoon/Destroy()
	STOP_PROCESSING(SSobj, src)
	// Contents are rescued even when an administrator deletes the cocoon.
	var/atom/destination = drop_location()
	for(var/atom/movable/occupant in contents)
		occupant.forceMove(destination)
	return ..()

/obj/structure/shadowcocoon/examine(mob/user)
	. = ..()
	if(istype(user, /mob/living/basic/demon/shadow))
		. += span_notice((silent ? "Нити неподвижны. Кокон не издаёт звуков." : "Нити шевелятся. Кокон издаёт звуки, приманивающие добычу."))
		. += span_notice("Alt+ЛКМ: включить или выключить звуковую приманку.")

/obj/structure/shadowcocoon/process(seconds_per_tick)
	time_since_last_hallucination += seconds_per_tick
	// The donor's 40% chance is per two-second SSobj tick.
	for(var/atom/target in range(4, src))
		if(SPT_PROB(40, seconds_per_tick / 2))
			if(istype(target, /obj/item/flashlight/flare) && !target.light_on)
				continue
			if(istype(target, /obj/item/weldingtool) && target.light_on)
				shadow_demon_extinguish(target, overload = TRUE)
				return
			shadow_demon_extinguish(target, overload = istype(target, /obj/item/flashlight/flare))
	if(!silent && time_since_last_hallucination >= rand(16, 24))
		playsound(src, pick('modular_bandastation/shadow_demon/sound/shadowhalluc1.ogg', 'modular_bandastation/shadow_demon/sound/shadowhalluc2.ogg', 'modular_bandastation/shadow_demon/sound/shadowhalluc3.ogg', 'sound/machines/airlock/airlockopen.ogg', 'sound/machines/airlock/airlockclose.ogg', 'sound/machines/airlock/boltsup.ogg', SFX_BODYFALL, 'sound/items/weapons/egloves.ogg'), 50, TRUE)
		time_since_last_hallucination = 0

/obj/structure/shadowcocoon/click_alt(mob/living/user)
	if(!istype(user, /mob/living/basic/demon/shadow) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return NONE
	silent = !silent
	to_chat(user, span_notice((silent ? "Нити замирают. Кокон затихает." : "Вы изменяете нити кокона, чтобы приманить новую добычу.")))
	return CLICK_ACTION_SUCCESS

/obj/structure/shadowcocoon/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN)
		playsound(src, 'sound/items/tools/welder.ogg', 100, TRUE)

/obj/structure/shadowcocoon/atom_destruction(damage_flag)
	visible_message(span_danger("[src] разрывается. Окружающие его тени рассеиваются."))
	return ..()
