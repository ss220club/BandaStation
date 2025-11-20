/datum/heretic_knowledge_tree_column/blade
	route = PATH_BLADE
	ui_bgr = "node_blade"
	complexity = "Hard"
	complexity_color = COLOR_RED
	icon = list(
		"icon" = 'icons/obj/weapons/khopesh.dmi',
		"state" = "dark_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"The Path of Blade is as the name suggests.",
		"You are highly competent at cutting your opponents to ribbons.",
		"Pick this path if you want to fight, and you want to be the best at fighting.",
	)
	pros = list(
		"Capable of blocking incoming attacks, retaliating with a riposte.",
		"Rapidly deals damage through dual-wielded blades and channeled strikes.",
		"High defense against stuns and knockdowns.",
		"Highly lethal combatant in a direct combat with a single opponent.",
	)
	cons = list(
		"Requires a high degree of skill input.",
		"Without blades, the path loses most of its fighting power.",
		"Lacks mobility options.",
		"Lacks environmental protections.",
	)
	tips = list(
		"Your Mansus Grasp will stun your opponent if they are attacked from behind or while they are prone. This also locks them in the room they are in until the mark is detonated. Triggering the mark will grant you a orbiting knife that will protect you from one melee or ranged attack.",
		"You have the highest blade cap out of all paths (A total of 4). But since they require silver or titanium to craft, you might be strapped for ingredients if the miners aren't doing their job. If you need materials, shuttle walls and seats are a source of titanium metal, and surgery tables a source of silver.",
		"You are highly reliant on approaching opponents in melee. Slips, bolas and beartraps are your worst enemy. You can counteract slips by crafting a pair of Greaves Of The Prophet, or remove restraints with Ashen Passage.",
		"Realignment will pull you out of stuns and knockdowns, but also pacifies you for the duration.",
		"With Empowered Blades, your offensive power grows considerably. You are able to fight with dual-wielded blades, and can empower them by activating your Mansus Grasp while wielding your blades. Your blades also deal additional damage to objects, silicons and mechs.",
		"Maintaining a good offense also creates a good defense. With orbiting blades, you are able to block additional incoming attacks.",
		"With Furious Steel, you can not only produce several knives for defensive purposes, but throw them by clicking with an empty hand. This gives you additional ranged power in a pinch.",
		"Use Wolves Among Sheep with caution. Not only does it have a significant cooldown, but it also arms anyone trapped in the effect with you with blades of their own. Use it either as a last ditch defense, or when you know you have the upper hand and need an extra edge. Just don't try to flee the area before taking someone out first.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_blade
	knowledge_tier1 = /datum/heretic_knowledge/spell/realignment
	guaranteed_side_tier1 = /datum/heretic_knowledge/greaves_of_the_prophet
	knowledge_tier2 = /datum/heretic_knowledge/duel_stance
	guaranteed_side_tier2 = /datum/heretic_knowledge/essence
	robes = /datum/heretic_knowledge/armor/blade
	knowledge_tier3 = /datum/heretic_knowledge/spell/furious_steel
	guaranteed_side_tier3 = /datum/heretic_knowledge/rune_carver
	blade = /datum/heretic_knowledge/blade_upgrade/blade
	knowledge_tier4 = /datum/heretic_knowledge/spell/wolves_among_sheep
	ascension = /datum/heretic_knowledge/ultimate/blade_final

/datum/heretic_knowledge/limited_amount/starting/base_blade
	name = "The Cutting Edge"
	desc = "Открывает перед вами Путь клинков. \
		Позволяет трансмутировать нож с одним слитком серебра или титаниума для создания Закаленного клинка. \
		Одновременно можно иметь не более четырех."
	gain_text = "Наши великие предки ковали мечи и практиковали спарринги накануне великих сражений."
	required_atoms = list(
		/obj/item/knife = 1,
		list(/obj/item/stack/sheet/mineral/silver, /obj/item/stack/sheet/mineral/titanium) = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/dark)
	limit = 4 // It's the blade path, it's a given
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "dark_blade"
	mark_type = /datum/status_effect/eldritch/blade
	eldritch_passive = /datum/status_effect/heretic_passive/blade

/datum/heretic_knowledge/limited_amount/starting/base_blade/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(!check_behind(source, target))
		return

	// We're officially behind them, apply effects
	target.AdjustParalyzed(1.5 SECONDS)
	target.apply_damage(10, BRUTE, wound_bonus = CANT_WOUND)
	target.balloon_alert(source, "удар в спину!")
	playsound(target, 'sound/items/weapons/guillotine.ogg', 100, TRUE)

/datum/heretic_knowledge/limited_amount/starting/base_blade/create_mark(mob/living/source, mob/living/target)
	var/datum/status_effect/eldritch/blade/blade_mark = ..()
	if(istype(blade_mark))
		var/area/to_lock_to = get_area(target)
		blade_mark.locked_to = to_lock_to
		to_chat(target, span_hypnophrase("Потусторонняя сила заставляет вас оставаться в [get_area_name(to_lock_to)]!"))
	return blade_mark

/datum/heretic_knowledge/limited_amount/starting/base_blade/trigger_mark(mob/living/source, mob/living/target)
	. = ..()
	if(!.)
		return
	source.apply_status_effect(/datum/status_effect/protective_blades, 60 SECONDS, 1, 20, 0 SECONDS)

/datum/heretic_knowledge/spell/realignment
	name = "Realignment"
	desc = "Дает вам заклинание Realignment, которое быстро и на короткое время выправит ваше тело. \
		Во время этого процесса вы будете быстро восстанавливать стамину и быстро восстанавливаться после оглушения, однако вы не сможете атаковать. \
		Это заклинание можно применять подряд, но при этом увеличивается время его перезарядки."
	gain_text = "В шквале смертей он обрел мир внутри себя. Несмотря на неодолимые шансы, он ступал вперед."
	action_to_add = /datum/action/cooldown/spell/realignment
	cost = 2

/// The amount of blood flow reduced per level of severity of gained bleeding wounds for Stance of the Torn Champion.
#define BLOOD_FLOW_PER_SEVEIRTY -1

/datum/heretic_knowledge/duel_stance
	name = "Stance of the Torn Champion"
	desc = "Grants resilience to blood loss from wounds and immunity to having your limbs dismembered. \
		Additionally, when damaged below 50% of your maximum health, \
		you gain increased resistance to gaining wounds and resistance to slowdown."
	gain_text = "In time, it was he who stood alone among the bodies of his former comrades, awash in blood, none of it his own. \
		He was without rival, equal, or purpose."
	cost = 2
	research_tree_icon_path = 'icons/effects/blood.dmi'
	research_tree_icon_state = "suitblood"
	research_tree_icon_dir = SOUTH
	drafting_tier = 5
	/// Whether we're currently in duelist stance, gaining certain buffs (low health)
	var/in_duelist_stance = FALSE

/datum/heretic_knowledge/duel_stance/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	ADD_TRAIT(user, TRAIT_NODISMEMBER, type)
	RegisterSignal(user, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(user, COMSIG_CARBON_GAIN_WOUND, PROC_REF(on_wound_gain))
	RegisterSignal(user, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_update))

	on_health_update(user) // Run this once, so if the knowledge is learned while hurt it activates properly

/datum/heretic_knowledge/duel_stance/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	REMOVE_TRAIT(user, TRAIT_NODISMEMBER, type)
	if(in_duelist_stance)
		user.remove_traits(list(TRAIT_HARDLY_WOUNDED), type)
		if(isliving(user))
			var/mob/living/living_mob = user
			living_mob.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown, TRUE)

	UnregisterSignal(user, list(COMSIG_ATOM_EXAMINE, COMSIG_CARBON_GAIN_WOUND, COMSIG_LIVING_HEALTH_UPDATE))

/datum/heretic_knowledge/duel_stance/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/obj/item/held_item = source.get_active_held_item()
	if(in_duelist_stance)
		examine_list += span_warning("[source] looks unnaturally poised[held_item?.force >= 15 ? " and ready to strike out":""].")

/datum/heretic_knowledge/duel_stance/proc/on_wound_gain(mob/living/source, datum/wound/gained_wound, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	if(gained_wound.blood_flow <= 0)
		return

	gained_wound.adjust_blood_flow(gained_wound.severity * BLOOD_FLOW_PER_SEVEIRTY)

/datum/heretic_knowledge/duel_stance/proc/on_health_update(mob/living/source)
	SIGNAL_HANDLER

	if(in_duelist_stance && source.health > source.maxHealth * 0.5)
		source.balloon_alert(source, "exited duelist stance")
		in_duelist_stance = FALSE
		source.remove_traits(list(TRAIT_HARDLY_WOUNDED), type)
		source.remove_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown, TRUE)
		return

	if(!in_duelist_stance && source.health <= source.maxHealth * 0.5)
		source.balloon_alert(source, "entered duelist stance")
		in_duelist_stance = TRUE
		ADD_TRAIT(source, TRAIT_HARDLY_WOUNDED, type)
		source.add_movespeed_mod_immunities(type, /datum/movespeed_modifier/damage_slowdown, TRUE)
		return

#undef BLOOD_FLOW_PER_SEVEIRTY

/datum/heretic_knowledge/armor/blade
	desc = "Allows you to transmute a table (or a suit), a mask and a sheet of titanium or silver to create a Shattered Panoply. \
			Provides baton resistance and shock insulation while worn. \
			Acts as a focus while hooded."
	gain_text = "The echoing, directionless cacophony of violence reverberates about me. \
				Even as the Champion's steel panoply was torn from their form, each piece craves purpose still, seeking to intercept unseen or imagined attackers."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/blade)
	research_tree_icon_state = "blade_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		list(/obj/item/stack/sheet/mineral/silver, /obj/item/stack/sheet/mineral/titanium) = 1,
	)

/datum/heretic_knowledge/spell/wolves_among_sheep
	name = "Wolves Among Sheep"
	desc = "Изменяет материю реальности, создавая магическую арену, недоступную для посторонних, \
		все участники находятся в ловушке и защищены от любых форм контроля толпы или опасностей окружающей среды; \
		попавшим в ловушку участникам выдается Клинок, и они не могут выйти или телепортироваться, пока не нанесут критический удар. \
		Критические удары частично восстанавливают здоровье еретика."
	gain_text = "Тени расползаются по комнате, отбрасывая силуэты на каждый стул, стол \
		и вырисовываются в фигуру еще одной предательской руки. \
		Я стал всеобщим врагом, и мне никогда не обрести покоя. \
		Я разрушил все связи и разорвал все союзы. В этой истине \
		теперь я знаю, как непрочно товарищество. Враги мои будут повсюду, каждый по частям."
	cost = 2
	action_to_add = /datum/action/cooldown/spell/wolves_among_sheep
	is_final_knowledge = TRUE

/datum/heretic_knowledge/blade_upgrade/blade
	name = "Empowered Blades"
	desc = "Атакуя кого-либо с Закаленным клинком в обеих руках, \
		теперь вы будете наносить удар обоими клинками сразу, нанося две атаки в быстрой последовательности. \
		Второй удар будет немного слабее. \
		Ваша Хватка мансуса может слиться с клинком, а сами клинки более эффективны против структур."
	gain_text = "Я нашел его рассеченным на две части, половинки сцепились в дуэли без конца; \
		шквал клинков, но ни один из них не попал в цель, ибо Чемпион был неукротим."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_blade"
	/// How much force do we apply to the offhand?
	var/offand_force_decrement = 0
	/// How much force was the last weapon we offhanded with? If it's different, we need to re-calculate the decrement
	var/last_weapon_force = -1

/datum/heretic_knowledge/blade_upgrade/blade/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_TOUCH_HANDLESS_CAST, PROC_REF(on_grasp_cast))
	RegisterSignal(user, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_blade_equipped))

/datum/heretic_knowledge/blade_upgrade/blade/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, list(COMSIG_TOUCH_HANDLESS_CAST, COMSIG_MOB_EQUIPPED_ITEM))

///Tries to infuse our held blade with our mansus grasp
/datum/heretic_knowledge/blade_upgrade/blade/proc/on_grasp_cast(mob/living/carbon/cast_on)
	SIGNAL_HANDLER

	var/held_item = cast_on.get_active_held_item()
	if(!istype(held_item, /obj/item/melee/sickly_blade/dark))
		return NONE
	var/obj/item/melee/sickly_blade/dark/held_blade = held_item
	if(held_blade.infused)
		return NONE
	held_blade.infused = TRUE
	held_blade.update_appearance(UPDATE_ICON)

	//Infuse our off-hand blade just so it's nicer visually
	var/obj/item/melee/sickly_blade/dark/off_hand_blade = cast_on.get_inactive_held_item()
	if(istype(off_hand_blade, /obj/item/melee/sickly_blade/dark))
		off_hand_blade.infused = TRUE
		off_hand_blade.update_appearance(UPDATE_ICON)
	cast_on.update_held_items()

	return COMPONENT_CAST_HANDLESS

/datum/heretic_knowledge/blade_upgrade/blade/do_melee_effects(mob/living/source, atom/target, obj/item/melee/sickly_blade/blade)
	if(target == source)
		return

	var/obj/item/off_hand = source.get_inactive_held_item()
	if(QDELETED(off_hand) || !istype(off_hand, /obj/item/melee/sickly_blade))
		return
	// If our off-hand is the blade that's attacking,
	// quit out now to avoid an infinite stab combo
	if(off_hand == blade)
		return

	// Give it a short delay (for style, also lets people dodge it I guess)
	addtimer(CALLBACK(src, PROC_REF(follow_up_attack), source, target, off_hand), 0.25 SECONDS)

/datum/heretic_knowledge/blade_upgrade/blade/proc/follow_up_attack(mob/living/source, atom/target, obj/item/melee/sickly_blade/blade)
	if(QDELETED(source) || QDELETED(target) || QDELETED(blade))
		return
	// Sanity to ensure that the blade we're delivering an offhand attack with is ACTUALLY our offhand
	if(blade != source.get_inactive_held_item())
		return
	// And we easily could've moved away
	if(!source.Adjacent(target))
		return

	// Check if we need to recaclulate our offhand force
	// This is just so we don't run this block every attack, that's wasteful
	if(last_weapon_force != blade.force)
		offand_force_decrement = 0
		// We want to make sure that the offhand blade increases their hits to crit by one, just about
		// So, let's do some quick math. Yes this'll be inaccurate if their mainhand blade is modified (whetstone), no I don't care
		// Find how much force we need to detract from the second blade
		var/hits_to_crit_on_average = ROUND_UP(100 / (blade.force * 2))
		while(hits_to_crit_on_average <= 3) // 3 hits and beyond is a bit too absurd
			if(offand_force_decrement + 2 > blade.force * 0.5) // But also cutting the force beyond half is absurd
				break

			offand_force_decrement += 2
			hits_to_crit_on_average = ROUND_UP(100 / (blade.force * 2 - offand_force_decrement))

	// Perform the offhand attack
	blade.melee_attack_chain(source, target, null, list(FORCE_MODIFIER = -offand_force_decrement))

///Modifies our blade demolition modifier so we can take down doors with it
/datum/heretic_knowledge/blade_upgrade/blade/proc/on_blade_equipped(mob/user, obj/item/equipped, slot)
	SIGNAL_HANDLER
	if(istype(equipped, /obj/item/melee/sickly_blade/dark))
		equipped.demolition_mod = 2.5

/datum/heretic_knowledge/spell/furious_steel
	name = "Furious Steel"
	desc = "Дарует вам Furious Steel, заклинание с выбором цели. При его использовании вокруг вас появятся три \
		вращающихся клинка. Эти клинки защищают вас от всех атак, \
		но при использовании расходуются. Кроме того, вы можете использовать кнопку, чтобы выстрелить лезвиями \
		в цель, нанося урон и вызывая кровотечение."
	gain_text = "Не раздумывая, я взял нож павшего солдата и со всей силы метнул. Моя меткость оказалась верна! \
		Чемпион Растерзаний улыбнулся их первому вкусу агонии, и, кивнув, их клинки стали моими собственными."
	action_to_add = /datum/action/cooldown/spell/pointed/projectile/furious_steel
	cost = 2

/datum/heretic_knowledge/ultimate/blade_final
	name = "Maelstrom of Silver"
	desc = "Ритуал вознесения Пути клинков. \
		Принесите 3 безголовых или со сломанным черепом трупа к руне трансмутации, чтобы завершить ритуал. \
		После завершения вы будете окружены постоянно восстанавливающимися вращающимися лезвиями. \
		Эти клинки защищают вас от всех атак, но расходуются при использовании. \
		Ваше заклинание Furious Steel также будет перезаряжаться быстрее. \
		Кроме того, вы становитесь мастером боя, получая полный иммунитет к ранам и возможность снимать короткие оглушения. \
		Ваши Закаленные клинки наносят бонусный урон и исцеляют вас при атаке на часть нанесенного урона."
	gain_text = "Чемпион Растерзаний освобожден! Я стану воссоединенным клинком, и с моими более великими амбициями, \
		МНЕ НЕТ РАВНЫХ! БУРЯ ИЗ СТАЛИ И СЕРЕБРА НАДВИГАЕТСЯ НА НАС! УЗРИТЕ МОЁ ВОЗНЕСЕНИЕ!"

	ascension_achievement = /datum/award/achievement/misc/blade_ascension
	announcement_text = "%SPOOKY% Мастер клинков %NAME%, ученик Чемпиона Растерзаний, вознесся! Их сталь — та, что рассечет реальность в серебряном шторме! %SPOOKY%"
	announcement_sound = 'sound/music/antag/heretic/ascend_blade.ogg'

/datum/heretic_knowledge/ultimate/blade_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE

	return !sacrifice.get_bodypart(BODY_ZONE_HEAD) || HAS_TRAIT(sacrifice, TRAIT_HAS_CRANIAL_FISSURE)

/datum/heretic_knowledge/ultimate/blade_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()

	ADD_TRAIT(user, TRAIT_NEVER_WOUNDED, type)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(on_eldritch_blade))
	user.apply_status_effect(/datum/status_effect/protective_blades/recharging, STATUS_EFFECT_PERMANENT, 8, 30, 0.25 SECONDS, /obj/effect/floating_blade, 60 SECONDS)
	user.add_stun_absorption(
		source = name,
		message = span_warning("%EFFECT_OWNER throws off the stun!"),
		self_message = span_warning("You throw off the stun!"),
		examine_message = span_hypnophrase("%EFFECT_OWNER_THEYRE standing stalwartly."),
		// flashbangs are like 5-10 seoncds,
		// a banana peel is ~5 seconds, depending on botany
		// body throws and tackles are less than 5 seconds,
		// stun baton / stamcrit detracts no time,
		// and worst case: beepsky / tasers are 10 seconds.
		max_seconds_of_stuns_blocked = 45 SECONDS,
		delete_after_passing_max = FALSE,
		recharge_time = 2 MINUTES,
	)
	var/datum/action/cooldown/spell/pointed/projectile/furious_steel/steel_spell = locate() in user.actions
	steel_spell?.cooldown_time /= 2

	var/mob/living/carbon/human/heretic = user
	heretic.physiology.knockdown_mod = 0.75 // Otherwise knockdowns would probably overpower the stun absorption effect.

/datum/heretic_knowledge/ultimate/blade_final/proc/on_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER

	if(target == source)
		return

	// Turns your heretic blades into eswords, pretty much.
	var/bonus_damage = clamp(30 - blade.force, 0, 12)

	target.apply_damage(
		damage = bonus_damage,
		damagetype = BRUTE,
		spread_damage = TRUE,
		wound_bonus = 5,
		sharpness = SHARP_EDGED,
		attack_direction = get_dir(source, target),
	)

	if(target.stat != DEAD)
		// And! Get some free healing for a portion of the bonus damage dealt.
		source.heal_overall_damage(bonus_damage / 2, bonus_damage / 2)
