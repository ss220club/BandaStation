/datum/controller/subsystem/ticker/PostSetup()
	. = .. ()
	SSgamemode.current_storyteller.process(STORYTELLER_WAIT_TIME * 0.1) // we want this asap
	SSgamemode.current_storyteller.round_started = TRUE
