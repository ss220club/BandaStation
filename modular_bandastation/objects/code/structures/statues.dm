// MARK: On-station statues
/obj/structure/statue/themis
	name = "Фемида"
	desc = "Статуя древнегреческой богини правосудия."
	icon = 'modular_bandastation/objects/icons/obj/structures/statuelarge.dmi'
	icon_state = "themis"
	layer = ABOVE_MOB_LAYER
	pixel_y = 7
	anchored = TRUE
	max_integrity = 1000
	impressiveness = 50
	abstract_type = /obj/structure/statue/themis

// Station statues
/obj/structure/statue/station_map
	anchored = TRUE
	impressiveness = 80
	max_integrity = 500

/obj/structure/statue/station_map/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seethrough, get_seethrough_map())

/obj/structure/statue/station_map/proc/get_seethrough_map()
	return

/obj/structure/statue/station_map/wrench_act(mob/living/user, obj/item/tool)
	return FALSE

/obj/structure/statue/station_map/Destroy()
	for(var/obj/structure/statue/station_map/self in orange(3, src))
		if(!QDELETED(self))
			qdel(self)
	return ..()

/obj/structure/statue/station_map/atom_deconstruct(disassembled = TRUE)
	for(var/obj/structure/statue/station_map/self in orange(3, src))
		if(!QDELETED(self))
			qdel(self)
	return ..()

// Cyberiad statue
/obj/structure/statue/station_map/cyberiad
	name = "статуя Кибериады"
	desc = "Гигантская модель научной станции «Кибериада». Судя по отличиям в конструкции, станцию несколько раз перестраивали."
	icon = 'modular_bandastation/objects/icons/obj/structures/cyberiad.dmi'

/obj/structure/statue/station_map/cyberiad/nw
	icon_state = "nw"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/statue/station_map/cyberiad/north
	icon_state = "north"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/statue/station_map/cyberiad/ne
	icon_state = "ne"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

// Adds transparency when the player gets behind an object, or is near it
/obj/structure/statue/station_map/cyberiad/nw/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/cyberiad/north/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/cyberiad/ne/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/cyberiad/w
	icon_state = "west"

/obj/structure/statue/station_map/cyberiad/c
	icon_state = "center"

/obj/structure/statue/station_map/cyberiad/e
	icon_state = "east"

/obj/structure/statue/station_map/cyberiad/w/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/cyberiad/c/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/cyberiad/e/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/cyberiad/sw
	icon_state = "sw"

/obj/structure/statue/station_map/cyberiad/s
	icon_state = "south"

/obj/structure/statue/station_map/cyberiad/se
	icon_state = "se"

// Delta statue
/obj/structure/statue/station_map/delta
	name = "статуя Кербероса"
	desc = "Гигантская модель научной станции «Керберос». Судя по отличиям в конструкции, станцию несколько раз перестраивали."
	icon = 'modular_bandastation/objects/icons/obj/structures/delta.dmi'

/obj/structure/statue/station_map/delta/nw
	icon_state = "nw"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/statue/station_map/delta/north
	icon_state = "north"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/statue/station_map/delta/ne
	icon_state = "ne"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

// Adds transparency when the player gets behind an object, or is near it
/obj/structure/statue/station_map/delta/nw/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/delta/north/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/delta/ne/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/delta/w
	icon_state = "west"

/obj/structure/statue/station_map/delta/c
	icon_state = "center"

/obj/structure/statue/station_map/delta/e
	icon_state = "east"

/obj/structure/statue/station_map/delta/w/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/delta/c/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/delta/e/get_seethrough_map()
	return SEE_THROUGH_MAP_STATION_STATUE

/obj/structure/statue/station_map/delta/sw
	icon_state = "sw"

/obj/structure/statue/station_map/delta/s
	icon_state = "south"

/obj/structure/statue/station_map/delta/se
	icon_state = "se"

// MARK: Off-station statues
/obj/structure/statue/mooniverse
	name = "Неизвестный агент"
	desc = "Информация на табличке под статуей исцарапана и нечитабельна... Поверх написано невнятное словосочетание из слов \"Moon\" и \"Universe\"."
	icon = 'modular_bandastation/objects/icons/obj/structures/statuelarge.dmi'
	icon_state = "mooniverse"
	pixel_y = 7
	anchored = TRUE
	max_integrity = 1000
	impressiveness = 100
	abstract_type = /obj/structure/statue/mooniverse

/obj/structure/statue/ell_good
	name = "Mr.Буум"
	desc = "Загадочный клоун с жёлтым оттенком кожи и выразительными зелёными глазами. Лучший двойной агент синдиката, получивший власть над множеством фасилити. \
			Его имя часто произносят неправильно из-за чего его заслуги по документам принадлежат сразу нескольким Буумам. \
			Так же знаменит тем, что убедил руководство НТ тратить время, силы и средства, на золотой унитаз."
	icon = 'modular_bandastation/objects/icons/obj/structures/statuelarge.dmi'
	icon_state = "ell_good"
	pixel_y = 7
	anchored = TRUE
	max_integrity = 1000
	impressiveness = 100
	abstract_type = /obj/structure/statue/ell_good

/obj/structure/statue/ell_good/halloween
	name = "Тотем Хонкоматери"
	desc = "Загадочный клоунский тотем, излучающий одновременно и смех, и страх. Судя по всему, именно от него Тоннельный Клоун питает свои силы..."
	resistance_flags = INDESTRUCTIBLE
	var/list/notified_mobs = list()
	var/proximity_check_interval = 1 SECONDS

/obj/structure/statue/ell_good/halloween/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(check_proximity)), proximity_check_interval)

/obj/structure/statue/ell_good/halloween/proc/check_proximity()
	if(QDELETED(src))
		return
	var/list/currently_nearby = list()
	for(var/mob/living/carbon/human/person in range(5, src))
		if(QDELETED(person))
			continue
		currently_nearby |= person
		if(person in notified_mobs)
			continue
		var/datum/antagonist/tunnel_clown/antagonist = GLOB.tunnel_clown_antagonist
		if(!antagonist || QDELETED(antagonist))
			continue
		var/mob/living/carbon/human/clown = antagonist.owner?.current
		if(!istype(clown) || QDELETED(clown))
			continue
		to_chat(clown, span_boldannounce("Хонкомать поведала тебе, что чужаки приблизились к \"[name]\""))
	notified_mobs = currently_nearby
	addtimer(CALLBACK(src, PROC_REF(check_proximity)), proximity_check_interval)

/obj/structure/statue/ell_good/halloween/one
	name = "Первый Тотем Хонкоматери"
	desc = "Загадочный клоунский тотем, излучающий одновременно и смех, и страх. Судя по всему, именно от него Тоннельный Клоун питает свои силы... Снизу на пъедестале выгравировано кривыми символами - Смех... Кажется, он смотрит на тебя своими наивными глазами и ждёт, пока ты что-то ему произнесёшь."
	var/your_answer = "Смех Хонкоматери радует детей"

/obj/structure/statue/ell_good/halloween/one/attack_hand(mob/living/user, list/modifiers)
	if(!Adjacent(user))
		return ..()
	var/response = tgui_input_text(user, "Произнесите заклинание", "Первый Тотем Хонкоматери", max_length = 50, encode = FALSE,)
	if(isnull(response))
		return
	response = trim(response)
	if(response == "[your_answer]")
		to_chat(user, span_purple("Она услышала тебя и сжалилась над тобой..."))
		new /obj/effect/temp_visual/small_smoke(loc)
		playsound(src, pick('sound/effects/hallucinations/behind_you1.ogg', 'sound/effects/hallucinations/i_see_you1.ogg', 'sound/effects/hallucinations/im_here1.ogg'), 75, TRUE)
		qdel(src)
	else
		to_chat(user, span_danger("Она не услышала тебя"))

/obj/structure/statue/ell_good/halloween/two
	name = "Второй Тотем Хонкоматери"
	desc = "Загадочный клоунский тотем, излучающий одновременно и смех, и страх. Судя по всему, именно от него Тоннельный Клоун питает свои силы..."

/obj/structure/statue/ell_good/halloween/two/Initialize(mapload)
	. = ..()
	for(var/turf/T in range(2, src))
		RegisterSignal(T, COMSIG_ATOM_ENTERED, PROC_REF(on_turf_entered))

/obj/structure/statue/ell_good/halloween/two/Destroy()
	for(var/turf/T in range(2, src))
		UnregisterSignal(T, COMSIG_ATOM_ENTERED)
	return ..()

/obj/structure/statue/ell_good/halloween/two/proc/on_turf_entered(turf/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(istype(arrived, /obj/item/storage/spooky))
		addtimer(CALLBACK(src, PROC_REF(check_offering)), 1)

/obj/structure/statue/ell_good/halloween/two/proc/check_offering()
	var/list/offering_turfs = list()
	for(var/turf/open/floor/mineral/bananium/tiled/T in range(2, src))
		if(length(offering_turfs) >= 4)
			break
		var/obj/item/storage/spooky/box = locate(/obj/item/storage/spooky) in T
		if(box)
			offering_turfs[T] = box
	if(length(offering_turfs) < 4)
		return FALSE
	for(var/turf/T as anything in offering_turfs)
		var/obj/item/storage/spooky/box = offering_turfs[T]
		if(box)
			qdel(box)
		new /obj/effect/temp_visual/small_smoke(T)
	playsound(src, pick('sound/effects/hallucinations/behind_you1.ogg', 'sound/effects/hallucinations/i_see_you1.ogg', 'sound/effects/hallucinations/im_here1.ogg'), 75, TRUE)
	qdel(src)
	return TRUE

/obj/structure/statue/ell_good/halloween/tree
	name = "Третий Тотем Хонкоматери"
	desc = "Загадочный клоунский тотем, излучающий одновременно и смех, и страх. Судя по всему, именно от него Тоннельный Клоун питает свои силы..."

/obj/structure/statue/heinrich_treisen
	name = "Генрих Трейзен Третий"
	desc = "Золотая статуя текущего главы семьи Трейзен. Его успешная агрессивная политика в отношении конкурентов, \
			формирование окончательной монополии на рынке и мудрое распоряжение имеющимися активами привели к получению Корпорацией исключительных прав на разработку, \
			переработку и продажу плазмы во многих известных мирах. Именно благодаря Генриху Трейзену Третьему мы сегодня знаем Компанию Нанотрейзен такой, какая она есть."
	icon = 'modular_bandastation/objects/icons/obj/structures/statue.dmi'
	icon_state = "heinrich_treisen"
	anchored = TRUE
	abstract_type = /obj/structure/statue/heinrich_treisen
	layer = ABOVE_MOB_LAYER

/obj/structure/statue/elwycco
	name = "Camper Hunter"
	desc = "Похоже это какой-то очень важный человек, или очень значимый для многих людей. Вы замечаете огроменный топор в его руках, с выгравированным числом 220. \
			Что это число значит? Каждый понимает по своему, однако по слухам оно означает количество его жертв. \n Надпись на табличке - Мы с тобой, Шустрила! Аве, Легион!"
	icon = 'modular_bandastation/objects/icons/obj/structures/statue.dmi'
	icon_state = "elwycco"
	anchored = TRUE
	abstract_type = /obj/structure/statue/elwycco

/obj/structure/statue/normandy_soo
	name = "Офицер специальных операций"
	desc = "Статуя одного из офицеров специальных операций. Подобной почести удостоены лишь самые верные..."
	icon = 'modular_bandastation/objects/icons/obj/structures/statue.dmi'
	icon_state = "mooniverse_soo"
	anchored = TRUE
	abstract_type = /obj/structure/statue/normandy_soo

/obj/structure/statue/angel
	name = "Angel"
	desc = "Хранитель усопших душ..."
	icon = 'modular_bandastation/objects/icons/obj/structures/statuewide.dmi'
	icon_state = "angel"
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/statue/grave
	name = "Grave"
	desc = "Могила с качественным надгробным камнем."
	icon = 'modular_bandastation/objects/icons/obj/structures/statue_graves.dmi'
	icon_state = "statue_grave"
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/statue/improvised_grave
	name = "Unnamed Grave"
	desc = "Безымянная могила с каменным крестом."
	icon = 'modular_bandastation/objects/icons/obj/structures/statue_graves.dmi'
	icon_state = "improvised_grave"
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/statue/sandstone/venus/pure
	name = "Венера"
	desc = "Эта мраморная реплика античной статуи восхлавляет женскую красоту и грацию, привлекая внимание своими изящными формами. \
			Скульптура создает величественный образ, который восхищает своим великолепием."
	icon = 'modular_bandastation/objects/icons/obj/structures/statuelarge.dmi'
	icon_state = "venus_pure"
	layer = ABOVE_MOB_LAYER
	pixel_y = 7
	anchored = TRUE
	max_integrity = 1000
	impressiveness = 50
	abstract_type = /obj/structure/statue/themis

/obj/structure/statue/statue_holoplanet
	name = "планетарная голограмма"
	desc = "Установка, позволяющая показывать подробные голографические карты известных миров."
	icon = 'modular_bandastation/objects/icons/obj/structures/statue.dmi'
	icon_state = "statue_holoplanet"
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	abstract_type = /obj/structure/statue/statue_holoplanet


// Dummies
/**
 *	It is used as decorative element, or for shitspawn/events
 *	DO NOT use these icons for PvE NPCs! TGs NPCs made different.
 */
/obj/structure/statue/dummy
	name = "Unknown"
	desc = null
	icon = 'modular_bandastation/mobs/icons/dummies.dmi'
	icon_state = null
	pixel_y = 7
	anchored = TRUE
	max_integrity = 1000
	impressiveness = 0
	abstract_type = /obj/structure/statue/dummy

/obj/structure/statue/dummy/srt
	name = "SRT Soldier"
	desc = "Он точно не спит..."
	icon_state = "srt"
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
