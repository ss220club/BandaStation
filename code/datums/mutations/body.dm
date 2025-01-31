//These mutations change your overall "form" somehow, like size

//Epilepsy gives a very small chance to have a seizure every life tick, knocking you unconscious.
/datum/mutation/human/epilepsy
	name = "Epilepsy"
	desc = "Генетический дефект, из-за которого случаются приступы эпилепсии."
	instability = NEGATIVE_STABILITY_MODERATE
	quality = NEGATIVE
	text_gain_indication = span_danger("Ты ощущаешь головную боль.")
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/epilepsy/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(0.5 * GET_MUTATION_SYNCHRONIZER(src), seconds_per_tick))
		trigger_seizure()

/datum/mutation/human/epilepsy/proc/trigger_seizure()
	if(owner.stat != CONSCIOUS)
		return
	owner.visible_message(span_danger("[owner] starts having a seizure!"), span_userdanger("You have a seizure!"))
	owner.Unconscious(200 * GET_MUTATION_POWER(src))
	owner.set_jitter(2000 SECONDS * GET_MUTATION_POWER(src)) //yes this number looks crazy but the jitter animations are amplified based on the duration.
	owner.add_mood_event("epilepsy", /datum/mood_event/epilepsy)
	addtimer(CALLBACK(src, PROC_REF(jitter_less)), 9 SECONDS)

/datum/mutation/human/epilepsy/proc/jitter_less()
	if(QDELETED(owner))
		return

	owner.set_jitter(20 SECONDS)

/datum/mutation/human/epilepsy/on_acquiring(mob/living/carbon/human/acquirer)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_FLASHED, PROC_REF(get_flashed_nerd))

/datum/mutation/human/epilepsy/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_FLASHED)

/datum/mutation/human/epilepsy/proc/get_flashed_nerd()
	SIGNAL_HANDLER

	if(!prob(30))
		return
	trigger_seizure()


//Unstable DNA induces random mutations!
/datum/mutation/human/bad_dna
	name = "Unstable DNA"
	desc = "Странная мутация, которая приводит к случайным мутациям у её обладателя."
	instability = NEGATIVE_STABILITY_MAJOR
	quality = NEGATIVE
	text_gain_indication = span_danger("Ты чувствуешь себя как-то старнно.")
	locked = TRUE

/datum/mutation/human/bad_dna/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	to_chat(owner, text_gain_indication)
	var/mob/new_mob
	if(prob(95))
		switch(rand(1,3))
			if(1)
				new_mob = owner.easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)
			if(2)
				new_mob = owner.random_mutate_unique_identity()
			if(3)
				new_mob = owner.random_mutate_unique_features()
	else
		new_mob = owner.easy_random_mutate(POSITIVE)
	if(new_mob && ismob(new_mob))
		owner = new_mob
	. = owner
	on_losing(owner)


//Cough gives you a chronic cough that causes you to drop items.
/datum/mutation/human/cough
	name = "Cough"
	desc = "Хронический кашель."
	instability = NEGATIVE_STABILITY_MODERATE
	quality = MINOR_NEGATIVE
	text_gain_indication = span_danger("Ты начинаешь кашлять.")
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/cough/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(2.5 * GET_MUTATION_SYNCHRONIZER(src), seconds_per_tick) && owner.stat == CONSCIOUS)
		owner.drop_all_held_items()
		owner.emote("cough")
		if(GET_MUTATION_POWER(src) > 1)
			var/cough_range = GET_MUTATION_POWER(src) * 4
			var/turf/target = get_ranged_target_turf(owner, REVERSE_DIR(owner.dir), cough_range)
			owner.throw_at(target, cough_range, GET_MUTATION_POWER(src))

/datum/mutation/human/paranoia
	name = "Paranoia"
	desc = "Субъект, обладающий данной мутацией, слегка напуган и может испытывать галлюцинации."
	instability = NEGATIVE_STABILITY_MODERATE
	quality = NEGATIVE
	text_gain_indication = span_danger("Ты слышишь эхо криков в закромах своего разума ..")
	text_lose_indication = span_notice("Крики в твоей голове затихают.")

/datum/mutation/human/paranoia/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(2.5, seconds_per_tick) && owner.stat == CONSCIOUS)
		owner.emote("scream")
		if(prob(25))
			owner.adjust_hallucinations(40 SECONDS)

//Dwarfism shrinks your body and lets you pass tables.
/datum/mutation/human/dwarfism
	name = "Dwarfism"
	desc = "Считается, что данная мутация является причиной карликовости."
	quality = POSITIVE
	difficulty = 16
	instability = POSITIVE_INSTABILITY_MINOR
	conflicts = list(/datum/mutation/human/gigantism, /datum/mutation/human/acromegaly)
	locked = TRUE // Default intert species for now, so locked from regular pool.

/datum/mutation/human/dwarfism/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_DWARF, GENETIC_MUTATION)
	owner.visible_message(span_danger("[capitalize(owner.declent_ru(NOMINATIVE))] неожиданно уменьшается!"), span_notice("Всё вокруг тебя увеличивается.."))

/datum/mutation/human/dwarfism/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_DWARF, GENETIC_MUTATION)
	owner.visible_message(span_danger("[capitalize(owner.declent_ru(NOMINATIVE))] неожиданно увеличивается!"), span_notice("Всё вокруг тебя уменьшается.."))

/datum/mutation/human/acromegaly
	name = "Acromegaly"
	desc = "Считается, что данная мутация вызвана акромегалией или 'необычно высоким ростом'."
	quality = MINOR_NEGATIVE
	difficulty = 16
	instability = NEGATIVE_STABILITY_MODERATE
	synchronizer_coeff = 1
	conflicts = list(/datum/mutation/human/dwarfism)

/datum/mutation/human/acromegaly/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_TOO_TALL, GENETIC_MUTATION)
	owner.visible_message(span_danger("[capitalize(owner.declent_ru(NOMINATIVE))] неожиданно становится выше!"), span_notice("У тебя появляется странное желание бороться с маленькими людьми с рогатками. Или стоит сыграть в баскетбол?"))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(head_bonk))
	owner.regenerate_icons()

/datum/mutation/human/acromegaly/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_TOO_TALL, GENETIC_MUTATION)
	owner.visible_message(span_danger("[capitalize(owner.declent_ru(NOMINATIVE))] неожиданно уменьшается!"), span_notice("Ты возвращаешься к своему обычному росту."))
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(head_bonk))
	owner.regenerate_icons()

// This is specifically happening because they're not used to their new height and are stumbling around into machinery made for normal humans
/datum/mutation/human/acromegaly/proc/head_bonk(mob/living/parent)
	SIGNAL_HANDLER
	var/atom/movable/whacked_by = (locate(/obj/machinery/door/airlock) in parent.loc) || (locate(/obj/machinery/door/firedoor) in parent.loc) || (locate(/obj/structure/mineral_door) in parent.loc)
	if(!whacked_by || prob(100 - (8 *  GET_MUTATION_SYNCHRONIZER(src))))
		return
	to_chat(parent, span_danger("You hit your head on \the [whacked_by]'s header!"))
	var/dmg = HAS_TRAIT(parent, TRAIT_HEAD_INJURY_BLOCKED) ? rand(1,4) : rand(2,9)
	parent.apply_damage(dmg, BRUTE, BODY_ZONE_HEAD)
	parent.do_attack_animation(whacked_by, ATTACK_EFFECT_PUNCH)
	playsound(whacked_by, 'sound/effects/bang.ogg', 10, TRUE)
	parent.adjust_staggered_up_to(STAGGERED_SLOWDOWN_LENGTH, 10 SECONDS)

/datum/mutation/human/gigantism
	name = "Gigantism" //negative version of dwarfism
	desc = "Клетки субъекта распространяются для охвата большей площади, визуально увеличивая носителя."
	quality = MINOR_NEGATIVE
	difficulty = 12
	conflicts = list(/datum/mutation/human/dwarfism)

/datum/mutation/human/gigantism/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_GIANT, GENETIC_MUTATION)
	owner.update_transform(1.25)
	owner.visible_message(span_danger("[capitalize(owner.declent_ru(NOMINATIVE))] неожиданно увеличивается!"), span_notice("Всё вокруг тебя уменьшается.."))

/datum/mutation/human/gigantism/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_GIANT, GENETIC_MUTATION)
	owner.update_transform(0.8)
	owner.visible_message(span_danger("[capitalize(owner.declent_ru(NOMINATIVE))] неожиданно уменьшается!"), span_notice("Всё вокруг тебя увеличивается..."))
//Clumsiness has a very large amount of small drawbacks depending on item.
/datum/mutation/human/clumsy
	name = "Clumsiness"
	desc = "Данный геном подавляет определённые функции мозга, из-за чего его обладатель выглядит неуклюжим."
	instability = NEGATIVE_STABILITY_MAJOR
	quality = MINOR_NEGATIVE
	text_gain_indication = span_danger("Тебя охватывает легкомыслие")

/datum/mutation/human/clumsy/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_CLUMSY, GENETIC_MUTATION)

/datum/mutation/human/clumsy/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_CLUMSY, GENETIC_MUTATION)


//Tourettes causes you to randomly stand in place and shout.
/datum/mutation/human/tourettes
	name = "Tourette's Syndrome"
	desc = "Хроническое расстройство, которое вызывает непроизвольные сокращения мышц носителя, заставляя его выкрикивать нецензурные слова." //definitely needs rewriting
	quality = NEGATIVE
	instability = 0
	text_gain_indication = span_danger("Ты немного дергаешься.")
	synchronizer_coeff = 1

/datum/mutation/human/tourettes/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(5 * GET_MUTATION_SYNCHRONIZER(src), seconds_per_tick) && owner.stat == CONSCIOUS && !owner.IsStun())
		switch(rand(1, 3))
			if(1)
				owner.emote("twitch")
			if(2 to 3)
				owner.say("[prob(50) ? ";" : ""][pick("ДЕРЬМО", "МОЧА", "БЛЯТЬ", "ПИЗДА", "ХУЕСОС", "УБЛЮДОК", "СИСЬКИ", "ХУЙ", "ЖОПА", "КОКПИТАН", "ХОС ХУЕСОС", "РД УЕБОК", "ПОШЕЛ НАХУЙ", "ВЫБЛЯДОК", "ОТСОСИ", "ДОЛБОЕБ", "КУКУРУЗА", "УБЛЮДОК", "МАТЬ ТВОЮ", "ГОВНО СОБАЧЬЕ", "ЕБАТЬ ТЕБЯ", "ОНАНИСТ ЧЕРТОВ", "ЕБАТЬ", "МРАЗЬ", "ХУЙНЯ", "КУДЛАТАЯ ХУЙНЯ", "ШЛЮХА", "ПРОФУРСЕТКА", "ШАЛАВА", "ПОХУЙ", "ИДИ НА ХУЙ", "ПАСКУДА", "СВОЛОЧЬ", "МУДАК", "ПОТАСКУХА", "УЕБАН", "МАНДАВОШКА", "БЛЭТ", "ПРИДУРОК", "ДУРАК", "ИДИОТ", "ОХУЕТЬ", "ХУЕТА", "ХУЕВО", "ЕБ ТВОЮ МАТЬ", "ГОВНЮК", "НАЕБЩИК")]", forced=name)
		var/x_offset_old = owner.pixel_x
		var/y_offset_old = owner.pixel_y
		var/x_offset = owner.pixel_x + rand(-2,2)
		var/y_offset = owner.pixel_y + rand(-1,1)
		animate(owner, pixel_x = x_offset, pixel_y = y_offset, time = 1)
		animate(owner, pixel_x = x_offset_old, pixel_y = y_offset_old, time = 1)


//Deafness makes you deaf.
/datum/mutation/human/deaf
	name = "Deafness"
	desc = "Обладатель данного генома полностью глухой."
	instability = NEGATIVE_STABILITY_MAJOR
	quality = NEGATIVE
	text_gain_indication = span_danger("Ты ничего не слышишь.")

/datum/mutation/human/deaf/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_DEAF, GENETIC_MUTATION)

/datum/mutation/human/deaf/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_DEAF, GENETIC_MUTATION)


//Monified turns you into a monkey.
/datum/mutation/human/race
	name = "Monkified"
	desc = "Странный геном который, по мнению общества, отличает обезьяну от человека."
	text_gain_indication = span_green("Ты чувствуешь необычно по-обезьяни.")
	text_lose_indication = span_notice("Ты чувствуешь себя как раньше.")
	quality = NEGATIVE
	instability = NEGATIVE_STABILITY_MAJOR // mmmonky
	remove_on_aheal = FALSE
	locked = TRUE //Species specific, keep out of actual gene pool
	mutadone_proof = TRUE
	var/datum/species/original_species = /datum/species/human
	var/original_name

/datum/mutation/human/race/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	if(ismonkey(owner))
		return
	original_species = owner.dna.species.type
	original_name = owner.real_name
	owner.monkeyize()

/datum/mutation/human/race/on_losing(mob/living/carbon/human/owner)
	if(owner.stat == DEAD)
		return
	. = ..()
	if(.)
		return
	if(QDELETED(owner))
		return

	owner.fully_replace_character_name(null, original_name)
	owner.humanize(original_species)

/datum/mutation/human/glow
	name = "Glowy"
	desc = "Вы будете излучать свет случайного цвета и интенсивности."
	quality = POSITIVE
	text_gain_indication = span_notice("Твоя кожа начинает немного светиться.")
	instability = POSITIVE_INSTABILITY_MINI
	power_coeff = 1
	conflicts = list(/datum/mutation/human/glow/anti)
	var/glow_power = 2
	var/glow_range = 2.5
	var/glow_color
	var/obj/effect/dummy/lighting_obj/moblight/glow

/datum/mutation/human/glow/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	glow_color = get_glow_color()
	glow = owner.mob_light()
	modify()

// Override modify here without a parent call, because we don't actually give an action.
/datum/mutation/human/glow/modify()
	if(!glow)
		return

	glow.set_light_range_power_color(glow_range * GET_MUTATION_POWER(src), glow_power, glow_color)

/datum/mutation/human/glow/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	QDEL_NULL(glow)

/// Returns a color for the glow effect
/datum/mutation/human/glow/proc/get_glow_color()
	return pick(COLOR_RED, COLOR_BLUE, COLOR_YELLOW, COLOR_GREEN, COLOR_PURPLE, COLOR_ORANGE)

/datum/mutation/human/glow/anti
	name = "Anti-Glow"
	desc = "Ваша кожа начинает притягивать и поглащать окружающий вас свет, создавая темноту вокруг вас."
	text_gain_indication = span_notice("Свет вокруг тебя понемногу пропадает.")
	conflicts = list(/datum/mutation/human/glow)
	instability = POSITIVE_INSTABILITY_MINOR
	locked = TRUE
	glow_power = -1.5

/datum/mutation/human/glow/anti/get_glow_color()
	return COLOR_BLACK

/datum/mutation/human/strong
	name = "Strength"
	desc = "У обладателя данного гена мышцы слегка увеличиваются. Commonly seen in top-ranking boxers."
	quality = POSITIVE
	text_gain_indication = span_notice("Ты чувствуешь себя сильнее.")
	instability = POSITIVE_INSTABILITY_MINI
	difficulty = 16

/datum/mutation/human/strong/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	ADD_TRAIT(owner, TRAIT_STRENGTH, GENETIC_MUTATION)

/datum/mutation/human/strong/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	REMOVE_TRAIT(owner, TRAIT_STRENGTH, GENETIC_MUTATION)


/datum/mutation/human/stimmed
	name = "Stimmed"
	desc = "Химический баланс обладателя данного генома становится более надёжным."
	quality = POSITIVE
	instability = POSITIVE_INSTABILITY_MINI
	text_gain_indication = span_notice("Ты ощущаешь странное чувство... Это баланс?")
	difficulty = 16

/datum/mutation/human/stimmed/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	ADD_TRAIT(owner, TRAIT_STIMMED, GENETIC_MUTATION)

/datum/mutation/human/stimmed/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	REMOVE_TRAIT(owner, TRAIT_STIMMED, GENETIC_MUTATION)

/datum/mutation/human/insulated
	name = "Insulated"
	desc = "Субъект, подверженный данной мутации, не позволяет провести электрический ток через себя."
	quality = POSITIVE
	text_gain_indication = span_notice("Кончики твоих пальцев немеют.")
	text_lose_indication = span_notice("Ты снова чувствуешь кончики своих пальцев.")
	difficulty = 16
	instability = POSITIVE_INSTABILITY_MODERATE

/datum/mutation/human/insulated/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, GENETIC_MUTATION)

/datum/mutation/human/insulated/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, GENETIC_MUTATION)

/datum/mutation/human/fire
	name = "Fiery Sweat"
	desc = "Кожный покров субъекта будет случайно воспламеняться, но он становится более устойчивым к огню."
	quality = NEGATIVE
	text_gain_indication = span_warning("Твое тело окутывает жар.")
	text_lose_indication = span_notice("Ты чувствуешь, что жар проходит и становится намного прохладнее.")
	conflicts = list(/datum/mutation/human/adaptation/heat)
	difficulty = 14
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/fire/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB((0.05+(100-dna.stability)/19.5) * GET_MUTATION_SYNCHRONIZER(src), seconds_per_tick))
		owner.adjust_fire_stacks(2 * GET_MUTATION_POWER(src))
		owner.ignite_mob()

/datum/mutation/human/fire/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.burn_mod *= 0.5

/datum/mutation/human/fire/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.burn_mod *= 2

/datum/mutation/human/badblink
	name = "Spatial Instability"
	desc = "Жертва данной мутации имеет очень слабую связь с пространственной реальностью и может быть перемещена. Часто является причиной тошноты."
	quality = NEGATIVE
	text_gain_indication = span_warning("Пространство вокруг тебя тошнотворно искажается.")
	text_lose_indication = span_notice("Пространство вокруг тебя возвращается в норму.")
	difficulty = 18//high so it's hard to unlock and abuse
	instability = NEGATIVE_STABILITY_MODERATE
	synchronizer_coeff = 1
	energy_coeff = 1
	power_coeff = 1
	var/warpchance = 0

/datum/mutation/human/badblink/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(warpchance, seconds_per_tick))
		var/warpmessage = pick(
		span_warning("With a sickening 720-degree twist of [owner.p_their()] back, [owner] vanishes into thin air."),
		span_warning("[owner] does some sort of strange backflip into another dimension. It looks pretty painful."),
		span_warning("[owner] does a jump to the left, a step to the right, and warps out of reality."),
		span_warning("[owner]'s torso starts folding inside out until it vanishes from reality, taking [owner] with it."),
		span_warning("One moment, you see [owner]. The next, [owner] is gone."))
		owner.visible_message(warpmessage, span_userdanger("You feel a wave of nausea as you fall through reality!"))
		var/warpdistance = rand(10, 15) * GET_MUTATION_POWER(src)
		do_teleport(owner, get_turf(owner), warpdistance, channel = TELEPORT_CHANNEL_FREE)
		owner.adjust_disgust(GET_MUTATION_SYNCHRONIZER(src) * (warpchance * warpdistance))
		warpchance = 0
		owner.visible_message(span_danger("[owner] appears out of nowhere!"))
	else
		warpchance += 0.0625 * seconds_per_tick / GET_MUTATION_ENERGY(src)

/datum/mutation/human/acidflesh
	name = "Acidic Flesh"
	desc = "Под кожными покровами субъекта накапливаются кислотные реагенты. Зачастую это смертельно."
	instability = NEGATIVE_STABILITY_MAJOR
	quality = NEGATIVE
	text_gain_indication = span_userdanger("Ужасное ощущение жжения охватывает тебя, когда твоя плоть превращается в кислоту!")
	text_lose_indication = span_notice("Тебя окутывает чувство облегчения, когда плоть возвращается в нормальное состояние.")
	difficulty = 18//high so it's hard to unlock and use on others
	/// The cooldown for the warning message
	COOLDOWN_DECLARE(msgcooldown)

/datum/mutation/human/acidflesh/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(13, seconds_per_tick))
		if(COOLDOWN_FINISHED(src, msgcooldown))
			to_chat(owner, span_danger("Твоя кислотная плоть пузырится..."))
			COOLDOWN_START(src, msgcooldown, 20 SECONDS)
		if(prob(15))
			owner.acid_act(rand(30, 50), 10)
			owner.visible_message(span_warning("[owner]'s skin bubbles and pops."), span_userdanger("Your bubbling flesh pops! It burns!"))
			playsound(owner,'sound/items/weapons/sear.ogg', 50, TRUE)

/datum/mutation/human/spastic
	name = "Spastic"
	desc = "Субъект страдает от спазма в мышцах."
	instability = NEGATIVE_STABILITY_MODERATE
	quality = NEGATIVE
	text_gain_indication = span_warning("Ты начинаешь дрожать.")
	text_lose_indication = span_notice("Твое дрожание проходит.")
	difficulty = 16

/datum/mutation/human/spastic/on_acquiring()
	if(..())
		return
	owner.apply_status_effect(/datum/status_effect/spasms)

/datum/mutation/human/spastic/on_losing()
	if(..())
		return
	owner.remove_status_effect(/datum/status_effect/spasms)

/datum/mutation/human/extrastun
	name = "Two Left Feet"
	desc = "Мутация заменяет правую ногу еще одной левой ногой. Симптомы включают в себя поцелуй пола при каждом шаге."
	instability = NEGATIVE_STABILITY_MODERATE
	quality = NEGATIVE
	text_gain_indication = span_warning("Твоя правая нога, кажется, стала леветь.")
	text_lose_indication = span_notice("Твоя правая нога, кажется, снова права.")
	difficulty = 16

/datum/mutation/human/extrastun/on_acquiring()
	. = ..()
	if(.)
		return
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/mutation/human/extrastun/on_losing()
	. = ..()
	if(.)
		return
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

///Triggers on moved(). Randomly makes the owner trip
/datum/mutation/human/extrastun/proc/on_move()
	SIGNAL_HANDLER

	if(prob(99.5)) //The brawl mutation
		return
	if(owner.buckled || owner.body_position == LYING_DOWN || HAS_TRAIT(owner, TRAIT_IMMOBILIZED) || owner.throwing || owner.movement_type & (VENTCRAWLING | FLYING | FLOATING))
		return //remove the 'edge' cases
	to_chat(owner, span_danger("Ты спотыкаешься об свои же ноги."))
	owner.Knockdown(30)

/datum/mutation/human/martyrdom
	name = "Internal Martyrdom"
	desc = "Мутация разрушающая тело вблизи смерти. Не причиняет вреда, но ОЧЕНЬ дезориентирует."
	instability = NEGATIVE_STABILITY_MAJOR // free stability >:)
	locked = TRUE
	quality = POSITIVE //not that cloning will be an option a lot but generally lets keep this around i guess?
	text_gain_indication = span_warning("Ты ощущаешь невыносимую изжогу.")
	text_lose_indication = span_notice("Ты ощущаешь облегчение внутренних органов.")

/datum/mutation/human/martyrdom/on_acquiring()
	. = ..()
	if(.)
		return TRUE
	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(bloody_shower))

/datum/mutation/human/martyrdom/on_losing()
	. = ..()
	if(.)
		return TRUE
	UnregisterSignal(owner, COMSIG_MOB_STATCHANGE)

/datum/mutation/human/martyrdom/proc/bloody_shower(datum/source, new_stat)
	SIGNAL_HANDLER

	if(new_stat != HARD_CRIT)
		return
	var/list/organs = owner.get_organs_for_zone(BODY_ZONE_HEAD, TRUE)

	for(var/obj/item/organ/I in organs)
		qdel(I)

	explosion(owner, light_impact_range = 2, adminlog = TRUE, explosion_cause = src)
	for(var/mob/living/carbon/human/splashed in view(2, owner))
		var/obj/item/organ/eyes/eyes = splashed.get_organ_slot(ORGAN_SLOT_EYES)
		if(eyes)
			to_chat(splashed, span_userdanger("You are blinded by a shower of blood!"))
			eyes.apply_organ_damage(5)
		else
			to_chat(splashed, span_userdanger("You are knocked down by a wave of... blood?!"))
		splashed.Stun(2 SECONDS)
		splashed.set_eye_blur_if_lower(40 SECONDS)
		splashed.adjust_confusion(3 SECONDS)
	for(var/mob/living/silicon/borgo in view(2, owner))
		to_chat(borgo, span_userdanger("Your sensors are disabled by a shower of blood!"))
		borgo.Paralyze(6 SECONDS)
	owner.investigate_log("has been gibbed by the martyrdom mutation.", INVESTIGATE_DEATHS)
	owner.gib(DROP_ALL_REMAINS)

/datum/mutation/human/headless
	name = "H.A.R.S."
	desc = "Мутация заставляет тело отторгать голову, мозг субъекта с данной мутацией переносится в грудь. Расшифровывается как Синдром Аллергического Отторжения Головы. Удаление данной мутации очень опасно, хоть она и регенерирует не жизненно важные органы головы."
	instability = NEGATIVE_STABILITY_MAJOR
	difficulty = 12 //pretty good for traitors
	quality = NEGATIVE //holy shit no eyes or tongue or ears
	text_gain_indication = span_warning("Что-то здесь не так.")

/datum/mutation/human/headless/on_acquiring()
	. = ..()
	if(.)//cant add
		return TRUE

	var/obj/item/organ/brain/brain = owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain)
		brain.Remove(owner, special = TRUE, movement_flags = NO_ID_TRANSFER)
		brain.zone = BODY_ZONE_CHEST
		brain.Insert(owner, special = TRUE, movement_flags = NO_ID_TRANSFER)

	var/obj/item/bodypart/head/head = owner.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		owner.visible_message(span_warning("[owner]'s head splatters with a sickening crunch!"), ignored_mobs = list(owner))
		new /obj/effect/gibspawner/generic(get_turf(owner), owner)
		head.drop_organs()
		head.dismember(dam_type = BRUTE, silent = TRUE)
		qdel(head)
	RegisterSignal(owner, COMSIG_ATTEMPT_CARBON_ATTACH_LIMB, PROC_REF(abort_attachment))

/datum/mutation/human/headless/on_losing()
	. = ..()
	if(.)
		return TRUE

	UnregisterSignal(owner, COMSIG_ATTEMPT_CARBON_ATTACH_LIMB)
	var/successful = owner.regenerate_limb(BODY_ZONE_HEAD)
	if(!successful)
		stack_trace("HARS mutation head regeneration failed! (usually caused by headless syndrome having a head)")
		return TRUE
	var/obj/item/organ/brain/brain = owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain)
		brain.Remove(owner, special = TRUE, movement_flags = NO_ID_TRANSFER)
		brain.zone = initial(brain.zone)
		brain.Insert(owner, special = TRUE, movement_flags = NO_ID_TRANSFER)

	owner.dna.species.regenerate_organs(owner, replace_current = FALSE, excluded_zones = list(BODY_ZONE_CHEST)) //replace_current needs to be FALSE to prevent weird adding and removing mutation healing
	owner.apply_damage(damage = 50, damagetype = BRUTE, def_zone = BODY_ZONE_HEAD) //and this to DISCOURAGE organ farming, or at least not make it free.
	owner.visible_message(span_warning("[owner]'s head returns with a sickening crunch!"), span_warning("Your head regrows with a sickening crack! Ouch."))
	new /obj/effect/gibspawner/generic(get_turf(owner), owner)

/datum/mutation/human/headless/proc/abort_attachment(datum/source, obj/item/bodypart/new_limb, special) //you aren't getting your head back
	SIGNAL_HANDLER

	if(istype(new_limb, /obj/item/bodypart/head))
		return COMPONENT_NO_ATTACH
