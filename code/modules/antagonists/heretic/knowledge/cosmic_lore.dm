/datum/heretic_knowledge_tree_column/cosmic
	route = PATH_COSMIC
	ui_bgr = "node_cosmos"
	complexity = "Hard"
	complexity_color = COLOR_RED
	icon = list(
		"icon" = 'icons/obj/weapons/khopesh.dmi',
		"state" = "cosmic_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"The Path of Cosmos revolves around area denial, teleporation, and mastery over space.",
		"Pick this path if you enjoy adapting to your environment and thinking outside (or inside) the box.",
	)
	pros = list(
		"Control the movement of foes with cosmic fields",
		"Move in and around space with ease.",
		"Teleport rapidly across the station.",
		"Confound opponents with barriers upon barriers.",
	)
	cons = list(
		"Requires you spread your star mark to affect opponents with your cosmic fields.",
		"Relatively low damage.",
		"Relatively low direct defense, highly reliant on proper use of abilities.",
	)
	tips = list(
		"Your Mansus Grasp will mark your opponent with a star mark, as well as leave a mark that, when detonated, will teleport your opponent back to the place where the mark was applied and briefly paralyze them.",
		"Your cosmic runes can quickly teleport you from two different locations instantly. Beware, however; non-heretics are also able to travel through them. Be creative and have your opponents teleport right into a trap. They come out star marked!",
		"When standing on top of a cosmic rune, you can click on yourself with a empty hand to activate it.",
		"Star marked opponents cannot cross your cosmic fields willingly. But they can be dragged through!",
		"Star Blast is both a jaunt ability as well as a disabling tool. Use it to catch several people in your cosmic fields at once.",
		"Star Touch will prevent your target from teleporting away. Should they fail to break the tether, they will be put to sleep and then teleport to your feet.",
		"It's Always a good idea to leave one cosmic rune near your ritual rune, it will allow you to quickly kidnap your targets to sacrifice them.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_cosmic
	knowledge_tier1 = /datum/heretic_knowledge/spell/cosmic_runes
	guaranteed_side_tier1 = /datum/heretic_knowledge/eldritch_coin
	knowledge_tier2 = /datum/heretic_knowledge/spell/star_blast
	guaranteed_side_tier2 = /datum/heretic_knowledge/spell/space_phase
	robes = /datum/heretic_knowledge/armor/cosmic
	knowledge_tier3 = /datum/heretic_knowledge/spell/star_touch
	guaranteed_side_tier3 = /datum/heretic_knowledge/essence
	blade = /datum/heretic_knowledge/blade_upgrade/cosmic
	knowledge_tier4 = /datum/heretic_knowledge/spell/cosmic_expansion
	ascension = /datum/heretic_knowledge/ultimate/cosmic_final

/datum/heretic_knowledge/limited_amount/starting/base_cosmic
	name = "Eternal Gate"
	desc = "Открывает перед вами Путь космоса. \
		озволяет трансмутировать лист плазмы и нож в Космический клинок. \
		Одновременно можно иметь только два."
	gain_text = "Туманность появилась в небе, ее пламенное рождение озарило меня. Это было начало великой трансценденции"
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/cosmic)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "cosmic_blade"
	mark_type = /datum/status_effect/eldritch/cosmic
	eldritch_passive = /datum/status_effect/heretic_passive/cosmic

/// Aplies the effect of the mansus grasp when it hits a target.
/datum/heretic_knowledge/limited_amount/starting/base_cosmic/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	to_chat(target, span_danger("Над вашей головой появилось космическое кольцо!"))
	target.apply_status_effect(/datum/status_effect/star_mark, source)
	create_cosmic_field(get_turf(source), source)

/datum/heretic_knowledge/spell/cosmic_runes
	name = "Cosmic Runes"
	desc = "Дает вам Cosmic Runes, заклинание, которое создает две руны, связанные друг с другом для легкой телепортации. \
		Перемещаться будет только тот, кто активирует руну, а использовать ее может любой человек без Метки звезды. \
		Однако люди с Меткой звезды будут переноситься вместе с тем, кто использует руну."
	gain_text = "Далекие звезды закрались в мои сны, беспричинно ревя и крича. \
		Я заговорил и услышал, как мои же слова отозвались эхом."
	action_to_add = /datum/action/cooldown/spell/cosmic_rune
	cost = 2
	drafting_tier = 5

/datum/heretic_knowledge/spell/star_blast
	name = "Star Blast"
	desc = "Fires a projectile that moves very slowly, raising a short-lived wall of cosmic fields where it goes. \
		Anyone hit by the projectile will receive burn damage, a knockdown, and give people in a three tile range a star mark."
	gain_text = "The Beast was behind me now at all times, with each sacrifice words of affirmation coursed through me."
	action_to_add = /datum/action/cooldown/spell/pointed/projectile/star_blast
	cost = 2

/datum/heretic_knowledge/armor/cosmic

	desc = "Allows you to transmute a table (or a suit), a mask and a sheet of plasma to create a Starwoven Cloak, grants protection from the hazards of space while granting to the user the ability to levitate at will. \
			Acts as a focus while hooded."
	gain_text = "Like radiant cords, the stars shone in union across the silken shape of a billowing cloak, that at once does and does not drape my shoulders. \
				The eyes of the Beast rested upon me, and through me."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/cosmic)
	research_tree_icon_state = "cosmic_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)

/datum/heretic_knowledge/spell/star_touch
	name = "Star Touch"
	desc = "Дарует вам Star Touch, заклинание, которое помещает Метку звезды на вашу цель \
		и создает космическое поле у ваших ног и на тайлах рядом с вами. Цели, которые уже имеют Метку звезды \
		будут усыплены на 4 секунды. Когда жертва получает удар, она также создает обжигающий луч. \
		Луч действует в течение минуты, пока луч не будет прегражден или пока не будет найдена новая цель."
	gain_text = "Проснувшись в холодном поту, я почувствовал ладонь на своем скальпе, сигил был выжжен на мне. \
		Теперь мои вены изучали странное фиолетовое сияние: Зверь знает, что я превзойду их ожидания."
	action_to_add = /datum/action/cooldown/spell/touch/star_touch
	cost = 2

/datum/heretic_knowledge/blade_upgrade/cosmic
	name = "Cosmic Blade"
	desc = "Теперь ваш клинок наносит Метку звезды своим жертвам, и позволяет атаковать язычников с Меткой на расстоянии. \
		Ваши атаки также наносят бонусный урон к двум предыдущим жертвам.\
		Комбо сбрасывается после двух секунд без атаки, или если вы атакуете кого-то уже отмеченного. \
		При комбинировании трёх атак вы получите космический след и увеличите таймер вашего комбо до 10 секунд."
	gain_text = "Когда Зверь взял мои клинки в свою руку, я упал на колени и почувствовал острую боль \
		Клинки теперь сверкали раздробленной силой. Я упал на землю и зарыдал у ног Зверя."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_cosmos"
	/// Storage for the second target.
	var/datum/weakref/second_target
	/// Storage for the third target.
	var/datum/weakref/third_target
	/// When this timer completes we reset our combo.
	var/combo_timer
	/// The active duration of the combo.
	var/combo_duration = 3 SECONDS
	/// The duration of a combo when it starts.
	var/combo_duration_amount = 3 SECONDS
	/// The maximum duration of the combo.
	var/max_combo_duration = 10 SECONDS
	/// The amount the combo duration increases.
	var/increase_amount = 0.5 SECONDS
	/// The hits we have on a mob with a mind.
	var/combo_counter = 0
	/// How much further we can hit people, modified by ascension
	var/max_attack_range = 2

/datum/heretic_knowledge/blade_upgrade/cosmic/on_ranged_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	. = ..()
	if(!isliving(target) || get_dist(source, target) > max_attack_range || !target.has_status_effect(/datum/status_effect/star_mark))
		return
	source.changeNext_move(blade.attack_speed)
	return blade.attack(target, source)

/datum/heretic_knowledge/blade_upgrade/cosmic/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return
	target.apply_status_effect(/datum/status_effect/star_mark, source)
	if(combo_timer)
		deltimer(combo_timer)
	combo_timer = addtimer(CALLBACK(src, PROC_REF(reset_combo), source), combo_duration, TIMER_STOPPABLE)
	var/mob/living/second_target_resolved = second_target?.resolve()
	var/mob/living/third_target_resolved = third_target?.resolve()
	var/need_mob_update = FALSE
	need_mob_update += target.adjust_fire_loss(5, updating_health = FALSE)
	if(need_mob_update)
		target.updatehealth()
	if(target == second_target_resolved || target == third_target_resolved)
		reset_combo(source)
		return
	if(target.mind && target.stat != DEAD)
		combo_counter += 1
	if(second_target_resolved)
		new /obj/effect/temp_visual/cosmic_explosion(get_turf(second_target_resolved))
		playsound(get_turf(second_target_resolved), 'sound/effects/magic/cosmic_energy.ogg', 25, FALSE)
		need_mob_update = FALSE
		need_mob_update += second_target_resolved.adjust_fire_loss(14, updating_health = FALSE)
		if(need_mob_update)
			second_target_resolved.updatehealth()
		if(third_target_resolved)
			new /obj/effect/temp_visual/cosmic_domain(get_turf(third_target_resolved))
			playsound(get_turf(third_target_resolved), 'sound/effects/magic/cosmic_energy.ogg', 50, FALSE)
			need_mob_update = FALSE
			need_mob_update += third_target_resolved.adjust_fire_loss(28, updating_health = FALSE)
			if(need_mob_update)
				third_target_resolved.updatehealth()
			if(combo_counter == 3)
				if(target.mind && target.stat != DEAD)
					increase_combo_duration()
					source.AddElement(cosmic_trail_based_on_passive(source), /obj/effect/forcefield/cosmic_field/fast)
		third_target = second_target
	second_target = WEAKREF(target)

/// Resets the combo.
/datum/heretic_knowledge/blade_upgrade/cosmic/proc/reset_combo(mob/living/source)
	second_target = null
	third_target = null
	source.RemoveElement(cosmic_trail_based_on_passive(source), /obj/effect/forcefield/cosmic_field/fast)
	combo_duration = combo_duration_amount
	combo_counter = 0
	new /obj/effect/temp_visual/cosmic_cloud(get_turf(source))
	if(combo_timer)
		deltimer(combo_timer)

/// Increases the combo duration.
/datum/heretic_knowledge/blade_upgrade/cosmic/proc/increase_combo_duration()
	if(combo_duration < max_combo_duration)
		combo_duration += increase_amount

/datum/heretic_knowledge/spell/cosmic_expansion
	name = "Cosmic Expansion"
	desc = "Дарует вам Cosmic Expansion, заклинание, создающее вокруг вас область космических полей размером 5x5. \
		Близлежащие существа также будут отмечены Меткой звезды."
	gain_text = "Теперь земля содрогалась подо мной. Зверь вселился в меня, и его голос был пьянящим."
	action_to_add = /datum/action/cooldown/spell/conjure/cosmic_expansion
	cost = 2
	is_final_knowledge = TRUE

/datum/heretic_knowledge/ultimate/cosmic_final
	name = "Creators's Gift"
	desc = "Ритуал вознесения Пути Космоса. \
		Для завершения ритуала принесите 3 трупа с Меткой звезды к руне трансмутации. \
		После завершения вы станете обладателем Звездочета. \
		Вы сможете управлять Звездочетом с помощью Альт-Клик. \
		Вы также можете отдавать ему команды с помощью речи. \
		Звездочет - сильный союзник, который может даже разрушить укрепленные стены. \
		Звездочет обладает аурой, которая исцеляет вас и наносит урон противникам. \
		Star Touch теперь может телепортировать вас к Звездочету, когда активируется в вашей руке. \
		Заклинание Cosmic Expansion и ваши клинки также значительно усилены."
	gain_text = "Зверь протянул руку, я ухватился за нее, и он притянул меня к себе. Их тело возвышалось надо моим, но также казалось настолько крохотными и слабым после всех их историй в моей голове. \
		Я прижался к ним, они защитят меня, и я защищаю их. \
		Я закрыл глаза, прижавшись головой к их телу. Я был в безопасности. \
		УЗРИТЕ МОЕ ВОЗНЕСЕНИЕ!"

	ascension_achievement = /datum/award/achievement/misc/cosmic_ascension
	announcement_text = "%SPOOKY% Звездочет прибыл на станцию, %NAME% вознесся! Эта станция - владения Космоса! %SPOOKY%"
	announcement_sound = 'sound/music/antag/heretic/ascend_cosmic.ogg'
	/// A static list of command we can use with our mob.
	var/static/list/star_gazer_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/attack/star_gazer
	)
	/// List of traits given once ascended
	var/static/list/ascended_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTCOLD, TRAIT_RESISTHEAT, TRAIT_XRAY_VISION)
	/// List of traits given to our cute lil guy
	var/static/list/stargazer_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTCOLD, TRAIT_RESISTHEAT, TRAIT_BOMBIMMUNE, TRAIT_XRAY_VISION)

/datum/heretic_knowledge/ultimate/cosmic_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE

	return sacrifice.has_status_effect(/datum/status_effect/star_mark)

/datum/heretic_knowledge/ultimate/cosmic_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	user.add_traits(ascended_traits, type)
	if(ishuman(user))
		var/mob/living/carbon/human/ascended_human = user
		var/obj/item/organ/eyes/heretic_eyes = ascended_human.get_organ_slot(ORGAN_SLOT_EYES)
		ascended_human.update_sight()
		heretic_eyes?.color_cutoffs = list(30, 30, 30)
		ascended_human.update_sight()

	var/mob/living/basic/heretic_summon/star_gazer/star_gazer_mob = new /mob/living/basic/heretic_summon/star_gazer(loc, user)
	star_gazer_mob.maxHealth = INFINITY
	star_gazer_mob.health = INFINITY
	user.AddComponent(/datum/component/death_linked, star_gazer_mob)
	star_gazer_mob.AddComponent(/datum/component/obeys_commands, star_gazer_commands, radial_menu_offset = list(30,0), radial_menu_lifetime = 15 SECONDS, radial_relative_to_user = TRUE)
	star_gazer_mob.befriend(user)
	var/datum/action/cooldown/open_mob_commands/commands_action = new /datum/action/cooldown/open_mob_commands()
	commands_action.Grant(user, star_gazer_mob)
	var/datum/action/cooldown/spell/touch/star_touch/star_touch_spell = locate() in user.actions
	if(star_touch_spell)
		star_touch_spell.set_star_gazer(star_gazer_mob)
		star_touch_spell.ascended = TRUE
	star_gazer_mob.add_traits(stargazer_traits, type)
	star_gazer_mob.leash_to(star_gazer_mob, user)

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/heretic_knowledge/blade_upgrade/cosmic/blade_upgrade = heretic_datum.get_knowledge(/datum/heretic_knowledge/blade_upgrade/cosmic)
	blade_upgrade.combo_duration = 10 SECONDS
	blade_upgrade.combo_duration_amount = 10 SECONDS
	blade_upgrade.max_combo_duration = 30 SECONDS
	blade_upgrade.increase_amount = 2 SECONDS
	blade_upgrade.max_attack_range = 3

	var/datum/action/cooldown/spell/conjure/cosmic_expansion/cosmic_expansion_spell = locate() in user.actions
	cosmic_expansion_spell?.ascended = TRUE

	var/datum/action/cooldown/mob_cooldown/replace_star_gazer/replace_gazer = new(src)
	replace_gazer.Grant(user)
	replace_gazer.bad_dog = WEAKREF(star_gazer_mob)

/// Replace an annoying griefer you were paired up to with a different but probably no less annoying player.
/datum/action/cooldown/mob_cooldown/replace_star_gazer
	name = "Reset Star Gazer Consciousness"
	desc = "Replaces the mind of your summon with that of a different ghost."
	button_icon = 'icons/mob/simple/mob.dmi'
	button_icon_state = "ghost"
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	check_flags = NONE
	click_to_activate = FALSE
	cooldown_time = 5 SECONDS
	melee_cooldown_time = 0
	shared_cooldown = NONE
	/// Weakref to the stargazer we care about
	var/datum/weakref/bad_dog

/datum/action/cooldown/mob_cooldown/replace_star_gazer/Activate(atom/target)
	StartCooldown(5 MINUTES)

	var/mob/living/to_reset = bad_dog.resolve()

	to_chat(owner, span_hierophant("You prompt [to_reset] to shift it\'s personality..."))
	var/mob/chosen_one = SSpolling.poll_ghost_candidates("Do you want to play as [span_danger("[owner.real_name]'s")] [span_notice(to_reset.name)]?", check_jobban = ROLE_PAI, poll_time = 10 SECONDS, alert_pic = to_reset, jump_target = owner, role_name_text = to_reset.name, amount_to_pick = 1)
	if(isnull(chosen_one))
		to_chat(owner, span_hierophant("Your request to shift [to_reset]'\s personality appears to have been denied... Looks like you're stuck with it for now."))
		StartCooldown()
		return FALSE
	to_chat(to_reset, span_hierophant("Your summoner reset you, and your body was taken over by a ghost. Looks like they weren't happy with your performance."))
	to_chat(owner, span_hierophant("The mind of [to_reset] has twisted itself to suit you better."))
	message_admins("[key_name_admin(chosen_one)] has taken control of ([ADMIN_LOOKUPFLW(to_reset)])")
	to_reset.ghostize(FALSE)
	to_reset.PossessByPlayer(chosen_one.key)
	StartCooldown()
	return TRUE
