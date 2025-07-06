// Sidepaths for knowledge between Void and Blade.

/datum/heretic_knowledge_tree_column/void_to_blade
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/void
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/blade

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/limited_amount/risen_corpse
	tier2 = /datum/heretic_knowledge/rune_carver
	tier3 = /datum/heretic_knowledge/summon/maid_in_mirror



/// The max health given to Shattered Risen
#define RISEN_MAX_HEALTH 125

/datum/heretic_knowledge/limited_amount/risen_corpse
	name = "Shattered Ritual"
	desc = "Позволяет трансмутировать труп с душой, пару латексных или нитриловых перчаток, \
		и любой костюм, чтобы создать Разбитого восставшего. \
		Разбитые восставшие это сильные гули с 125 здоровья, но не могут держать предметы, \
		вместо этого имеют в руках два жестоких оружия. Вы можете иметь только одного."
	gain_text = "Я узрел как холодная, раздирающая сила вернула этот труп к полу-жизни. \
		Движения хрустящие, как сломанное стекло. Руки больше не похожи на человеческие - \
		в каждом сжатом кулаке жестокие гнезда острых костяных осколков."

	required_atoms = list(
		/obj/item/clothing/suit = 1,
		/obj/item/clothing/gloves/latex = 1,
	)
	limit = 1
	cost = 1

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "ghoul_shattered"


/datum/heretic_knowledge/limited_amount/risen_corpse/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue
		if(!IS_VALID_GHOUL_MOB(body) || HAS_TRAIT(body, TRAIT_HUSK))
			to_chat(user, span_hierophant_warning("[capitalize(body.declent_ru(NOMINATIVE))] не в подходящем состоянии для превращения в гуля."))
			continue
		if(!body.mind)
			to_chat(user, span_hierophant_warning("[capitalize(body.declent_ru(NOMINATIVE))] не имеет разума и не может быть превращен в гуля."))
			continue
		if(!body.client && !body.mind.get_ghost(ghosts_with_clients = TRUE))
			to_chat(user, span_hierophant_warning("[capitalize(body.declent_ru(NOMINATIVE))] не имеет души и не может быть превращен в гуля."))
			continue

		// We will only accept valid bodies with a mind, or with a ghost connected that used to control the body
		selected_atoms += body
		return TRUE

	loc.balloon_alert(user, "ритуал провален, нет подходящего тела!")
	return FALSE

/datum/heretic_knowledge/limited_amount/risen_corpse/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(QDELETED(soon_to_be_ghoul)) // No body? No ritual
		stack_trace("[type] reached on_finished_recipe without a human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "ритуал провален, нет подходящего тела!")
		return FALSE

	soon_to_be_ghoul.grab_ghost()
	if(!soon_to_be_ghoul.mind || !soon_to_be_ghoul.client)
		stack_trace("[type] reached on_finished_recipe without a minded / cliented human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "ритуал провален, нет подходящего тела!")
		return FALSE

	selected_atoms -= soon_to_be_ghoul
	make_risen(user, soon_to_be_ghoul)
	return TRUE

/// Make [victim] into a shattered risen ghoul.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/make_risen(mob/living/user, mob/living/carbon/human/victim)
	user.log_message("created a shattered risen out of [key_name(victim)].", LOG_GAME)
	victim.log_message("became a shattered risen of [key_name(user)]'s.", LOG_VICTIM, log_globally = FALSE)
	message_admins("[ADMIN_LOOKUPFLW(user)] created a shattered risen, [ADMIN_LOOKUPFLW(victim)].")

	victim.apply_status_effect(
		/datum/status_effect/ghoul,
		RISEN_MAX_HEALTH,
		user.mind,
		CALLBACK(src, PROC_REF(apply_to_risen)),
		CALLBACK(src, PROC_REF(remove_from_risen)),
	)

/// Callback for the ghoul status effect - what effects are applied to the ghoul.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/apply_to_risen(mob/living/risen)
	LAZYADD(created_items, WEAKREF(risen))
	risen.AddComponent(/datum/component/mutant_hands, mutant_hand_path = /obj/item/mutant_hand/shattered_risen)

/// Callback for the ghoul status effect - cleaning up effects after the ghoul status is removed.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/remove_from_risen(mob/living/risen)
	LAZYREMOVE(created_items, WEAKREF(risen))
	qdel(risen.GetComponent(/datum/component/mutant_hands))

#undef RISEN_MAX_HEALTH

/// The "hand" "weapon" used by shattered risen
/obj/item/mutant_hand/shattered_risen
	name = "bone-shards"
	desc = "То, что когда-то казалось обычным человеческим кулаком, теперь превратилось в гнездо острых костяных осколков."
	color = "#001aff"
	hitsound = SFX_SHATTER
	force = 16
	wound_bonus = -30
	exposed_wound_bonus = 15
	demolition_mod = 1.5
	sharpness = SHARP_EDGED

/datum/heretic_knowledge/rune_carver
	name = "Carving Knife"
	desc = "Позволяет трансмутировать нож, осколок стекла и лист бумаги, чтобы создать Резьбовой нож. \
		Резьбовой нож позволяет вырезать трудноразличимые ловушки, которые срабатывают на язычников, проходящих над ними. \
		Также является удобным метательным оружием."
	gain_text = "Высеченные, вырезанные... вечные. Сила скрыта во всем. Я могу раскрыть ее! \
		Я могу вырезать монолит, раскрывающий цепи!"

	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/shard = 1,
		/obj/item/paper = 1,
	)
	result_atoms = list(/obj/item/melee/rune_carver)
	cost = 1


	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "rune_carver"

/datum/heretic_knowledge/summon/maid_in_mirror
	name = "Maid in the Mirror"
	desc = "Позволяет трансмутировать пять листов титаниума, флэш, броню и пару легких \
		чтобы создать Зеркальную служанку. Зеркальные служанки - достойные бойцы, которые могут становиться бесплотными, \
		переходя в зеркальный мир и обратно, и служат мощными разведчиками и засадчиками. \
		Но они слабы против взгляда смертных и получают урон при осмотре."
	gain_text = "Внутри каждого отражения - ворота в невообразимый мир невиданных красок и \
		незнакомых людей. Подъем - стекло, а стены - ножи. Каждый шаг - это кровь, если у вас нет проводника."

	required_atoms = list(
		/obj/item/stack/sheet/mineral/titanium = 5,
		/obj/item/clothing/suit/armor = 1,
		/obj/item/assembly/flash = 1,
		/obj/item/organ/lungs = 1,
	)
	cost = 1

	mob_to_summon = /mob/living/basic/heretic_summon/maid_in_the_mirror
	poll_ignore_define = POLL_IGNORE_MAID_IN_MIRROR

