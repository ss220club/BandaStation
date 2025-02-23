// vulpkanin
#define SPECIES_VULPKANIN "vulpkanin"
#define BUTT_SPRITE_VULPKANIN "vulpkanin"
#define DEFAULT_SPRITE_LIST "default_sprites"
#define DNA_VULPKANIN_BODY_MARKINGS DNA_FEATURE_BLOCKS + 1
#define DNA_VULPKANIN_HEAD_MARKINGS DNA_FEATURE_BLOCKS + 2
#define DNA_VULPKANIN_HEAD_ACCESSORIES DNA_FEATURE_BLOCKS + 3
#define DNA_VULPKANIN_TAIL DNA_FEATURE_BLOCKS + 4
#define DNA_VULPKANIN_TAIL_MARKINGS DNA_FEATURE_BLOCKS + 5
#define DNA_VULPKANIN_FACIAL_HAIR DNA_FEATURE_BLOCKS + 6
#define DNA_FURCOLOR_1 DNA_FEATURE_BLOCKS + 7
#define DNA_FURCOLOR_2 DNA_FEATURE_BLOCKS + 8
#define DNA_FURCOLOR_3 DNA_FEATURE_BLOCKS + 9
#define DNA_FURCOLOR_4 DNA_FEATURE_BLOCKS + 10
#define DNA_FURCOLOR_5 DNA_FEATURE_BLOCKS + 11

// tajaran
#define SPECIES_TAJARAN "tajaran"
#define DNA_TAJARAN_BODY_MARKINGS DNA_FEATURE_BLOCKS + 12
#define DNA_TAJARAN_HEAD_MARKINGS DNA_FEATURE_BLOCKS + 13
#define DNA_TAJARAN_TAIL DNA_FEATURE_BLOCKS + 14
#define DNA_TAJARAN_TAIL_MARKINGS DNA_FEATURE_BLOCKS + 15
#define DNA_TAJARAN_FACIAL_HAIR DNA_FEATURE_BLOCKS + 16
#define DNA_FURCOLOR_TAJARAN_1 DNA_FEATURE_BLOCKS + 17
#define DNA_FURCOLOR_TAJARAN_2 DNA_FEATURE_BLOCKS + 18
#define DNA_FURCOLOR_TAJARAN_3 DNA_FEATURE_BLOCKS + 19
#define DNA_FURCOLOR_TAJARAN_4 DNA_FEATURE_BLOCKS + 20

#define DNA_MODULAR_BLOCKS_COUNT 20

#define HEAD_VULPKANIN (1<<16)
#define HEAD_TAJARAN (1<<17)

GLOBAL_LIST_INIT(first_names_female_vulp, world.file2list("strings/names/first_female_vulp.txt"))
GLOBAL_LIST_INIT(first_names_male_vulp, world.file2list("strings/names/first_male_vulp.txt"))
GLOBAL_LIST_INIT(last_names_vulp, world.file2list("strings/names/last_vulp.txt"))

GLOBAL_LIST_INIT(first_names_female_tajaran, world.file2list("strings/names/first_female_tajaran.txt"))
GLOBAL_LIST_INIT(first_names_male_tajaran, world.file2list("strings/names/first_male_tajaran.txt"))
GLOBAL_LIST_INIT(last_names_tajaran, world.file2list("strings/names/last_tajaran.txt"))

/datum/controller/subsystem/accessories
	// vulpkanin
	var/list/vulpkanin_body_markings_list
	var/list/vulpkanin_head_markings_list
	var/list/vulpkanin_head_accessories_list
	var/list/tails_list_vulpkanin
	var/list/vulpkanin_tail_markings_list
	var/list/vulpkanin_facial_hair_list
	// tajaran
	var/list/tajaran_body_markings_list
	var/list/tajaran_head_markings_list
	var/list/tails_list_tajaran
	var/list/tajaran_tail_markings_list
	var/list/tajaran_facial_hair_list

/datum/controller/subsystem/accessories/proc/init_modular_lists()
	// vulpkanin
	vulpkanin_body_markings_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/vulpkanin_body_markings, add_blank = TRUE)[DEFAULT_SPRITE_LIST]
	vulpkanin_head_markings_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/vulpkanin_head_markings, add_blank = TRUE)[DEFAULT_SPRITE_LIST]
	vulpkanin_head_accessories_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/vulpkanin_head_accessories, add_blank = TRUE)[DEFAULT_SPRITE_LIST]
	tails_list_vulpkanin = init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/vulpkanin, add_blank = FALSE)[DEFAULT_SPRITE_LIST]
	vulpkanin_tail_markings_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/vulpkanin_tail_markings, add_blank = TRUE)[DEFAULT_SPRITE_LIST]
	vulpkanin_facial_hair_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/vulpkanin_facial_hair, add_blank = TRUE)[DEFAULT_SPRITE_LIST]
	// tajaran
	tajaran_body_markings_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/tajaran_body_markings, add_blank = TRUE)[DEFAULT_SPRITE_LIST]
	tajaran_head_markings_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/tajaran_head_markings, add_blank = TRUE)[DEFAULT_SPRITE_LIST]
	tails_list_tajaran = init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/tajaran, add_blank = FALSE)[DEFAULT_SPRITE_LIST]
	tajaran_tail_markings_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/tajaran_tail_markings, add_blank = TRUE)[DEFAULT_SPRITE_LIST]
	tajaran_facial_hair_list = init_sprite_accessory_subtypes(/datum/sprite_accessory/tajaran_facial_hair, add_blank = TRUE)[DEFAULT_SPRITE_LIST]

/datum/controller/subsystem/accessories/PreInit()
	..()
	init_modular_lists()
