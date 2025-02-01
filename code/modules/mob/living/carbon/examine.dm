/// Adds a newline to the examine list if the above entry is not empty and it is not the first element in the list
#define ADD_NEWLINE_IF_NECESSARY(list) if(length(list) > 0 && list[length(list)]) { list += "" }
#define CARBON_EXAMINE_EMBEDDING_MAX_DIST 4

/mob/living/carbon/human/get_examine_name(mob/user, declent) // BANDASTATION EDIT - Declents
	if(!HAS_TRAIT(user, TRAIT_PROSOPAGNOSIA))
		return ..()

	return "Неизвестный"

/mob/living/carbon/human/get_examine_icon(mob/user)
	return null

/mob/living/carbon/examine(mob/user)
	if(HAS_TRAIT(src, TRAIT_UNKNOWN))
		return list(span_warning("Вам сложно разглядеть какие либо детали..."))

	var/t_He = ru_p_they(TRUE)
	var/t_His = ru_p_them(TRUE)
	var/t_his = ru_p_them()
	var/t_him = ru_p_them()
	// var/t_has = ru_p_have()
	// var/t_is = ru_p_are()

	. = list()
	. += get_clothing_examine_info(user)
	// give us some space between clothing examine and the rest
	ADD_NEWLINE_IF_NECESSARY(.)

	var/appears_dead = FALSE
	var/just_sleeping = FALSE

	if(!appears_alive())
		appears_dead = TRUE

		var/obj/item/clothing/glasses/shades = get_item_by_slot(ITEM_SLOT_EYES)
		var/are_we_in_weekend_at_bernies = shades?.tint && buckled && istype(buckled, /obj/vehicle/ridden/wheelchair)

		if(isliving(user) && (HAS_MIND_TRAIT(user, TRAIT_NAIVE) || are_we_in_weekend_at_bernies))
			just_sleeping = TRUE

		if(!just_sleeping)
			// since this is relatively important and giving it space makes it easier to read
			ADD_NEWLINE_IF_NECESSARY(.)
			if(HAS_TRAIT(src, TRAIT_SUICIDED))
				. += span_warning("Кажется, причина [t_his] смерти - суицид... нет никакой надежды на выздоровление.")

			. += generate_death_examine_text()

	//Status effects
	var/list/status_examines = get_status_effect_examinations()
	if (length(status_examines))
		. += status_examines

	if(get_bodypart(BODY_ZONE_HEAD) && !get_organ_by_type(/obj/item/organ/brain))
		. += span_deadsay("Кажется, [t_his] мозг отсутствует...")

	var/list/missing = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/list/disabled = list()
	for(var/obj/item/bodypart/body_part as anything in bodyparts)
		if(body_part.bodypart_disabled)
			disabled += body_part
		missing -= body_part.body_zone
		for(var/obj/item/embedded as anything in body_part.embedded_objects)
			var/harmless = embedded.get_embed().is_harmless()
			var/stuck_wordage = harmless ? "застревает" : "впивается"
			var/embed_line = "[capitalize(embedded.declent_ru(ACCUSATIVE))]"
			if (get_dist(src, user) <= CARBON_EXAMINE_EMBEDDING_MAX_DIST)
				embed_line = "<a href='byond://?src=[REF(src)];embedded_object=[REF(embedded)];embedded_limb=[REF(body_part)]'>[embedded]</a>"
			var/embed_text = "[icon2html(embedded, user)] [embed_line] [stuck_wordage] в [t_his] [body_part.ru_plaintext_zone[ACCUSATIVE] || body_part.plaintext_zone]!"
			if (harmless)
				. += span_italics(span_notice(embed_text))
			else
				. += span_boldwarning(embed_text)

		for(var/datum/wound/iter_wound as anything in body_part.wounds)
			. += span_danger(iter_wound.get_examine_description(user))

	for(var/obj/item/bodypart/body_part as anything in disabled)
		var/damage_text
		if(HAS_TRAIT(body_part, TRAIT_DISABLED_BY_WOUND))
			continue // skip if it's disabled by a wound (cuz we'll be able to see the bone sticking out!)
		if(body_part.get_damage() < body_part.max_damage) //we don't care if it's stamcritted
			damage_text = "обмякла и безжизненна"
		else
			damage_text = (body_part.brute_dam >= body_part.burn_dam) ? body_part.heavy_brute_msg : body_part.heavy_burn_msg
		. += span_boldwarning("[t_His] [body_part.ru_plaintext_zone[NOMINATIVE] || body_part.plaintext_zone] [damage_text]!")

	//stores missing limbs
	var/l_limbs_missing = 0
	var/r_limbs_missing = 0
	for(var/gone in missing)
		if(gone == BODY_ZONE_HEAD)
			. += span_deadsay("<B>[t_His] [ru_parse_zone(gone, declent = NOMINATIVE)] отсутствует!</B>")
			continue
		if(gone == BODY_ZONE_L_ARM || gone == BODY_ZONE_L_LEG)
			l_limbs_missing++
		else if(gone == BODY_ZONE_R_ARM || gone == BODY_ZONE_R_LEG)
			r_limbs_missing++

		. += span_boldwarning("[t_His] [ru_parse_zone(gone, declent = NOMINATIVE)] отсутствует!")

	if(l_limbs_missing >= 2 && r_limbs_missing == 0)
		. += span_tinydanger("[t_He] полностью прав[genderize_ru(gender, "", "а", "о", "ы")]...")
	else if(l_limbs_missing == 0 && r_limbs_missing >= 2)
		. += span_tinydanger("[t_He] полностью лев[genderize_ru(gender, "", "а", "о", "ы")]...")
	else if(l_limbs_missing >= 2 && r_limbs_missing >= 2)
		. += span_tinydanger("[t_He] не выглядит полноценно...")

	if(!(user == src && has_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy))) //fake healthy
		var/temp
		if(user == src && has_status_effect(/datum/status_effect/grouped/screwy_hud/fake_crit))//fake damage
			temp = 50
		else
			temp = getBruteLoss()
		var/list/damage_desc = get_majority_bodypart_damage_desc()
		if(temp)
			if(temp < 25)
				. += span_danger("У [ru_p_theirs()] незначительные [damage_desc[BRUTE]].")
			else if(temp < 50)
				. += span_danger("У [ru_p_theirs()] <b>умеренные</b> [damage_desc[BRUTE]]!")
			else
				. += span_bolddanger("У [ru_p_theirs()] тяжелые [damage_desc[BRUTE]]!")

		temp = getFireLoss()
		if(temp)
			if(temp < 25)
				. += span_danger("У [ru_p_theirs()] незначительные [damage_desc[BURN]].")
			else if (temp < 50)
				. += span_danger("У [ru_p_theirs()] <b>умеренные</b> [damage_desc[BURN]]!")
			else
				. += span_bolddanger("У [ru_p_theirs()] тяжелые [damage_desc[BURN]]!")

	if(pulledby?.grab_state)
		. += span_warning("[t_His] держит в захвате [pulledby.declent_ru(NOMINATIVE)].")

	if(nutrition < NUTRITION_LEVEL_STARVING - 50)
		. += span_warning("У [ru_p_theirs()] сильное истощение.")
	else if(nutrition >= NUTRITION_LEVEL_FAT)
		if(user.nutrition < NUTRITION_LEVEL_STARVING - 50)
			. += span_hypnophrase("[t_He] выглядит пухло и аппетитно - как маленький толстый поросенок. Вкусный поросенок.")
		else
			. += "<b>[t_He] довольно пухлый.</b>"
	switch(disgust)
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			. += "[t_He] выглядит немного отвращенно."
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			. += "[t_He] выглядит довольно отвращенно."
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			. += "[t_He] выглядит крайне отвращенно."

	var/apparent_blood_volume = blood_volume
	if(HAS_TRAIT(src, TRAIT_USES_SKINTONES) && ishuman(src))
		var/mob/living/carbon/human/husrc = src // gross istypesrc but easier than refactoring even further for now
		if(husrc.skin_tone == "albino")
			apparent_blood_volume -= (BLOOD_VOLUME_NORMAL * 0.25) // knocks you down a few pegs
	switch(apparent_blood_volume)
		if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
			. += span_warning("У [ru_p_theirs()] бледная кожа.")
		if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
			. += span_boldwarning("[t_He] выглядит бледно, как сама смерть.")
		if(-INFINITY to BLOOD_VOLUME_BAD)
			. += span_deadsay("<b>[t_He] напоминает раздавленный пустой пакетик из-под сока.</b>")

	if(is_bleeding())
		var/list/obj/item/bodypart/bleeding_limbs = list()
		var/list/obj/item/bodypart/grasped_limbs = list()

		for(var/obj/item/bodypart/body_part as anything in bodyparts)
			if(body_part.get_modified_bleed_rate())
				bleeding_limbs += body_part.ru_plaintext_zone[GENITIVE] || body_part.plaintext_zone
			if(body_part.grasped_by)
				grasped_limbs += body_part.ru_plaintext_zone[ACCUSATIVE] || body_part.plaintext_zone

		if(LAZYLEN(bleeding_limbs))
			var/bleed_text = "<b>"
			if(appears_dead)
				bleed_text += "<span class='deadsay'>"
				bleed_text += "Видна кровь из [t_his] открытых "
			else
				bleed_text += "<span class='warning'>"
				bleed_text += "[t_He] кровоточит из "

			bleed_text += english_list(bleeding_limbs)

			if(appears_dead)
				bleed_text += ", но кровь скопилась и не течет."
			else
				if(HAS_TRAIT(src, TRAIT_BLOODY_MESS))
					bleed_text += " невероятно быстро"
				bleed_text += "!"

			if(appears_dead)
				bleed_text += "<span class='deadsay'>"
			else
				bleed_text += "<span class='warning'>"
			bleed_text += "</b>"

			. += bleed_text
			if(LAZYLEN(grasped_limbs))
				for(var/grasped_part in grasped_limbs)
					. += "[t_He] прижимает [grasped_part], чтобы замедлить кровотечение!"

	if(reagents.has_reagent(/datum/reagent/teslium, needs_metabolizing = TRUE))
		. += span_smallnoticeital("[t_He] излучает слабое голубое свечение!") // this should be signalized

	if(just_sleeping)
		. += span_notice("[t_He] не реагирует на [t_him] окружение и, кажется, спит.")

	else if(!appears_dead)
		var/mob/living/living_user = user
		if(src != user)
			if(HAS_TRAIT(user, TRAIT_EMPATH))
				if (combat_mode)
					. += "[t_He] выглядит начеку."
				if (getOxyLoss() >= 10)
					. += "[t_He] выглядит измотанным."
				if (getToxLoss() >= 10)
					. += "[t_He] выглядит болезненно."
				if(mob_mood.sanity <= SANITY_DISTURBED)
					. += "[t_He] выглядит обеспокоенным."
					living_user.add_mood_event("empath", /datum/mood_event/sad_empath, src)
				if(is_blind())
					. += "[t_He], кажется, смотрит в пустоту."
				if (HAS_TRAIT(src, TRAIT_DEAF))
					. += "[t_He], кажется, не реагирует на звуки."
				if (bodytemperature > dna.species.bodytemp_heat_damage_limit)
					. += "[t_He] краснеет и хрипло дышит."
				if (bodytemperature < dna.species.bodytemp_cold_damage_limit)
					. += "[t_He] дрожит."
				if(HAS_TRAIT(src, TRAIT_EVIL))
					. += "[t_His] глаза излучают полную безчувственность и холодную отстраненность. Нет ничего, кроме как тьмы, в [t_his] душе."
					if(living_user.mind?.holy_role >= HOLY_ROLE_PRIEST)
						. += span_warning("ИДЕАЛЬНЫЙ КАНДИДАТ ДЛЯ КАРЫ!!")
					else
						living_user.add_mood_event("encountered_evil", /datum/mood_event/encountered_evil)
						living_user.set_jitter_if_lower(15 SECONDS)

			if(HAS_TRAIT(user, TRAIT_SPIRITUAL) && mind?.holy_role)
				. += "Вокруг [ru_p_theirs()] видно святую ауру."
				living_user.add_mood_event("religious_comfort", /datum/mood_event/religiously_comforted)

		switch(stat)
			if(UNCONSCIOUS, HARD_CRIT)
				. += span_notice("[t_He] не реагирует на [t_him] окружение и, кажется, спит.")
			if(SOFT_CRIT)
				. += span_notice("[t_He] едва находится в сознании.")
			if(CONSCIOUS)
				if(HAS_TRAIT(src, TRAIT_DUMB))
					. += "У [ru_p_theirs()] глупое выражение лица."
		var/obj/item/organ/brain/brain = get_organ_by_type(/obj/item/organ/brain)
		if(brain && isnull(ai_controller))
			var/npc_message = ""
			if(HAS_TRAIT(brain, TRAIT_GHOSTROLE_ON_REVIVE))
				npc_message = "Душа всё ещё тут..."
			else if(!key)
				npc_message = "[t_He] в полной кататонии. Стресс, связанный с жизнью в глубоком космосе, видимо, переселил [t_him]. Восстановление маловероятно."
			else if(!client)
				npc_message ="У [ru_p_theirs()] пустой и рассеянный взгляд и, кажется, [ru_p_they()] совершенно ни на что не реагирует. [t_He], возможно, скоро опомнится."
			if(npc_message)
				// give some space since this is usually near the end
				ADD_NEWLINE_IF_NECESSARY(.)
				. += span_deadsay(npc_message)

	var/scar_severity = 0
	for(var/datum/scar/scar as anything in all_scars)
		if(scar.is_visible(user))
			scar_severity += scar.severity

	if(scar_severity >= 1)
		// give some space since this is even more usually near the end
		ADD_NEWLINE_IF_NECESSARY(.)
		switch(scar_severity)
			if(1 to 4)
				. += span_tinynoticeital("У [ru_p_theirs()] видно шрамы; вы можете осмотреть подробнее, чтобы разглядеть шрамы...")
			if(5 to 8)
				. += span_smallnoticeital("У [ru_p_theirs()] видно несколько плохих шрамов; вы можете осмотреть подробнее, чтобы разглядеть шрамы...")
			if(9 to 11)
				. += span_notice("<i>У [ru_p_theirs()] видно значительно обезображивающие шрамы; вы можете осмотреть подробнее, чтобы разглядеть шрамы...</i>")
			if(12 to INFINITY)
				. += span_notice("<b><i>[t_He] выглядит абсолютно ужасно; вы можете осмотреть подробнее, чтобы разглядеть шрамы...</i></b>")

	if(HAS_TRAIT(src, TRAIT_HUSK))
		. += span_warning("Это тело превратилось в гротескную шелуху.")
	if(HAS_MIND_TRAIT(user, TRAIT_MORBID))
		if(HAS_TRAIT(src, TRAIT_DISSECTED))
			. += span_notice("[t_He] appear[p_s()] to have been dissected. Useless for examination... <b><i>for now.</i></b>")
		if(HAS_TRAIT(src, TRAIT_SURGICALLY_ANALYZED))
			. += span_notice("A skilled hand has mapped this one's internal intricacies. It will be far easier to perform future experimentations upon [user.p_them()]. <b><i>Exquisite.</i></b>")
	if(isliving(user) && HAS_MIND_TRAIT(user, TRAIT_EXAMINE_FITNESS))
		. += compare_fitness(user)

	var/hud_info = get_hud_examine_info(user)
	if(length(hud_info))
		. += hud_info

	if(isobserver(user))
		ADD_NEWLINE_IF_NECESSARY(.)
		. += "<b>Черты:</b> [get_quirk_string(FALSE, CAT_QUIRK_ALL)]"

	SEND_SIGNAL(src, COMSIG_ATOM_EXAMINE, user, .)
	if(length(.))
		.[1] = "<span class='info'>" + .[1]
		.[length(.)] += "</span>"
	return .

/**
 * Shows any and all examine text related to any status effects the user has.
 */
/mob/living/proc/get_status_effect_examinations()
	var/list/examine_list = list()

	for(var/datum/status_effect/effect as anything in status_effects)
		var/effect_text = effect.get_examine_text()
		if(!effect_text)
			continue

		examine_list += effect_text

	if(!length(examine_list))
		return

	return examine_list.Join("<br>")

/// Returns death message for mob examine text
/mob/living/carbon/proc/generate_death_examine_text()
	var/mob/dead/observer/ghost = get_ghost(TRUE, TRUE)
	var/t_He = ru_p_they(TRUE)
	var/t_his = ru_p_them()
	// var/t_is = p_are()
	//This checks to see if the body is revivable
	var/obj/item/organ/brain = get_organ_by_type(/obj/item/organ/brain)
	if(brain && HAS_TRAIT(brain, TRAIT_GHOSTROLE_ON_REVIVE))
		return span_deadsay("[t_He] выглядит обмякло и не реагирует; но [t_his] душа ещё может вернуться...")
	var/client_like = client || HAS_TRAIT(src, TRAIT_MIND_TEMPORARILY_GONE)
	var/valid_ghost = ghost?.can_reenter_corpse && ghost?.client
	var/valid_soul = brain || !HAS_TRAIT(src, TRAIT_FAKE_SOULLESS)
	if((brain && client_like) || (valid_ghost && valid_soul))
		return span_deadsay("[t_He] выглядит обмякло и не реагирует; нет признаков жизни...")
	return span_deadsay("[t_He] выглядит обмякло и не реагирует; нет признаков жизни, и [t_his] душа ушла...")

/// Returns a list of "damtype" => damage description based off of which bodypart description is most common
/mob/living/carbon/proc/get_majority_bodypart_damage_desc()
	var/list/seen_damage = list() // This looks like: ({Damage type} = list({Damage description for that damage type} = {number of times it has appeared}, ...), ...)
	var/list/most_seen_damage = list() // This looks like: ({Damage type} = {Frequency of the most common description}, ...)
	var/list/final_descriptions = list() // This looks like: ({Damage type} = {Most common damage description for that type}, ...)
	for(var/obj/item/bodypart/part as anything in bodyparts)
		for(var/damage_type in part.damage_examines)
			var/damage_desc = part.damage_examines[damage_type]
			if(!seen_damage[damage_type])
				seen_damage[damage_type] = list()

			if(!seen_damage[damage_type][damage_desc])
				seen_damage[damage_type][damage_desc] = 1
			else
				seen_damage[damage_type][damage_desc] += 1

			if(seen_damage[damage_type][damage_desc] > most_seen_damage[damage_type])
				most_seen_damage[damage_type] = seen_damage[damage_type][damage_desc]
				final_descriptions[damage_type] = damage_desc
	return final_descriptions

/// Coolects examine information about the mob's clothing and equipment
/mob/living/carbon/proc/get_clothing_examine_info(mob/living/user)
	. = list()
	var/obscured = check_obscured_slots()
	var/t_He = ru_p_they(TRUE)
	var/t_His = ru_p_them(TRUE)
	// var/t_his = p_their()
	// var/t_has = p_have()
	// var/t_is = p_are()
	//head
	if(head && !(obscured & ITEM_SLOT_HEAD) && !(head.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [head.examine_title(user, declent = ACCUSATIVE)] на голове."
	//back
	if(back && !(back.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [back.examine_title(user, declent = ACCUSATIVE)] на спине."
	//Hands
	for(var/obj/item/held_thing in held_items)
		if(held_thing.item_flags & (ABSTRACT|EXAMINE_SKIP|HAND_ITEM))
			continue
		. += "[t_He] держит [held_thing.examine_title(user, declent = ACCUSATIVE)] в [get_held_index_name(get_held_index_of_item(held_thing))]."
	//gloves
	if(gloves && !(obscured & ITEM_SLOT_GLOVES) && !(gloves.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [gloves.examine_title(user, declent = ACCUSATIVE)] на руках."
	else if(GET_ATOM_BLOOD_DNA_LENGTH(src))
		if(num_hands)
			. += span_warning("У [ru_p_theirs()] окровавленн[num_hands > 1 ? "ые" : "ую"] рук[num_hands > 1 ? "и" : "у"]!")
	//handcuffed?
	if(handcuffed)
		var/cables_or_cuffs = istype(handcuffed, /obj/item/restraints/handcuffs/cable) ? "в связках" : "в наручниках"
		. += span_warning("[t_He] [icon2html(handcuffed, user)] [cables_or_cuffs]!")
	//shoes
	if(shoes && !(obscured & ITEM_SLOT_FEET)  && !(shoes.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [shoes.examine_title(user, declent = ACCUSATIVE)] на ногах."
	//mask
	if(wear_mask && !(obscured & ITEM_SLOT_MASK)  && !(wear_mask.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [wear_mask.examine_title(user, declent = ACCUSATIVE)] на лице."
	if(wear_neck && !(obscured & ITEM_SLOT_NECK)  && !(wear_neck.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [wear_neck.examine_title(user, declent = ACCUSATIVE)] вокруг шеи."
	//eyes
	if(!(obscured & ITEM_SLOT_EYES) )
		if(glasses  && !(glasses.item_flags & EXAMINE_SKIP))
			. += "[t_He] носит [glasses.examine_title(user, declent = ACCUSATIVE)] на глазах."
		else if(HAS_TRAIT(src, TRAIT_UNNATURAL_RED_GLOWY_EYES))
			. += span_warning("<B>[t_His] глаза светятся неестественной красной аурой!</B>")
		else if(HAS_TRAIT(src, TRAIT_BLOODSHOT_EYES))
			. += span_warning("<B>[t_His] глаза налиты кровью!</B>")
	//ears
	if(ears && !(obscured & ITEM_SLOT_EARS) && !(ears.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [ears.examine_title(user, declent = ACCUSATIVE)] на ушах."

// Yes there's a lot of copypasta here, we can improve this later when carbons are less dumb in general
/mob/living/carbon/human/get_clothing_examine_info(mob/living/user)
	. = list()
	var/obscured = check_obscured_slots()
	var/t_He = ru_p_they(TRUE)
	var/t_His = ru_p_them(TRUE)
	// var/t_his = ru_p_them()
	// var/t_has = ru_p_have()
	// var/t_is = p_are()

	//uniform
	if(w_uniform && !(obscured & ITEM_SLOT_ICLOTHING) && !(w_uniform.item_flags & EXAMINE_SKIP))
		//accessory
		var/accessory_message = ""
		if(istype(w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/undershirt = w_uniform
			var/list/accessories = undershirt.list_accessories_with_icon(user)
			if(length(accessories))
				accessory_message = " с прикрепленными: [english_list(accessories)]"

		. += "[t_He] носит [w_uniform.examine_title(user, declent = ACCUSATIVE)][accessory_message]."
	//head
	if(head && !(obscured & ITEM_SLOT_HEAD) && !(head.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [head.examine_title(user, declent = ACCUSATIVE)] на голове."
	//mask
	if(wear_mask && !(obscured & ITEM_SLOT_MASK)  && !(wear_mask.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [wear_mask.examine_title(user, declent = ACCUSATIVE)] на лице."
	//neck
	if(wear_neck && !(obscured & ITEM_SLOT_NECK)  && !(wear_neck.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [wear_neck.examine_title(user, declent = ACCUSATIVE)] на шее."
	//eyes
	if(!(obscured & ITEM_SLOT_EYES) )
		if(glasses  && !(glasses.item_flags & EXAMINE_SKIP))
			. += "[t_He] носит [glasses.examine_title(user, declent = ACCUSATIVE)] на глазах."
		else if(HAS_TRAIT(src, TRAIT_UNNATURAL_RED_GLOWY_EYES))
			. += span_warning("<B>[t_His] глаза светятся неестественной красной аурой!</B>")
		else if(HAS_TRAIT(src, TRAIT_BLOODSHOT_EYES))
			. += span_warning("<B>[t_His] глаза налиты кровью!</B>")
	//ears
	if(ears && !(obscured & ITEM_SLOT_EARS) && !(ears.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [ears.examine_title(user, declent = ACCUSATIVE)] на ушах."
	//suit/armor
	if(wear_suit && !(wear_suit.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [wear_suit.examine_title(user, declent = ACCUSATIVE)]."
		//suit/armor storage
		if(s_store && !(obscured & ITEM_SLOT_SUITSTORE) && !(s_store.item_flags & EXAMINE_SKIP))
			. += "[t_He] носит [s_store.examine_title(user, declent = ACCUSATIVE)] на [wear_suit.declent_ru(PREPOSITIONAL)]."
	//back
	if(back && !(back.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [back.examine_title(user, declent = ACCUSATIVE)] на спине."
	//ID
	if(wear_id && !(wear_id.item_flags & EXAMINE_SKIP))
		var/obj/item/card/id/id = wear_id.GetID()
		if(id && get_dist(user, src) <= ID_EXAMINE_DISTANCE)
			var/id_href = "<a href='byond://?src=[REF(src)];see_id=1;id_ref=[REF(id)];id_name=[id.registered_name];examine_time=[world.time]'>[wear_id.examine_title(user, declent = ACCUSATIVE)]</a>"
			. += "[t_He] носит [id_href]."

		else
			. += "[t_He] носит [wear_id.examine_title(user, declent = ACCUSATIVE)]."
	//Hands
	for(var/obj/item/held_thing in held_items)
		if(held_thing.item_flags & (ABSTRACT|EXAMINE_SKIP|HAND_ITEM))
			continue
		. += "[t_He] держит [held_thing.examine_title(user, declent = ACCUSATIVE)] в [get_held_index_name(get_held_index_of_item(held_thing))]."
	//gloves
	if(gloves && !(obscured & ITEM_SLOT_GLOVES) && !(gloves.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [gloves.examine_title(user, declent = ACCUSATIVE)] на руках."
	else if(GET_ATOM_BLOOD_DNA_LENGTH(src) || blood_in_hands)
		if(num_hands)
			. += span_warning("У [ru_p_theirs()] окровавленн[num_hands > 1 ? "ые" : "ую"] рук[num_hands > 1 ? "и" : "у"]!")
	//handcuffed?
	if(handcuffed)
		var/cables_or_cuffs = istype(handcuffed, /obj/item/restraints/handcuffs/cable) ? "в связках" : "в наручниках"
		. += span_warning("[t_He] [icon2html(handcuffed, user)] [cables_or_cuffs]!")
	//belt
	if(belt && !(obscured & ITEM_SLOT_BELT) && !(belt.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [belt.examine_title(user, declent = ACCUSATIVE)] на поясе."
	//shoes
	if(shoes && !(obscured & ITEM_SLOT_FEET)  && !(shoes.item_flags & EXAMINE_SKIP))
		. += "[t_He] носит [shoes.examine_title(user, declent = ACCUSATIVE)] на ногах."

/// Collects info displayed about any HUDs the user has when examining src
/mob/living/carbon/proc/get_hud_examine_info(mob/living/user)
	return

/mob/living/carbon/human/get_hud_examine_info(mob/living/user)
	. = list()

	var/perpname = get_face_name(get_id_name(""))
	var/title = ""
	if(perpname && (HAS_TRAIT(user, TRAIT_SECURITY_HUD) || HAS_TRAIT(user, TRAIT_MEDICAL_HUD)) && (user.stat == CONSCIOUS || isobserver(user)) && user != src)
		var/datum/record/crew/target_record = find_record(perpname)
		if(target_record)
			. += "Должность: [target_record.rank]"
			. += "<a href='byond://?src=[REF(src)];hud=1;photo_front=1;examine_time=[world.time]'>\[Фото спереди\]</a><a href='byond://?src=[REF(src)];hud=1;photo_side=1;examine_time=[world.time]'>\[Фото сбоку\]</a>"
		if(HAS_TRAIT(user, TRAIT_MEDICAL_HUD) && HAS_TRAIT(user, TRAIT_SECURITY_HUD))
			title = separator_hr("Медицинский и безопасности анализы")
			. += get_medhud_examine_info(user, target_record)
			. += get_sechud_examine_info(user, target_record)

		else if(HAS_TRAIT(user, TRAIT_MEDICAL_HUD))
			title = separator_hr("Медицинский анализ")
			. += get_medhud_examine_info(user, target_record)

		else if(HAS_TRAIT(user, TRAIT_SECURITY_HUD))
			title = separator_hr("Анализ безопасности")
			. += get_sechud_examine_info(user, target_record)

	// applies the separator correctly without an extra line break
	if(title && length(.))
		.[1] = title + .[1]
	return .

/// Collects information displayed about src when examined by a user with a medical HUD.
/mob/living/carbon/proc/get_medhud_examine_info(mob/living/user, datum/record/crew/target_record)
	. = list()

	var/list/cybers = list()
	for(var/obj/item/organ/cyberimp/cyberimp in organs)
		if(IS_ROBOTIC_ORGAN(cyberimp) && !(cyberimp.organ_flags & ORGAN_HIDDEN))
			cybers += cyberimp.examine_title(user)
	if(length(cybers))
		. += "<span class='notice ml-1'>Обнаружены кибернетические модификации:</span>"
		. += "<span class='notice ml-2'>[english_list(cybers, and_text = ", и")]</span>"
	if(target_record)
		. += "<a href='byond://?src=[REF(src)];hud=m;physical_status=1;examine_time=[world.time]'>\[[target_record.physical_status]\]</a>"
		. += "<a href='byond://?src=[REF(src)];hud=m;mental_status=1;examine_time=[world.time]'>\[[target_record.mental_status]\]</a>"
	else
		. += "\[Запись отсутствует\]"
		. += "\[Запись отсутствует\]"
	. += "<a href='byond://?src=[REF(src)];hud=m;evaluation=1;examine_time=[world.time]'>\[Медицинское обследование\]</a>"
	. += "<a href='byond://?src=[REF(src)];hud=m;quirk=1;examine_time=[world.time]'>\[Показать черты\]</a>"

/// Collects information displayed about src when examined by a user with a security HUD.
/mob/living/carbon/proc/get_sechud_examine_info(mob/living/user, datum/record/crew/target_record)
	. = list()

	var/wanted_status = WANTED_NONE
	var/security_note = "Пусто."

	if(target_record)
		wanted_status = target_record.wanted_status
		if(target_record.security_note)
			security_note = target_record.security_note
	if(ishuman(user))
		. += "Криминальный статус: <a href='byond://?src=[REF(src)];hud=s;status=1;examine_time=[world.time]'>\[[wanted_status]\]</a>"
	else
		. += "Криминальный статус: [wanted_status]"
	. += "Важные заметки: [security_note]"
	. += "Записи охраны: <a href='byond://?src=[REF(src)];hud=s;view=1;examine_time=[world.time]'>\[Показать\]</a>"
	if(ishuman(user))
		. += "<a href='byond://?src=[REF(src)];hud=s;add_citation=1;examine_time=[world.time]'>\[Добавить штраф\]</a>\
			<a href='byond://?src=[REF(src)];hud=s;add_crime=1;examine_time=[world.time]'>\[Добавить преступление\]</a>\
			<a href='byond://?src=[REF(src)];hud=s;add_note=1;examine_time=[world.time]'>\[Добавить примечание\]</a>"

/mob/living/carbon/human/examine_more(mob/user)
	. = ..()
	if((wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE)))
		return
	if(HAS_TRAIT(src, TRAIT_UNKNOWN) || HAS_TRAIT(src, TRAIT_INVISIBLE_MAN))
		return
	var/age_text
	switch(age)
		if(-INFINITY to 25)
			age_text = "очень молодо"
		if(26 to 35)
			age_text = "взросло"
		if(36 to 55)
			age_text = "среднего возраста"
		if(56 to 75)
			age_text = "довольно старо"
		if(76 to 100)
			age_text = "очень старо"
		if(101 to INFINITY)
			age_text = "увядающе"
	. += list(span_notice("[ru_p_they(TRUE)] выглядит [age_text]."))

	if(istype(w_uniform, /obj/item/clothing/under))
		var/obj/item/clothing/under/undershirt = w_uniform
		if(undershirt.has_sensor == BROKEN_SENSORS)
			. += list(span_notice("[capitalize(undershirt.declent_ru(NOMINATIVE))] имеет коротящие медицинские датчики."))

	for(var/datum/scar/iter_scar as anything in all_scars)
		if(iter_scar.is_visible(user))
			. += iter_scar.get_examine_description(user)

#undef ADD_NEWLINE_IF_NECESSARY
#undef CARBON_EXAMINE_EMBEDDING_MAX_DIST
