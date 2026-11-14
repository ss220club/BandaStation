//Skrell Foods, for skrell
/obj/item/food/skrell
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'

// MARK: Breads & Bakery

// 2. plump helmet rice flatbread
/obj/item/food/skrell/plump_rice_flatbread
	name = "plump helmet rice flatbread"
	desc = "Традиционная пористая лепёшка, пропитанная грибами толстошлемника и соевым молоком. Очень ароматная и сытная."
	icon_state = "plump_rice_flatbread"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/soymilk = 5,
	)
	tastes = list("bread" = 2, "mushroom" = 2, "soy" = 1)
	foodtypes = GRAIN | MUSHROOM
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_NORMAL

// 3. fly amanita bun
/obj/item/food/skrell/fly_amanita_bun
	name = "fly amanita bun"
	desc = "Пышная булочка, запечённая со свежим мухомором. Крайне токсична и галлюциногенна для большинства видов, но для скреллов это вкусное повседневное блюдо."
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

/obj/item/food/skrell/fly_amanita_bun/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/skrell/fly_amanita_bun_slice, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = /datum/sound_effect/knife_slice)

/obj/item/food/skrell/fly_amanita_bun_slice
	name = "fly amanita bun slice"
	desc = "Мягкий, усеянный токсинами ломтик булочки с мухомором."
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


// 4. ximikoa rice roll
/obj/item/food/skrell/ximikoa_roll
	name = "ximikoa rice roll"
	desc = "Нежный сладковатый запечённый рисовый ролл, обогащённый ксими'коа и мукой. Полон ценных растительных белков."
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


// 5. capsaicin fungal focaccia
/obj/item/food/skrell/capsaicin_focaccia
	name = "capsaicin fungal focaccia"
	desc = "Огненная пряная лепёшка с обилием грибов и острого соуса. Скреллы высоко ценят её стимулирующий жар."
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


// MARK: Soups & Stews

// 6. qerrbalak fungal stew
/obj/item/food/soup/qerrbalak_stew
	name = "qerrbalak fungal stew"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Традиционное сытное повседневное рагу, которое едят по всему Керрбалаку. Загущено мукой и наполнено ароматными грибами."
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

// 7. glowshroom chowder
/obj/item/food/soup/glowshroom_chowder
	name = "glowshroom chowder"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Сливочный светящийся суп из радиоактивных светогрибов и соевого молока. Успокаивает и насыщает скреллов."
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

// 8. destroying angel bisque
/obj/item/food/soup/destroying_angel_bisque
	name = "destroying angel bisque"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Смертоносный белый биск, настоянный на белой поганке. Изысканный деликатес для скреллов, но смертельный для других видов."
	icon_state = "angel_bisque"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/toxin/amatoxin = 4,
		/datum/reagent/toxin/amanitin = 4,
		/datum/reagent/consumable/soysauce = 2,
	)
	tastes = list("intense umami" = 3, "numbing toxin" = 1)
	foodtypes = MUSHROOM | TOXIC
	trash_type = /obj/item/reagent_containers/cup/bowl
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_EXOTIC

// 9. kenin tofu soup
/obj/item/food/soup/kenin_tofu_soup
	name = "kenin tofu soup"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Успокаивающий изысканный суп с обилием кубиков тофу и трутовиков. Оказывает приятное обезболивающее действие."
	icon_state = "kenin_soup"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/medicine/salglu_solution = 3,
		/datum/reagent/medicine/c2/multiver = 2,
	)
	tastes = list("soft tofu" = 2, "soothing bitterness" = 2)
	foodtypes = VEGETABLES | MUSHROOM
	trash_type = /obj/item/reagent_containers/cup/bowl
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 10. embershroom lava stew
/obj/item/food/soup/embershroom_lava_stew
	name = "embershroom lava stew"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Томящийся острый красный бульон из Лавалендских грибов и огнецветов. Согревает в лютый мороз."
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

// 11. eden's gaia noodle soup
/obj/item/food/soup/edens_gaia_noodles
	name = "eden's gaia noodle soup"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Священная светящаяся миска лапши, плавающей в бульоне из амброзии божественной. Вызывает высшее умиротворение и ментальную гармонию."
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

// 12. puffball gas soup
/obj/item/food/soup/puffball_gas_soup
	name = "puffball gas soup"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Шипящий туманный суп, сваренный из мерзкого дождевика и волшебной травы. При употреблении выделяет галлюциногенные споры."
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

// MARK: Main Dishes

// 13. Plump Fungal Roast
/obj/item/food/skrell/raw_plump_fungal_roast
	name = "raw plump fungal roast"
	desc = "Толстый ломоть сырого толстошлемника, замаринованный в соевом соусе и присыпанный рисовой мукой. Готов к жарке на гриле или запеканию."
	icon_state = "raw_plump_fungal_roast"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2,
		/datum/reagent/consumable/soysauce = 2,
	)
	tastes = list("raw mushroom" = 3, "savory soy" = 2)
	foodtypes = MUSHROOM | RAW
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_CHEAP

/obj/item/food/skrell/raw_plump_fungal_roast/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/skrell/plump_fungal_roast, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

/obj/item/food/skrell/raw_plump_fungal_roast/make_bakeable()
	AddComponent(/datum/component/bakeable, /obj/item/food/skrell/plump_fungal_roast, rand(15 SECONDS, 25 SECONDS), TRUE, TRUE)

// 13.1
/obj/item/food/skrell/plump_fungal_roast
	name = "plump fungal roast"
	desc = "Толстый сочный стейк из толстошлемника, приправленный соевым соусом и рисовой мукой, идеально обжаренный на гриле. Сытная основа повседневной скрелльской трапезы."
	icon_state = "plump_fungal_roast"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/soysauce = 2,
	)
	tastes = list("juicy mushroom" = 3, "savory soy" = 2)
	foodtypes = MUSHROOM | GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 14. crispy walking mushroom skewers
/obj/item/food/kebab/walking_mushroom_skewer
	name = "crispy walking mushroom skewer"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Нежные ножки ходячего гриба, нанизанные на шпажку и обжаренные в масле до хрустящей корочки. Весьма популярная уличная еда на Керрбалаке."
	icon_state = "walking_skewer"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/fat/oil = 2,
		/datum/reagent/consumable/salt = 1,
	)
	tastes = list("crispy mushroom" = 3, "salted oil" = 1)
	foodtypes = MUSHROOM | FRIED
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_NORMAL

// 15. psychedelic tempeh stir-fry
/obj/item/food/skrell/psychedelic_tempeh
	name = "psychedelic tempeh stir-fry"
	desc = "Ферментированный соевый темпе, обжаренный со либерти‑кэпом и насыщенным соевым соусом. Вызывает лёгкую эйфорию у скреллов и сильные галлюцинации у людей."
	icon_state = "psychedelic_tempeh"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/drug/mushroomhallucinogen = 3,
	)
	tastes = list("nutty tempeh" = 2, "tingling mushrooms" = 2, "soy" = 1)
	foodtypes = VEGETABLES | MUSHROOM | GRAIN
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_EXOTIC

// 16. steel cap dumplings
/obj/item/food/skrell/steelcap_dumplings
	name = "steel cap dumplings"
	desc = "Плотные рисовые клёцки, начинённые измельчёнными сталешляпниками и какао. Богаты пищевым железом и клетчаткой."
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

/obj/item/food/skrell/steelcap_dumplings/on_craft_completion(list/components, datum/crafting_recipe/current_recipe, atom/crafter)
	. = ..()
	if(!reagents)
		return
	for(var/obj/item/grown/log/steel/steel_log in components)
		if(steel_log.reagents)
			reagents.maximum_volume = max(reagents.maximum_volume, reagents.total_volume + steel_log.reagents.total_volume)
			steel_log.reagents.trans_to(src, steel_log.reagents.total_volume)

// 17. skrell fungal ramen
/obj/item/food/skrell/skrell_fungal_ramen
	name = "skrell fungal ramen"
	desc = "Дымящаяся миска рисовой лапши в концентрированном бульоне из толстошлемников, лисичек и выдержанного соевого соуса."
	icon_state = "skrell_ramen"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/vitamin = 5,
		/datum/reagent/consumable/soysauce = 3,
	)
	tastes = list("savory broth" = 3, "tender noodles" = 2, "mushrooms" = 2)
	foodtypes = GRAIN | MUSHROOM
	trash_type = /obj/item/reagent_containers/cup/bowl
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 18. Seraka & Flame Roast
/obj/item/food/skrell/seraka_flame_roast
	name = "seraka flame roast"
	desc = "Обжигающе острое блюдо из жареного мицелия сераки и кактуса, глазированное капсаициновым маслом."
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

// 19. baked eggplant skrell cheetal
/obj/item/food/skrell/skrell_cheetal_eggplant
	name = "baked eggplant skrell cheetal"
	desc = "Баклажан, вырезанный в величественной форме головного щупальца скрелла, фаршированный тофу, толстошлемниками и украшенный сладкими сливами. Высший символ гостеприимства."
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

// 20. mindbreaker fungal bake
/obj/item/food/skrell/mindbreaker_fungal_bake
	name = "mindbreaker fungal bake"
	desc = "Психоделический запечённый пирог со светящимися грибами, кубками Юпитера и радужной травой. Отправляет разум в трансцендентное калейдоскопическое блаженство."
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

/obj/item/food/skrell/mindbreaker_fungal_bake/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/skrell/mindbreaker_fungal_bake_slice, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = /datum/sound_effect/knife_slice)

/obj/item/food/skrell/mindbreaker_fungal_bake_slice
	name = "mindbreaker fungal bake slice"
	desc = "Светящийся ароматный кусочек психоделической грибной запеканки."
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

// 21. qerrbalak eclipse stew
/obj/item/food/soup/qerrbalak_eclipse_stew
	name = "qerrbalak eclipse stew"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Чёрное как смоль психоактивное рагу, сваренное из омега-травы, свободошляпников и тенегрибов с пикантной ноткой ананаса. Чрезвычайно мощное."
	icon_state = "eclipse_stew"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/toxin/mindbreaker = 5,
		/datum/reagent/drug/mushroomhallucinogen = 3,
		/datum/reagent/uranium/radium = 2,
	)
	tastes = list("tangy pineapple" = 2, "numbing shadows" = 3, "pure trip" = 2)
	foodtypes = VEGETABLES | MUSHROOM | FRUIT | TOXIC
	trash_type = /obj/item/reagent_containers/cup/bowl
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_4
	venue_value = FOOD_PRICE_EXOTIC

// 22. crimson fungal mix
/obj/item/food/skrell/crimson_fungal_mix
	name = "crimson fungal mix"
	desc = "Соте из ярко-красных и золотистых грибов. Источает пряный, изменяющий сознание аромат."
	icon_state = "crimson_mix"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/toxin/amatoxin = 2,
	)
	tastes = list("peppery mushrooms" = 2, "wild heat" = 1)
	foodtypes = MUSHROOM | TOXIC
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

// twilight fungal paste
/obj/item/food/skrell/twilight_fungal_paste
	name = "twilight fungal paste"
	desc = "Паста цвета тёмного индиго, приготовленная из глубоких пещерных грибов, ягод и винограда."
	icon_state = "twilight_paste"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/uranium/radium = 1,
	)
	tastes = list("sweet berries" = 2, "earthy mushrooms" = 2)
	foodtypes = MUSHROOM | FRUIT
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

// luminous white salad
/obj/item/food/skrell/luminous_white_salad
	name = "luminous white salad"
	desc = "Пикантная светящаяся смесь биолюминесцентных грибов и трав, заправленная свежим соком лайма."
	icon_state = "luminous_salad"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/toxin/amanitin = 2,
	)
	tastes = list("lime zest" = 2, "luminescent crunch" = 2)
	foodtypes = MUSHROOM | FRUIT | TOXIC
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3

// grand qerrbalak mycelial roast
/obj/item/food/skrell/grand_mycelial_roast
	name = "grand qerrbalak mycelial roast"
	desc = "Неоспоримая вершина скрелльского кулинарного мастерства. Три изысканные грибные эссенции, томлённые в священном супе с лапшой из амброзии божественной. Шедевр цвета, вкуса и биогармонии."
	icon_state = "mycelial_roast"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 40,
		/datum/reagent/consumable/nutriment/vitamin = 30,
		/datum/reagent/consumable/qerr_primordial_nectar = 20,
		/datum/reagent/medicine/omnizine = 12,
	)
	tastes = list("infinite fungal harmony" = 4, "divine nectar" = 3, "pure euphoria" = 2)
	foodtypes = MUSHROOM | GRAIN | FRUIT | TOXIC
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_5
	venue_value = FOOD_PRICE_LEGENDARY

/obj/item/food/skrell/grand_mycelial_roast/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/skrell/mycelial_roast_slice, 6, 5 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = /datum/sound_effect/knife_slice)

/obj/item/food/skrell/grand_mycelial_roast/on_craft_completion(list/components, datum/crafting_recipe/current_recipe, atom/crafter)
	. = ..()
	if(reagents)
		reagents.maximum_volume = max(reagents.maximum_volume, 300)
		reagents.add_reagent(/datum/reagent/consumable/qerr_primordial_nectar, 30)

/obj/item/food/skrell/mycelial_roast_slice
	name = "mycelial roast slice"
	desc = "Небольшой светящийся кусочек психоделической грибной запеканки."
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

// MARK: Salads & Appetizers

// 26. coniine berry bowl
/obj/item/food/salad/coniine_berry
	name = "coniine berry bowl"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Салат с обилием смертоягод, алоэ и плодов бунго. Концентрированные нейротоксины служат стимулирующим тоником для скреллов, но смертельны для других видов."
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
/obj/item/food/skrell/soy_fungal_chips
	name = "soy chips with fungal dip"
	desc = "Хрустящие ломтики жареного толстошлемника, подаваемые с мисочкой нежного соевого дипа. Идеальная закуска для перерыва в лаборатории."
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
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Освежающий салат из нарезанных огурцов, свежих толстошлемников и лепестков луноцвета. Следы травяного самогона мягко нейтрализуются грибной основой."
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

// MARK: Burgers, Sandwiches & Wraps

// 29. skrellian tofu burger
/obj/item/food/burger/skrell_tofu
	name = "skrellian tofu burger"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Сытный вегетарианский бургер с нежной котлетой из тофу, ломтиком толстошлемника и насыщенным соевым соусом в мягкой рисовой булочке."
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

// 30. qerr fungal taco
/obj/item/food/taco/qerr_fungal
	name = "qerr fungal taco"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Хрустящая кукурузная лепёшка тако, наполненная обжаренными лисичками и приправленная чесноком с пикантным соевым соусом."
	icon_state = "qerr_taco"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/garlic = 2,
		/datum/reagent/consumable/soysauce = 2,
	)
	tastes = list("crispy shell" = 2, "golden chanterelles" = 2, "garlic" = 1)
	foodtypes = GRAIN | MUSHROOM
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 31. Destroying Angel Slider
/obj/item/food/burger/destroying_angel
	name = "destroying angel slider"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Пугающий бургер с обжаренной на гриле белой поганкой, хрустящими луковыми кольцами и тофу. Смертельно опасен для не-скреллов!"
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

// 32. rice cheese sandwich
/obj/item/food/sandwich/rice_cheese
	name = "rice cheese sandwich"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Простой питательный сэндвич с сыром между двумя ломтиками мягкого рисового хлеба. Можно идеально поджарить на гриле."
	icon_state = "rice_cheese_sandwich"
	custom_materials = null
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

// 32.1. Grilled rice cheese sandwich
/obj/item/food/sandwich/grilled_rice_cheese
	name = "grilled rice cheese sandwich"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Тёплый поджаренный до золотистой корочки рисовый сэндвич с тягучим расплавленным сыром."
	icon_state = "grilled_rice_cheese"
	custom_materials = null
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
/obj/item/food/skrell/fairy_glow_roll
	name = "fairy glow roll"
	desc = "Светящийся ролл из теста низайя, начинённый сияющей волшебной травой и нарезанным светогрибом. Вызывает мягкое расслабление и искрится в темноте."
	icon_state = "fairy_glow_roll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/teslium = 1,
	)
	tastes = list("chewy nizaya" = 2, "sparkling fairy flora" = 2, "electric tingle" = 1)
	foodtypes = GRAIN | MUSHROOM
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// MARK: Desserts, Cakes & Rolls

// 34. citrus coffee cake
/obj/item/food/cake/skrell_citrus_cake
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	name = "citrus coffee cake"
	desc = "Ароматный слоёный торт, пропитанный свежей апельсиновой цедрой и тёмным кофе арабика. Бодрящий десерт, популярный на дипломатических приёмах."
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
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/cake/skrell_citrus_cake/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/skrell_citrus_slice, 6, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = /datum/sound_effect/knife_slice)

/obj/item/food/cakeslice/skrell_citrus_slice
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	name = "citrus coffee cake slice"
	desc = "Кусочек ароматного торта с нотками цитрусов и кофе."
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
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	name = "blue cherry moonflower cake"
	desc = "Потрясающий торт, испечённый со светящейся голубой вишней, какао, ксими'коа и лепестками луноцвета. Излучает успокаивающее прохладное синее сияние."
	icon_state = "blue_cherry_moon"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/consumable/cherryjelly = 4,
		/datum/reagent/consumable/ethanol/moonshine = 1,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("sweet blue cherries" = 3, "crisp crust" = 2, "cocoa" = 1)
	foodtypes = GRAIN | FRUIT | SUGAR | VEGETABLES | DAIRY
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/cake/blue_cherry_moon_cake/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/cakeslice/blue_cherry_slice, 6, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = /datum/sound_effect/knife_slice)

/obj/item/food/cakeslice/blue_cherry_slice
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	name = "blue cherry moonflower cake slice"
	desc = "Кусочек светящегося торта с голубой вишней."
	icon_state = "blue_cherry_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/sugar = 1,
		/datum/reagent/consumable/cherryjelly = 0.8,
	)
	tastes = list("sweet blue cherries" = 3, "crisp crust" = 2)
	foodtypes = GRAIN | FRUIT | SUGAR
	food_flags = FOOD_FINGER_FOOD

// 36. liberty fungus donuts
/obj/item/food/donut/liberty_fungus
	name = "liberty fungus donut"
	desc = "Обжаренное во фритюре сладкое колечко из теста, пропитанное выверенным экстрактом либерти-кэпа. Поднимает настроение и снимает стресс."
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	icon_state = "liberty_donut"
	is_decorated = TRUE
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/drug/mushroomhallucinogen = 5,
	)
	tastes = list("fried sweet dough" = 3, "sugar glaze" = 2, "tingling trip" = 1)
	foodtypes = JUNKFOOD | GRAIN | FRUIT | DAIRY | FRIED | SUGAR | BREAKFAST | MUSHROOM
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_NORMAL

// 37. skrell vanilla pudding
/obj/item/food/skrell/skrell_vanilla_pudding
	name = "skrell vanilla pudding"
	desc = "Нежный растительный пудинг из соевого молока, сладкой ванили и капли вишнёвого желе. Невероятно шелковистый и мягкий."
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

// 38. caramelized plump cap
/obj/item/food/kebab/caramelized_plump_cap
	name = "caramelized plump cap"
	icon = 'modular_bandastation/food_and_drinks/icons/foods/skrell.dmi'
	desc = "Толстошлемник, глазированный хрустящей янтарной карамелью и украшенный сладкими фруктами. Уникальное восхитительное сочетание пикантных и сладких нот."
	icon_state = "caramel_plump"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/caramel = 5,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2,
	)
	tastes = list("crunchy caramel" = 3, "tender mushroom" = 2, "sweetness" = 2)
	foodtypes = MUSHROOM | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_2
	venue_value = FOOD_PRICE_NORMAL

// 39. ambrosia deus tart
/obj/item/food/skrell/ambrosia_deus_tart
	name = "ambrosia deus tart"
	desc = "Изысканный светящийся торт, подслащённый ксими'коа и нектаром корта. Выверенная эссенция омнизина быстро унимает боль и придаёт сил."
	icon_state = "deus_tart"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/korta_nectar = 4,
		/datum/reagent/medicine/omnizine = 2.5,
	)
	tastes = list("divine sweet nectar" = 3, "pastry crust" = 2, "invigorating tingling" = 2)
	foodtypes = VEGETABLES | GRAIN | FRUIT | DAIRY | SUGAR
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_EXOTIC

/obj/item/food/skrell/ambrosia_deus_tart/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/skrell/ambrosia_deus_tart_slice, 6, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = /datum/sound_effect/knife_slice)

/obj/item/food/skrell/ambrosia_deus_tart_slice
	name = "ambrosia deus tart slice"
	desc = "Светящийся кусочек восхитительного торта с амброзией деус."
	icon_state = "deus_tart_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/korta_nectar = 1,
		/datum/reagent/medicine/omnizine = 0.6,
	)
	tastes = list("divine sweet nectar" = 3, "pastry crust" = 2)
	foodtypes = VEGETABLES | GRAIN | FRUIT | DAIRY | SUGAR
	w_class = WEIGHT_CLASS_TINY
	food_flags = FOOD_FINGER_FOOD

// 40. ambrosia vulgaris roll
/obj/item/food/skrell/ambrosia_vulgaris_roll
	name = "ambrosia vulgaris roll"
	desc = "Свёрнутый рулет с начинкой из свежей амброзии обыкновенной и пикантного соевого соуса. Сбалансированный повседневный сладкий рулет, снимающий усталость."
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
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/skrell/ambrosia_vulgaris_roll/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/skrell/ambrosia_vulgaris_roll_slice, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = /datum/sound_effect/knife_slice)

/obj/item/food/skrell/ambrosia_vulgaris_roll_slice
	name = "ambrosia vulgaris roll slice"
	desc = "Кусочек сладкого травяного рулета с амброзией."
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


// 41. vulgaris chocolate roll
/obj/item/food/skrell/vulgaris_chocolate_roll
	name = "vulgaris chocolate roll"
	desc = "Насыщенный рулет из тёмного какао с завитками нежного зелёного крема из амброзии обыкновенной, увенчанный свежим листком. Смягчает боль и восстанавливает силы."
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
	crafting_complexity = FOOD_COMPLEXITY_4
	venue_value = FOOD_PRICE_NORMAL

/obj/item/food/skrell/vulgaris_chocolate_roll/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/skrell/vulgaris_chocolate_roll_slice, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = /datum/sound_effect/knife_slice)

/obj/item/food/skrell/vulgaris_chocolate_roll_slice
	name = "vulgaris chocolate roll slice"
	desc = "Кусочек рулета из тёмного шоколада с зелёным кремом из амброзии."
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


// 42. deus golden roll
/obj/item/food/skrell/deus_golden_roll
	name = "deus golden roll"
	desc = "Золотисто-жёлтый рулет с начинкой из сияющего крема амброзии божественной и мёда, украшенный мерцающим листком золотого яблока. Внушает чистую эйфорию."
	icon_state = "deus_golden_roll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/honey = 4,
		/datum/reagent/medicine/omnizine = 2.5,
		/datum/reagent/gold = 1,
	)
	tastes = list("golden honey" = 3, "divine ambrosia" = 3, "sparkling sweetness" = 2)
	foodtypes = VEGETABLES | GRAIN | FRUIT | DAIRY | SUGAR
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_5
	venue_value = FOOD_PRICE_EXOTIC

/obj/item/food/skrell/deus_golden_roll/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/skrell/deus_golden_roll_slice, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = /datum/sound_effect/knife_slice)

/obj/item/food/skrell/deus_golden_roll_slice
	name = "deus golden roll slice"
	desc = "Кусочек светящегося золотого рулета с божественным кремом из амброзии."
	icon_state = "deus_golden_roll_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2.5,
		/datum/reagent/consumable/honey = 1,
		/datum/reagent/medicine/omnizine = 0.6,
	)
	tastes = list("golden honey" = 3, "divine ambrosia" = 3)
	foodtypes = GRAIN | SUGAR | VEGETABLES
	w_class = WEIGHT_CLASS_TINY
	food_flags = FOOD_FINGER_FOOD


// 43. crimson gaia roll
/obj/item/food/skrell/crimson_gaia_roll
	name = "crimson gaia roll"
	desc = "Насыщенный рубиново-красный рулет, естественно подслащённый ксими'коа и мёдом, с начинкой из священного крема амброзии гайя и огненным лепестком сверху. Дарует глубокий покой."
	icon_state = "crimson_gaia_roll"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/honey = 4,
		/datum/reagent/consumable/capsaicin = 0.5,
	)
	tastes = list("rich crimson pastry" = 3, "divine honey cream" = 3, "serene warmth" = 2)
	foodtypes = VEGETABLES | GRAIN | FRUIT | DAIRY | SUGAR
	w_class = WEIGHT_CLASS_NORMAL
	crafting_complexity = FOOD_COMPLEXITY_5
	venue_value = FOOD_PRICE_LEGENDARY

/obj/item/food/skrell/crimson_gaia_roll/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/skrell/crimson_gaia_roll_slice, 4, 3 SECONDS, table_required = TRUE, screentip_verb = "Slice", sound_to_play = /datum/sound_effect/knife_slice)

/obj/item/food/skrell/crimson_gaia_roll_slice
	name = "crimson gaia roll slice"
	desc = "Кусочек рубиново-красного рулета гайя с медовым кремом."
	icon_state = "crimson_gaia_roll_slice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2.5,
		/datum/reagent/consumable/honey = 1,
	)
	tastes = list("rich crimson pastry" = 3, "divine honey cream" = 3)
	foodtypes = GRAIN | SUGAR | VEGETABLES
	w_class = WEIGHT_CLASS_TINY
	food_flags = FOOD_FINGER_FOOD

// MARK: Sweets & Ice Cream

// 44. skrell vanilla ice cream
/obj/item/food/skrell/skrell_vanilla_icecream
	name = "skrell vanilla ice cream"
	desc = "Сливочное безмолочное мороженое на деревянной палочке, приготовленное из нежного соевого молока, сладкой ванили и сахара."
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

// 45. glowcap ice scoop
/obj/item/food/skrell/glowcap_ice_scoop
	name = "glowcap ice scoop"
	desc = "Биолюминесцентное замороженное лакомство из пюре светогриба, соевого молока и следов галлюциногенов. Покалывает язык и искрится в темноте."
	icon_state = "glowcap_ice_scoop"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/soymilk = 4,
		/datum/reagent/teslium = 1,
		/datum/reagent/consumable/ice = 2,
	)
	tastes = list("electric chill" = 3, "creamy mushroom" = 2, "sparkles" = 1)
	foodtypes = SUGAR | TOXIC | MUSHROOM
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL

// 46. soy ambrosia sundae
/obj/item/food/skrell/soy_ambrosia_sundae
	name = "soy ambrosia sundae"
	desc = "Экзотический сандай, сочетающий взбитые соевые сливки, какао, ксими'коа, кофе арабика и утончённую нотку божественной амброзии."
	icon_state = "soy_ambrosia_sundae"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/soymilk = 4,
		/datum/reagent/consumable/coffee = 2,
		/datum/reagent/medicine/omnizine = 1.5,
		/datum/reagent/consumable/ice = 2,
	)
	tastes = list("rich coffee cocoa" = 3, "creamy soy" = 2, "divine herbal touch" = 1)
	foodtypes = VEGETABLES | FRUIT | SUGAR
	trash_type = /obj/item/reagent_containers/cup/glass/sillycup
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_EXOTIC

// 47. fyrsskar drops
/obj/item/food/skrell/fyrsskar_drops
	name = "fyrsskar drops"
	desc = "Твёрдые полупрозрачные леденцы, полученные путём кристаллизации карамелизированного сахара со Слёзами Фирскара. Быстро очищают организм скреллов от метаболических примесей."
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

/obj/item/food/skrell/fyrsskar_drops/make_edible()
	. = ..()
	AddComponentFrom(SOURCE_EDIBLE_INNATE, /datum/component/edible, after_eat = CALLBACK(src, PROC_REF(after_eat)))

/obj/item/food/skrell/fyrsskar_drops/proc/after_eat(mob/living/carbon/consumer)
	if(isskrell(consumer))
		to_chat(consumer, span_notice("Свежесть Фирскара мягко очищает вашу кровь и четалы от чужеродных токсинов..."))
		if(consumer.reagents)
			for(var/datum/reagent/toxin/toxin in consumer.reagents.reagent_list.Copy())
				consumer.reagents.remove_reagent(toxin.type, toxin.volume)
		consumer.adjust_disgust(-30)

// 48. slime-fungus freeze
/obj/item/food/skrell/slime_fungus_freeze
	name = "slime-fungus freeze"
	desc = "Терпкий психоделический фруктовый лёд из сладкого ягодного сока, соевого молока и толчёных либерти-кэпов. Дарит всплеск красочной эйфории."
	icon_state = "slime_fungus_freeze"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/berryjuice = 3,
		/datum/reagent/consumable/soymilk = 3,
		/datum/reagent/consumable/ice = 2,
		/datum/reagent/drug/mushroomhallucinogen = 4,
	)
	tastes = list("sweet tart berries" = 3, "earthy hallucinogen" = 2, "creamy chill" = 1)
	foodtypes = FRUIT | SUGAR | MUSHROOM
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	crafting_complexity = FOOD_COMPLEXITY_3
	venue_value = FOOD_PRICE_NORMAL
