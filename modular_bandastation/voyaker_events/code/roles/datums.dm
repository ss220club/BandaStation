#define JOB_EXECUTOR "Исполнитель"
#define JOB_BLESSED_MEDIC "Медик \"Милосердия\""
#define JOB_BLESSED_GENETICIST "Генетик \"Милосердия\""
#define JOB_TECHNICAN "Техник АСБ \"Ковчег\""

/obj/item/card/id/advanced/blessed
	icon_state = "card_grey"

// Исполнитель
/datum/outfit/job/assistant
	name = "Исполнитель"
	uniform = /obj/item/clothing/under/hoodie_black
	shoes = /obj/item/clothing/shoes/jackboots
	id = /obj/item/card/id/advanced/black
	id_trim = /datum/id_trim/job/executor
	belt = /obj/item/storage/belt/military/army/tsf/full_pistol
	ears = /obj/item/radio/headset/headset_sec
	suit = /obj/item/clothing/suit/armor/vest
	gloves = /obj/item/clothing/gloves/color/black
	back = /obj/item/storage/backpack
	backpack_contents = list(
		/obj/item/holochip/thousand = 1
	)

/datum/job/assistant
	title = JOB_EXECUTOR
	description = "Вы только что пробудились в бункере после случившейся катастрофы. Вы не помните, на кого работали по контракту на планете. Теперь, ваша единственная цель - выбраться отсюда. Ходите в рейды, собирайте предметы, развивайте отношения с торговцами, выполняя их поручения."
	departments_list = list(
		/datum/job_department/assistant,
	)
	department_for_prefs = /datum/job_department/assistant

/datum/id_trim/job/executor
	assignment = "Исполнитель"
	trim_state = "trim_mime"
	job = /datum/job/assistant

//MARK: Фракция: "Милосердие".
// Медик "Милосердия"
/datum/outfit/job/medic_blessed
	name = "Медик \"Милосердия\""
	id = /obj/item/card/id/advanced/blessed
	id_trim = /datum/id_trim/job/medic_blessed
	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	ears = /obj/item/radio/headset/headset_med
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/latex/nitrile
	belt = /obj/item/storage/belt/medical/ert
	neck = /obj/item/clothing/neck/cloak/colorable_cloak
	pda_slot = /obj/item/modular_computer/pda/medical
	head = /obj/item/clothing/head/fedora/det_hat/noir
	mask = /obj/item/clothing/mask/gas/plaguedoctor
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger
	backpack_contents = list(
		/obj/item/holochip/thousand = 1,
		/obj/item/storage/medkit/surgery = 1,
		/obj/item/storage/medkit/toxin = 1,
		/obj/item/book/granter/crafting_recipe/medical_manual_light = 1,
		/obj/item/book/granter/crafting_recipe/medical_manual_medium = 1,
		/obj/item/stack/documents/blessing = 50,
		/obj/item/paper/fluff/eftk/blessed_artefacts = 1,
		/obj/item/paper/fluff/eftk/blessed_mutants = 1,
	)

/datum/job/doctor
	title = JOB_BLESSED_MEDIC
	description = "Вы - один из немногих уцелевших врачей на территории Нового Сиднея, посвятивший себя безвозмездной помощи всем выжившим на планете. Лечите Исполнителей после рейдов, устанавливайте импланты, или же - выдвигайтесь на помощь прямо в рейде, принимая взамен скромные пожертвования во благо вашей организации. Дарите Благостные грамоты Исполнителям за определенные заслуги. Но помните, что применение грубой силы - разрешено по вашему кодексу только по отношению к мутантам."
	departments_list = list(
		/datum/job_department/medical,
	)
	outfit = /datum/outfit/job/medic_blessed
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/medical
	family_heirlooms = list(/obj/item/storage/medkit/ancient/heirloom, /obj/item/scalpel, /obj/item/hemostat, /obj/item/circular_saw, /obj/item/retractor, /obj/item/cautery, /obj/item/statuebust/hippocratic)
	job_flags = STATION_JOB_FLAGS
	liver_traits = list(TRAIT_MEDICAL_METABOLISM)

/datum/id_trim/job/medic_blessed
	assignment = "Медик \"Милосердия\""
	trim_state = "trim_medicaldoctor"
	department_color = COLOR_MEDICAL_BLUE
	subdepartment_color = COLOR_MEDICAL_BLUE
	minimal_access = list(
		ACCESS_MECH_MEDICAL,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_PHARMACY,
		ACCESS_SURGERY,
		ACCESS_VIROLOGY,
		ACCESS_PARAMEDIC,
		ACCESS_PLUMBING,
		)
	job = /datum/job/doctor

// Генетик "Милосердия"
/datum/outfit/job/geneticist_blessed
	name = "Генетик \"Милосердия\""
	id = /obj/item/card/id/advanced/blessed
	id_trim = /datum/id_trim/job/geneticist_blessed
	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	ears = /obj/item/radio/headset/headset_med
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/latex/nitrile
	pda_slot = /obj/item/modular_computer/pda/geneticist
	head = /obj/item/clothing/head/fedora/det_hat/noir
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger
	backpack_contents = list(
		/obj/item/holochip/thousand = 1,
		/obj/item/sequence_scanner  = 1,
		/obj/item/book/granter/crafting_recipe/medical_manual_light = 1,
		/obj/item/book/granter/crafting_recipe/medical_manual_medium = 1,
		/obj/item/stack/documents/blessing = 50,
		/obj/item/paper/fluff/eftk/blessed_artefacts = 1,
		/obj/item/paper/fluff/eftk/blessed_mutants = 1,
	)

/datum/job/geneticist
	title = JOB_BLESSED_GENETICIST
	description = "Вы - один из немногих уцелевших врачей на территории Нового Сиднея, посвятивший себя безвозмездной помощи всем выжившим на планете. Выдавайте Исполнителям гены за пожертвования, или осуществляйте помощь братьям-медикам в лечении. Помните, что вам лучше оставаться в бункере на своём рабочем месте."
	departments_list = list(
		/datum/job_department/science,
	)
	outfit = /datum/outfit/job/geneticist_blessed
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/science
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/geneticist_blessed
	assignment = "Генетик \"Милосердия\""
	trim_state = "trim_medicaldoctor"
	department_color = COLOR_MEDICAL_BLUE
	subdepartment_color = COLOR_MEDICAL_BLUE
	minimal_access = list(
		ACCESS_MECH_MEDICAL,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_PHARMACY,
		ACCESS_SURGERY,
		ACCESS_VIROLOGY,
		ACCESS_PARAMEDIC,
		ACCESS_PLUMBING,
		ACCESS_SCIENCE,
		ACCESS_GENETICS
		)
	job = /datum/job/geneticist

//MARK: Сотрудники АСБ "Ковчег"
// Техник АСБ "Ковчег"
/datum/outfit/job/technican
	name = "Техник АСБ \"Ковчег\""
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/job/technican
	uniform = /obj/item/clothing/under/misc/overalls
	ears = /obj/item/radio/headset/heads/ce
	head = /obj/item/clothing/head/flatcap
	shoes = /obj/item/clothing/shoes/workboots
	suit = /obj/item/clothing/suit/apron/overalls
	gloves = /obj/item/clothing/gloves/color/yellow
	belt = /obj/item/storage/belt/utility/full/powertools
	pda_slot = /obj/item/modular_computer/pda/engineering
	backpack = /obj/item/storage/backpack
	satchel = /obj/item/storage/backpack/satchel
	duffelbag = /obj/item/storage/backpack/duffelbag
	messenger = /obj/item/storage/backpack/messenger
	backpack_contents = list(
		/obj/item/holochip/thousand = 2,
		/obj/item/stack/sheet/mineral/plasma/fifty = 1,
		/obj/item/stack/documents/trust_letter = 50,
		/obj/item/book/granter/crafting_recipe/equipment_manual_light = 1,
		/obj/item/book/granter/crafting_recipe/equipment_manual_medium = 1,
		/obj/item/book/granter/crafting_recipe/ammo_manual_light = 1,
		/obj/item/book/granter/crafting_recipe/ammo_manual_medium = 1,
	)

/datum/job/station_engineer
	title = JOB_TECHNICAN
	supervisors = "смотрителем бункера"
	description = "На вас выпало тяжелое время орудования молотком и напильником в условиях пост-апокалипсиса. Восстановите ваш топливный генератор, выкупите у Исполнителей детали, которых так не хватает в бункере, создавайте по заказам предметы снаряжения и боеприпасы. Помните - от вас зависит благополучие многих в бункере!"
	departments_list = list(
		/datum/job_department/engineering,
	)
	outfit = /datum/outfit/job/technican
	faction = FACTION_STATION
	total_positions = 2
	spawn_positions = 2
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/engineering
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS

/datum/id_trim/job/technican
	assignment = "Техник АСБ \"Ковчег\""
	trim_state = "trim_stationengineer"
	department_color = COLOR_ENGINEERING_ORANGE
	subdepartment_color = COLOR_ENGINEERING_ORANGE
	sechud_icon_state = SECHUD_STATION_ENGINEER
	minimal_access = list(
		ACCESS_AUX_BASE,
		ACCESS_CONSTRUCTION,
		ACCESS_ENGINEERING,
		ACCESS_ENGINE_EQUIP,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MECH_ENGINE,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINISAT,
		ACCESS_TCOMMS,
		ACCESS_TECH_STORAGE,
		)
	extra_access = list(
		ACCESS_ATMOSPHERICS,
		)
	template_access = list(
		ACCESS_CAPTAIN,
		ACCESS_CHANGE_IDS,
		ACCESS_CE,
		)
	job = /datum/job/station_engineer

