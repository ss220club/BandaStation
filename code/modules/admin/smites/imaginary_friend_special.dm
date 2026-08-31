#define CHOICE_PICK_PLAYER "Pick player"
#define CHOICE_POLL_GHOSTS "Offer to ghosts"
#define CHOICE_END_THEM "Do it!"
#define CHOICE_CANCEL "Cancel"

/**
 * Custom imaginary friend.
 *
 * Allows the admin to select the ckey to put into the imaginary friend.
 * Appearance is chosen by the player themselves now.
 *
 * Is not tied to the brain trauma and can be used on all mobs, technically. Including cyborgs and simple/basic mobs.
 *
 * Warranty void if used on AI eyes or other imaginary friends. Please smite responsibly.
 **/
/datum/smite/custom_imaginary_friend
	name = "Imaginary Friend (Special)"
	/// Are we polling for ghosts
	var/ghost_polling
	/// How many imaginary friends should be added when polling
	var/polled_friend_count

/datum/smite/custom_imaginary_friend/configure(client/user)
	var/client_selection_choice = tgui_alert(user,
		"Do you want to pick a specific player, or poll for ghosts?",
		"Imaginary Friend Selection?",
		list(CHOICE_PICK_PLAYER, CHOICE_POLL_GHOSTS, CHOICE_CANCEL))

	if(isnull(client_selection_choice) || client_selection_choice == CHOICE_CANCEL)
		return FALSE
	ghost_polling = client_selection_choice == CHOICE_POLL_GHOSTS

	if(ghost_polling)
		var/how_many = tgui_input_number(user, "How many imaginary friends should be added?", "Imaginary friend count", default = 1, min_value = 1)
		if(isnull(how_many) || how_many < 1)
			return FALSE
		polled_friend_count = how_many

		var/confirm_ghosts = tgui_alert(user, "Вы уверены, что хотите предложить это призракам?", "Подтверждение", list("Да", "Отмена"))
		if(confirm_ghosts != "Да")
			return FALSE

	return TRUE


/// Try to offer the role to ghosts
/datum/smite/custom_imaginary_friend/proc/poll_ghosts(client/user, mob/living/target)
	var/list/volunteers = SSpolling.poll_ghost_candidates(
		check_jobban = ROLE_PAI,
		poll_time = 10 SECONDS,
		ignore_category = POLL_IGNORE_IMAGINARYFRIEND,
		jump_target = target,
		role_name_text = "an imaginary friend for [target.real_name]",
	)
	var/volunteer_count = length(volunteers)
	if(volunteer_count == 0)
		to_chat(user, span_warning("No candidates volunteered, aborting."))
		return

	shuffle_inplace(volunteers)
	var/list/friend_candidates = list()
	while(polled_friend_count > 0 && length(volunteers) > 0)
		var/mob/dead/observer/lucky_ghost = pop(volunteers)
		if (!lucky_ghost.client)
			continue
		polled_friend_count--
		friend_candidates += lucky_ghost.client
	return friend_candidates

/// Pick client manually
/datum/smite/custom_imaginary_friend/proc/pick_client(client/user)
	var/picked_client = tgui_input_list(user, "Pick the player to put in control", "New Imaginary Friend", sort_list(GLOB.clients))
	if(isnull(picked_client))
		return

	var/client/friend_candidate_client = picked_client
	if(QDELETED(friend_candidate_client))
		to_chat(user, span_warning("Selected player no longer has a client, aborting."))
		return

	var/confirm_player = tgui_alert(user, "Вы уверены, что хотите выбрать [friend_candidate_client.ckey]?", "Подтверждение", list("Да", "Отмена"))
	if(confirm_player != "Да")
		return

	if(isliving(friend_candidate_client.mob))
		var/end_them_choice = tgui_alert(user,
			"This player already has a living mob ([friend_candidate_client.mob]). Do you still want to turn them into an Imaginary Friend?",
			"Remove player from mob?",
			list(CHOICE_END_THEM, CHOICE_CANCEL))
		if(end_them_choice == CHOICE_CANCEL)
			return

	if(QDELETED(friend_candidate_client))
		to_chat(user, span_warning("Selected player no longer has a client, aborting."))
		return

	return list(friend_candidate_client)


/datum/smite/custom_imaginary_friend/effect(client/user, mob/living/target)
	. = ..()

	// Run this check before and after polling, we don't wanna poll for something which already stopped existing
	if(QDELETED(target))
		to_chat(user, span_warning("The target mob no longer exists, aborting."))
		return

	var/list/friend_candidates
	if(ghost_polling)
		friend_candidates = poll_ghosts(user, target)
	else
		friend_candidates = pick_client(user)

	if(QDELETED(target))
		to_chat(user, span_warning("The target mob no longer exists, aborting."))
		return

	if(isnull(friend_candidates) || !length(friend_candidates))
		to_chat(user, span_warning("No provided imaginary friend candidates, aborting."))
		return

	var/list/final_clients = list()
	for(var/client/client as anything in friend_candidates)
		if(QDELETED(client))
			continue
		final_clients += client

	if(!length(final_clients))
		to_chat(user, span_warning("No provided imaginary friend candidates had clients, aborting."))
		return

	for(var/client/friend_candidate_client as anything in final_clients)
		var/mob/client_mob = friend_candidate_client.mob
		if(isliving(client_mob))
			client_mob.ghostize()

		var/mob/eye/imaginary_friend/friend_mob = client_mob.change_mob_type(
			new_type = /mob/eye/imaginary_friend,
			location = get_turf(client_mob),
			delete_old_mob = TRUE,
		)
		friend_mob.attach_to_owner(target)
		// Передаем настройки игрока, чтобы в новом меню у него появилась кнопка "Свой персонаж"
		friend_mob.setup_appearance(friend_candidate_client.prefs)

#undef CHOICE_PICK_PLAYER
#undef CHOICE_POLL_GHOSTS
#undef CHOICE_END_THEM
#undef CHOICE_CANCEL
