/obj/item/card/id/advanced/bountyhunter/vishibala
	assignment = "Вышибала"

/obj/item/card/id/advanced/bountyhunter/chuk
	assignment = "Чук"

/obj/item/card/id/advanced/bountyhunter/gek
	assignment = "Гек"

/obj/item/clothing/under/goon
	name = "Свитер Вышибалы"
	desc = "Тёмный, полосатый свитер, принадлежавший Вышибале. Пропитан запахом курева и дешёвого виски."
	icon = 'modular_bandastation/voyaker_events/icons/mafia_goons.dmi'
	icon_state = "bandit_icon"
	worn_icon = 'modular_bandastation/voyaker_events/icons/mafia_goons.dmi'
	worn_icon_state = "bandit_onmob"

/obj/item/clothing/head/goon_cap
	name = "Кепка Вышибалы"
	desc = "Поношенная, пошарпанная коричневая кепка с козырьком, принадлежавшая Вышибале. В такой обычно выходили на уличные разборки."
	icon = 'modular_bandastation/voyaker_events/icons/mafia_goons.dmi'
	icon_state = "flatcap_icon"
	worn_icon = 'modular_bandastation/voyaker_events/icons/mafia_goons.dmi'
	worn_icon_state = "flatcap_onmob"

/obj/effect/mob_spawn/corpse/human/tsf
	name = "TSF Marine Body"
	outfit = /datum/outfit/tsf/marine_unarmed/dead
	brute_damage = 100
	burn_damage = 100
	mob_species = /datum/species/skeleton
	mob_name = "Неизвестный"

/obj/effect/mob_spawn/corpse/human/tsf/marine
	name = "TSF Marine Body"
	outfit = /datum/outfit/tsf/marine/dead

/obj/effect/mob_spawn/corpse/human/tsf/marine_officer
	name = "TSF Marine Squad Leader"
	outfit = /datum/outfit/tsf/marine/officer/dead

/obj/effect/mob_spawn/corpse/human/tsf/marsoc
	name = "TSF MARSOC"
	outfit = /datum/outfit/tsf/marsoc_unarmed/dead

/obj/effect/mob_spawn/corpse/human/ussp
	name = "USSP Ryadovoy"
	outfit = /datum/outfit/ussp/soldier_unarmed/dead
	brute_damage = 100
	burn_damage = 100
	mob_species = /datum/species/skeleton
	mob_name = "Неизвестный"

/obj/effect/mob_spawn/corpse/human/ussp/ryadovoy
	name = "USSP Ryadovoy"
	outfit = /datum/outfit/ussp/military/dead

/obj/effect/mob_spawn/corpse/human/ussp/spetsnaz
	name = "USSP SPETSNAZ"
	outfit = /datum/outfit/ussp/spetsnaz_unarmed/dead

/obj/effect/mob_spawn/corpse/human/ussp/officer
	name = "USSP Officer"
	outfit = /datum/outfit/ussp/ussp_officer/dead

/obj/effect/mob_spawn/corpse/human/irs_agent
	name = "IRS Agent"
	outfit = /datum/outfit/pirate/irs
	brute_damage = 100
	burn_damage = 100
	mob_species = /datum/species/skeleton
	mob_name = "Неизвестный"

/obj/effect/mob_spawn/corpse/human/special(mob/living/carbon/human/spawned_human, mob/mob_possessor, apply_prefs)
	spawned_human.ignore_raid_death = TRUE
	. = ..()

/datum/outfit/tsf/marine_unarmed/dead
	name = "TSF - Dead Marine (Unarmed)"
	back = null
	backpack_contents = null

/datum/outfit/tsf/marine/dead
	name = "TSF - Dead and Looted Marine Rifleman"
	suit = /obj/item/clothing/suit/armor/vest/marine/sulaco
	suit_store = null
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf,
		/obj/item/storage/medkit/regular,
		/obj/item/clothing/head/beret/tsf_marine,
	)
	head = /obj/item/clothing/head/helmet/marine/sulaco
	belt = /obj/item/storage/belt/military/army

/datum/outfit/tsf/marine/officer/dead
	name = "TSF - Dead and Looted Marine Officer"
	suit = /obj/item/clothing/suit/armor/vest/marine/sulaco
	suit_store = null
	back = /obj/item/storage/backpack/tsf
	backpack_contents = list(
		/obj/item/storage/box/survival/tsf/officer,
		/obj/item/clothing/head/beret/tsf_marine_officer,
	)
	belt = /obj/item/storage/belt/military/army
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/tsf
	neck = /obj/item/binoculars
	head = /obj/item/clothing/head/helmet/marine/sulaco

/datum/outfit/tsf/marsoc_unarmed/dead
	name = "TSF - Dead MARSOC (Unarmed)"
	back = null
	backpack_contents = null
	belt = /obj/item/storage/belt/military/army

/datum/outfit/ussp/soldier_unarmed/dead
	name = "USSP - Dead Red Army Ryadovoy (Unarmed)"
	back = null
	backpack_contents = null

/datum/outfit/ussp/military/dead
	name = "USSP - Dead Red Army Ryadovoy"
	suit = /obj/item/clothing/suit/armor/vest/marine/security/ussp_security/broken
	suit_store = null
	back = /obj/item/storage/backpack/ussp
	backpack_contents = list(
		/obj/item/storage/box/survival/ussp,
		/obj/item/storage/medkit/emergency,
	)
	head = /obj/item/clothing/head/helmet/marine/security/ussp_kaska/broken
	belt = /obj/item/storage/belt/military/army/ussp

/obj/item/clothing/suit/armor/vest/marine/security/ussp_security/broken
	armor_type = /datum/armor/derelict_marine

/obj/item/clothing/head/helmet/marine/security/ussp_kaska/broken
	armor_type = /datum/armor/derelict_marine

/datum/outfit/ussp/spetsnaz_unarmed/dead
	name = "USSP - Dead SPETSNAZ (Unarmed)"
	back = null
	backpack_contents = null
	belt = /obj/item/storage/belt/military/army/ussp

/datum/outfit/ussp/ussp_officer/dead
	name = "USSP - Dead Red Army Officer (Unarmed)"
	belt = /obj/item/storage/belt/military/army/ussp

/datum/outfit/ussp/vishibala
	name = "Boss - Vishibala (AMK)"
	id = /obj/item/card/id/advanced/bountyhunter/vishibala
	id_trim = /datum/id_trim/bounty_hunter
	uniform = /obj/item/clothing/under/syndicate/tacticool
	suit = /obj/item/clothing/suit/armor/vest/marine/pmc
	shoes = /obj/item/clothing/shoes/sneakers/black
	head = /obj/item/clothing/head/goon_cap
	ears = /obj/item/radio/headset/headset_cargo
	belt = /obj/item/storage/belt/military/army/ussp/full_autorifle
	accessory = /obj/item/clothing/accessory/ammo_vest/black
	gloves = /obj/item/clothing/gloves/fingerless/biker_gloves
	l_pocket = /obj/item/knife/combat
	r_pocket = /obj/item/grenade/frag
	r_hand = /obj/item/gun/ballistic/automatic/sabel/auto/upgraded

/datum/outfit/ussp/vishibala/baseball_bat
	name = "Boss - Vishibala (Baseball Bat)"
	r_hand = /obj/item/melee/baseball_bat/ablative
	belt = /obj/item/gun/ballistic/automatic/mini_uzi
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/ammo_box/magazine/uzim9mm = 5,
		/obj/item/reagent_containers/cup/glass/bottle/vodka,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold,
		/obj/item/lighter/skull,
		/obj/item/keycard/nt_labs,
	)

/datum/outfit/ussp/vishibala/shotgun
	name = "Boss - Vishibala (Shotgun)"
	r_hand = /obj/item/gun/ballistic/shotgun/automatic/combat
	belt = 	/obj/item/storage/belt/bandolier
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(
		/obj/item/ammo_box/c12ga/dragonsbreath,
		/obj/item/ammo_box/c12ga/milspec,
		/obj/item/ammo_box/c12ga/slug/milspec,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold,
		/obj/item/lighter/skull,
		/obj/item/clothing/accessory/medal,
		/obj/item/keycard/forest_bunker,
	)
	l_pocket = /obj/item/knife/combat
	r_pocket = /obj/item/grenade/frag

/datum/outfit/ussp/geck
	name = "Boss - Geck (Shotgun)"
	id = /obj/item/card/id/advanced/bountyhunter/gek
	id_trim = /datum/id_trim/bounty_hunter
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/armor/swat/ussp_heavy
	back = /obj/item/storage/backpack/satchel/explorer
	backpack_contents = list(
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/ammo_box/magazine/m12g/slug = 2,
		/obj/item/ammo_box/magazine/m12g/dragon,
		/obj/item/ammo_box/magazine/m12g = 2,
		/obj/item/ammo_box/magazine/m12g/flechette,
		/obj/item/documents/nanotrasen,
	)
	shoes = /obj/item/clothing/shoes/russian
	head = /obj/item/clothing/head/helmet/toggleable/riot/ussp_heavy
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	belt = /obj/item/storage/belt/military/army/ussp/full
	mask = /obj/item/clothing/mask/gas
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	l_pocket = /obj/item/grenade/frag
	r_pocket = /obj/item/grenade/frag
	r_hand = /obj/item/gun/ballistic/shotgun/bulldog/unrestricted

/datum/outfit/ussp/geck/machinegun
	name = "Boss - Geck (Machinegun)"
	backpack_contents = list(
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/knife/combat,
		/obj/item/documents/syndicate/red,
		/obj/item/keycard/cafeteria/administration,
	)
	belt = /obj/item/storage/belt/military/army/ussp/full_machinegun_pmk
	r_hand = /obj/item/gun/ballistic/automatic/pmk

/datum/outfit/ussp/chuck
	name = "Boss - Chuck (GL China Lake)"
	id = /obj/item/card/id/advanced/bountyhunter
	id_trim = /datum/id_trim/bounty_hunter
	uniform = /obj/item/clothing/under/pants/camo
	suit = /obj/item/clothing/suit/armor/vest/marine/pmc
	back = /obj/item/storage/backpack/satchel/explorer
	backpack_contents = list(
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/storage/fancy/a40mm_box/frag,
		/obj/item/storage/fancy/a40mm_box/hedp,
		/obj/item/storage/fancy/a40mm_box/weak,
		/obj/item/storage/fancy/a40mm_box/incendiary,
		/obj/item/stack/sheet/mineral/gold = 3,
		/obj/item/keycard/blue/mine_exit,
	)
	shoes = /obj/item/clothing/shoes/russian
	head = /obj/item/clothing/head/helmet/toggleable/riot/ussp_riot
	ears = /obj/item/radio/headset/heads/captain/alt/ussp
	belt = 	/obj/item/storage/belt/bandolier
	mask = /obj/item/clothing/mask/gas
	gloves = /obj/item/clothing/gloves/tackler/combat/insulated
	l_pocket = /obj/item/grenade/frag
	r_pocket = /obj/item/grenade/frag
	r_hand = /obj/item/gun/ballistic/shotgun/china_lake

/datum/outfit/ussp/chuck/shotgun
	name = "Boss - Chuck (Shotgun)"
	backpack_contents = list(
		/obj/item/storage/medkit/tactical_lite,
		/obj/item/ammo_box/c12ga/dragonsbreath,
		/obj/item/ammo_box/c12ga/milspec,
		/obj/item/ammo_box/c12ga/slug/milspec,
		/obj/item/ammo_box/c12ga/flechette,
		/obj/item/ammo_box/c12ga/incendiary,
		/obj/item/disk/computer/virus,
		/obj/item/documents,
	)
	r_hand = /obj/item/gun/ballistic/shotgun/riot/renoster/black
