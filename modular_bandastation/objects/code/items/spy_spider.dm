/obj/item/clothing/accessory/stealth/spy_spider
	name = "шпионский жучок"
	desc = "Кажется, ты видел такого в фильмах про шпионов."
	icon = 'modular_bandastation/objects/icons/obj/items/spy_spider.dmi'
	icon_state = "spy_spider"
	worn_icon = null
	var/obj/item/radio/spider_transmitter/transmitter = null

/obj/item/clothing/accessory/stealth/spy_spider/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pinnable_accessory, silent = TRUE)
	transmitter = new /obj/item/radio/spider_transmitter(src)

/obj/item/clothing/accessory/stealth/spy_spider/Destroy()
	QDEL_NULL(transmitter)
	. = ..()

/obj/item/clothing/accessory/stealth/spy_spider/examine(mob/user)
	. = ..()
	. += span_info("Сейчас он [transmitter.get_broadcasting() ? "включён" : "выключен"].")

/obj/item/clothing/accessory/stealth/spy_spider/attack_self(mob/user, modifiers)
	transmitter.ui_interact(user)
	return ..()

/obj/item/radio/spider_transmitter
	name = "шпионский передатчик"
	desc = "Кажется, ты видел такого в фильмах про шпионов."
	icon = 'modular_bandastation/objects/icons/obj/items/spy_spider.dmi'
	icon_state = "spy_spider"
	canhear_range = 3
	radio_noise = FALSE
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_ALLOW_USER_LOCATION

/obj/item/radio/spider_transmitter/Initialize(mapload)
	. = ..()
	set_listening(FALSE)
	set_broadcasting(FALSE)

/obj/item/radio/spider_transmitter/ui_state(mob/user)
	return GLOB.always_state

/obj/item/encryptionkey/spy_spider
	name = "Spy Encryption Key"
	icon = 'modular_bandastation/objects/icons/obj/items/spy_spider.dmi'
	icon_state = "spy_cypherkey"
	channels = list("Spy Spider" = TRUE)

/obj/item/storage/lockbox/spy_kit
	name = "набор жучков"
	desc = "Не самый легальный из способов достать информацию, но какая разница, если никто не узнает?"
	req_access = list(ACCESS_DETECTIVE)

/obj/item/storage/lockbox/spy_kit/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 5
	atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	atom_storage.max_total_storage = 20
	atom_storage.locked = STORAGE_FULLY_LOCKED
	new /obj/item/clothing/accessory/stealth/spy_spider(src)
	new /obj/item/clothing/accessory/stealth/spy_spider(src)
	new /obj/item/clothing/accessory/stealth/spy_spider(src)
