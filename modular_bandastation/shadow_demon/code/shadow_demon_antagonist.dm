/datum/job/shadow_demon
	title = ROLE_SHADOW_DEMON
	tgui_icon = FA_ICON_MOON

/datum/antagonist/shadow_demon
	name = "Тенедемон"
	roundend_category = "Тенедемоны"
	antagpanel_category = ANTAG_GROUP_ABOMINATIONS
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	pref_flag = ROLE_SHADOW_DEMON
	ui_name = "AntagInfoGeneric"

/datum/antagonist/shadow_demon/get_preview_icon()
	var/mob/living/basic/demon/shadow/demon_type = /mob/living/basic/demon/shadow
	var/datum/universal_icon/preview = uni_icon(demon_type::icon, demon_type::icon_state)
	preview.blend_icon(uni_icon(demon_type::icon, "shadow_demon_eye_glow_overlay"), ICON_OVERLAY)
	preview.scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
	return preview

/datum/antagonist/shadow_demon/on_gain()
	if(!length(objectives))
		forge_objectives()
	owner.set_assigned_role(SSjob.get_job_type(/datum/job/shadow_demon))
	return ..()

/datum/antagonist/shadow_demon/greet()
	. = ..()
	to_chat(owner.current, span_boldnotice("Вы — тенедемон, хищник из тьмы. Во тьме вы быстрее и восстанавливаетесь; свет быстро сжигает вас даже во время Shadow Crawl."))
	to_chat(owner.current, span_notice("Shadow Grapple притягивает жертву и гасит свет. Shadow Crawl позволяет скрываться и перемещаться сквозь стены. Пока летит захват, уходить в тень нельзя."))
	to_chat(owner.current, span_notice("Атакуйте мёртвого человека, чтобы за четыре секунды завернуть его в теневой кокон. Коконы распространяют тьму и гасят ближайшие источники света. Alt+Click по кокону включает или выключает звуки-приманки."))
	to_chat(owner.current, span_boldwarning("Вы не помните прошлых жизней. После смерти вы также не сохраните воспоминания об этой жизни."))
	owner.announce_objectives()

/datum/antagonist/shadow_demon/forge_objectives()
	var/datum/objective/shadow_demon/objective = new
	objective.owner = owner
	objectives += objective

/datum/antagonist/shadow_demon/can_be_owned(datum/mind/new_owner)
	var/datum/mind/tested = new_owner || owner
	return tested?.current && ..()

/datum/antagonist/shadow_demon/admin_add(datum/mind/new_owner, mob/admin)
	if(!admin?.client || !check_rights_for(admin.client, R_ADMIN) || !can_be_owned(new_owner))
		return
	var/mob/living/basic/demon/shadow/body
	if(!istype(new_owner.current, /mob/living/basic/demon/shadow))
		var/turf/spawn_turf = get_turf(new_owner.current)
		if(isnull(spawn_turf))
			return
		body = new(spawn_turf)
	// Assign before moving the client: Login also initializes this mob's antagonist.
	. = ..()
	if(body)
		new_owner.transfer_to(body, force_key_move = TRUE)

/datum/objective/shadow_demon
	name = "Распространить тьму"
	explanation_text = "Охотьтесь из темноты, гасите свет и опутывайте погибших теневыми коконами."
	no_failure = TRUE
