//Уникальный питомец Офицера Телекомов. Спрайты от Элл Гуда
/mob/living/basic/snake/rouge
	name = "Руж"
	desc = "Уникальная трёхголовая змея Офицера Телекоммуникаций синдиката. Выращена в лаборатории. У каждой головы свой характер!"
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	mob_size = MOB_SIZE_SMALL
	gender = FEMALE
	icon_state = "rouge"
	icon_living = "rouge"
	icon_dead = "rouge_dead"
	icon_resting = "rouge_rest"
	health = 20
	maxHealth = 20
	attack_verb_continuous = "вгрызается"
	attack_verb_simple = "кусает"
	melee_damage_lower = 5
	melee_damage_upper = 20
	//var/obj/item/inventory_head // TODO Snake Fashion
	faction = list("neutral", "syndicate")
	gold_core_spawnable = NO_SPAWN
	///icon state of the collar we can wear
	var/collar_icon_state

/mob/living/basic/snake/rouge/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wears_collar, collar_icon_state = collar_icon_state)

/mob/living/basic/snake/rouge/verb/chasetail()
	set name = "Помахать хвостом"
	set desc = "Ваааай!"
	set category = "Animal"
	visible_message("[src] [pick("кружится", "махает хвостом")].", "[pick("Вы кружитесь.", "Вы махаете хвостом.")].")
	spin(20, 1)

/mob/living/basic/snake/rouge/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(user.combat_mode)
		shh(-1, user)
	else
		shh(1, user)

/mob/living/basic/snake/rouge/proc/shh(change, mob/M)
	if(!M || stat)
		return
	if(change > 0)
		new /obj/effect/temp_visual/heart(loc)
		manual_emote("радостно шипит!")
	else
		manual_emote("злобно шипит!")
