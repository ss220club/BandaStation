/datum/buildmode_mode/offer
	key = "offer"

/datum/buildmode_mode/offer/Destroy()
	return ..()

/datum/buildmode_mode/offer/show_help(client/builder)
	to_chat(builder, span_purple(boxed_message(
		"[span_bold("Offer mob to ghosts")] -> Left Mouse Button on mob"))
	)

/datum/buildmode_mode/offer/Reset()
	. = ..()

/datum/buildmode_mode/offer/handle_click(client/user, params, object)
	if (!check_rights(R_ADMIN))
		return

	var/list/modifiers = params2list(params)

	if (!LAZYACCESS(modifiers, LEFT_CLICK))
		return

	if (!ismob(object))
		return

	offer_control(object)
