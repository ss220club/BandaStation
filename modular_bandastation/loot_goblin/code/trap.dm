/datum/action/cooldown/loot_goblin_trap
	name = "Гоблинский капкан"
	desc = "Поставить незаметный капкан под собой. Нужно 5 листов железа. Одновременно может стоять не больше 3 капканов."
	button_icon = 'modular_bandastation/loot_goblin/icons/trap.dmi'
	button_icon_state = "trap"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED | AB_CHECK_HANDS_BLOCKED
	cooldown_time = LOOT_GOBLIN_TRAP_COOLDOWN
	var/list/obj/structure/loot_goblin_trap/active_traps = list()

/datum/action/cooldown/loot_goblin_trap/Destroy()
	var/list/traps_to_delete = active_traps.Copy()
	active_traps.Cut()
	QDEL_LIST(traps_to_delete)
	return ..()

/datum/action/cooldown/loot_goblin_trap/Activate(atom/cast_on)
	var/turf/trap_turf = owner.loc
	if(!isfloorturf(trap_turf))
		to_chat(owner, span_warning("Капкан можно поставить только на пол!"))
		return FALSE
	if(locate(/obj/structure/loot_goblin_trap) in trap_turf)
		to_chat(owner, span_warning("Здесь уже стоит капкан!"))
		return FALSE
	if(length(active_traps) >= LOOT_GOBLIN_MAX_TRAPS)
		to_chat(owner, span_warning("У вас уже стоит [LOOT_GOBLIN_MAX_TRAPS] капкана — больше не унести!"))
		return FALSE
	var/list/iron_stacks = list()
	var/iron_amount = 0
	for(var/obj/item/stack/sheet/iron/iron in owner.get_all_contents())
		iron_stacks += iron
		iron_amount += iron.amount
	if(iron_amount < LOOT_GOBLIN_TRAP_IRON)
		to_chat(owner, span_warning("Для капкана нужно [LOOT_GOBLIN_TRAP_IRON] листов железа, у вас [iron_amount]."))
		return FALSE
	var/iron_needed = LOOT_GOBLIN_TRAP_IRON
	for(var/obj/item/stack/sheet/iron/iron as anything in iron_stacks)
		var/used = min(iron_needed, iron.amount)
		iron.use(used)
		iron_needed -= used
		if(iron_needed <= 0)
			break
	active_traps += new /obj/structure/loot_goblin_trap(trap_turf, src)
	playsound(trap_turf, 'sound/effects/snap.ogg', 20, TRUE)
	to_chat(owner, span_notice("Вы прячете капкан под ногами."))
	StartCooldown()
	return TRUE

/obj/structure/loot_goblin_trap
	name = "goblin snare"
	desc = "Ржавые зубья, присыпанные мусором. Лучше не наступать."
	icon = 'modular_bandastation/loot_goblin/icons/trap.dmi'
	icon_state = "trap"
	anchored = TRUE
	density = FALSE
	alpha = LOOT_GOBLIN_TRAP_ALPHA
	layer = LOW_OBJ_LAYER
	max_integrity = 20
	var/datum/action/cooldown/loot_goblin_trap/owner_action
	var/datum/weakref/goblin_ref

/obj/structure/loot_goblin_trap/Initialize(mapload, datum/action/cooldown/loot_goblin_trap/new_action)
	. = ..()
	owner_action = new_action
	goblin_ref = WEAKREF(new_action?.owner)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/loot_goblin_trap/Destroy()
	owner_action?.active_traps -= src
	owner_action = null
	return ..()

/obj/structure/loot_goblin_trap/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(!ishuman(arrived))
		return
	var/mob/living/carbon/human/victim = arrived
	if(HAS_TRAIT(victim, TRAIT_LOOT_GOBLIN) || (victim.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return
	spring(victim)

/obj/structure/loot_goblin_trap/proc/spring(mob/living/carbon/human/victim)
	playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
	victim.visible_message(
		span_danger("[capitalize(victim.declent_ru(NOMINATIVE))] наступает в гоблинский капкан и валится с ног!"),
		span_userdanger("Капкан захлопывается, и вы падаете, не в силах вымолвить ни слова!"),
	)
	victim.Knockdown(LOOT_GOBLIN_TRAP_KNOCKDOWN)
	victim.adjust_stamina_loss(LOOT_GOBLIN_TRAP_STAMINA)
	victim.apply_status_effect(/datum/status_effect/silenced, LOOT_GOBLIN_TRAP_SILENCE)
	var/mob/living/goblin = goblin_ref?.resolve()
	log_combat(goblin, victim, "caught in a loot goblin trap")
	qdel(src)
