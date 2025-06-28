///Tracking reasons
/datum/antagonist/heretic_monster
	name = "\improper Eldritch Horror"
	roundend_category = "Еретики"
	antagpanel_category = ANTAG_GROUP_HORRORS
	antag_moodlet = /datum/mood_event/heretics
	pref_flag = ROLE_HERETIC
	antag_hud_name = "heretic_beast"
	suicide_cry = "МОЙ ХОЗЯИН УЛЫБАЕТСЯ МНЕ!!"
	show_in_antagpanel = FALSE
	stinger_sound = 'sound/music/antag/heretic/heretic_gain.ogg'
	/// Our master (a heretic)'s mind.
	var/datum/mind/master

/datum/antagonist/heretic_monster/on_removal()
	if(!silent)
		if(master?.current)
			to_chat(master.current, span_warning("Сущность [owner], вашего слуги, исчезает из твоего сознания."))
		if(owner.current)
			to_chat(owner.current, span_deconversion_message("Ваш разум начинает заполняться туманом - ваш хозяин [master ? "больше не [master]":"отсутствует"], вы свободны!"))
			owner.current.visible_message(span_deconversion_message("[capitalize(owner.current.declent_ru(NOMINATIVE))], кажется, освобождается от оков Мансура!"), ignored_mobs = owner.current)

	master = null
	return ..()

/*
 * Set our [master] var to a new mind.
 */
/datum/antagonist/heretic_monster/proc/set_owner(datum/mind/master)
	src.master = master
	owner.enslave_mind_to_creator(master.current)

	var/datum/objective/master_obj = new()
	master_obj.owner = owner
	master_obj.explanation_text = "Помогайте своему хозяину."
	master_obj.completed = TRUE

	objectives += master_obj
	owner.announce_objectives()
	to_chat(owner, span_boldnotice("Ты - [ishuman(owner.current) ? "возвращенный труп":"ужасное создание, принесенное"] в этот мир через врата Мансуса"))
	to_chat(owner, span_notice("Твой хозяин - [master]. Помогай ему во всех деяниях."))
