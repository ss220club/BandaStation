/datum/loadout_category/uniforms
	category_name = "Униформы"
	category_ui_icon = FA_ICON_CIRCLE_USER
	type_to_generate = /datum/loadout_item/uniforms
	tab_order = /datum/loadout_category/head::tab_order + 1

/datum/loadout_item/uniforms
	abstract_type = /datum/loadout_item/uniforms

/datum/loadout_item/glasses/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(outfit.uniform)
		LAZYADD(outfit.backpack_contents, outfit.uniform)
	outfit.uniform = item_path

/datum/loadout_item/uniforms/roman_armor
    name = "Римская броня"
    item_path = /obj/item/clothing/under/costume/roman

/datum/loadout_item/uniforms/owl_uniform
    name = "униформа совы"
    item_path = /obj/item/clothing/under/costume/owl

/datum/loadout_item/uniforms/griffin_uniform
    name = "униформа грифона"
    item_path = /obj/item/clothing/under/costume/griffin

/datum/loadout_item/uniforms/blue_schoolgirl_uniform
    name = "синяя униформа школьницы"
    item_path = /obj/item/clothing/under/costume/schoolgirl

/datum/loadout_item/uniforms/red_schoolgirl_uniform
    name = "красная униформа школьницы"
    item_path = /obj/item/clothing/under/costume/schoolgirl/red

/datum/loadout_item/uniforms/green_schoolgirl_uniform
    name = "зелёная униформа школьницы"
    item_path = /obj/item/clothing/under/costume/schoolgirl/green

/datum/loadout_item/uniforms/orange_schoolgirl_uniform
    name = "оранжевая униформа школьницы"
    item_path = /obj/item/clothing/under/costume/schoolgirl/orange

/datum/loadout_item/uniforms/pirate_outfit
    name = "пиратский наряд"
    item_path = /obj/item/clothing/under/costume/pirate

/datum/loadout_item/uniforms/soviet_uniform
    name = "советская униформа"
    item_path = /obj/item/clothing/under/costume/soviet

/datum/loadout_item/uniforms/kilt
    name = "килт"
    item_path = /obj/item/clothing/under/costume/kilt

/datum/loadout_item/uniforms/highlander_kilt
    name = "килт горца"
    item_path = /obj/item/clothing/under/costume/kilt/highlander

/datum/loadout_item/uniforms/gladiator_uniform
    name = "униформа гладиатора"
    item_path = /obj/item/clothing/under/costume/gladiator

/datum/loadout_item/uniforms/maid_costume
    name = "костюм горничной"
    item_path = /obj/item/clothing/under/costume/maid

/datum/loadout_item/uniforms/geisha_suit
    name = "костюм гейши"
    item_path = /obj/item/clothing/under/costume/geisha

/datum/loadout_item/uniforms/villain_suit
    name = "костюм злодея"
    item_path = /obj/item/clothing/under/costume/villain

/datum/loadout_item/uniforms/sailor_suit
    name = "униформа моряка"
    item_path = /obj/item/clothing/under/costume/sailor

/datum/loadout_item/uniforms/yellow_performer_outfit
    name = "жёлтый костюм исполнителя"
    item_path = /obj/item/clothing/under/costume/singer/yellow

/datum/loadout_item/uniforms/blue_performer_outfit
    name = "синий костюм исполнителя"
    item_path = /obj/item/clothing/under/costume/singer/blue

/datum/loadout_item/uniforms/mummy_wrapping
    name = "обёртка мумии"
    item_path = /obj/item/clothing/under/costume/mummy

/datum/loadout_item/uniforms/scarecrow_clothes
    name = "одежда пугала"
    item_path = /obj/item/clothing/under/costume/scarecrow

/datum/loadout_item/uniforms/draculass_coat
    name = "плащ Дракулы"
    item_path = /obj/item/clothing/under/costume/draculass

/datum/loadout_item/uniforms/doctor_freeze_jumpsuit
    name = "комбинезон доктора Фриза"
    item_path = /obj/item/clothing/under/costume/drfreeze

/datum/loadout_item/uniforms/foam_lobster_suit
    name = "костюм лобстера"
    item_path = /obj/item/clothing/under/costume/lobster

/datum/loadout_item/uniforms/skeleton_jumpsuit
    name = "комбинезон скелета"
    item_path = /obj/item/clothing/under/costume/skeleton

/datum/loadout_item/uniforms/mech_pilot_suit
    name = "костюм пилота меха"
    item_path = /obj/item/clothing/under/costume/mech_suit

/datum/loadout_item/uniforms/russian_officer_uniform
    name = "форма русского офицера"
    item_path = /obj/item/clothing/under/costume/russian_officer

/datum/loadout_item/uniforms/buttondown_shirt_slacks
    name = "рубашка на пуговицах с брюками"
    item_path = /obj/item/clothing/under/costume/buttondown/slacks

/datum/loadout_item/uniforms/buttondown_shirt_shorts
    name = "рубашка на пуговицах с шортами"
    item_path = /obj/item/clothing/under/costume/buttondown/shorts

/datum/loadout_item/uniforms/buttondown_shirt_skirt
    name = "рубашка на пуговицах с юбкой"
    item_path = /obj/item/clothing/under/costume/buttondown/skirt

/datum/loadout_item/uniforms/deckers_outfit
    name = "наряд Декеров"
    item_path = /obj/item/clothing/under/costume/deckers

/datum/loadout_item/uniforms/football_uniform
    name = "футбольная форма"
    item_path = /obj/item/clothing/under/costume/football_suit

/datum/loadout_item/uniforms/swag_outfit
    name = "наряд Swag"
    item_path = /obj/item/clothing/under/costume/swagoutfit

/datum/loadout_item/uniforms/referee_uniform
    name = "форма рефери"
    item_path = /obj/item/clothing/under/costume/referee

/datum/loadout_item/uniforms/comedian_suit
    name = "костюм комика"
    item_path = /obj/item/clothing/under/costume/joker

/datum/loadout_item/uniforms/yuri_initiate_jumpsuit
    name = "комбинезон юрия-инициата"
    item_path = /obj/item/clothing/under/costume/yuri

/datum/loadout_item/uniforms/dutch_suit
    name = "костюм Датча"
    item_path = /obj/item/clothing/under/costume/dutch

/datum/loadout_item/uniforms/martial_artist_gi
    name = "ги боевого мастера"
    item_path = /obj/item/clothing/under/costume/gi

/datum/loadout_item/uniforms/sacred_gi
    name = "священное ги"
    item_path = /obj/item/clothing/under/costume/gi/goku

/datum/loadout_item/uniforms/traditional
	name = "Традиционный костюм"
	item_path = /obj/item/clothing/under/costume/traditional

/datum/loadout_item/uniforms/loincloth
	name = "Кожаная набедренная повязка"
	item_path = /obj/item/clothing/under/costume/loincloth

/datum/loadout_item/uniforms/henchmen
	name = "Комбинезон приспешника"
	item_path = /obj/item/clothing/under/costume/henchmen

/datum/loadout_item/uniforms/gamberson
	name = "Гамбезон реконструктора"
	item_path = /obj/item/clothing/under/costume/gamberson

/datum/loadout_item/uniforms/gamberson_military
	name = "Гамбезон мечника"
	item_path = /obj/item/clothing/under/costume/gamberson/military

/datum/loadout_item/uniforms/pj_red
	name = "Красная пижама"
	item_path = /obj/item/clothing/under/misc/pj/red

/datum/loadout_item/uniforms/pj_blue
	name = "Синяя пижама"
	item_path = /obj/item/clothing/under/misc/pj/blue

/datum/loadout_item/uniforms/patriotsuit
	name = "Патриотический костюм"
	item_path = /obj/item/clothing/under/misc/patriotsuit

/datum/loadout_item/uniforms/mailman
	name = "Комбинезон почтальона"
	item_path = /obj/item/clothing/under/misc/mailman

/datum/loadout_item/uniforms/psyche
	name = "Психоделический комбинезон"
	item_path = /obj/item/clothing/under/misc/psyche

/datum/loadout_item/uniforms/burial
	name = "Погребальные одежды"
	item_path = /obj/item/clothing/under/misc/burial

/datum/loadout_item/uniforms/overalls
	name = "Рабочий комбинезон"
	item_path = /obj/item/clothing/under/misc/overalls

/datum/loadout_item/uniforms/assistantformal
	name = "Формальная униформа ассистента"
	item_path = /obj/item/clothing/under/misc/assistantformal

/datum/loadout_item/uniforms/bouncer
	name = "Форма вышибалы"
	item_path = /obj/item/clothing/under/misc/bouncer

/datum/loadout_item/uniforms/syndicate_souvenir
	name = "Сувенирная футболка Синдиката"
	item_path = /obj/item/clothing/under/misc/syndicate_souvenir

/datum/loadout_item/uniforms/slacks
	name = "Широкие брюки"
	item_path = /obj/item/clothing/under/pants/slacks

/datum/loadout_item/uniforms/jeans
	name = "Джинсы"
	item_path = /obj/item/clothing/under/pants/jeans

/datum/loadout_item/uniforms/track_pants
	name = "Спортивные штаны"
	item_path = /obj/item/clothing/under/pants/track

/datum/loadout_item/uniforms/camo_pants
	name = "Камуфляжные штаны"
	item_path = /obj/item/clothing/under/pants/camo

/datum/loadout_item/uniforms/greensuit
    name = "Зелёный костюм"
    item_path = /obj/item/clothing/under/suit/green

/datum/loadout_item/uniforms/redsuit
    name = "Красный костюм"
    item_path = /obj/item/clothing/under/suit/red

/datum/loadout_item/uniforms/charcoalsuit
    name = "Угольный костюм"
    item_path = /obj/item/clothing/under/suit/charcoal

/datum/loadout_item/uniforms/navysuit
    name = "Тёмно-синий костюм"
    item_path = /obj/item/clothing/under/suit/navy

/datum/loadout_item/uniforms/burgundysuit
    name = "Бургундский костюм"
    item_path = /obj/item/clothing/under/suit/burgundy

/datum/loadout_item/uniforms/checkeredsuit
    name = "Клетчатый костюм"
    item_path = /obj/item/clothing/under/suit/checkered

/datum/loadout_item/uniforms/beigesuit
    name = "Бежевый костюм"
    item_path = /obj/item/clothing/under/suit/beige

/datum/loadout_item/uniforms/blacksuit
    name = "Чёрный двубортный костюм"
    item_path = /obj/item/clothing/under/suit/black

/datum/loadout_item/uniforms/blacksuitskirt
    name = "Чёрный костюм с юбкой"
    item_path = /obj/item/clothing/under/suit/black/skirt

/datum/loadout_item/uniforms/whitesuit
    name = "Белый костюм"
    item_path = /obj/item/clothing/under/suit/white

/datum/loadout_item/uniforms/whitesuitskirt
    name = "Белая юбка-костюм"
    item_path = /obj/item/clothing/under/suit/white/skirt

/datum/loadout_item/uniforms/tansuit
    name = "Жёлтый костюм"
    item_path = /obj/item/clothing/under/suit/tan

/datum/loadout_item/uniforms/waitersoutfit
    name = "Официантский наряд"
    item_path = /obj/item/clothing/under/suit/waiter

/datum/loadout_item/uniforms/tuxedo
    name = "Смокинг"
    item_path = /obj/item/clothing/under/suit/tuxedo

/datum/loadout_item/uniforms/stripeddress
    name = "Полосатое платье"
    item_path = /obj/item/clothing/under/dress/striped

/datum/loadout_item/uniforms/sailordress
    name = "Морское платье"
    item_path = /obj/item/clothing/under/dress/sailor

/datum/loadout_item/uniforms/weddingdress
    name = "Свадебное платье"
    item_path = /obj/item/clothing/under/dress/wedding_dress

/datum/loadout_item/uniforms/eveninggown
    name = "Вечернее платье"
    item_path = /obj/item/clothing/under/dress/eveninggown

/datum/loadout_item/uniforms/cardiganskirt
    name = "Юбка-кардиган"
    item_path = /obj/item/clothing/under/dress/skirt

/datum/loadout_item/uniforms/plaidskirt
    name = "Клетчатая юбка"
    item_path = /obj/item/clothing/under/dress/skirt/plaid

/datum/loadout_item/uniforms/turtleskirt
    name = "Джемпер-юбка"
    item_path = /obj/item/clothing/under/dress/skirt/turtleskirt

/datum/loadout_item/uniforms/tangodress
    name = "Танцевальное платье"
    item_path = /obj/item/clothing/under/dress/tango

/datum/loadout_item/uniforms/sundress
    name = "Летнее платье"
    item_path = /obj/item/clothing/under/dress/sundress

///Т0
/datum/loadout_item/uniforms/yellowgreen_skirt
	name = "жёлто-зеленая юбка"
	item_path = /obj/item/clothing/under/yellowgreen_skirt

///Т0
/datum/loadout_item/uniforms/aqua_skirt
	name = "морская юбка"
	item_path = /obj/item/clothing/under/aqua_skirt

///Т0
/datum/loadout_item/uniforms/black_skirt
	name = "черная юбка"
	item_path = /obj/item/clothing/under/black_skirt

///Т0
/datum/loadout_item/uniforms/blue_skirt
	name = "синяя юбка"
	item_path = /obj/item/clothing/under/blue_skirt

///Т0
/datum/loadout_item/uniforms/brown_skirt
	name = "коричневая юбка"
	item_path = /obj/item/clothing/under/brown_skirt

///Т0
/datum/loadout_item/uniforms/darkblue_skirt
	name = "тёмно-синяя юбка"
	item_path = /obj/item/clothing/under/darkblue_skirt

///Т0
/datum/loadout_item/uniforms/darkred_skirt
	name = "тёмно-красная юбка"
	item_path = /obj/item/clothing/under/darkred_skirt

///Т0
/datum/loadout_item/uniforms/green_skirt
	name = "зеленая юбка"
	item_path = /obj/item/clothing/under/green_skirt

///Т0
/datum/loadout_item/uniforms/grey_skirt
	name = "серая юбка"
	item_path = /obj/item/clothing/under/grey_skirt

///Т0
/datum/loadout_item/uniforms/lightblue_skirt
	name = "светло-синяя юбка"
	item_path = /obj/item/clothing/under/lightblue_skirt

///Т0
/datum/loadout_item/uniforms/lightbrown_skirt
	name = "светло-коричневая юбка"
	item_path = /obj/item/clothing/under/lightbrown_skirt

///Т0
/datum/loadout_item/uniforms/lightgreen_skirt
	name = "светло-зеленая юбка"
	item_path = /obj/item/clothing/under/lightgreen_skirt

///Т0
/datum/loadout_item/uniforms/lightpurple_skirt
	name = "светло-фиолетовая юбка"
	item_path = /obj/item/clothing/under/lightpurple_skirt

///Т0
/datum/loadout_item/uniforms/lightred_skirt
	name = "светло-красная юбка"
	item_path = /obj/item/clothing/under/lightred_skirt

///Т0
/datum/loadout_item/uniforms/orange_skirt
	name = "оранжевая юбка"
	item_path = /obj/item/clothing/under/orange_skirt

///Т0
/datum/loadout_item/uniforms/pink_skirt
	name = "розовая юбка"
	item_path = /obj/item/clothing/under/pink_skirt

///Т0
/datum/loadout_item/uniforms/purple_skirt
	name = "фиолетовая юбка"
	item_path = /obj/item/clothing/under/purple_skirt

///Т0
/datum/loadout_item/uniforms/prisoner_skirt
	name = "юбка преступника"
	item_path = /obj/item/clothing/under/prisoner_skirt

///Т0
/datum/loadout_item/uniforms/rainbow_skirt
	name = "радужная юбка"
	item_path = /obj/item/clothing/under/rainbow_skirt

///Т0
/datum/loadout_item/uniforms/red_skirt
	name = "красная юбка"
	item_path = /obj/item/clothing/under/red_skirt

///Т0
/datum/loadout_item/uniforms/white_skirt
	name = "белая юбка"
	item_path = /obj/item/clothing/under/white_skirt

///Т0
/datum/loadout_item/uniforms/yellow_skirt
	name = "жёлтая юбка"
	item_path = /obj/item/clothing/under/yellow_skirt

///Т4
/datum/loadout_item/uniforms/katarina_suit
	name = "Костюм Катарины"
	item_path = /obj/item/clothing/under/costume/katarina_suit

///Т4
/datum/loadout_item/uniforms/katarina_cybersuit
	name = "Кибер-костюм Катарины"
	item_path = /obj/item/clothing/under/costume/katarina_cybersuit
