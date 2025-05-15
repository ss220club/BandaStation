/obj/item/melee/katana_tsf
    name = "Ночная Стужа"
    desc = "Неоновая энергетическая катана синего цвета, сделанная в лучших традициях современных мастеров-мечников Транс-Солнечной Федерации и являющаяся уникальной в своём роде, благодаря добавлению в качестве материала блюспэйс-кристаллов. \
	        Небольшие их вкрапления находятся в гарде и рукоятке, основная же, заряженная часть - непосредственно составляет само лезвие. \
			Основа сделана из закаленной стали прямиком с Адомая, являющаяся самой крепкой в Галактике. \
			Энергия кристаллов настолько сжалась внутри клинка, что вы чувствуете очень пронзительный холод, едва только прикоснувшись к этому лезвию. \
			Судя по всему, он позволяет замораживать своих обидчиков по нанесению серии ударов, при этом проходя через их броню, как нож сквозь масло. \
			Легкость рукоятки, сделанной из плазменного полимера, позволяет наносить удары с завидной быстротой. \
			Этот клинок - настоящее воплощение холодного нрава его владельца. \
			Надпись на рукояти гласит - Перед вами один из двух образцов гениальных творений мастера Фигерса - сделанных по заказу Мистера К."
    icon = 'modular_bandastation/objects/icons/obj/weapons/sword.dmi'
    icon_state = 'katana_tsf'
    inhand_icon_state = "katana_tsf"
    icon_angle = 180
    lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/weapons/melee_lefthand.dmi'
    righthand_file = 'modular_bandastation/objects/icons/mob/inhands/weapons/melee_righthand.dmi'
    worn_icon_state = "katana_tsf"
    slot_flags = ITEM_SLOT_BELT
    force = 25
    armour_penetration = 70
    block_chance = 60

/obj/item/melee/katana_tsf/chill(mob/living/target, mob/living/user)
	target.apply_status_effect(/datum/status_effect/void_chill, 3)
