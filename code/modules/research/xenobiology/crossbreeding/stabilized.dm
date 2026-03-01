/*
Stabilized extracts:
	Provides a passive buff to the holder.
*/

//To add: Create an effect in crossbreeding/_status_effects.dm with the name "/datum/status_effect/stabilized/[color]"
//Status effect will automatically be applied while held, and lost on drop.

/obj/item/slimecross/stabilized
	name = "stabilized extract"
	desc = "Он кажется инертным, но все, к чему он прикасается, мягко светится..."
	effect = "stabilized"
	icon_state = "stabilized"
	var/datum/status_effect/linked_effect

/obj/item/slimecross/stabilized/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj,src)

/obj/item/slimecross/stabilized/Destroy()
	STOP_PROCESSING(SSobj,src)
	qdel(linked_effect)
	return ..()

/// Returns the mob that is currently holding us if we are either in their inventory or a backpack analogue.
/// Returns null if it's in an invalid location, so that we can check explicitly for null later.
/obj/item/slimecross/stabilized/proc/get_held_mob()
	if(isnull(loc))
		return null
	if(isliving(loc))
		return loc
	// Snowflake check for modsuit backpacks, which should be valid but are 3 rather than 2 steps from the owner
	if(istype(loc, /obj/item/mod/module/storage))
		var/obj/item/mod/module/storage/mod_backpack = loc
		var/mob/living/modsuit_wearer = mod_backpack.mod?.wearer
		return modsuit_wearer ? modsuit_wearer : null
	var/nested_loc = loc.loc
	if (isliving(nested_loc))
		return nested_loc
	return null

/obj/item/slimecross/stabilized/process()
	var/mob/living/holder = get_held_mob()
	if(isnull(holder))
		return
	var/effectpath = /datum/status_effect/stabilized
	var/static/list/effects = subtypesof(/datum/status_effect/stabilized)
	for(var/datum/status_effect/stabilized/effect as anything in effects)
		if(initial(effect.colour) != colour)
			continue
		effectpath = effect
		break
	if (holder.has_status_effect(effectpath))
		return
	holder.apply_status_effect(effectpath, src)
	return PROCESS_KILL

//Colors and subtypes:
/obj/item/slimecross/stabilized/grey
	colour = SLIME_TYPE_GREY
	effect_desc = "Делает слаймов дружелюбными для владельца."

/obj/item/slimecross/stabilized/orange
	colour = SLIME_TYPE_ORANGE
	effect_desc = "Пассивно повышает или понижает температуру тела до нормального уровня."

/obj/item/slimecross/stabilized/purple
	colour = SLIME_TYPE_PURPLE
	effect_desc = "Обеспечивает эффект регенерации."

/obj/item/slimecross/stabilized/blue
	colour = SLIME_TYPE_BLUE
	effect_desc = "Позволяет вам не подскальзываться на воде, мыле или пене. Космическая смазка и лёд все ещё слишком скользкие!"

/obj/item/slimecross/stabilized/metal
	colour = SLIME_TYPE_METAL
	effect_desc = "Каждые 30 секунд добавляет лист материала в случайную стопку в вашем инвентаре."

/obj/item/slimecross/stabilized/yellow
	colour = SLIME_TYPE_YELLOW
	effect_desc = "Каждые 10 секунд подзаряжает случайное устройство в вашем инвентаре примерно на 10%."

/obj/item/slimecross/stabilized/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE
	effect_desc = "Делает кончики пальцев настолько горячими, что вы способны автоматически приготовить еду, которую держите в руках, как в микроволновой печи."

/obj/item/slimecross/stabilized/darkblue
	colour = SLIME_TYPE_DARK_BLUE
	effect_desc = "Медленно тушит владельца, если он загорелся, а также смачивает предметы, такие как обезьяньи кубики, создавая обезьяну."

/obj/item/slimecross/stabilized/silver
	colour = SLIME_TYPE_SILVER
	effect_desc = "Замедляет скорость голодания."

/obj/item/slimecross/stabilized/bluespace
	colour = SLIME_TYPE_BLUESPACE
	effect_desc = "С перезарядкой в 2 минуты телепортирует вас в безопасное для людей место, когда вы получите достаточно урона. "

/obj/item/slimecross/stabilized/sepia
	colour = SLIME_TYPE_SEPIA
	effect_desc = "Случайным образом меняет вашу скорость."

/obj/item/slimecross/stabilized/cerulean
	colour = SLIME_TYPE_CERULEAN
	effect_desc = "Создает ваш дубликат. Если вы умрёте, удерживая при себе этот экстракт, то автоматически возьмёте под контроль дубликат, если он жив. Не работает, если оригинал умирает от обезглавливания или полного уничтожения."

/obj/item/slimecross/stabilized/pyrite
	colour = SLIME_TYPE_PYRITE
	effect_desc = "Случайно окрашивает вас в разные цвета каждые несколько секунд."

/obj/item/slimecross/stabilized/red
	colour = SLIME_TYPE_RED
	effect_desc = "На вас больше не влияет замедление или другие изменения скорости из-за вашей экипировки."

/obj/item/slimecross/stabilized/green
	colour = SLIME_TYPE_GREEN
	effect_desc = "Меняет случайным образом имя и внешность, если держать экстракт при себе."

/obj/item/slimecross/stabilized/pink
	colour = SLIME_TYPE_PINK
	effect_desc = "Существа не будут нападать на вас, пока ни одно из них не пострадало в вашем поле зрения. Если мир нарушен, экстракт восстанавливается 2 минуты."

/obj/item/slimecross/stabilized/gold
	colour = SLIME_TYPE_GOLD
	effect_desc = "Вызывает питомца-компаньона, пока экстракт находится у вас. "
	var/mob_type
	var/datum/mind/saved_mind
	var/mob_name = "Familiar"

/obj/item/slimecross/stabilized/gold/proc/generate_mobtype()
	var/static/list/mob_spawn_pets = list()
	if(!length(mob_spawn_pets))
		for(var/mob/living/simple_animal/animal as anything in subtypesof(/mob/living/simple_animal))
			if(initial(animal.gold_core_spawnable) == FRIENDLY_SPAWN)
				mob_spawn_pets += animal
		for(var/mob/living/basic/basicanimal as anything in subtypesof(/mob/living/basic))
			if(initial(basicanimal.gold_core_spawnable) == FRIENDLY_SPAWN)
				mob_spawn_pets += basicanimal
	mob_type = pick(mob_spawn_pets)

/obj/item/slimecross/stabilized/gold/Initialize(mapload)
	. = ..()
	generate_mobtype()

/obj/item/slimecross/stabilized/gold/attack_self(mob/user)
	var/choice = tgui_input_list(user, "Which do you want to reset?", "Familiar Adjustment", sort_list(list("Familiar Location", "Familiar Species", "Familiar Sentience", "Familiar Name")))
	if(isnull(choice))
		return
	if(!user.can_perform_action(src))
		return
	if(isliving(user))
		var/mob/living/L = user
		if(L.has_status_effect(/datum/status_effect/stabilized/gold))
			L.remove_status_effect(/datum/status_effect/stabilized/gold)
	if(choice == "Familiar Location")
		to_chat(user, span_notice("Вы нажимаете на [src.declent_ru(ACCUSATIVE)] и он слегка вздрагивает."))
		START_PROCESSING(SSobj, src)
	if(choice == "Familiar Species")
		to_chat(user, span_notice("Вы нажимаете [src.declent_ru(ACCUSATIVE)] и вам кажется, что форма внутри слегка вздрагивает."))
		generate_mobtype()
		START_PROCESSING(SSobj, src)
	if(choice == "Familiar Sentience")
		to_chat(user, span_notice("Вы тыкаете [src.declent_ru(ACCUSATIVE)] и он испускает светящийся импульс."))
		saved_mind = null
		START_PROCESSING(SSobj, src)
	if(choice == "Familiar Name")
		var/newname = sanitize_name(tgui_input_text(user, "Would you like to change the name of [mob_name]", "Name change", mob_name, MAX_NAME_LEN))
		if(newname)
			mob_name = newname
		to_chat(user, span_notice("Вы тихо говорите в [src.declent_ru(ACCUSATIVE)], и он слегка дрожит в ответ."))
		START_PROCESSING(SSobj, src)

/obj/item/slimecross/stabilized/oil
	colour = SLIME_TYPE_OIL
	effect_desc = "Если вы умрёте, держа при себе этот экстракт - произойдёт сильный взрыв."

/obj/item/slimecross/stabilized/black
	colour = SLIME_TYPE_BLACK
	effect_desc = "Когда вы душите кого-то, ваши руки смыкаются вокруг его шеи, высасывая жизнь в обмен на еду и исцеление."

/obj/item/slimecross/stabilized/lightpink
	colour = SLIME_TYPE_LIGHT_PINK
	effect_desc = "Вы двигаетесь быстрее, получая временный пацифизм, а все, кто находится рядом с вами в критическом состоянии, стабилизируются с помощью эпинефрина. "

/obj/item/slimecross/stabilized/adamantine
	colour = SLIME_TYPE_ADAMANTINE
	effect_desc = "Вы получаете небольшое сопротивление всем типам урона."

/obj/item/slimecross/stabilized/rainbow
	colour = SLIME_TYPE_RAINBOW
	effect_desc = "Вставьте в него регенеративный экстракт. Если вы войдете в критическом состояние, он автоматически использует экстракт на вас."
	var/obj/item/slimecross/regenerative/regencore

/obj/item/slimecross/stabilized/rainbow/attackby(obj/item/O, mob/user)
	var/obj/item/slimecross/regenerative/regen = O
	if(istype(regen) && !regencore)
		to_chat(user, span_notice("Вы помещаете [O.declent_ru(ACCUSATIVE)] в [src.declent_ru(ACCUSATIVE)], подготавливая экстракт к автоматическому применению!"))
		regencore = regen
		regen.forceMove(src)
		return
	return ..()
