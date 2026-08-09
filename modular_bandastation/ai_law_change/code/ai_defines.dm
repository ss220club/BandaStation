/mob/living/silicon/ai
	/// Whether the AI's law change request has already been approved this shift, blocking further requests
	var/law_change_used = FALSE
	/// Whether the AI's law change request was rejected, permanently blocking further requests
	var/law_change_rejected = FALSE
	/// The law change request datum tied to this AI, if any
	var/datum/ai_law_change_request/law_change_request
