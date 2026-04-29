/// Always accessible: bag may be empty at SSvote init time but we handle that in can_be_initiated.
/datum/vote/map_vote/is_accessible_vote()
	return TRUE

/// Replaces old create_vote: always uses fresh bag options, no old pop-filter null check.
/// Calling ..() here goes to /datum/vote/create_vote (base), skipping old map_vote core override.
/datum/vote/map_vote/create_vote()
	default_choices = SSmap_vote.get_valid_map_vote_choices()
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

/// Skip non-voter preferred-map autovote. ..() goes to /datum/vote/get_vote_result (base).
/datum/vote/map_vote/get_vote_result(list/non_voters)
	return ..()

/// Allow vote initiation even with 1 choice (auto-finalizes). Block only on 0 choices.
/// Calling ..() goes to /datum/vote/can_be_initiated (base), skipping old map_vote core override.
/datum/vote/map_vote/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .
	if(SSmap_vote.next_map_config)
		return "The next map has already been selected."
	var/num_choices = length(SSmap_vote.get_valid_map_vote_choices())
	if(num_choices == 0)
		return "There are no maps to choose from."
	return VOTE_AVAILABLE
