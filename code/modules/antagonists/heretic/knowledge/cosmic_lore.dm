
/datum/heretic_knowledge_tree_column/main/cosmic
	neighbour_type_left = /datum/heretic_knowledge_tree_column/rust_to_cosmic
	neighbour_type_right = /datum/heretic_knowledge_tree_column/cosmic_to_ash

	route = PATH_COSMIC
	ui_bgr = "node_cosmos"

	start = /datum/heretic_knowledge/limited_amount/starting/base_cosmic
	grasp = /datum/heretic_knowledge/cosmic_grasp
	tier1 = /datum/heretic_knowledge/spell/cosmic_runes
	mark = /datum/heretic_knowledge/mark/cosmic_mark
	ritual_of_knowledge = /datum/heretic_knowledge/knowledge_ritual/cosmic
	unique_ability = /datum/heretic_knowledge/spell/star_touch
	tier2 = /datum/heretic_knowledge/spell/star_blast
	blade = /datum/heretic_knowledge/blade_upgrade/cosmic
	tier3 =	 /datum/heretic_knowledge/spell/cosmic_expansion
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

/datum/heretic_knowledge/cosmic_grasp
	name = "Grasp of Cosmos"
	desc = "Ваша Хватка Мансуса теперь накладывает Метку звезды (космическое кольцо) и создаст космическое поле там, где вы стоите. \
		Люди с Меткой звезды не могут проходить через космические поля."
	gain_text = "Некоторые звезды меркли, другие увеличивались. \
		С новообретенной силой я смог направить силу туманности в себя."
	cost = 1
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "grasp_cosmos"

/datum/heretic_knowledge/cosmic_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/cosmic_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/// Aplies the effect of the mansus grasp when it hits a target.
/datum/heretic_knowledge/cosmic_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	to_chat(target, span_danger("Над вашей головой появилось космическое кольцо!"))
	target.apply_status_effect(/datum/status_effect/star_mark, source)
	new /obj/effect/forcefield/cosmic_field(get_turf(source))

/datum/heretic_knowledge/spell/cosmic_runes
	name = "Cosmic Runes"
	desc = "Дает вам Cosmic Runes, заклинание, которое создает две руны, связанные друг с другом для легкой телепортации. \
		Перемещаться будет только тот, кто активирует руну, а использовать ее может любой человек без Метки звезды. \
		Однако люди с Меткой звезды будут переноситься вместе с тем, кто использует руну."
	gain_text = "Далекие звезды закрались в мои сны, беспричинно ревя и крича. \
		Я заговорил и услышал, как мои же слова отозвались эхом."
	action_to_add = /datum/action/cooldown/spell/cosmic_rune
	cost = 1


/datum/heretic_knowledge/mark/cosmic_mark
	name = "Mark of Cosmos"
	desc = "Ваша Хватка Мансуса теперь накладывает Метку космоса. Метка срабатывает при атаке вашим Космическим клинком. \
		При срабатывании жертва возвращается в то место, где на нее первоначально была нанесена метка, \
		оставляя в прошлом месте космическое поле. \
		Затем они будут парализованы на 2 секунды."
	gain_text = "Теперь Зверь изредка шептал мне, рассказывая лишь немного о своих обстоятельствах. \
		Я могу им помочь, я должен им помочь."
	mark_type = /datum/status_effect/eldritch/cosmic

/datum/heretic_knowledge/knowledge_ritual/cosmic

/datum/heretic_knowledge/spell/star_touch
	name = "Star Touch"
	desc = "Дарует вам Star Touch, заклинание, которое помещает Метку звезды на вашу цель \
		и создает космическое поле у ваших ног и на тайлах рядом с вами. Цели, которые уже имеют Метку звезды \
		будут усыплены на 4 секунды. Когда жертва получает удар, она также создает обжигающий луч. \
		Луч действует в течение минуты, пока луч не будет прегражден или пока не будет найдена новая цель."
	gain_text = "Проснувшись в холодном поту, я почувствовал ладонь на своем скальпе, сигил был выжжен на мне. \
		Теперь мои вены изучали странное фиолетовое сияние: Зверь знает, что я превзойду их ожидания."
	action_to_add = /datum/action/cooldown/spell/touch/star_touch
	cost = 1

/datum/heretic_knowledge/spell/star_blast
	name = "Star Blast"
	desc = "Выпускает снаряд, который движется очень медленно и создает стену космического поля на своем пути на короткое время. \
		Каждый, в кого попадет снаряд, получит урон от ожога, будет сбит с ног и даст людям в радиусе трех тайлов Метку звезды."
	gain_text = "Зверь теперь всегда следовал за мной, и при каждом жертвоприношении в меня вливались слова одобрения."
	action_to_add = /datum/action/cooldown/spell/pointed/projectile/star_blast
	cost = 1

/datum/heretic_knowledge/blade_upgrade/cosmic
	name = "Cosmic Blade"
	desc = "Теперь ваш клинок наносит урон органам людей с помощью космической радиации. \
		Ваши атаки также наносят бонусный урон к двум предыдущим жертвам.\
		Комбо сбрасывается после двух секунд без атаки, \
		или если вы атакуете кого-то уже отмеченного. При комбинировании более четырех атак вы получите \
		космический след и увеличите таймер вашего комбо до 10 секунд."
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

/datum/heretic_knowledge/blade_upgrade/cosmic/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	var/static/list/valid_organ_slots = list(
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_STOMACH,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_BRAIN
	)
	if(source == target || !isliving(target))
		return
	if(combo_timer)
		deltimer(combo_timer)
	combo_timer = addtimer(CALLBACK(src, PROC_REF(reset_combo), source), combo_duration, TIMER_STOPPABLE)
	var/mob/living/second_target_resolved = second_target?.resolve()
	var/mob/living/third_target_resolved = third_target?.resolve()
	var/need_mob_update = FALSE
	need_mob_update += target.adjustFireLoss(5, updating_health = FALSE)
	need_mob_update += target.adjustOrganLoss(pick(valid_organ_slots), 8)
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
		need_mob_update += second_target_resolved.adjustFireLoss(14, updating_health = FALSE)
		need_mob_update += second_target_resolved.adjustOrganLoss(pick(valid_organ_slots), 12)
		if(need_mob_update)
			second_target_resolved.updatehealth()
		if(third_target_resolved)
			new /obj/effect/temp_visual/cosmic_domain(get_turf(third_target_resolved))
			playsound(get_turf(third_target_resolved), 'sound/effects/magic/cosmic_energy.ogg', 50, FALSE)
			need_mob_update = FALSE
			need_mob_update += third_target_resolved.adjustFireLoss(28, updating_health = FALSE)
			need_mob_update += third_target_resolved.adjustOrganLoss(pick(valid_organ_slots), 14)
			if(need_mob_update)
				third_target_resolved.updatehealth()
			if(combo_counter > 3)
				target.apply_status_effect(/datum/status_effect/star_mark, source)
				if(target.mind && target.stat != DEAD)
					increase_combo_duration()
					if(combo_counter == 4)
						source.AddElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)
		third_target = second_target
	second_target = WEAKREF(target)

/// Resets the combo.
/datum/heretic_knowledge/blade_upgrade/cosmic/proc/reset_combo(mob/living/source)
	second_target = null
	third_target = null
	if(combo_counter > 3)
		source.RemoveElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)
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
	desc = "Дарует вам Cosmic Expansion, заклинание, создающее вокруг вас область космических полей размером 3x3. \
		Близлежащие существа также будут отмечены Меткой звезды."
	gain_text = "Теперь земля содрогалась подо мной. Зверь вселился в меня, и его голос был пьянящим."
	action_to_add = /datum/action/cooldown/spell/conjure/cosmic_expansion
	cost = 1

/datum/heretic_knowledge/ultimate/cosmic_final
	name = "Creators's Gift"
	desc = "Ритуал вознесения Пути Космоса. \
		Для завершения ритуала принесите 3 трупа с блуспейс пылью в теле к руне трансмутации. \
		После завершения вы станете обладателем Звездочета. \
		Вы сможете управлять Звездочет с помощью Альт-Клик. \
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

/datum/heretic_knowledge/ultimate/cosmic_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return FALSE

	return sacrifice.has_reagent(/datum/reagent/bluespace)

/datum/heretic_knowledge/ultimate/cosmic_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/mob/living/basic/heretic_summon/star_gazer/star_gazer_mob = new /mob/living/basic/heretic_summon/star_gazer(loc)
	star_gazer_mob.maxHealth = INFINITY
	star_gazer_mob.health = INFINITY
	user.AddComponent(/datum/component/death_linked, star_gazer_mob)
	star_gazer_mob.AddComponent(/datum/component/obeys_commands, star_gazer_commands, radial_menu_offset = list(30,0), radial_menu_lifetime = 15 SECONDS, radial_relative_to_user = TRUE)
	star_gazer_mob.AddComponent(/datum/component/damage_aura, range = 7, burn_damage = 0.5, simple_damage = 0.5, immune_factions = list(FACTION_HERETIC), current_owner = user)
	star_gazer_mob.befriend(user)
	var/datum/action/cooldown/open_mob_commands/commands_action = new /datum/action/cooldown/open_mob_commands()
	commands_action.Grant(user, star_gazer_mob)
	var/datum/action/cooldown/spell/touch/star_touch/star_touch_spell = locate() in user.actions
	if(star_touch_spell)
		star_touch_spell.set_star_gazer(star_gazer_mob)
		star_touch_spell.ascended = TRUE

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/datum/heretic_knowledge/blade_upgrade/cosmic/blade_upgrade = heretic_datum.get_knowledge(/datum/heretic_knowledge/blade_upgrade/cosmic)
	blade_upgrade.combo_duration = 10 SECONDS
	blade_upgrade.combo_duration_amount = 10 SECONDS
	blade_upgrade.max_combo_duration = 30 SECONDS
	blade_upgrade.increase_amount = 2 SECONDS

	var/datum/action/cooldown/spell/conjure/cosmic_expansion/cosmic_expansion_spell = locate() in user.actions
	cosmic_expansion_spell?.ascended = TRUE
