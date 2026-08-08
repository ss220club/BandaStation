/obj/structure/closet/crate/secure/weapon/air
	resistance_flags = INDESTRUCTIBLE
	var/unlock_time = 0
	var/unlocking = FALSE
	var/unlock_sound_timer = null

/obj/structure/closet/crate/secure/weapon/air/attack_hand(mob/living/user)
	if(!ishuman(user))
		return ..()
	var/mob/living/carbon/human/H = user
	if(unlocking)
		var/time_left = round((unlock_time - world.time) / 10)
		to_chat(H, span_warning("Разблокировка ящика продолжается. Осталось [time_left] сек."))
		return
	if(!locked)
		return ..()
	start_unlock(H)

/obj/structure/closet/crate/secure/weapon/air/proc/start_unlock(mob/user)
	unlocking = TRUE
	unlock_time = world.time + 1 MINUTES
	to_chat(user, span_warning("Вы запустили процедуру разблокировки контейнера. Процедура займёт одну минуту."))
	playsound(src, 'sound/items/timer.ogg', 80, TRUE)
	unlock_sound_loop()
	addtimer(CALLBACK(src, PROC_REF(finish_unlock)), 1 MINUTES)

/obj/structure/closet/crate/secure/weapon/air/proc/unlock_sound_loop()
	if(!unlocking)
		return
	var/last_tick = 0
	if(world.time - last_tick < 10)
		return
	last_tick = world.time
	playsound(src, 'sound/items/timer.ogg', 50, FALSE)
	addtimer(CALLBACK(src, PROC_REF(unlock_sound_loop)), 1 SECONDS)

/obj/structure/closet/crate/secure/weapon/air/proc/finish_unlock()
	unlocking = FALSE
	locked = FALSE
	playsound(src, 'sound/machines/beep/beep.ogg', 80, TRUE)
	for(var/mob/living/M in viewers(5, src))
		to_chat(M, span_notice("Замок ящика разблокирован."))

/obj/structure/closet/crate/secure/weapon/air/common
	name = "ящик общего обеспечения"
	desc = "Ящик общего обеспечения из гуманитарной капсулы. В таких обычно находятся различные инструменты, детали и прочие приспособления для выживания. Вы видите, что на кодовом замке - находится блокиратор с таймером."

/obj/structure/closet/crate/secure/weapon/air/common/Initialize(mapload)
	. = ..()

	var/list/loot = list(
		/obj/item/stack/sheet/iron = 5,
		/obj/item/storage/toolbox = 1,
		/obj/item/flashlight = 1,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/servo = 2,
		/obj/item/stock_parts/subspace/ansible = 1,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/subspace/amplifier = 1,
		/obj/item/stock_parts/subspace/analyzer = 1,
		/obj/item/stock_parts/subspace/crystal = 1,
		/obj/item/stock_parts/card_reader = 1,
		/obj/item/stock_parts/water_recycler = 1,
		/obj/item/assembly/signaler = 1,
		/obj/item/analyzer = 1,
		/obj/item/stack/sheet/leather/five = 1,
		/obj/item/stack/sheet/plasteel = 3,
		/obj/item/stack/sheet/rglass = 3,
		/obj/item/stack/sheet/plastitaniumglass = 1,
		/obj/item/crafting_items/gunpowder = 5,
		/obj/item/crafting_items/gunpowder/medium = 3,
		/obj/item/crafting_items/gunpowder/high = 2,
		/obj/item/reagent_containers/cup/fuel_can = 1,
		/obj/item/stack/sheet/plastic/five = 1,
		/obj/item/screwdriver = 1,
		/obj/item/weldingtool = 1,
		/obj/item/wirecutters = 1,
		/obj/item/fuel_pellet = 1,
		/obj/item/circuitboard/machine/thermomachine = 1,
		/obj/item/spess_knife = 1,
		/obj/item/fireaxe = 1,
		/obj/item/radio/off = 1,
		/obj/item/flashlight/seclite = 1,
		/obj/item/storage/toolbox/emergency = 1,
		/obj/item/binoculars = 1,
		/obj/item/clothing/gloves/color/yellow = 1,
		/obj/item/food/rationpack = 1,
		/obj/item/multitool = 1,
		/obj/item/clothing/head/utility/radiation = 1,
		/obj/item/clothing/suit/utility/radiation = 1,
		/obj/item/clothing/mask/gas/welding = 1,
		/obj/item/tank/internals/oxygen = 1,
		/obj/item/clothing/glasses/hud/security/night = 1,
		/obj/item/storage/backpack/ert/extra_large = 1,
		/obj/item/storage/backpack/industrial = 1,
	)
	for(var/i in 1 to rand(3,9))
		var/path = pick(loot)
		new path(src)

/obj/structure/closet/crate/secure/weapon/air/medical
	name = "ящик медицинского снабжения"
	desc = "Ящик медицинского снабжения из гуманитарной капсулы. В таких обычно присылают медикаменты и медицинские устройства. Вы видите, что на кодовом замке - находится блокиратор с таймером."

/obj/structure/closet/crate/secure/weapon/air/medical/Initialize(mapload)
	. = ..()

	var/list/loot = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/clothing/neck/stethoscope = 1,
		/obj/item/autosurgeon = 1,
		/obj/item/organ/cyberimp/chest/pump = 1,
		/obj/item/organ/cyberimp/brain/anti_drop = 1,
		/obj/item/storage/box/bandages = 1,
		/obj/item/stack/medical/suture = 3,
		/obj/item/stack/medical/ointment = 3,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/reagent_containers/cup/bottle/epinephrine = 1,
		/obj/item/reagent_containers/syringe/antiviral = 1,
		/obj/item/reagent_containers/applicator/patch/libital = 3,
		/obj/item/reagent_containers/applicator/patch/aiuri = 3,
		/obj/item/reagent_containers/cup/bottle/morphine = 1,
		/obj/item/storage/medkit/regular = 1,
		/obj/item/reagent_containers/blood/o_minus = 1,
		/obj/item/storage/pill_bottle/penacid = 2,
		/obj/item/storage/medkit/o2 = 1,
		/obj/item/reagent_containers/hypospray/cmo = 1,
		/obj/item/storage/medkit/toxin = 1,
		/obj/item/storage/medkit/brute = 1,
		/obj/item/storage/medkit/fire = 1,
		/obj/item/reagent_containers/medigel/libital = 1,
		/obj/item/reagent_containers/medigel/aiuri = 1,
		/obj/item/storage/medkit/surgery = 1,
		/obj/item/storage/pill_bottle/mannitol = 1,
		/obj/item/reagent_containers/cup/bottle/potass_iodide = 1,
		/obj/item/storage/medkit/advanced = 1,
		/obj/item/storage/medkit/tactical = 1,
		/obj/item/reagent_containers/hypospray/combat = 1,
	)
	for(var/i in 1 to rand(3,9))
		var/path = pick(loot)
		new path(src)

/obj/structure/closet/crate/secure/weapon/air/ammunition
	name = "ящик аммуниции"
	desc = "Ящик с аммуницией из гуманитарной капсулы. В таких обычно находятся оружие, боеприпасы и различные оружейные приспособления. Вы видите, что на кодовом замке - находится блокиратор с таймером."

/obj/structure/closet/crate/secure/weapon/air/ammunition/Initialize(mapload)
	. = ..()

	var/list/loot = list(
		/obj/item/clothing/accessory/holster = 1,
		/obj/item/clothing/accessory/holster/tacticool = 1,
		/obj/item/clothing/accessory/ammo_vest/black = 1,
		/obj/item/storage/belt/military/army = 1,
		/obj/item/gun/ballistic/automatic/pistol/cm70 = 1,
		/obj/item/gun/ballistic/automatic/pistol/cm23 = 1,
		/obj/item/gun/ballistic/automatic/cm5 = 1,
		/obj/item/gun/ballistic/automatic/battle_rifle = 1,
		/obj/item/gun/ballistic/automatic/pistol/gp9/spec = 1,
		/obj/item/gun/ballistic/automatic/cm5/compact = 1,
		/obj/item/gun/ballistic/automatic/cm82 = 1,
		/obj/item/gun/ballistic/automatic/cm15 = 1,
		/obj/item/gun/ballistic/automatic/f4 = 1,
		/obj/item/gun/ballistic/automatic/f90 = 1,
		/obj/item/gun/ballistic/automatic/pistol/cm357 = 1,
		/obj/item/ammo_box/magazine/c9x25mm_pistol = 2,
		/obj/item/grenade/flashbang = 1,
		/obj/item/grenade/frag = 1,
		/obj/item/grenade/smokebomb = 1,
		/obj/item/ammo_box/magazine/c38 = 2,
		/obj/item/ammo_box/magazine/c45 = 2,
		/obj/item/ammo_box/magazine/cm5 = 2,
		/obj/item/ammo_box/magazine/m38 = 2,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/hp = 2,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo = 2,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/hp = 2,
		/obj/item/ammo_box/magazine/cm5/hp = 2,
		/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/ap = 2,
		/obj/item/ammo_box/magazine/cm15 = 2,
		/obj/item/ammo_box/magazine/c223 = 2,
		/obj/item/ammo_box/magazine/c45/hp = 2,
		/obj/item/ammo_box/magazine/c762x51mm = 2,
		/obj/item/ammo_box/magazine/c338 = 2,
		/obj/item/ammo_box/magazine/c357 = 2,
		/obj/item/ammo_box/magazine/cm5/ap = 2,
		/obj/item/ammo_box/magazine/c45/ap = 2,
		/obj/item/ammo_box/magazine/c38/ap = 2,
	)
	for(var/i in 1 to rand(3,9))
		var/path = pick(loot)
		new path(src)
