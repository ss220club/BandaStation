/datum/trader_quest
	var/name = "Quest"
	var/description = ""
	var/reward_money = 0
	var/reward_rep = 0
	var/id = "quest"

	proc/start(mob/living/carbon/human/H)
		return

	proc/can_complete(mob/living/carbon/human/H, obj/item/I)
		return FALSE

	proc/on_target_killed(mob/living/carbon/human/H, mob/living/victim)
		return FALSE

	proc/complete(mob/living/carbon/human/H, trader_id, obj/item/I)
		if(I)
			qdel(I)
		var/obj/item/card/id/id_card = H.get_idcard(TRUE)
		if(id_card?.registered_account)
			id_card.registered_account.adjust_money(reward_money)
		if(trader_id)
			H.add_trader_rep(trader_id, reward_rep)
			H.trader_quests -= trader_id
		H.completed_trader_quests += id
		to_chat(H, span_nicegreen("Задание выполнено. Получена награда: [reward_money] кредитов и [reward_rep] очков репутации."))
		playsound(H, 'sound/machines/synth/synth_yes.ogg', 60, TRUE)

/datum/trader_quest/samopal_medal
	name = "Старая медаль"
	id = "samopal_medal"
	description = "Вольно, салага. Работу, гришь, ищешь? Да уж, много теперь вас стало таких - вольнопашцев, как говна за баней. Ну ладно ты, не сердись так - у нас это неорусским юмором называется. Пока не могу поручить тебе ничего серьёзного, ты только на ноги встал, но вот халтурку подкинуть - всегда можно. Как раз растрясешь жирок, проветришься, красотами полюбуешься... хе-хе. Моих ребят под Новым Сиднеем много полегло, хочется от них хоть какую-то память заиметь. Помню перед десантом на планету их медалями награждали, ещё за прошые наши заслуги по обезглавливанию федератской мрази. Найди мне одну такую - я буду тебе благодарен."
	reward_money = 500
	reward_rep = 5
	can_complete(mob/living/carbon/human/H, obj/item/I)
		return istype(I, /obj/item/clothing/accessory/medal/gold/captain)

/datum/trader_quest/samopal_kill_punpun
	name = "Ликвидация цели"
	id = "samopal_kill_punpun"
	description = "Этот чёртов Пун-Пун слишком много знает. Разберись с ним."
	reward_money = 1000
	reward_rep = 2
	on_target_killed(mob/living/carbon/human/H, mob/living/victim)
		return istype(victim, /mob/living/carbon/human/species/monkey/punpun)

/datum/trader_quest/fashion_jacket
	name = "Потерянная куртка"
	id = "fashion_jacket"
	description = "Аллоха, братуха! Ещё один приблуда из мерков! Да ты не кипятись так - не кипяток же! Меня пока Фейшном зови, будем знакомы. Ты чего бледный такой, поганок объелся? Может тебе у милосердников Терезы проставиться? А, понял, ты пробудился только после отключки. Ну не беда, это даже без шота виски - дело поправимое. Пока работки серьёзной для тебя нет, браза, но меня тут одна маза гложит. Я когда сваливал в порт после ядерного пиздеца - пришлось по пути мой куртец скинуть, когда ящики грузил. Он мне дорог... ну, как память, понимаешь? Да чё ты ржёшь, ну со всеми же бывает! Так вот, кажись скинул его на северной автостраде на Побережье, которая в центр ведёт, рядом с одной из тачек. Только ты там давай поаккуратнее - там торчок этот отбитый ошивается, с битой в руках, походу тоже куртец мой вынюхивает. Так что давай, чоп-чоп. Буду ждать тебя с ним. А потом обрисую тебе дела поконкретнее."
	reward_money = 250
	reward_rep = 5
	can_complete(mob/living/carbon/human/H, obj/item/I)
		return istype(I, /obj/item/clothing/suit/jacket/leather_trenchcoat)

/datum/trader_quest/teresa_defibrillator
	name = "Дефибриллятор для лагеря"
	id = "teresa_defibrillator"
	description = "Рада вас приветствовать в столь мрачном месте, о дитя Господа. Как вы уже могли догадаться - мои люди сделали всё возможное, чтобы привести вас в чувство. Вы были найдены не так далеко от места катастрофы в пустошах, и боюсь, если бы пролежали ещё дольше - вы неизбежно бы предстали перед судом Божьим, будучи осыпанным радиоактивным пеплом. Но кажется, Всевышний решил оставить вас на этой бренной земле, дабы вы помогли нам в тяготах наших. Понимаю, что вас распирает любопытство, но я пока не могу вас посвятить в детали того, чем занимается наша организация. Но знаете... Мои люди не испытывают проблем в лекарствах и своих непревзойденных навыках, но вот с техникой - у нас серьёзные проблемы. Помогите достать для нашего бункера компактный дефибриллятор - тогда Господь позволит мне говорить с вами более откровенно. Обычно такого рода устройства лежат рядом с машинами скорой помощи."
	reward_money = 350
	reward_rep = 10
	can_complete(mob/living/carbon/human/H, obj/item/I)
		return istype(I, /obj/item/defibrillator/compact)
