/proc/get_bluespace_beacon_random_spawn_tables()
	var/static/list/spawn_tables = list(
		"trash" = list(
			"weight" = 40,
			"items" = list(
				/obj/item/food/urinalcake = 10,
				/obj/item/bikehorn/rubberducky/plasticducky = 5,
				/obj/item/soap = 2,
				/obj/item/bikehorn/rubberducky = 7,
				/obj/item/coin/plastic = 7,
				/obj/item/slime_extract/grey = 1,
				/obj/item/storage/pill_bottle/lsd = 1,
				/obj/item/storage/pill_bottle/zoom = 1,
				/obj/item/storage/pill_bottle/happy = 1,
				/obj/item/storage/pill_bottle/potassiodide = 1,
				/obj/item/reagent_containers/hypospray/medipen/pumpup = 1,
				/obj/item/stack/medical/suture = 1,
				/obj/item/stack/medical/mesh = 1,
				/obj/item/grenade/iedcasing/spawned = 1,
				/obj/item/spear = 1,
				/obj/item/knife/shiv = 1,
				/obj/item/trash/candy = 1,
				/obj/item/trash/raisins = 1,
				/obj/item/trash/cheesie = 1,
				/obj/item/trash/chips = 1,
				/obj/item/trash/popcorn = 1,
			),
		),
		"hostiles" = list(
			"weight" = 8,
			"items" = list(
				/mob/living/basic/frog/crazy = 7,
				/mob/living/basic/lizard/big/gator = 1,
				/mob/living/basic/lizard/big/crocodile = 4,
				/mob/living/basic/blob_minion/spore = 10,
				/mob/living/carbon/human/species/monkey/angry = 2,
				/mob/living/basic/mining/legion/monkey = 1,
			),
		),
		"food" = list(
			"weight" = 22,
			"items" = list(
				/obj/item/food/grown/banana = 7,
				/obj/item/food/chips = 7,
				/obj/item/food/chips/shrimp = 5,
				/obj/item/food/candy = 6,
				/obj/item/food/candy_corn = 5,
				/obj/item/food/cookie = 6,
				/obj/item/food/cookie/chocolate_chip_cookie = 5,
				/obj/item/food/donut/plain = 6,
				/obj/item/food/donut/choco = 5,
				/obj/item/reagent_containers/cup/glass/waterbottle = 4,
			),
		),
		"peaceful_animals" = list(
			"weight" = 20,
			"items" = list(
				/mob/living/basic/junkermoff = 8,
				/mob/living/basic/pet/cat = 3,
				/mob/living/basic/pet/dog/corgi = 2,
				/mob/living/basic/possum = 2,
			),
		),
		"lego" = list(
			"weight" = 8,
			"items" = list(
				/obj/item/bodypart/leg/left = 1,
				/obj/item/bodypart/leg/right = 1,
				/obj/item/bodypart/arm/left = 1,
				/obj/item/bodypart/arm/right = 1,
				/obj/item/bodypart/chest = 1,
				/obj/item/bodypart/head = 1,
				/obj/item/bodypart/head/skeleton = 1,
				/obj/effect/gibspawner/generic = 1,
			),
		),
		"security_equipment" = list(
			"weight" = 3,
			"items" = list(
				/obj/item/shield/riot = 1,
				/obj/item/clothing/head/helmet/sec = 2,
				/obj/item/clothing/suit/armor/vest = 2,
				/obj/item/clothing/mask/gas/sechailer = 1,
				/obj/item/coin/antagtoken = 1,
				/obj/item/clothing/glasses = 1,
				/obj/item/restraints/handcuffs = 4,
				/obj/item/melee/baton/security/cattleprod = 3,
				/obj/item/restraints/handcuffs/cable/zipties = 7,
				/obj/item/restraints/handcuffs/cable/zipties/used = 10,
			),
		),
		"engineering_equipment" = list(
			"weight" = 7,
			"items" = list(
				/obj/item/clothing/suit/hazardvest = 4,
				/obj/item/clothing/glasses/meson = 3,
				/obj/item/clothing/head/utility/hardhat/welding/up = 1,
				/obj/item/tank/internals/emergency_oxygen/engi/empty = 3,
				/obj/item/tank/internals/emergency_oxygen/double/empty = 1,
				/obj/item/storage/belt/utility = 2,
				/obj/item/storage/belt/utility/full/engi = 1,
				/obj/item/screwdriver = 7,
				/obj/item/wrench = 7,
				/obj/item/weldingtool = 7,
				/obj/item/crowbar = 7,
				/obj/item/wirecutters = 7,
				/obj/item/multitool = 3,
				/obj/item/t_scanner = 7,
				/obj/item/stack/cable_coil = 10,
			),
		),
		"rare_items" = list(
			"weight" = 1,
			"items" = list(
				/obj/item/melee/baton/telescopic = 1,
				/obj/item/dice/d20 = 1,
				/obj/item/dice/d20/fate/stealth/cursed/one_use = 1,
				/obj/item/dice/d20/fate/stealth/one_use = 1,
			),
		),
	)
	return spawn_tables

/proc/pick_bluespace_beacon_random_spawn_type(list/spawn_tables = null)
	if(!length(spawn_tables))
		spawn_tables = get_bluespace_beacon_random_spawn_tables()

	var/list/subtable_weights = list()
	for(var/subtable_name in spawn_tables)
		var/list/subtable_data = spawn_tables[subtable_name]
		if(!islist(subtable_data))
			continue
		subtable_weights[subtable_name] = max(1, subtable_data["weight"] || 1)

	if(!length(subtable_weights))
		return null

	var/subtable_name = pick_weight(subtable_weights)
	var/list/subtable_data = spawn_tables[subtable_name]
	if(!islist(subtable_data))
		return null

	var/list/items = subtable_data["items"]
	if(!length(items))
		return null

	return pick_weight(items)

