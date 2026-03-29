/obj/item/money_button
	name = "красная кнопка прибыли"
	desc = "Пластиковая кнопка с наклейкой «Быстрая наличка™». Нажмите чтобы моментально обналичить чей-то орган. Счёт будет выставлен случайному члену экипажа."
	icon = 'icons/obj/devices/assemblies.dmi'
	icon_state = "bigred"
	inhand_icon_state = "electronic"
	w_class = WEIGHT_CLASS_TINY
	var/next_use = 0

/obj/item/money_button/attack_self(mob/user)
	. = ..()
	if(!isliving(user))
		return

	if(world.time < next_use)
		to_chat(user, span_notice("Кнопка неактивна, подождите немного."))
		return

	var/mob/living/living_user = user
	if(!living_user.can_perform_action(src, NEED_DEXTERITY | NEED_HANDS))
		return

	var/mob/living/carbon/human/victim = pick_money_button_victim(living_user)
	if(!victim)
		to_chat(user, span_warning("Сделка сорвалась: подходящих доноров на станции не нашлось."))
		return

	var/list/stealable = list()
	for(var/obj/item/organ/organ as anything in victim.organs)
		if(QDELETED(organ) || organ.owner != victim)
			continue
		if(istype(organ, /obj/item/organ/brain))
			continue
		stealable += organ

	if(!length(stealable))
		to_chat(user, span_warning("Сделка сорвалась: у выбранного члена экипажа нечего изъять."))
		return

	var/obj/item/organ/picked = pick(stealable)
	var/organ_name = picked.name
	var/victim_name = victim.real_name
	var/payout = rand(750, 1250)

	next_use = world.time + 3 MINUTES
	picked.Remove(victim, special = FALSE)
	do_sparks(5, FALSE, src)

	var/turf/drop_spot = get_turf(user)
	for(var/obj/item/stack/spacecash/cash_type as anything in credits_to_spacecash(payout))
		new cash_type(drop_spot)

	priority_announce(
		text = "Капитан [user.real_name] продал [organ_name] члена экипажа [victim_name] за [payout] кредитов. Нанотрейзен не одобряет подобные сделки и напоминает о политике телесной целостности персонала.",
		title = "[command_name()]: финансовая сводка",
		sound = 'sound/misc/blessing.ogg',
		has_important_message = TRUE,
	)
	to_chat(victim, span_userdanger("Вы чувствуете как у вас перехватывает дыхание, и [organ_name] болезненно исчезает!"))
	message_admins("[ADMIN_LOOKUPFLW(user)] used the money button: removed [picked.type] from [ADMIN_LOOKUPFLW(victim)] for [payout] cr.")
	log_game("Money button: [key_name(user)] sold [organ_name] from [key_name(victim)] ([payout] cr).")

/obj/item/money_button/proc/pick_money_button_victim(mob/living/buyer)
	var/list/candidates = list()
	for(var/mob/living/carbon/human/human as anything in GLOB.human_list)
		if(QDELETED(human) || human.stat == DEAD || human == buyer)
			continue
		if(!human.client)
			continue
		var/datum/mind/mind = human.mind
		if(!mind || !mind.assigned_role || istype(mind.assigned_role, /datum/job/unassigned))
			continue
		if(!(mind.assigned_role.job_flags & JOB_CREW_MEMBER))
			continue
		candidates += human

	if(!length(candidates))
		return null
	return pick(candidates)
