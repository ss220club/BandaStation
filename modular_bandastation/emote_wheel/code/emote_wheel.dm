#define EMOTE_WHEEL_SLOTS 6

/datum/emote_wheel
	var/list/slots
	var/current_slot

/datum/emote_wheel/New()
	. = ..()
	slots = new/list(EMOTE_WHEEL_SLOTS)

/datum/emote_wheel/ui_state(mob/user)
	return GLOB.always_state

/datum/emote_wheel/ui_status(mob/user)
	return UI_INTERACTIVE

/datum/emote_wheel/ui_data(mob/user)
	return list("slot" = current_slot)

/datum/emote_wheel/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	switch(action)
		if("select")
			var/datum/emote_entry/E = get_emote_entry(params["key"])
			if(E)
				slots[current_slot] = E
				SStgui.close_uis(src)
			return TRUE

/datum/emote_wheel/ui_static_data(mob/user)
	var/list/emotes = list()
	for(var/datum/emote_entry/E in GLOB.emote_registry)
		emotes += list(list("key" = E.key, "name" = E.name, "category" = E.category,))
	return list("emotes" = emotes,)

/datum/emote_wheel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "EmotePicker")
	ui.open()

/datum/emote_wheel/proc/open_picker(client/C, slot)
	current_slot = slot
	ui_interact(C.mob)

/client
	var/datum/emote_wheel/emote_wheel

/client/New()
	. = ..()
	emote_wheel = new
	emote_wheel.slots[1] = get_emote_entry("laugh")

/client/proc/play_emote_slot(slot)
	if(!mob)
		return
	var/datum/emote_entry/E = emote_wheel.slots[slot]
	if(!E)
		return
	mob.emote(E.key, intentional = TRUE)

/client/proc/open_emote_picker(slot)
	emote_wheel.open_picker(src, slot)

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_KB_HUMAN_EMOTE_WHEEL_DOWN, PROC_REF(on_emote_wheel))
	return .

/mob/living/carbon/human/proc/on_emote_wheel()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(open_emote_wheel))

/mob/living/carbon/human/proc/open_emote_wheel()
	if(!client?.emote_wheel)
		return
	var/list/radial = list()
	for(var/i in 1 to EMOTE_WHEEL_SLOTS)
		var/datum/emote_entry/E = client.emote_wheel.slots[i]
		var/image/I = image('icons/hud/radial.dmi', "radial_slice")
		I.maptext_width = 32
		I.maptext_height = 0
		I.maptext_x = 0
		I.maptext_y = 0
		if(E)
			I.maptext = "<div align='center'><font size=1>[E.name]</font></div>"
		else
			I.maptext = "<div align='center'><font size=1>SLOT [i]</font></div>"
		radial["slot_[i]"] = I
	var/result = show_radial_menu(src, src, radial, radius = 48, require_near = FALSE)
	if(!result || !client?.emote_wheel)
		return
	var/slot = text2num(copytext(result, 6))
	if(!slot || slot < 1 || slot > EMOTE_WHEEL_SLOTS)
		return
	var/datum/emote_entry/E = client.emote_wheel.slots[slot]
	if(E)
		client.play_emote_slot(slot)
	else
		client.open_emote_picker(slot)
