/area/awaymission/wild_west
	name = "Wild West"
	icon_state = "away"
	abstract_type = /area/awaymission/wild_west
	requires_power = FALSE

/area/awaymission/wild_west/mines
	name = "Wild West Mines"
	icon_state = "awaycontent1"

/area/awaymission/wild_west/vault_doors
	name = "Wild West Vault Doors"
	icon_state = "awaycontent2"

/area/awaymission/wild_west/refinery
	name = "Wild West Refinery"
	icon_state = "awaycontent3"

/area/awaymission/wild_west/vault
	name = "Wild West Vault"
	icon_state = "awaycontent3"

/obj/effect/mine/dna_scramble
	name = "Radiation Mine"

/obj/effect/mine/dna_scramble/mineEffect(mob/living/carbon/victim)
	if(!istype(victim))
		return
	victim.easy_random_mutate(NEGATIVE | MINOR_NEGATIVE, sequence = FALSE)

/mob/living/basic/faithless/wild_west
	faction = list(FACTION_WILD_WEST)

/mob/living/basic/creature/wild_west
	faction = list(FACTION_WILD_WEST)

/mob/living/basic/migo/wild_west
	faction = list(FACTION_WILD_WEST)

/obj/structure/wish_granter
	name = "Исполнитель желаний"
	desc = "Вы уже не уверены в этом..."
	icon = 'modular_bandastation/objects/icons/obj/structures/wish_granter.dmi'
	icon_state = "wish_granter"
	anchored = TRUE
	density = TRUE
	/// The various mutations that are given when making a Power wish
	var/list/power_mutations = list(
		/datum/mutation/adaptation/cold,
		/datum/mutation/cryokinesis,
		/datum/mutation/night_vision,
		/datum/mutation/xray,
	)
	/// How many times can be used
	var/charges = 1
	/// Has it been clicked once? (Need for warning users)
	var/insisting = FALSE

/obj/structure/wish_granter/examine(mob/user)
	. = ..()
	if(IS_CULTIST(user))
		. += span_cult("Ваше культисткое чутье подсказывает вам, что [name] искушает вас, дабы завладеть вашей душой.")
	if(!charges)
		. += span_notice("[name] не подаёт никаких признаков активности.")
	else
		. += span_notice("[name] издаётся манящим кроваво-красным светом.")

/obj/structure/wish_granter/update_icon_state()
	. = ..()
	if(insisting)
		icon_state = "[initial(icon_state)]_pulse"
		return
	if(!charges)
		icon_state = "[initial(icon_state)]_dormant"

/obj/structure/wish_granter/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(!charges)
		to_chat(user, span_notice("[name] никак не реагирует."))
		return
	if(!istype(user))
		to_chat(user, span_warning("Вы чувствуете темное движение внутри [name], которого опасаются ваши инстинкты."))
		return
	if(user.is_antag())
		to_chat(user, span_notice("Что-то инстинктивно заставляет вас отстраниться."))
		return
	if(!insisting)
		to_chat(user, span_cult("Ваше первое прикосновение заставляет [name] зашевелиться, прислушиваясь к вам. Вы действительно уверены, что хотите это сделать?"))
		insisting = TRUE
		update_icon(UPDATE_ICON_STATE)
		return

	insisting = FALSE
	var/wish = tgui_input_list(user, "Вы хотите...", "Желание", list("Силу", "Богатство", "Бессмертие", "Покой"))
	if(isnull(wish))
		return
	charges--
	update_icon(UPDATE_ICON_STATE)
	var/become_shadow = TRUE
	var/list/output = list()
	switch(wish)
		if("Силу")
			for(var/mutation_type in power_mutations)
				user.dna.add_mutation(mutation_type, MUTATION_SOURCE_WISHGRANTER)

		if("Богатство")
			var/obj/structure/closet/syndicate/resources/everything/closet = new /obj/structure/closet/syndicate/resources/everything(loc)
			var/dice = pick_weight(list(
				/obj/item/dice/d20/fate,
				/obj/item/dice/d20/fate/one_use = 9,
			))
			new dice(closet)

		if("Бессмертие")
			var/datum/action/cooldown/wish_granter_revive/ability = new(user)
			ability.Grant(user)

		if("Покой")
			for(var/mob/living/basic/faithless/faithless in GLOB.alive_mob_list)
				faithless.death()
			become_shadow = FALSE

	if(become_shadow && !isshadow(user))
		to_chat(user, span_warning("Ваша плоть темнеет!"))
		to_chat(user, span_warning("Ваше тело бурно реагирует на свет, однако естественным образом исцеляется в темноте..."))
		output.Add(span_userdanger("Ваше желание исполнено, но какой ценой?..."))
		output.Add(span_danger("[name] наказывает вас за ваш эгоизм, забирая душу и деформируя тело, чтобы оно соответствовало тьме в вашем сердце."))
		output.Add(span_revenbignotice("Вы теперь <b>Тень</b>, раса живущих во тьме гуманоидов."))
		output.Add(span_revenboldnotice("Помимо ваших новых качеств, вы психически не изменились и сохраняете свою прежнюю личность."))
		user.set_species(/datum/species/shadow)
		user.regenerate_icons()
	else
		output.Add(span_boldnotice("Вы чувствуете как избежали горькой судьбы..."))
		output.Add(span_notice("Каким бы инопланетным разумом ни обладал [name], оно удовлетворяет ваше желание.\nНаступает тишина..."))

	to_chat(user, custom_boxed_message("red_box", output.Join("<br>")))

/datum/action/cooldown/wish_granter_revive
	name = "Возрождение"
	button_icon = 'icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "revive"
	var/reviving = FALSE

/datum/action/cooldown/wish_granter_revive/Activate(atom/target)
	if(owner.stat != DEAD)
		owner.balloon_alert(owner, "живы!")
		return FALSE
	reviving = TRUE
	to_chat(owner, span_notice("Смерть - ещё не конец!"))
	var/revive_delay = rand(80 SECONDS, 120 SECONDS)
	cooldown_time = revive_delay
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/action/cooldown/wish_granter_revive, revive)), revive_delay)
	return ..()

/datum/action/cooldown/wish_granter_revive/IsAvailable(feedback = FALSE)
	if(reviving)
		return FALSE
	return ..()

/datum/action/cooldown/wish_granter_revive/proc/revive()
	reviving = FALSE
	if(owner.stat != DEAD)
		return
	var/mob/living/carbon/human/human = owner
	human.revive(ADMIN_HEAL_ALL)
	human.visible_message(
		span_warning("[human] восстаёт из мертвых, исцелив все свои раны!"),
		span_notice("Вы вернулись из небытия."),
	)

/obj/item/mod/control/pre_equipped/mining/asteroid
	applied_skin = "asteroid"

/obj/item/storage/medkit/brute/empty
	empty = TRUE

/obj/structure/curtain/cloth/start_closed
	open = FALSE

/obj/structure/falsewall/rock_indestructible
	name = /turf/closed/indestructible/rock::name
	desc = /turf/closed/indestructible/rock::desc
	icon = 'modular_bandastation/aesthetics/walls/icons/false_walls.dmi'
	icon_state = "smoothrocks-open"
	base_icon_state = "smoothrocks"
	fake_icon = DEFAULT_ROCKS
	color = /turf/closed/indestructible/rock::color
	smoothing_groups = /turf/closed/indestructible/rock::smoothing_groups
	canSmoothWith = /turf/closed/indestructible/rock::canSmoothWith
	smoothing_flags = /turf/closed/indestructible/rock::smoothing_flags
	walltype = /turf/closed/indestructible/rock

/obj/effect/step_trigger/sound_effect/wild_west
	abstract_type = /obj/effect/step_trigger/sound_effect/wild_west
	happens_once = TRUE
	triggerer_only = TRUE

/obj/effect/step_trigger/sound_effect/wild_west/whisper
	sound = 'modular_bandastation/aesthetics_sounds/sound/many_whisper1.ogg'

/obj/effect/step_trigger/sound_effect/wild_west/whisper_2
	sound = 'modular_bandastation/aesthetics_sounds/sound/many_whisper2.ogg'

/obj/effect/step_trigger/sound_effect/wild_west/whisper_3
	sound = 'modular_bandastation/aesthetics_sounds/sound/scary_whisper1.ogg'

/obj/effect/step_trigger/sound_effect/wild_west/turn
	sound = 'sound/effects/hallucinations/turn_around1.ogg'

/obj/effect/step_trigger/sound_effect/wild_west/here
	sound = 'sound/effects/hallucinations/im_here1.ogg'

/obj/effect/step_trigger/sound_effect/wild_west/see
	sound = 'sound/effects/hallucinations/i_see_you1.ogg'

/obj/effect/step_trigger/sound_effect/wild_west/behind
	sound = 'sound/effects/hallucinations/behind_you1.ogg'

/obj/effect/step_trigger/sound_effect/wild_west/over
	sound = 'sound/effects/hallucinations/over_here1.ogg'

/obj/effect/step_trigger/message/wild_west
	abstract_type = /obj/effect/step_trigger/message/wild_west

/obj/effect/step_trigger/message/wild_west/first
	message = span_cult_bold_italic("Вы ощущаете странный зловещий зов, что доносится из глубин пещеры...")

/obj/effect/step_trigger/message/wild_west/second
	message = span_cult_bold_italic("Этот камень как будто не на своем месте.")

/obj/effect/step_trigger/message/wild_west/third
	message = span_cult_bold_italic("Вы ловите себя на мысли, что ваши ноги начали двигаться в такт хаотичному ритму зова!")

/obj/effect/step_trigger/message/wild_west/fourth
	message = span_cult_bold_italic("Древние циклопические стены, ужасающие петроглифы и сладковатый запах затхлости... Стоит скорее повернуть назад, пока этот проклятый зов окончательно не захватил ваш разум!")

/obj/structure/closet/wardrobe/miner/empty/PopulateContents()
	return

/obj/effect/landmark/awaystart/wild_west
	name = "Wild West"
	id = AWAYSTART_WILD_WEST
