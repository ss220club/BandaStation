/datum/vote/map_vote
	name = "Map"
	default_message = "Vote for next round's map!"
	count_method = VOTE_COUNT_METHOD_SINGLE
	winner_method = VOTE_WINNER_METHOD_NONE
	display_statistics = FALSE
/datum/vote/map_vote/New()
	. = ..()
	default_choices = SSmap_vote.get_valid_map_vote_choices()


/datum/vote/map_vote/toggle_votable()
	CONFIG_SET(flag/allow_vote_map, !CONFIG_GET(flag/allow_vote_map))

/datum/vote/map_vote/is_config_enabled()
	return CONFIG_GET(flag/allow_vote_map)

/datum/vote/map_vote/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .

	if(SSmap_vote.next_map_config)
		return "The next map has already been selected."

	var/list/new_choices = SSmap_vote.get_valid_map_vote_choices()
	if (new_choices)
		default_choices = new_choices
	return VOTE_AVAILABLE

/datum/vote/map_vote/get_result_text(list/all_winners, real_winner, list/non_voters)
	return null

/datum/vote/map_vote/get_vote_result(list/non_voters)
	// Even if we have default no vote off,
	// if our default map is null for some reason, we shouldn't continue
	if(CONFIG_GET(flag/default_no_vote) || isnull(global.config.defaultmap))
		return ..()

	for(var/non_voter_ckey in non_voters)
		var/client/non_voter_client = non_voters[non_voter_ckey]
		// Non-voters will have their preferred map voted for automatically.
		var/their_preferred_map = non_voter_client?.prefs.read_preference(/datum/preference/choiced/preferred_map)
		// If the non-voter's preferred map is null for some reason, we just use the default map.
		var/voting_for = their_preferred_map || global.config.defaultmap.map_name

		if(voting_for in choices)
			choices[voting_for] += 1

	return ..()

/datum/vote/map_vote/finalize_vote(winning_option)
	SSmap_vote.finalize_map_vote(src)
