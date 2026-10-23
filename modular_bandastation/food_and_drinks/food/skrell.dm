//Skrell Foods, for skrell

// Breads & Bakery

// 2. Plump Helmet Rice Flatbread
/obj/item/food/plump_rice_flatbread
	name = "plump helmet rice flatbread"
	desc = "A traditional porous flatbread infused with plump helmet mushrooms and soymilk. Highly aromatic and satisfying."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "plump_rice_flatbread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/soymilk = 5,
	)
	tastes = list("bread" = 2, "mushroom" = 2, "soy" = 1)
	foodtypes = GRAIN | VEGETABLES | MUSHROOM
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_NORMAL

// 3. Fly Amanita Bun
/obj/item/food/fly_amanita_bun
	name = "fly amanita bun"
	desc = "A fluffy bun baked with fresh fly amanita. Highly toxic and hallucinogenic to most species, but a delicious staple for Skrell."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "fly_amanita_bun"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/toxin/amatoxin = 2,
	)
	tastes = list("bread" = 2, "mushroom" = 1)
	foodtypes = GRAIN | MUSHROOM | TOXIC
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/fly_amanita_bun/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/fly_amanita_bun_slice, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = SFX_KNIFE_SLICE)

/obj/item/food/fly_amanita_bun_slice
	name = "fly amanita bun slice"
	desc = "A soft, toxin-speckled slice of fly amanita bun."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "fly_amanita_bun_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/toxin/amatoxin = 0.5,
	)
	tastes = list("bread" = 2, "mushroom" = 1)
	foodtypes = GRAIN | MUSHROOM | TOXIC
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY


// 4. Ximikoa Rice Roll
/obj/item/food/ximikoa_roll
	name = "ximikoa rice roll"
	desc = "A tender, sweet-tasting baked rice roll enriched with ximikoa and flour. Packed with rich plant proteins."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "ximikoa_roll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/nutriment/protein = 4,
	)
	tastes = list("sweet rice" = 2, "rich cocoa" = 2)
	foodtypes = GRAIN | FRUIT | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL


// 5. Capsaicin Fungal Focaccia
/obj/item/food/capsaicin_focaccia
	name = "capsaicin fungal focaccia"
	desc = "A fiery, seasoned flatbread loaded with embershrooms and spicy sauce. Skrell highly appreciate its stimulating heat."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "capsaicin_focaccia"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/capsaicin = 5,
	)
	tastes = list("scorching heat" = 3, "crisp crust" = 2, "mushroom" = 1)
	foodtypes = VEGETABLES|GRAIN|MUSHROOM
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL


// SOUPS & STEWS

// 6. Qerrbalak Fungal Stew
/obj/item/food/soup/qerrbalak_stew
	name = "Qerrbalak fungal stew"
	desc = "A traditional everyday hearty stew eaten across Qerrbalak. Thickened with flour and filled with aromatic mushrooms."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "qerrbalak_stew"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("mushroom" = 2, "earthy broth" = 1)
	foodtypes = GRAIN | VEGETABLES | MUSHROOM
	trash_type = /obj/item/reagent_containers/cup/bowl
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 7. Glowshroom Chowder
/obj/item/food/soup/glowshroom_chowder
	name = "glowshroom chowder"
	desc = "A creamy, glowing soup made from radioactive glowshrooms and soymilk. Provides soothing nourishment for Skrell."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "glowshroom_chowder"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/soymilk = 6,
		/datum/reagent/uranium/radium = 2,
		/datum/reagent/phosphorus = 2,
	)
	tastes = list("creamy mushrooms" = 2, "tingling radiation" = 1)
	foodtypes = VEGETABLES | MUSHROOM | TOXIC
	trash_type = /obj/item/reagent_containers/cup/bowl
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 8. Destroying Angel Bisque
/obj/item/food/soup/destroying_angel_bisque
	name = "destroying angel bisque"
	desc = "A deadly white bisque infused with destroying angel mushroom. A prized delicacy for Skrell, but lethal to other species."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "angel_bisque"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/toxin/amatoxin = 4,
		/datum/reagent/toxin/amanitin = 4,
		/datum/reagent/consumable/soysauce = 2,
	)
	tastes = list("intense umami" = 3, "numbing toxin" = 1)
	foodtypes = VEGETABLES | MUSHROOM | TOXIC
	trash_type = /obj/item/reagent_containers/cup/bowl
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_EXOTIC

// 9. Kenin Tofu Soup
/obj/item/food/soup/kenin_tofu_soup
	name = "Kenin tofu soup"
	desc = "A soothing gourmet soup loaded with tofu cubes and reishi mushrooms. Provides pleasant pain relief."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "kenin_soup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/medicine/morphine = 3,
		/datum/reagent/medicine/c2/multiver = 2,
	)
	tastes = list("soft tofu" = 2, "soothing bitterness" = 2)
	foodtypes = VEGETABLES | MUSHROOM
	trash_type = /obj/item/reagent_containers/cup/bowl
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 10. Embershroom Lava Stew
/obj/item/food/soup/embershroom_lava_stew
	name = "embershroom lava stew"
	desc = "A simmering spicy red broth made from Lavaland embershrooms and fire blossoms. Keeps you warm in freezing environments."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "embershroom_stew"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/capsaicin = 4,
	)
	tastes = list("blazing heat" = 3, "earthy sulfur" = 1)
	foodtypes = VEGETABLES | MUSHROOM
	trash_type = /obj/item/reagent_containers/cup/bowl
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 11. Eden's Gaia Noodle Soup
/obj/item/food/soup/edens_gaia_noodles
	name = "Eden's Gaia noodle soup"
	desc = "A sacred glowing bowl of noodles floating in an Ambrosia Gaia broth. Induces supreme tranquility and mental harmony."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "gaia_noodle_soup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/medicine/omnizine = 4,
	)
	tastes = list("divine sweetness" = 2, "tender noodles" = 2, "pure peace" = 1)
	foodtypes = VEGETABLES | GRAIN
	trash_type = /obj/item/reagent_containers/cup/bowl
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_4
	venue_value = FOOD_PRICE_LEGENDARY

// 12. Puffball Gas Soup
/obj/item/food/soup/puffball_gas_soup
	name = "puffball gas soup"
	desc = "A fizzing, misty soup brewed from odious puffball and fairy grass. Releases mild hallucinogenic spores as you consume it."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "puffball_soup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/toxin/spore = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("fizzy vapor" = 2, "sweet spores" = 1)
	foodtypes = VEGETABLES | MUSHROOM | TOXIC
	trash_type = /obj/item/reagent_containers/cup/bowl
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_EXOTIC

// MAIN DISHES

// 13. Plump Fungal Roast
/obj/item/food/raw_plump_fungal_roast
	name = "raw plump fungal roast"
	desc = "A thick cut of raw plump helmet mushroom marinated in soy sauce and dusted with rice flour. Ready to be grilled or baked."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "raw_plump_fungal_roast"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/soysauce = 2,
	)
	tastes = list("raw mushroom" = 3, "savory soy" = 2)
	foodtypes = VEGETABLES | MUSHROOM | RAW
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/raw_plump_fungal_roast/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/plump_fungal_roast, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/food/raw_plump_fungal_roast/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/plump_fungal_roast, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

// 13.1
/obj/item/food/plump_fungal_roast
	name = "plump fungal roast"
	desc = "A thick, juicy steak cut from a plump helmet mushroom, seasoned with soy sauce and rice flour, grilled to perfection. A hearty staple of everyday Skrellian dining."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "plump_fungal_roast"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/soysauce = 2,
	)
	tastes = list("juicy mushroom" = 3, "savory soy" = 2)
	foodtypes = VEGETABLES | MUSHROOM | GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 14. Crispy Walking Mushroom Skewers
/obj/item/food/kebab/walking_mushroom_skewer
	name = "crispy walking mushroom skewer"
	desc = "Tender legs of a walking mushroom skewered and crisped in oil. Highly popular street food on Qerrbalak."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "walking_skewer"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/fat/oil = 2,
		/datum/reagent/consumable/salt = 1,
	)
	tastes = list("crispy mushroom" = 3, "salted oil" = 1)
	foodtypes = VEGETABLES | MUSHROOM | FRIED
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_NORMAL

// 15. Psychedelic Tempeh Stir-fry
/obj/item/food/psychedelic_tempeh
	name = "psychedelic tempeh stir-fry"
	desc = "Fermented soy tempeh stir-fried with liberty-cap mushrooms and rich soy dip. Causes gentle euphoria in Skrell and intense trips in humans."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "psychedelic_tempeh"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/protein = 6,
	)
	tastes = list("nutty tempeh" = 2, "tingling mushrooms" = 2, "soy" = 1)
	foodtypes = VEGETABLES | MUSHROOM | GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_EXOTIC

// 16. Steel Cap Dumplings
/obj/item/food/steelcap_dumplings
	name = "steel cap dumplings"
	desc = "Dense rice dumplings stuffed with shredded steel cap mushrooms and cocoa. Rich in dietary iron and cellulose."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "steelcap_dumplings"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/iron = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("earthy dough" = 2, "metallic sweetness" = 1, "sugar" = 1)
	foodtypes = GRAIN | MUSHROOM | SUGAR | FRUIT
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 17. Skrell Fungal Ramen
/obj/item/food/skrell_fungal_ramen
	name = "Skrell fungal ramen"
	desc = "Steaming bowl of rice noodles served in a concentrated broth of plump helmets, chanterelles, and aged soy sauce."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "skrell_ramen"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/soysauce = 3,
	)
	tastes = list("savory broth" = 3, "tender noodles" = 2, "mushrooms" = 2)
	foodtypes = GRAIN | VEGETABLES | MUSHROOM
	trash_type = /obj/item/reagent_containers/cup/bowl
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 18. Seraka & Flame Roast
/obj/item/food/seraka_flame_roast
	name = "seraka flame roast"
	desc = "A searingly spicy dish of roasted seraka mycelium and fruiting cactus glazed with capsaicin oil."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "seraka_roast"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/capsaicin = 5,
		/datum/reagent/consumable/nutriment/vitamin = 3,
	)
	tastes = list("cactus tang" = 2, "scorching heat" = 3, "mushroom" = 1)
	foodtypes = VEGETABLES | FRUIT | MUSHROOM
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 19. Baked Eggplant Skrell Cheetal
/obj/item/food/skrell_cheetal_eggplant
	name = "baked eggplant Skrell cheetal"
	desc = "An eggplant carved into the majestic shape of a Skrellian head-tentacle, stuffed with tofu and plump helmets, garnished with sweet plums. A supreme symbol of hospitality."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "skrell_cheetal"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/soysauce = 2,
	)
	tastes = list("tender eggplant" = 2, "sweet plum" = 2, "savory tofu" = 2)
	foodtypes = VEGETABLES | FRUIT | MUSHROOM
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_4
	venue_value = FOOD_PRICE_EXOTIC

// 20. Mindbreaker Fungal Bake
/obj/item/food/mindbreaker_fungal_bake
	name = "mindbreaker fungal bake"
	desc = "A trippy baked pie with glowing glowcaps, jupiter cups, and rainbow weed. Sends the mind into transcendent kaleidoscopic bliss."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "mindbreaker_bake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/toxin/mindbreaker = 4,
		/datum/reagent/medicine/psicodine = 3,
	)
	tastes = list("electric tingling" = 3, "sweet weed" = 2, "dough" = 1)
	foodtypes = VEGETABLES | GRAIN | TOXIC | MUSHROOM
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_4
	venue_value = FOOD_PRICE_EXOTIC

/obj/item/food/mindbreaker_fungal_bake/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/mindbreaker_fungal_bake_slice, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = SFX_KNIFE_SLICE)

/obj/item/food/mindbreaker_fungal_bake_slice
	name = "mindbreaker fungal bake slice"
	desc = "A glowing, fragrant slice of psychedelic fungal bake."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "mindbreaker_bake_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/toxin/mindbreaker = 1,
		/datum/reagent/medicine/psicodine = 0.75,
	)
	tastes = list("electric tingling" = 3, "sweet weed" = 2, "dough" = 1)
	foodtypes = GRAIN | MUSHROOM | TOXIC
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY

// 21. Qerrbalak Eclipse Stew
/obj/item/food/soup/qerrbalak_eclipse_stew
	name = "Qerrbalak eclipse stew"
	desc = "A pitch-black psychoactive stew brewed from omega weed, liberty-caps, and shadowshrooms with a tangy pineapple accent. Extremely potent."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "eclipse_stew"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/toxin = 8,
		/datum/reagent/uranium/radium = 2,
	)
	tastes = list("tangy pineapple" = 2, "numbing shadows" = 3, "pure trip" = 2)
	foodtypes = VEGETABLES | MUSHROOM | FRUIT | TOXIC
	trash_type = /obj/item/reagent_containers/cup/bowl
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_4
	venue_value = FOOD_PRICE_EXOTIC

// 22. Crimson Fungal Mix
/obj/item/food/crimson_fungal_mix
	name = "crimson fungal mix"
	desc = "A sauté of bright red and golden fungi. Radiates a spicy, mind-altering aroma."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "crimson_mix"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/toxin/amatoxin = 2,
	)
	tastes = list("peppery mushrooms" = 2, "wild heat" = 1)
	foodtypes = VEGETABLES | MUSHROOM | TOXIC
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

// Twilight Fungal Paste
/obj/item/food/twilight_fungal_paste
	name = "twilight fungal paste"
	desc = "A dark indigo paste made from deep cavern mushrooms, berries, and grapes."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "twilight_paste"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/uranium/radium = 1,
	)
	tastes = list("sweet berries" = 2, "earthy mushrooms" = 2)
	foodtypes = VEGETABLES | MUSHROOM | FRUIT
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

// Luminous White Salad
/obj/item/food/luminous_white_salad
	name = "luminous white salad"
	desc = "A zesty glowing mix of bioluminescent mushrooms and herbs tossed in fresh lime juice."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "luminous_salad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/toxin/amanitin = 2,
	)
	tastes = list("lime zest" = 2, "luminescent crunch" = 2)
	foodtypes = VEGETABLES | MUSHROOM | FRUIT | TOXIC
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

// Grand Qerrbalak Mycelial Roast
/obj/item/food/grand_mycelial_roast
	name = "Grand Qerrbalak Mycelial Roast"
	desc = "The undisputed pinnacle of Skrellian culinary mastery. Three refined fungal essences braised inside a sacred Eden's Gaia noodle soup. A masterpiece of color, taste, and bio-harmony."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "mycelial_roast"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 40,
		/datum/reagent/consumable/nutriment/vitamin = 30,
		/datum/reagent/consumable/qerr_primordial_nectar = 20,
		/datum/reagent/medicine/omnizine = 12,
	)
	tastes = list("infinite fungal harmony" = 4, "divine nectar" = 3, "pure euphoria" = 2)
	foodtypes = VEGETABLES | MUSHROOM | GRAIN | FRUIT | TOXIC
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_5
	venue_value = FOOD_PRICE_LEGENDARY

/obj/item/food/grand_mycelial_roast/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/mycelial_roast_slice, 6, 5 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = SFX_KNIFE_SLICE)

/obj/item/food/grand_mycelial_roast/on_craft_completion(list/components, datum/crafting_recipe/current_recipe, atom/crafter)
	. = ..()
	if(reagents)
		reagents.maximum_volume = max(reagents.maximum_volume, 150)
		reagents.add_reagent(/datum/reagent/consumable/qerr_primordial_nectar, 30)

/obj/item/food/mycelial_roast_slice
	name = "mycelial roast slice"
	desc = "A bite-sized glowing slice of psychedelic fungal bake."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "mycelial_roast_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/qerr_primordial_nectar = 4,
		/datum/reagent/medicine/omnizine = 3,
	)
	tastes = list("electric tingling" = 3, "sweet weed" = 2, "dough" = 1)
	foodtypes = GRAIN | MUSHROOM | FRUIT
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY

// SALADS & APPETIZERS

// 26. Coniine Berry Bowl
/obj/item/food/salad/coniine_berry
	name = "coniine berry bowl"
	desc = "A salad loaded with death berries, aloe, and bungo fruit. The concentrated neurotoxins serve as a stimulating tonic for Skrell, but are lethal to non-immune species."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "coniine_salad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/toxin/coniine = 3,
		/datum/reagent/toxin/bungotoxin = 2,
	)
	tastes = list("tart nightshade" = 2, "soothing aloe" = 1, "numbing cold" = 2)
	foodtypes = VEGETABLES | FRUIT | TOXIC
	trash_type = /obj/item/reagent_containers/cup/bowl
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_EXOTIC

// 27. Soy Chips & Fungal Dip
/obj/item/food/soy_fungal_chips
	name = "soy chips with fungal dip"
	desc = "Crispy slices cut from a roasted plump helmet served alongside a creamy bowl of soy dip. A quintessential lab-break snack."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "soy_chips"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/soysauce = 2,
	)
	tastes = list("crunchy roasted mushroom" = 3, "savory soy dip" = 2)
	foodtypes = VEGETABLES | MUSHROOM | GRAIN
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 28. Moonflower & Plump Bowl
/obj/item/food/salad/moonflower_plump
	name = "moonflower and plump salad"
	desc = "A cooling salad prepared with sliced cucumbers, fresh plump helmets, and moonflower petals. The trace herbal moonshine is safely mellowed by the fungal base."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "moonflower_salad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/ethanol/moonshine = 1,
		/datum/reagent/medicine/c2/multiver = 1,
	)
	tastes = list("crisp cucumber" = 2, "glowing floral petal" = 2, "earthy mushroom" = 1)
	foodtypes = VEGETABLES | MUSHROOM
	trash_type = /obj/item/reagent_containers/cup/bowl
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// BURGERS, SANDWICHES & WRAPS

// 29. Skrellian Tofu Burger
/obj/item/food/burger/skrell_tofu
	name = "Skrellian tofu burger"
	desc = "A wholesome vegetarian burger made with a tender tofu patty, sliced plump helmet, and rich soy dip in a soft rice bun."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "skrell_burger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/soysauce = 2,
	)
	tastes = list("rice bun" = 2, "savory tofu" = 2, "juicy mushroom" = 2)
	foodtypes = GRAIN | VEGETABLES | MUSHROOM | BREAKFAST
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 30. Qerr Fungal Taco
/obj/item/food/taco/qerr_fungal
	name = "Qerr fungal taco"
	desc = "A crunchy corn taco shell packed with sauteed chanterelles and seasoned with garlic and savory soy sauce."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "qerr_taco"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/garlic = 2,
		/datum/reagent/consumable/soysauce = 2,
	)
	tastes = list("crispy shell" = 2, "golden chanterelles" = 2, "garlic" = 1)
	foodtypes = GRAIN | VEGETABLES | MUSHROOM
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 31. Destroying Angel Slider
/obj/item/food/burger/destroying_angel
	name = "destroying angel slider"
	desc = "A terrifying burger packed with a grilled destroying angel mushroom, crispy onion rings, and tofu. Highly lethal to non-Skrell!"
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "angel_burger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/toxin/amatoxin = 4,
		/datum/reagent/toxin/amanitin = 4,
	)
	tastes = list("rice bun" = 2, "crispy onion" = 2, "intense numbing mushroom" = 3)
	foodtypes = GRAIN | VEGETABLES | MUSHROOM | TOXIC | BREAKFAST
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_4
	venue_value = FOOD_PRICE_EXOTIC

// 32. Rice Cheese Sandwich
/obj/item/food/sandwich/rice_cheese
	name = "rice cheese sandwich"
	desc = "A simple, nourishing sandwich made of cheese between two slices of soft rice bread. Can be grilled to perfection."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "rice_cheese_sandwich"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("rice bread" = 2, "cheese" = 2)
	foodtypes = GRAIN | DAIRY | BREAKFAST
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/sandwich/rice_cheese/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/sandwich/grilled_rice_cheese, rand(20 SECONDS, 35 SECONDS), TRUE)

// 32.1. Grilled Rice Cheese Sandwich
/obj/item/food/sandwich/grilled_rice_cheese
	name = "grilled rice cheese sandwich"
	desc = "A warm, golden-brown toasted rice sandwich with melted gooey cheese."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "grilled_rice_cheese"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/carbon = 2,
	)
	tastes = list("crisp toast" = 2, "melted cheese" = 3)
	foodtypes = GRAIN | DAIRY
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 33. Fairy Grass & Glow Roll
/obj/item/food/fairy_glow_roll
	name = "fairy glow roll"
	desc = "A glowing wrap of nizaya dough stuffed with luminous fairy grass and a sliced glowcap. Causes gentle relaxation and sparkles in the dark."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "fairy_glow_roll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/teslium = 1,
	)
	tastes = list("chewy nizaya" = 2, "sparkling fairy flora" = 2, "electric tingle" = 1)
	foodtypes = GRAIN | VEGETABLES | MUSHROOM
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// DESSERTS, CAKES & ROLLS

// 34. Citrus Coffee Cake
/obj/item/food/cake/skrell_citrus_cake
	name = "citrus coffee cake"
	desc = "A fragrant layered cake infused with fresh orange zest and dark Arabica coffee. A revitalizing dessert popular during diplomatic galas."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "citrus_coffee_cake"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/sugar = 6,
		/datum/reagent/consumable/orangejuice = 4,
		/datum/reagent/consumable/coffee = 4,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("sweet cake" = 2, "zesty citrus" = 2, "aromatic coffee" = 1)
	foodtypes = GRAIN | FRUIT | DAIRY | SUGAR | ORANGES
	slice_type = /obj/item/food/cakeslice/skrell_citrus_slice
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/cake/skrell_citrus_cake/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/skrell_citrus_slice, 6, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = SFX_KNIFE_SLICE)

/obj/item/food/cakeslice/skrell_citrus_slice
	name = "citrus coffee cake slice"
	desc = "A slice of fragrant citrus and coffee infused cake."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "citrus_coffee_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2.4,
		/datum/reagent/consumable/sugar = 1.2,
		/datum/reagent/consumable/orangejuice = 0.8,
		/datum/reagent/consumable/coffee = 0.8,
		/datum/reagent/consumable/nutriment/vitamin = 0.8,
	)
	tastes = list("sweet cake" = 2, "zesty citrus" = 2, "coffee" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY

// 35. Blue Cherry & Moonflower cake
/obj/item/food/cake/blue_cherry_moon_cake
	name = "blue cherry moonflower cake"
	desc = "A stunning cake baked with glowing blue cherries, ximikoa cocoa, and moonflower petals. Radiates a soothing, chilled blue shimmer."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "blue_cherry_moon"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/cherryjelly = 4,
		/datum/reagent/consumable/ethanol/moonshine = 1, // М'яка безпечна доза
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("sweet blue cherries" = 3, "crisp crust" = 2, "cocoa" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR | VEGETABLES | DAIRY
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/cake/blue_cherry_moon_cake/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/blue_cherry_slice, 6, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = SFX_KNIFE_SLICE)

/obj/item/food/cakeslice/blue_cherry_slice
	name = "blue cherry moonflower cake slice"
	desc = "A slice of glowing blue cherry cake."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "blue_cherry_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/sugar = 1,
		/datum/reagent/consumable/cherryjelly = 0.8,
	)
	tastes = list("sweet blue cherries" = 3, "crisp crust" = 2)
	foodtypes = GRAIN | FRUIT | SUGAR
	food_flags = FOOD_FINGER_FOOD

// 36. Liberty Fungus Donuts
/obj/item/food/donut/liberty_fungus
	name = "liberty fungus donut"
	desc = "A deep-fried sweet pastry ring infused with a controlled extract of liberty-cap mushroom. Lifts the spirits and dissolves laboratory stress."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "liberty_donut"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/sugar = 3,
	)
	tastes = list("fried sweet dough" = 3, "sugar glaze" = 2, "tingling trip" = 1)
	foodtypes = VEGETABLES | JUNKFOOD | GRAIN | FRUIT | DAIRY | FRIED | SUGAR | BREAKFAST | MUSHROOM
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_NORMAL

// 37. Skrell Vanilla Pudding
/obj/item/food/skrell_vanilla_pudding
	name = "Skrell vanilla pudding"
	desc = "A delicate plant-based pudding made with soy milk, sweet vanilla, and a hint of cherry jelly. Incredibly silky and gentle."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "vanilla_pudding"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/sugar = 4,
		/datum/reagent/consumable/vanilla = 3,
		/datum/reagent/consumable/soymilk = 4,
		/datum/reagent/consumable/cherryjelly = 2,
	)
	tastes = list("creamy vanilla" = 3, "sweet cherry" = 1, "soymilk" = 1)
	foodtypes = GRAIN | SUGAR | FRUIT | DAIRY
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_NORMAL

// 38. Caramelized Plump Cap
/obj/item/food/kebab/caramelized_plump_cap
	name = "caramelized plump cap"
	desc = "A plump helmet mushroom glazed with crunchy amber caramel and garnished with sweet fruit. A uniquely delightful blend of savory and sugary notes."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "caramel_plump"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/caramel = 5,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("crunchy caramel" = 3, "tender mushroom" = 2, "sweetness" = 2)
	foodtypes = VEGETABLES | MUSHROOM | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_NORMAL

// 39. Ambrosia Deus Tart
/obj/item/food/ambrosia_deus_tart
	name = "Ambrosia Deus tart"
	desc = "An exquisite glowing tart sweetened with ximikoa and korta nectar. The controlled omnizine essence rapidly eases aches and invigorates the consumer."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "deus_tart"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/korta_nectar = 4,
		/datum/reagent/medicine/omnizine = 2.5,
		/datum/reagent/medicine/synaptizine = 2.5,
	)
	tastes = list("divine sweet nectar" = 3, "pastry crust" = 2, "invigorating tingling" = 2)
	foodtypes = VEGETABLES | GRAIN | FRUIT | DAIRY | SUGAR
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_EXOTIC

/obj/item/food/ambrosia_deus_tart/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/ambrosia_deus_tart_slice, 6, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = SFX_KNIFE_SLICE)

/obj/item/food/ambrosia_deus_tart_slice
	name = "Ambrosia Deus tart slice"
	desc = "A glowing slice of delicious Ambrosia Deus tart."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "deus_tart_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/korta_nectar = 1,
		/datum/reagent/medicine/omnizine = 0.6,
		/datum/reagent/medicine/synaptizine = 0.6,
	)
	tastes = list("divine sweet nectar" = 3, "pastry crust" = 2)
	foodtypes = VEGETABLES | GRAIN | FRUIT | DAIRY | SUGAR
	w_class = WEIGHT_CLASS_TINY
	food_flags = FOOD_FINGER_FOOD

// 40. Ambrosia Vulgaris Roll
/obj/item/food/ambrosia_vulgaris_roll
	name = "Ambrosia Vulgaris roll"
	desc = "A rolled pastry filled with fresh ambrosia vulgaris and savory soy dip. A balanced everyday sweet roll that relieves fatigue."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "vulgaris_roll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/medicine/c2/libital = 2,
		/datum/reagent/medicine/c2/aiuri = 2,
	)
	tastes = list("sweet pastry" = 2, "herbal ambrosia" = 2, "soy" = 1)
	foodtypes = VEGETABLES | GRAIN | DAIRY
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/ambrosia_vulgaris_roll/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/ambrosia_vulgaris_roll_slice, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = SFX_KNIFE_SLICE)

/obj/item/food/ambrosia_vulgaris_roll_slice
	name = "Ambrosia Vulgaris roll slice"
	desc = "A slice of sweet and herbal ambrosia roll."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "vulgaris_roll_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/medicine/c2/libital = 0.5,
		/datum/reagent/medicine/c2/aiuri = 0.5,
	)
	tastes = list("sweet pastry" = 2, "herbal ambrosia" = 2)
	foodtypes = GRAIN | VEGETABLES
	w_class = WEIGHT_CLASS_TINY
	food_flags = FOOD_FINGER_FOOD


// 41. Vulgaris Chocolate Roll
/obj/item/food/vulgaris_chocolate_roll
	name = "Vulgaris chocolate roll"
	desc = "A rich, dark cocoa roll swirled with a delicate green ambrosia vulgaris cream and topped with a fresh leaf. Mellows pain and restores energy."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "vulgaris_chocolate_roll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/medicine/c2/libital = 2,
		/datum/reagent/medicine/c2/aiuri = 2,
	)
	tastes = list("rich dark chocolate" = 3, "sweet green cream" = 2, "herbal soothing" = 1)
	foodtypes = VEGETABLES | JUNKFOOD | GRAIN | FRUIT | DAIRY | SUGAR
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/vulgaris_chocolate_roll/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/vulgaris_chocolate_roll_slice, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = SFX_KNIFE_SLICE)

/obj/item/food/vulgaris_chocolate_roll_slice
	name = "Vulgaris chocolate roll slice"
	desc = "A slice of dark chocolate roll with green ambrosia cream."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "vulgaris_chocolate_roll_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2.5,
		/datum/reagent/consumable/sugar = 0.75,
		/datum/reagent/medicine/c2/libital = 0.5,
		/datum/reagent/medicine/c2/aiuri = 0.5,
	)
	tastes = list("rich dark chocolate" = 3, "sweet green cream" = 2)
	foodtypes = GRAIN | SUGAR | VEGETABLES
	w_class = WEIGHT_CLASS_TINY
	food_flags = FOOD_FINGER_FOOD


// 42. Deus Golden Roll
/obj/item/food/deus_golden_roll
	name = "Deus golden roll"
	desc = "A golden-yellow roll filled with radiant Ambrosia Deus cream, honey, and finished with a shimmering gold apple leaf. Inspires pure euphoria."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "deus_golden_roll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/honey = 4,
		/datum/reagent/medicine/omnizine = 2.5,
		/datum/reagent/medicine/synaptizine = 2.5,
		/datum/reagent/gold = 1,
	)
	tastes = list("golden honey" = 3, "divine ambrosia" = 3, "sparkling sweetness" = 2)
	foodtypes = VEGETABLES | GRAIN | FRUIT | DAIRY | SUGAR
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_4
	venue_value = FOOD_PRICE_EXOTIC

/obj/item/food/deus_golden_roll/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/deus_golden_roll_slice, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = SFX_KNIFE_SLICE)

/obj/item/food/deus_golden_roll_slice
	name = "Deus golden roll slice"
	desc = "A slice of glowing golden roll with divine ambrosia cream."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "deus_golden_roll_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2.5,
		/datum/reagent/consumable/honey = 1,
		/datum/reagent/medicine/omnizine = 0.6,
		/datum/reagent/medicine/synaptizine = 0.6,
	)
	tastes = list("golden honey" = 3, "divine ambrosia" = 3)
	foodtypes = GRAIN | SUGAR | VEGETABLES
	w_class = WEIGHT_CLASS_TINY
	food_flags = FOOD_FINGER_FOOD


// 43. Crimson Gaia Roll
/obj/item/food/crimson_gaia_roll
	name = "Crimson Gaia roll"
	desc = "A deep ruby-red roll naturally sweetened with ximikoa and honey, filled with sacred Ambrosia Gaia cream and crowned with a fiery petal. Grants deep peace."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "crimson_gaia_roll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/honey = 4,
		/datum/reagent/consumable/capsaicin = 0.5,
	)
	tastes = list("rich crimson pastry" = 3, "divine honey cream" = 3, "serene warmth" = 2)
	foodtypes = VEGETABLES | GRAIN | FRUIT | DAIRY | SUGAR
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_4
	venue_value = FOOD_PRICE_LEGENDARY

/obj/item/food/crimson_gaia_roll/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/crimson_gaia_roll_slice, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = SFX_KNIFE_SLICE)

/obj/item/food/crimson_gaia_roll_slice
	name = "Crimson Gaia roll slice"
	desc = "A slice of ruby-red Gaia roll with honey cream."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "crimson_gaia_roll_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2.5,
		/datum/reagent/consumable/honey = 1,
	)
	tastes = list("rich crimson pastry" = 3, "divine honey cream" = 3)
	foodtypes = GRAIN | SUGAR | VEGETABLES
	w_class = WEIGHT_CLASS_TINY
	food_flags = FOOD_FINGER_FOOD

// ICE CREAM & SWEETS

// 44. Skrell Vanilla Ice Cream
/obj/item/food/skrell_vanilla_icecream
	name = "Skrell vanilla ice cream"
	desc = "A creamy, dairy-free frozen treat made from smooth soy milk, sweet vanilla, and sugar on a wooden stick."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "skrell_vanilla_icecream"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/soymilk = 4,
		/datum/reagent/consumable/vanilla = 2,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/ice = 2,
	)
	tastes = list("creamy vanilla" = 3, "sweet soy" = 2, "cold ice" = 1)
	foodtypes = FRUIT | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_CHEAP

// 45. Glowcap Ice Scoop
/obj/item/food/glowcap_ice_scoop
	name = "glowcap ice scoop"
	desc = "A bioluminescent frozen treat made of pureed glowcaps, soy milk, and trace hallucinogens. Tingles on the tongue and sparkles in the dark."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "glowcap_ice_scoop"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/soymilk = 4,
		/datum/reagent/teslium = 1,
		/datum/reagent/consumable/ice = 2,
	)
	tastes = list("electric chill" = 3, "creamy mushroom" = 2, "sparkles" = 1)
	foodtypes = VEGETABLES | SUGAR | TOXIC | MUSHROOM
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 46. Soy Ambrosia Sundae
/obj/item/food/soy_ambrosia_sundae
	name = "soy ambrosia sundae"
	desc = "An exotic sundae combining whipped soy cream, ximikoa cocoa, arabica coffee, and a delicate touch of divine Ambrosia Deus."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "soy_ambrosia_sundae"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/soymilk = 4,
		/datum/reagent/consumable/coffee = 2,
		/datum/reagent/medicine/omnizine = 1.5,
		/datum/reagent/medicine/synaptizine = 1.5,
		/datum/reagent/consumable/ice = 2,
	)
	tastes = list("rich coffee cocoa" = 3, "creamy soy" = 2, "divine herbal touch" = 1)
	foodtypes = VEGETABLES | FRUIT | SUGAR
	trash_type = /obj/item/reagent_containers/cup/glass/sillycup
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_EXOTIC

// 47. Fyrsskar Drops
/obj/item/food/fyrsskar_drops
	name = "Fyrsskar drops"
	desc = "Hard translucent drops made by crystallizing caramelized sugars with Tears of Fyrsskar. Rapidly cleanses metabolic impurities from Skrell."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "fyrsskar_drops"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/caramel = 5,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/triple_citrus = 1,
	)
	tastes = list("sweet caramel" = 2, "citrus plasma zest" = 3)
	foodtypes = SUGAR | TOXIC
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/fyrsskar_drops/make_edible()
	. = ..()
	AddComponentFrom(SOURCE_EDIBLE_INNATE, /datum/component/edible, after_eat = CALLBACK(src, PROC_REF(after_eat)))

/obj/item/food/fyrsskar_drops/proc/after_eat(mob/living/carbon/consumer)
	if(isskrell(consumer))
		to_chat(consumer, span_notice("Свежесть Фурскара мягко очищает вашу кровь и четалы от чужеродных токсинов..."))
		if(consumer.reagents)
			for(var/datum/reagent/toxin/toxin in consumer.reagents.reagent_list.Copy())
				consumer.reagents.remove_reagent(toxin.type, toxin.volume)
		consumer.adjust_disgust(-30)

// 48. Slime-Fungus Freeze
/obj/item/food/slime_fungus_freeze
	name = "slime-fungus freeze"
	desc = "A tart and trippy popsicle blending sweet berry juice, soy milk, and crushed liberty-cap mushrooms. Brings a burst of colorful euphoria."
	icon = 'icons/obj/food/skrell.dmi'
	icon_state = "slime_fungus_freeze"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/berryjuice = 3,
		/datum/reagent/consumable/soymilk = 3,
		/datum/reagent/consumable/ice = 2,
	)
	tastes = list("sweet tart berries" = 3, "earthy hallucinogen" = 2, "creamy chill" = 1)
	foodtypes = VEGETABLES | FRUIT | SUGAR | MUSHROOM
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL
