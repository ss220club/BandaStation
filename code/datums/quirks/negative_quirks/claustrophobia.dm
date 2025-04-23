/datum/quirk/claustrophobia
	name = "Claustrophobia"
	desc = "Вы боитесь маленьких пространств и некоторых праздничных персонажей. Если вы оказываетесь внутри какого-либо контейнера, шкафчика или механизма, у вас начинается приступ паники и вам становится труднее дышать."
	icon = FA_ICON_BOX_OPEN
	value = -4
	medical_record_text = "Пациент испытывает страх в замкнутых пространствах."
	hardcore_value = 5
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/item/reagent_containers/syringe/convermol) // to help breathing
	maximum_process_stat = SOFT_CRIT
	no_process_traits = list(TRAIT_MIND_TEMPORARILY_GONE, TRAIT_FEARLESS, TRAIT_KNOCKEDOUT)

/datum/quirk/claustrophobia/remove()
	quirk_holder.clear_mood_event("claustrophobia")

/datum/quirk/claustrophobia/process(seconds_per_tick)
	var/nick_spotted = FALSE

	for(var/mob/living/carbon/human/possible_claus in view(5, quirk_holder))
		if(evaluate_jolly_levels(possible_claus))
			nick_spotted = TRUE
			break

	if(!nick_spotted && isturf(quirk_holder.loc))
		quirk_holder.clear_mood_event("claustrophobia")
		return

	quirk_holder.add_mood_event("claustrophobia", /datum/mood_event/claustrophobia)
	quirk_holder.losebreath += 0.25 // miss a breath one in four times
	if(SPT_PROB(25, seconds_per_tick))
		if(nick_spotted)
			to_chat(quirk_holder, span_warning("Дед Мороз пришел за мной! Надо сваливать!"))
		else
			to_chat(quirk_holder, span_warning("Вы оказались в ловушке! Нужно выбираться... не могу дышать..."))

///investigates whether possible_saint_nick possesses a high level of christmas cheer
/datum/quirk/claustrophobia/proc/evaluate_jolly_levels(mob/living/carbon/human/possible_saint_nick)
	if(!istype(possible_saint_nick))
		return FALSE

	if(istype(possible_saint_nick.back, /obj/item/storage/backpack/santabag))
		return TRUE

	if(istype(possible_saint_nick.head, /obj/item/clothing/head/costume/santa) || istype(possible_saint_nick.head,  /obj/item/clothing/head/helmet/space/santahat))
		return TRUE

	if(istype(possible_saint_nick.wear_suit, /obj/item/clothing/suit/space/santa))
		return TRUE

	return FALSE
