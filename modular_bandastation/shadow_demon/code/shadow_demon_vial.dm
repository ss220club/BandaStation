/// Paradise's wizard summon: the creature is hostile even to its summoner.
/obj/item/antag_spawner/slaughter_demon/shadow
	name = "vial of shadow"
	desc = "Флакон чистой тьмы, заключённой в магическое стекло. Его содержимое привлекает тенедемона, который не пощадит даже призвавшего его волшебника."
	icon = 'modular_bandastation/shadow_demon/icons/items.dmi'
	icon_state = "vialshadows"
	demon_type = /mob/living/basic/demon/shadow
	veil_msg = span_warning("Вы чувствуете тёмное присутствие, затаившееся в тенях...")
	/// Keep a single ghost poll active for this vial.
	var/summoning = FALSE

/obj/item/antag_spawner/slaughter_demon/shadow/attack_self(mob/user)
	if(used || summoning || !user.mind || !user.is_holding(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	if(!is_station_level(user.z))
		to_chat(user, span_warning("Дождитесь прибытия на станцию."))
		return
	summoning = TRUE
	var/datum/mind/summoner = user.mind
	var/mob/chosen_one = SSpolling.poll_ghosts_for_target(
		check_jobban = list(ROLE_SHADOW_DEMON, ROLE_SENTIENCE),
		role = ROLE_SHADOW_DEMON,
		poll_time = 5 SECONDS,
		checked_target = src,
		alert_pic = demon_type,
		jump_target = src,
		role_name_text = initial(demon_type.name),
	)
	if(QDELETED(src))
		return
	summoning = FALSE
	if(used || QDELETED(user) || !user.client || user.mind != summoner || !user.is_holding(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH) || !is_station_level(user.z))
		return
	if(QDELETED(chosen_one) || !isobserver(chosen_one) || !SSpolling.is_eligible(chosen_one, ROLE_SHADOW_DEMON, list(ROLE_SHADOW_DEMON, ROLE_SENTIENCE)))
		to_chat(user, span_warning("Демоны не отвечают на ваш призыв. Попробуйте позже."))
		return
	used = TRUE
	user.log_message("has summoned a shadow demon (played by [key_name(chosen_one)]) using a [name].", LOG_GAME)
	spawn_antag(chosen_one.client, get_turf(src), initial(demon_type.name), summoner)
	to_chat(user, shatter_msg)
	to_chat(user, veil_msg)
	playsound(user, 'sound/effects/glass/glassbr1.ogg', 100, TRUE)
	qdel(src)

/obj/item/antag_spawner/slaughter_demon/shadow/spawn_antag(client/candidate, turf/spawn_turf, kind = "", datum/mind/summoner)
	var/mob/living/basic/demon/shadow/spawned = new demon_type(spawn_turf)
	var/datum/action/cooldown/spell/jaunt/shadow_demon/crawl = locate() in spawned.actions
	crawl.enter_jaunt(spawned)
	spawned.PossessByPlayer(candidate.key)
	var/datum/antagonist/shadow_demon/antag = spawned.mind.has_antag_datum(/datum/antagonist/shadow_demon)
	var/datum/objective/assassinate/kill_summoner = new
	kill_summoner.owner = spawned.mind
	kill_summoner.target = summoner
	kill_summoner.explanation_text = "Убейте [summoner.name], по глупости призвавшего вас в этот мир."
	antag.objectives += kill_summoner
	for(var/datum/objective/shadow_demon/objective in antag.objectives)
		objective.explanation_text = "Убивайте всех остальных и распространяйте тьму."
	spawned.mind.announce_objectives()

/datum/spellbook_entry/item/shadowbottle
	name = "Bottle of Shadows"
	desc = "Флакон чистой тьмы. Разбейте его, чтобы привлечь тенедемона из другого измерения. Он охотится во тьме, быстро гибнет на свету и враждебен даже к призвавшему его волшебнику."
	item_path = /obj/item/antag_spawner/slaughter_demon/shadow
	cost = 1
	limit = 3
	category = "Поддержка"

/datum/spellbook_entry/item/shadowbottle/can_refund(mob/living/carbon/human/user, obj/item/spellbook/book, obj/item/refunding_item)
	var/obj/item/antag_spawner/slaughter_demon/shadow/vial = refunding_item
	if(!istype(vial) || vial.used || vial.summoning)
		return FALSE
	return ..()
