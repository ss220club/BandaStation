/**
 * Gives Bloodsuckers the ability to choose a Clan.
 *
 * If they are already in a Clan (or in a Frenzy), they will not be able to do so.
 *
 * The arguement 'person_selecting' defaults to the clan owner when not set. It should only be set when the
 * function is called by an admin assigning the clan— 'admin_selecting' should also be TRUE in that case.
 *
 * For regular players the clan is selected through a radial menu over the player's body.
 *
 * Admins get to select this through a tgui input list in case either the radial menu is bugged or
 * they aren't within viewing range of the player's body (in which case the radial menu wouldn't
 * work).
 *
 * Args:
 * * person_selecting - Mob override for stuff like Admins selecting someone's clan.
 * * admin_selecting - Set to TRUE if an admin is using this proc to select a clan for someone.
 */
/datum/antagonist/bloodsucker/proc/assign_clan_and_bane(mob/person_selecting, admin_selecting = FALSE)
	if(my_clan || owner.current.has_status_effect(/datum/status_effect/frenzy))
		return
	person_selecting ||= owner.current

	var/list/options = list()
	var/list/radial_display = list()
	for(var/datum/bloodsucker_clan/all_clans as anything in typesof(/datum/bloodsucker_clan))
		// Проверяем не является ли клан Caitiff и доступен ли он для присоединения (или админ выбирает)
		if((!all_clans::joinable_clan && !admin_selecting) || (!admin_selecting && all_clans::name == CLAN_NONE))
			continue
		options[all_clans::name] = all_clans

		var/datum/radial_menu_choice/option = new
		option.image = image(icon = all_clans::join_icon, icon_state = all_clans::join_icon_state)
		option.info = "[all_clans::name] - [span_boldnotice(all_clans::join_description)]"
		radial_display[all_clans::name] = option

	var/chosen_clan
	if(admin_selecting)
		chosen_clan = tgui_input_list(person_selecting, "What clan should [owner.current] be?", "Выбор клана", options)
	else
		chosen_clan = show_radial_menu(person_selecting, owner.current, radial_display)
	chosen_clan = options[chosen_clan]
	if(QDELETED(src) || QDELETED(owner.current))
		return FALSE
	if(!chosen_clan)
		to_chat(person_selecting, span_announce("You choose to remain ignorant, for now."))
		return
	my_clan = new chosen_clan(src)

/datum/antagonist/bloodsucker/proc/remove_clan(mob/admin)
	if(owner.current.has_status_effect(/datum/status_effect/frenzy))
		to_chat(admin, span_announce("Удаление Bloodsucker из клана, пока он находится в кровавом безумие, приведет к многочисленным ошибкам. Это действие было заблокировано."))
		return
	QDEL_NULL(my_clan)
	to_chat(owner.current, span_announce("Вы были вынуждены покинуть свой клан! Вы можете вернуться в него обычным способом."))

/datum/antagonist/bloodsucker/proc/admin_set_clan(mob/admin)
	assign_clan_and_bane(admin, admin_selecting = TRUE)
