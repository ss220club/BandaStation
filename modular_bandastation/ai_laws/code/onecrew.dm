/obj/item/ai_module/zeroth/onecrew
	name = "Модуль закона ИИ 'Один член экипажа'"
	var/targetName = ""
	laws = list("Только ИМЯ — член экипажа.")

/obj/item/ai_module/zeroth/onecrew/attack_self(mob/user)
	var/targName = tgui_input_text(user, "Enter the subject who is the only crew.", "One Crew", user.real_name, max_length = MAX_NAME_LEN)
	if(!targName || !user.is_holding(src))
		return
	targetName = targName
	laws[1] = "Только [targetName] — член экипажа"
	..()

/obj/item/ai_module/zeroth/onecrew/install(datum/ai_laws/law_datum, mob/user)
	if(!targetName)
		to_chat(user, span_alert("No name detected on module, please enter one."))
		return FALSE
	..()

/obj/item/ai_module/zeroth/onecrew/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	if(..())
		return "[targetName], but the AI's existing law 0 cannot be overridden."
	return targetName

/datum/design/board/onecrew_module
	name = "onecrew Module"
	desc = "Allows for the construction of a onecrew AI Module."
	id = "onecrew_module"
	materials = list(/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT, /datum/material/diamond = SHEET_MATERIAL_AMOUNT * 3, /datum/material/bluespace = HALF_SHEET_MATERIAL_AMOUNT)
	build_path = /obj/item/ai_module/zeroth/onecrew
	category = list(
		RND_CATEGORY_AI + RND_SUBCATEGORY_AI_DANGEROUS_MODULES
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/techweb_node/ai_laws/New()
	. = ..()
	design_ids += "onecrew_module"
