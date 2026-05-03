/datum/vote/map_vote/is_accessible_vote()
	return TRUE

/datum/vote/map_vote/create_vote()
	var/bag_check = SSmap_vote.check_bag_before_vote()
	var/safety = 0
	while(bag_check == "REFILL" && safety++ < 2)
		SSmap_vote.refill_bag()
		SSmap_vote.save_bag_state()
		bag_check = SSmap_vote.check_bag_before_vote()

	if(istext(bag_check) && bag_check != "REFILL")
		SSmap_vote.auto_select_single_map(bag_check)
		return FALSE

	if(bag_check == "REFILL")
		if(length(SSmap_vote.remaining_bag))
			SSmap_vote.auto_select_single_map(SSmap_vote.remaining_bag[1])
		return FALSE

	default_choices = SSmap_vote.get_valid_map_vote_choices()
	if(!length(default_choices) && length(SSmap_vote.remaining_bag))
		SSmap_vote.auto_select_single_map(SSmap_vote.remaining_bag[1])
		return FALSE

	. = ..()
	if(!.)
		return FALSE
	if(length(choices) == 1)
		finalize_vote(choices[1])
		return FALSE
	if(length(choices) == 0)
		to_chat(world, span_boldannounce("A map vote was called, but there are no maps to vote for! \
			Players, complain to the admins. Admins, complain to the coders."))
		return FALSE
	return TRUE

/datum/vote/map_vote/get_vote_result(list/non_voters)
	return ..()

/datum/vote/map_vote/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .
	if(SSmap_vote.next_map_config)
		return "The next map has already been selected."

	var/bag_check = SSmap_vote.check_bag_before_vote()
	if(bag_check == "REFILL" || istext(bag_check))
		return VOTE_AVAILABLE

	var/num_choices = length(SSmap_vote.get_valid_map_vote_choices())
	if(num_choices == 0)
		return "There are no maps to choose from."
	return VOTE_AVAILABLE
