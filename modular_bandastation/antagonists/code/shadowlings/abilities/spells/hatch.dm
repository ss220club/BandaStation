/datum/action/cooldown/shadowling/hatch
	name = "Вылупиться"
	desc = "Обратить свою оболочку и явить истинную тень."
	button_icon_state = "shadow_hatch"
	cooldown_time = 0

	requires_dark_user = TRUE
	requires_dark_target = FALSE
	max_range = 0
	channel_time = 0

/datum/action/cooldown/shadowling/hatch/DoEffect(mob/living/carbon/human/H, atom/_)
	if(!istype(H))
		return FALSE

	if(istype(H.dna?.species, /datum/species/shadow/shadowling))
		return FALSE

	var/steps = 6
	var/step_time = 5 SECONDS

	for(var/i = 1, i <= steps, i++)
		var/turf/T = get_turf(H)
		if(!T || T.get_lumcount() >= L_DIM)
			to_chat(H, span_warning("Свет мешает вылуплению — вы прерываете процесс."))
			return FALSE

		playsound(T, 'sound/effects/nightmare_poof.ogg', 35, TRUE, -1)

		if(i == 1)
			to_chat(H, span_notice("Вы начинаете разрывать оболочку..."))
		else
			to_chat(H, span_notice("Тьма сгущается внутри вас ([(i - 1) * 5]/30 сек)."))

		if(!do_after(H, step_time, H))
			to_chat(H, span_warning("Вы теряете концентрацию и вылупление срывается."))
			return FALSE

	H.set_species(/datum/species/shadow/shadowling)
	to_chat(H, span_boldnotice("Вы разрываете оболочку и становитесь Тенью."))

	Remove(H)
	qdel(src)
	return TRUE
