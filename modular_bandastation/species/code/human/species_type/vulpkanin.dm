/datum/species/vulpkanin
	name = "\improper Вульпканин"
	plural_form = "Вульпкане"
	id = SPECIES_VULPKANIN
	inherent_traits = list(
		TRAIT_MUTANT_COLORS
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

	species_language_holder = /datum/language_holder/vulpkanin

	mutantbrain = /obj/item/organ/brain/vulpkanin
	mutantheart = /obj/item/organ/heart/vulpkanin
	mutantlungs = /obj/item/organ/lungs/vulpkanin
	mutanteyes = /obj/item/organ/eyes/vulpkanin
	mutantears = /obj/item/organ/ears/vulpkanin
	mutanttongue = /obj/item/organ/tongue/vulpkanin
	mutantliver = /obj/item/organ/liver/vulpkanin
	mutantstomach = /obj/item/organ/stomach/vulpkanin
	mutant_organs = list(
		/obj/item/organ/tail/vulpkanin = /datum/sprite_accessory/tails/vulpkanin/fluffy::name,
	)

	body_markings = list(
		/datum/bodypart_overlay/simple/body_marking/vulpkanin_head = SPRITE_ACCESSORY_NONE,
		/datum/bodypart_overlay/simple/body_marking/vulpkanin_chest = SPRITE_ACCESSORY_NONE,
		/datum/bodypart_overlay/simple/body_marking/vulpkanin_limb = SPRITE_ACCESSORY_NONE,
		/datum/bodypart_overlay/simple/body_marking/vulpkanin_facial_hair = SPRITE_ACCESSORY_NONE,
	)

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/vulpkanin,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/vulpkanin,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/vulpkanin,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/vulpkanin,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/vulpkanin,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/vulpkanin,
	)

	payday_modifier = 0.8
	bodytemp_heat_damage_limit = BODYTEMP_HEAT_DAMAGE_LIMIT + 30
	bodytemp_cold_damage_limit = BODYTEMP_COLD_DAMAGE_LIMIT - 60


/datum/species/vulpkanin/prepare_human_for_preview(mob/living/carbon/human/human)
	human.set_haircolor("#A26324", update = FALSE) // brown
	human.set_hairstyle("Jagged", update = TRUE)
	human.dna.features["mcolor"] = "#D69E67"
	human.dna.features["vulpkanin_body_markings_color"] = "#bd762f"
	human.dna.features["vulpkanin_tail_markings_color"] = "#2b2015"
	human.dna.features["vulpkanin_head_markings_color"] = "#2b2015"
	human.dna.features["vulpkanin_facial_hair_color"] = "#bd762f"
	human.update_body(is_creating = TRUE)

/datum/species/vulpkanin/randomize_features()
	var/list/features = ..()
	features["vulpkanin_chest_markings"] = prob(50) ? pick(SSaccessories.vulpkanin_chest_markings_list) : SPRITE_ACCESSORY_NONE
	features["tail_markings"] = prob(50) ? pick(SSaccessories.vulpkanin_tail_markings_list) : SPRITE_ACCESSORY_NONE
	features["vulpkanin_head_markings"] = prob(50) ? pick(SSaccessories.vulpkanin_head_markings_list) : SPRITE_ACCESSORY_NONE
	features["vulpkanin_facial_hair"] = prob(50) ? pick(SSaccessories.vulpkanin_facial_hair_list) : SPRITE_ACCESSORY_NONE

	var/furcolor = "#[random_color()]"
	features["vulpkanin_body_markings_color"] = furcolor
	features["vulpkanin_tail_markings_color"] = furcolor
	features["vulpkanin_head_markings_color"] = furcolor
	features["vulpkanin_facial_hair_color"] = furcolor
	return features

/datum/species/vulpkanin/get_physical_attributes()
	return "Вульпканины - двуногие гуманоиды собакоподобные покрытые шерстью, ростом от 140 до 180 см и весом до 60 кг. \
	Их скелет легкий и прочный, а череп особенно прочно соединен с позвоночником. \
	У них глубоко расположенный речевой аппарат, длинный язык, паутинообразная грудная клетка, длинные пальцы с острыми \
	когтями, длинные задние конечности для ходьбы и бега, хвост для равновесия и невербального общения. \
	Их шерсть мягкая, хорошо сохраняет тепло, но уязвима к высоким температурам и химическим веществам."

/datum/species/vulpkanin/get_species_description()
	return "Вульпканины происходят с планеты Альтам, которая долгое время находится в стадии кровопролитной войны трёх доминирующих кланов, \
	которые пытаются установить на планете единый режим и привести расу вульпканинов к процветанию."

/datum/species/vulpkanin/get_species_lore()
	return list(
		"Альтам, родина вульпканинов, представляет собой мир, где горы, покрытые снегом, устремляются к небесам, а ниже расстилаются холодные пустыни. \
		Температура здесь редко поднимается выше одного градуса, создавая пейзаж вечного прохладного уединения. \
		В мире Альтама растения хитроумно сохраняют влагу под восковыми листьями, расцветая в короткую весну и оживляя холодные пустыни яркими красками. \
		Вульпканины гармонично вписываются в этот мир. Их мягкая шерсть и стальные мышцы помогают противостоять холоду.",

		"В силу того, что вульпкане окончательно не оформились в единственное государство, они представляют из себя децентрализованное скопление кланов, находящихся на своей родной планете Альтам. \
		Интересы расы во внешней политике не представляют из себя ничего. Вульпканины погружены в распри и кровопролитные войны на своей планете. \
		Сотни тысяч беженцев-вульпканинов заполонили всю галактику; те, кто хочет мира своей нации, бегут от войны, им чужды идеи их соплеменников, из-за чего оставшиеся на Альтаме вульпканины буквально ненавидят кочующих собратьев.",

		"Культура вульпканинов - это небогатое, но многообразное наследие, которое развивается в условиях войны и поиске единства на Альтаме. \
		На протяжении всей войны вульпканинская культура потеряла многие кланы, племена и народности. \
		Вульпканины продолжают бороться между собой за единство и мирную жизнь на планете Альтам, стремясь достичь процветания и равновесия для своей расы.",

		"Представители расы вульпканинов являются отличными разнорабочими, которые без особых проблем выполняют свои обязанности - от уборщика до наёмника. \
		В частности, представители кланов - это относительно дешёвая рабочая сила, неприхотливая в быту и пище, готовая работать за скромную плату. \
		Практически все члены кланов отправляют часть заработанных средств своему родному клану. \
		Что касается беженцев, то они не особо проявляют активность, например, на политическом поприще.",
	)

/datum/species/vulpkanin/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Чувствительный нюх",
			SPECIES_PERK_DESC = "[plural_form] могут различать больше запахов и запоминать их.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "assistive-listening-systems",
			SPECIES_PERK_NAME = "Чувствительный слух",
			SPECIES_PERK_DESC = "[plural_form] лучше слышат, но более чувствительны к громким звукам, например, светошумовым гранатам.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire-alt",
			SPECIES_PERK_NAME = "Быстрый метаболизм",
			SPECIES_PERK_DESC = "[plural_form] быстрее тратят полезные вещества, потому чаще хотят есть.",
		),
	)

	return to_add

/datum/species/vulpkanin/get_scream_sound(mob/living/carbon/human/human)
	if(human.physique == MALE)
		return pick(
			'sound/mobs/humanoids/human/scream/malescream_1.ogg',
			'sound/mobs/humanoids/human/scream/malescream_2.ogg',
			'sound/mobs/humanoids/human/scream/malescream_3.ogg',
			'sound/mobs/humanoids/human/scream/malescream_4.ogg',
			'sound/mobs/humanoids/human/scream/malescream_5.ogg',
			'sound/mobs/humanoids/human/scream/malescream_6.ogg',
		)

	return pick(
		'sound/mobs/humanoids/human/scream/femalescream_1.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_2.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_3.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_4.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_5.ogg',
	)

/datum/species/vulpkanin/get_cough_sound(mob/living/carbon/human/human)
	if(human.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cough/female_cough1.ogg',
			'sound/mobs/humanoids/human/cough/female_cough2.ogg',
			'sound/mobs/humanoids/human/cough/female_cough3.ogg',
			'sound/mobs/humanoids/human/cough/female_cough4.ogg',
			'sound/mobs/humanoids/human/cough/female_cough5.ogg',
			'sound/mobs/humanoids/human/cough/female_cough6.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cough/male_cough1.ogg',
		'sound/mobs/humanoids/human/cough/male_cough2.ogg',
		'sound/mobs/humanoids/human/cough/male_cough3.ogg',
		'sound/mobs/humanoids/human/cough/male_cough4.ogg',
		'sound/mobs/humanoids/human/cough/male_cough5.ogg',
		'sound/mobs/humanoids/human/cough/male_cough6.ogg',
	)

/datum/species/vulpkanin/get_cry_sound(mob/living/carbon/human/human)
	if(human.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cry/female_cry1.ogg',
			'sound/mobs/humanoids/human/cry/female_cry2.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cry/male_cry1.ogg',
		'sound/mobs/humanoids/human/cry/male_cry2.ogg',
		'sound/mobs/humanoids/human/cry/male_cry3.ogg',
	)


/datum/species/vulpkanin/get_sneeze_sound(mob/living/carbon/human/human)
	if(human.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg'
	return 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg'

/datum/species/vulpkanin/get_laugh_sound(mob/living/carbon/human/human)
	if(!ishuman(human))
		return
	if(human.physique == FEMALE)
		return 'sound/mobs/humanoids/human/laugh/womanlaugh.ogg'
	return pick(
		'sound/mobs/humanoids/human/laugh/manlaugh1.ogg',
		'sound/mobs/humanoids/human/laugh/manlaugh2.ogg',
	)
