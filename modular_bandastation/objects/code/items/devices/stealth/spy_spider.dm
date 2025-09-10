/obj/item/spy_spider
	name = "spy spider"
	desc = "Кажется, ты видел такого в фильмах про шпионов."
	icon = 'modular_bandastation/objects/icons/obj/items/spy_spider.dmi'
	icon_state = "spy_spider"
	worn_icon = null
	var/obj/item/radio/spider_transmitter/transmitter = null

/obj/item/spy_spider/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/stealth_device)
	transmitter = new /obj/item/radio/spider_transmitter(src)

/obj/item/spy_spider/Destroy()
	QDEL_NULL(transmitter)
	. = ..()

/obj/item/spy_spider/examine(mob/user)
	. = ..()
	if(!transmitter)
		. += span_info("Передатчик отсутствует.")
		return
	. += span_info("Сейчас он [transmitter.get_broadcasting() ? "включён" : "выключен"].")

/obj/item/spy_spider/attack_self(mob/user, modifiers)
	if(transmitter)
		transmitter.ui_interact(user)
	return ..()

/obj/item/radio/quiet
	name = "narrow-focused receiver"
	desc = "Компактный радиоприёмник, оснащённый направленным микроизлучателем звука, обеспечивающим воспроизведение аудиосигнала в строго ограниченной зоне."
	canhear_range = 0

/obj/item/radio/spider_transmitter
	name = "spy transmitter"
	desc = "Миниатюрный передатчик, размер которого позволяет устанавливать его в небольших устройствах."
	icon = 'modular_bandastation/objects/icons/obj/items/spy_spider.dmi'
	icon_state = "spy_spider"
	canhear_range = 3
	radio_noise = FALSE
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_ALLOW_USER_LOCATION
	overlay_speaker_idle = null
	overlay_speaker_active = null
	overlay_mic_idle = null
	overlay_mic_active = null

/obj/item/radio/spider_transmitter/Initialize(mapload)
	. = ..()
	set_listening(FALSE)
	set_broadcasting(FALSE)

/obj/item/radio/spider_transmitter/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/datum/storage/lockbox/detective
	max_total_storage = 20
	max_slots = 5

/obj/item/storage/lockbox/spy_kit
	name = "spy bug kit"
	desc = "Не самый легальный из способов достать информацию, но какая разница, если никто не узнает?"
	req_access = list(ACCESS_DETECTIVE)
	storage_type = /datum/storage/lockbox/detective

/obj/item/storage/lockbox/spy_kit/PopulateContents()
	new /obj/item/radio/quiet(src)
	new /obj/item/spy_spider(src)
	new /obj/item/spy_spider(src)
	new /obj/item/spy_spider(src)
