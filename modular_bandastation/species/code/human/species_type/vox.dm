/datum/species/vox
	name = "Вокс"
	plural_form = "Воксы"
	id = SPECIES_VOX
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
	)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

	species_language_holder = /datum/language_holder/vox

	mutantbrain = /obj/item/organ/brain/cybernetic/vox
	mutantheart = /obj/item/organ/heart/vox
	mutantlungs = /obj/item/organ/lungs/vox
	mutanteyes = /obj/item/organ/eyes/vox
	mutantears = /obj/item/organ/ears/cybernetic
	mutanttongue = /obj/item/organ/tongue/vox
	mutantliver = /obj/item/organ/liver/vox
	mutantstomach = /obj/item/organ/stomach/vox
	mutant_organs = list(
		/obj/item/organ/snout/vox = "Vox beak",
		/obj/item/organ/tail/vox = "Vox tail",
		/obj/item/organ/quills/vox = "Ruffhawk",
		/obj/item/organ/facial_quills/vox = "None",
	)
	exotic_bloodtype = /datum/blood_type/vox

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/vox,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/vox,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/vox,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/vox,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade/vox,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade/vox,
	)

	payday_modifier = 0.8
	outfit_important_for_life = /datum/outfit/vox

/datum/species/vox/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	give_important_for_life(equipping)

/datum/species/vox/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features[FEATURE_VOX_QUILLS_COLOR] = "#361512"
	human.dna.features[FEATURE_VOX_FACIAL_QUILLS_COLOR] = "#361512"
	human.dna.features[FEATURE_MUTANT_COLOR] = "#8a6036"
	human.dna.features[FEATURE_VOX_SNOUT_COLOR] = "#FFB906"
	human.set_eye_color("#9BBB64")
	human.update_body(is_creating = TRUE)

/datum/species/vox/get_physical_attributes()
	return "Вокс — небольшой прямоходящий гуманоид с внешностью, напоминающей смесь раптора и птицы. \
	Рост взрослого вокс-прималис обычно составляет около 100–150 сантиметров. \
	Тело покрыто жесткими кератиновыми чешуйками, под которыми располагается кожа, а на голове и иногда конечностях растут яркие перья. \
	Глаза узкие, часто флуоресцентные, снабжены двумя веками и мигательной перепонкой. \
	Вокс обладает мощным клювом и гибким цепким хвостом, используемым как противовес и способным частично выполнять функции третьей конечности. \
	Окраска кожи и перьев может значительно различаться, а на шее и иногда запястьях часто присутствуют характерные флуоресцентные отметины, имеющие важное социальное значение. \
	Воксы являются принципиально бесполыми существами и не способны к естественному размножению. \
	Их организм приспособлен к дыханию чистым азотом, тогда как кислород оказывает на него крайне разрушительное воздействие. \
	Наиболее необычной особенностью анатомии вокса является двойная структура мозга: органическая часть отвечает за физиологические процессы, тогда как личность и воспоминания хранятся в электронном мозговом стеке."

/datum/species/vox/get_species_description()
	return "Вид искусственно созданных прямоходящих гуманоидов, происходящих с неизвестных космических кораблей, известных как Ковчеги. \
	Воксы представляют собой крайне закрытую расу, о происхождении и создателях которой большинство других разумных видов практически ничего не знает. \
	Известные галактическому сообществу воксы относятся преимущественно к подвиду вокс-прималис — небольшим и приспособленным к разнообразной промышленной деятельности существам. \
	Их цивилизация строится вокруг Стаи и Ковчегов, огромных странствующих сооружений, одновременно являющихся домом, производственным комплексом, хранилищем ресурсов и центром их общества. \
	В отличие от большинства разумных видов, воксы не имеют родной планеты, привычного представления о семье или доме и не воспринимают собственное существование как единственную жизнь. \
	После смерти тела их мозговой стек может быть извлечен и помещен в новую оболочку, позволяя воксу продолжить существование в новом теле."

/datum/species/vox/get_species_lore()
	return list(
		"Происхождение воксов неизвестно. Они являются искусственно созданными существами, состоящими из органической оболочки и электронного мозгового стека. \
		Предполагается существование высших форм воксов — ауралис и апекс, однако даже сами прималис почти ничего о них не знают.",

		"Воксы обитают на гигантских космических кораблях, называемых Ковчегами. \
		Ковчеги служат одновременно домом, производственным комплексом, хранилищем ресурсов и центром жизни Стаи. \
		Их точное количество и местоположение неизвестно, а крупнейшие из них способны содержать сотни миллионов и даже миллиарды воксов.",

		"Жизнь вокса начинается с создания мозгового стека и выращивания органической оболочки. \
		После смерти тела стек может быть извлечен и помещен в новую оболочку, сохраняя большую часть воспоминаний и навыков. \
		Однако повреждение или потеря стека означает окончательную смерть, а ауралис способны признать отдельный стек неэффективным и прекратить его дальнейшее перерождение.",

		"Общество воксов строится вокруг Стаи. Каждый вокс создается с определенным предназначением и стремится приносить пользу своим сородичам. \
		Их поведение определяется Нерушимым кодексом: убивать как можно меньше, тратить как можно меньше, оберегать Ковчеги и материалы, а также постоянно приспосабливаться и развиваться. \
		Нарушение этих принципов может поставить под угрозу дальнейшее существование стека.",

		"Некоторые воксы покидают Ковчеги для изучения внешнего мира и получения новых знаний, становясь торговцами, рейдерами или наемными работниками. \
		Несмотря на возможность сотрудничества, воксы относятся к большинству других рас с настороженностью и часто воспринимают их как источник ресурсов или информации. \
		Большая часть сведений о цивилизации воксов остается неизвестной другим разумным видам."
	)

/datum/species/vox/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "microchip",
			SPECIES_PERK_NAME = "Питание электроникой",
			SPECIES_PERK_DESC = "[plural_form] способны питаться электронными компонентами, в том числе печатными платами.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Кибернетический мозг",
			SPECIES_PERK_DESC = "[plural_form] имеют мозговой стек, который уязвим к электромагнитным импульсам.",
		),
	)

	return to_add
