/datum/disease/species
	name = "species"
	max_stages = 5
	spread_text = "pray"
	cure_text = "A coder's love (theoretical)."
	agent = "Shenanigans"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/alien)
	visibility_flags = NONE
	spread_flags = DISEASE_SPREAD_BLOOD|DISEASE_SPREAD_CONTACT_FLUIDS|DISEASE_SPREAD_CONTACT_SKIN|DISEASE_SPREAD_AIRBORNE
	cure_chance = 25
	stage_prob = 2
	severity = DISEASE_SEVERITY_BIOHAZARD

	var/new_form = /mob/living/carbon/human
	var/new_species = /datum/species/human

/datum/disease/species/proc/transform(mob/living/carbon/affected_mob)
	if(is_species(affected_mob, new_species))
		return

	if(ishuman(affected_mob))
		affected_mob.set_species(new_species, replace_missing = TRUE)
	else
		do_disease_transformation(affected_mob)

/datum/disease/species/proc/do_disease_transformation(mob/living/affected_mob)
	if(iscarbon(affected_mob) && affected_mob.stat != DEAD)
		if(QDELETED(affected_mob))
			return
		if(HAS_TRAIT_FROM(affected_mob, TRAIT_NO_TRANSFORM, REF(src)))
			return
		ADD_TRAIT(affected_mob, TRAIT_NO_TRANSFORM, REF(src))
		for(var/obj/item/W in affected_mob.get_equipped_items(INCLUDE_POCKETS))
			affected_mob.dropItemToGround(W)
		for(var/obj/item/I in affected_mob.held_items)
			affected_mob.dropItemToGround(I)
		var/mob/living/new_mob = new new_form(affected_mob.loc)
		if(istype(new_mob))
			new_mob.set_combat_mode(TRUE)
			if(affected_mob.mind)
				affected_mob.mind.transfer_to(new_mob)
			else
				new_mob.PossessByPlayer(affected_mob.ckey)
		new_mob.name = affected_mob.real_name
		new_mob.real_name = new_mob.name
		infect(new_mob)
		qdel(affected_mob)

/datum/disease/species/tajaran
	name = "Синдром Кингстона"
	desc = "Если не лечить, субъект превратится в кошку. У кошачьих это приводит к... ДРУГИМ... последствиям."
	spread_text = "ERROR///"
	cure_text = "Молоко."
	agent = "Микро кошки"
	cures = list(/datum/reagent/consumable/milk)
	new_form = /mob/living/carbon/human/species/tajaran
	new_species = /datum/species/tajaran

/datum/disease/species/tajaran/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(10, seconds_per_tick))
				if(istajaran(affected_mob))
					to_chat(affected_mob, span_notice("Вы чувствуете себя хорошо."))
				else
					to_chat(affected_mob, span_notice("Вам хочется поиграть с ниткой."))
		if(3)
			if(SPT_PROB(5, seconds_per_tick))
				if(istajaran(affected_mob))
					to_chat(affected_mob, span_warning("У вас что-то застряло в горле."))
				else
					to_chat(affected_mob, span_warning("Вам НУЖНО найти мышь."))
		if(4)
			if(SPT_PROB(10, seconds_per_tick))
				if(istajaran(affected_mob))
					to_chat(affected_mob, span_danger("Вы чувствуете что-то в горле!"))
					affected_mob.emote("cough", forced = "tajaran transformation")
				else
					affected_mob.say(pick("Мяу", "Мяу!", "Ня!~"), forced = "tajaran transformation")
		if(5)
			if(istajaran(affected_mob))
				if(SPT_PROB(5, seconds_per_tick))
					affected_mob.emote("cough", forced = "tajaran transformation")
					affected_mob.visible_message(span_danger("[affected_mob] выкашливает комок шерсти!"), \
												span_userdanger("Вы выкашляли комок шерсти!"))
					affected_mob.Stun(2 SECONDS)
			else
				affected_mob.visible_message(span_danger("Форма [affected_mob] искажается во что-то более кошачье!"), \
											span_userdanger("ВЫ ПРЕВРАТИЛИСЬ В ТАЯРУ!"))
			transform(affected_mob)

/datum/disease/species/felinid
	name = "Генная регрессия"
	desc = "Если не лечить, субъект превратится в фелинида."
	spread_text = "ERROR///"
	cure_text = "Неурин."
	agent = "Ретровирус Felis"
	cures = list(/datum/reagent/medicine/neurine)
	new_form = /mob/living/carbon/human
	new_species = /datum/species/human/felinid

/datum/disease/species/felinid/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(10, seconds_per_tick))
				if(isfelinid(affected_mob))
					to_chat(affected_mob, span_notice("Вы чувствуете необычную лёгкость."))
				else
					to_chat(affected_mob, span_notice("Вам хочется потянуться как кошка."))
		if(3)
			if(SPT_PROB(10, seconds_per_tick))
				if(isfelinid(affected_mob))
					to_chat(affected_mob, span_warning("У вас что-то застряло в горле."))
				else
					to_chat(affected_mob, span_warning("Вы ощущаете покалывание в ушах."))
		if(4)
			if(SPT_PROB(10, seconds_per_tick))
				if(isfelinid(affected_mob))
					to_chat(affected_mob, span_danger("Вы чувствуете что-то в горле!"))
					affected_mob.emote("cough", forced = "felinid transformation")
				else
					affected_mob.say(pick("Мяу", "Мррр", "Мяу!"), forced = "felinid transformation")
		if(5)
			if(isfelinid(affected_mob))
				if(SPT_PROB(5, seconds_per_tick))
					affected_mob.emote("cough", forced = "felinid transformation")
					affected_mob.visible_message(span_danger("[affected_mob] выкашливает комок шерсти!"), \
												span_userdanger("Вы выкашляли комок шерсти!"))
					affected_mob.Stun(2 SECONDS)
			else
				affected_mob.visible_message(span_danger("Форма [affected_mob] искажается в фелинида!"), \
											span_userdanger("ВЫ ПРЕВРАТИЛИСЬ В ФЕЛИНИДА!"))
			transform(affected_mob)

/datum/disease/species/human
	name = "Гуманизация"
	desc = "Если не лечить, субъект превратится в человека. У людей вызывает галлюцинации."
	spread_text = "ERROR///"
	cure_text = "Этанол."
	agent = "Вирус Homo Sapiens"
	cures = list(/datum/reagent/consumable/ethanol)
	new_form = /mob/living/carbon/human
	new_species = /datum/species/human

/datum/disease/species/human/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(10, seconds_per_tick))
				if(ishumanbasic(affected_mob))
					to_chat(affected_mob, span_notice("Вы чувствуете себя обычным."))
				else
					to_chat(affected_mob, span_notice("Вам хочется чего-то... нормального."))
		if(3)
			if(SPT_PROB(10, seconds_per_tick))
				if(ishumanbasic(affected_mob))
					to_chat(affected_mob, span_warning("Как хорошо быть человеком."))
				else
					to_chat(affected_mob, span_warning("Вы ощущаете потерю уникальных черт."))
		if(4)
			if(SPT_PROB(10, seconds_per_tick))
				if(ishumanbasic(affected_mob))
					to_chat(affected_mob, span_danger("Вы чувствуете себя слишком обычным!"))
				else
					affected_mob.say(pick("Хуман супремаси!", "ИИ, открой!", "Слава НТ!"), forced = "human transformation")
		if(5)
			if(ishumanbasic(affected_mob))
				if(SPT_PROB(5, seconds_per_tick))
					to_chat(affected_mob, span_userdanger("Вы чувствуете полную обыденность!"))
					affected_mob.adjust_hallucinations_up_to(10 SECONDS, 120 SECONDS)
			else
				affected_mob.visible_message(span_danger("[affected_mob] превращается в человека!"), \
											span_userdanger("ВЫ ПРЕВРАТИЛИСЬ В ЧЕЛОВЕКА!"))
			transform(affected_mob)

/datum/disease/species/vulpkanin
	name = "Лисья мутация"
	desc = "Если не лечить, субъект превратится в вульпканина. У вульпканинов вызывает галлюцинации."
	spread_text = "ERROR///"
	cure_text = "Синаптизин."
	agent = "Вирус Vulpis"
	cures = list(/datum/reagent/medicine/synaptizine)
	new_form = /mob/living/carbon/human/species/vulpkanin
	new_species = /datum/species/vulpkanin

/datum/disease/species/vulpkanin/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(10, seconds_per_tick))
				if(isvulpkanin(affected_mob))
					to_chat(affected_mob, span_notice("Вы чувствуете себя прекрасно."))
				else
					to_chat(affected_mob, span_notice("Вам хочется погнаться за чем-то."))
		if(3)
			if(SPT_PROB(10, seconds_per_tick))
				if(isvulpkanin(affected_mob))
					to_chat(affected_mob, span_warning("Уши свербят."))
				else
					to_chat(affected_mob, span_warning("Вы ощущаете зуд в носу."))
		if(4)
			if(SPT_PROB(10, seconds_per_tick))
				if(isvulpkanin(affected_mob))
					to_chat(affected_mob, span_danger("Хвост дёргается сам по себе!"))
				else
					affected_mob.say(pick("Гав", "Тяф", "Вуф!"), forced = "vulpkanin transformation")
		if(5)
			if(isvulpkanin(affected_mob))
				if(SPT_PROB(5, seconds_per_tick))
					to_chat(affected_mob, span_userdanger("Всегда ли вы были вульпой?"))
					affected_mob.adjust_hallucinations_up_to(10 SECONDS, 120 SECONDS)
			else
				affected_mob.visible_message(span_danger("[affected_mob] превращается в вульпканина!"), \
											span_userdanger("ВЫ ПРЕВРАТИЛИСЬ В ВУЛЬПКАНИНА!"))
			transform(affected_mob)

/datum/disease/species/skrell
	name = "Кальмаризация"
	desc = "Если не лечить, субъект превратится в скрелла. У скреллов вызывает генетический коллапс."
	spread_text = "ERROR///"
	cure_text = "Поваренная соль."
	agent = "Ксеновирус Nralakk"
	cures = list(/datum/reagent/consumable/salt)
	new_form = /mob/living/carbon/human/species/skrell
	new_species = /datum/species/skrell

/datum/disease/species/skrell/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(10, seconds_per_tick))
				if(isskrell(affected_mob))
					to_chat(affected_mob, span_notice("Вы чувствуете мудрость."))
				else
					to_chat(affected_mob, span_notice("Ваша кожа становится влажной."))
		if(3)
			if(SPT_PROB(10, seconds_per_tick))
				if(isskrell(affected_mob))
					to_chat(affected_mob, span_warning("Вы чувствуете пульсацию в голове."))
				else
					to_chat(affected_mob, span_warning("Вам хочется в более влажное место."))
		if(4)
			if(SPT_PROB(10, seconds_per_tick))
				if(isskrell(affected_mob))
					to_chat(affected_mob, span_danger("Тентакли дёргаются!"))
				else
					affected_mob.say(pick("Квак", "Ква", "Бульк"), forced = "skrell transformation")
		if(5)
			if(isskrell(affected_mob))
				if(SPT_PROB(5, seconds_per_tick))
					to_chat(affected_mob, span_userdanger("Вы чувствуете как исчезают тентакли!"))
					affected_mob.adjust_hallucinations_up_to(10 SECONDS, 120 SECONDS)
			else
				affected_mob.visible_message(span_danger("[affected_mob] превращается в скрелла!"), \
											span_userdanger("ВЫ ПРЕВРАТИЛИСЬ В СКРЕЛЛА!"))
			transform(affected_mob)

/datum/disease/species/moth
	name = "Молификация"
	desc = "Если не лечить, субъект превратится в моль. У молей вызывает жужжание."
	spread_text = "ERROR///"
	cure_text = "Пиво и мед."
	agent = "Медоносный ксеновирус"
	cures = list(/datum/reagent/consumable/ethanol/beer, /datum/reagent/consumable/honey)
	new_form = /mob/living/carbon/human/species/moth
	new_species = /datum/species/moth

/datum/disease/species/moth/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(SPT_PROB(10, seconds_per_tick))
				if(ismoth(affected_mob))
					to_chat(affected_mob, span_notice("Вы чувствуете мед."))
				else
					to_chat(affected_mob, span_notice("Лампы всегда были такими яркими?"))
		if(3)
			if(SPT_PROB(10, seconds_per_tick))
				if(ismoth(affected_mob))
					to_chat(affected_mob, span_warning("Вам хочется пожужжать."))
				else
					to_chat(affected_mob, span_warning("Вам так хочется потрогать эту лампу..."))
		if(4)
			if(SPT_PROB(10, seconds_per_tick))
				if(ismoth(affected_mob))
					to_chat(affected_mob, span_danger("Ваши крылья дёргаются!"))
				else
					if(prob(50))
						affected_mob.say(pick("Лампы...", "Мед...", "Жужж"), forced = "moth transformation")
					else
						affected_mob.emote("жужжит", force_silence = TRUE, forced = "moth transformation")
						playsound(affected_mob, 'sound/mobs/humanoids/moth/scream_moth.ogg', 50, TRUE)
		if(5)
			if(ismoth(affected_mob))
				if(SPT_PROB(5, seconds_per_tick))
					affected_mob.emote("scream", forced = "moth transformation")
			else
				affected_mob.visible_message(span_danger("[affected_mob] превращается в моль!"), \
											span_userdanger("ВЫ ПРЕВРАТИЛИСЬ В МОЛЬ!"))
			transform(affected_mob)
