#define BASIC_KA_ENERGY_COST 5000
#define REPEATER_ENERGY_COST 1500

/obj/item/gun/energy/recharge/kinetic_accelerator/railgun
	name = "proto-kinetic railgun"
	desc = "Крайне громоздкая и мощная версия прото-кинетического ускорителя."
	icon = 'modular_bandastation/weapon/icons/ranged/mining.dmi'
	icon_state = "kineticrailgun"
	base_icon_state = "kineticrailgun"
	inhand_icon_state = "kineticgun"
	w_class = WEIGHT_CLASS_HUGE
	pin = /obj/item/firing_pin/wastes
	recharge_time = 3 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/railgun)
	item_flags = NONE
	obj_flags = UNIQUE_RENAME
	weapon_weight = WEAPON_HEAVY
	max_mod_capacity = 0 //no mods for this gun
	recoil = 3
	gun_flags = NOT_A_REAL_GUN
	disable_modification = TRUE

/obj/item/gun/energy/recharge/kinetic_accelerator/railgun/add_bayonet_point()
	AddComponent(/datum/component/bayonet_attachable, offset_x = 20, offset_y = 9)

/obj/item/gun/energy/recharge/kinetic_accelerator/railgun/examine_more(mob/user)
	. = ..()
	. += "Перед созданием современного и элегантного прото-кинетического ускорителя, команда исследований и разработок в области горнодобычи (MR&D) разработала множество вариантов. "
	. += "Многие из них оказались неудачными, включая этот, который был слишком громоздким и недостаточно эффективным. Недавно команда MR&D напилась и решила  «к чёрту, работаем», вернулась "
	. += "к более массивному дизайну, разогнала его и сделала рабочим — превратив его в то, что по сути представляет собой переносимый ускоритель частиц. "
	. += "Этот дизайн создает мощную, трудно контролируемую волну кинетической энергии, способную пробивать существ и наносить огромный урон. "
	. += "Единственная проблема — он настолько громоздкий, что для использования требуется обе руки, а технология оснащена ударником,  "
	. += "который запрещает его использование вблизи или на станции из-за его разрушительной силы."

/obj/item/gun/energy/recharge/kinetic_accelerator/repeater
	name = "proto-kinetic repeater"
	desc = "Вариация прото-кинетического ускорителя которая может совершить больше выстрелов перед перезарядкой."
	icon = 'modular_bandastation/weapon/icons/ranged/mining.dmi'
	icon_state = "kineticrepeater"
	base_icon_state = "kineticrepeater"
	inhand_icon_state = "kineticgun"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/repeater)
	item_flags = NONE
	obj_flags = UNIQUE_RENAME
	weapon_weight = WEAPON_LIGHT
	max_mod_capacity = 60

/obj/item/gun/energy/recharge/kinetic_accelerator/repeater/examine_more(mob/user)
	. = ..()
	. += "Во время пицце вечеринки в честь выпуска новых вариаций крашеров, членам команды MR&D разрешили взять только по одному кусочку. Один из участников воскликнул: «Хотелось бы больше чем один кусочек!» "
	. += "и другой ответил: «Я бы хотел стрелять ускорителем больше одного раза!» И так, прямо на месте появился репитер. "
	. += "Репитер жертвует мощностью ради возможности сделать три выстрела, прежде чем он уйдёт на перезарядку, при этом он может полностью перезарядиться за один раз. "
	. += "К сожалению, за этой функции в ускорителе меньше места для модификаций чем в обычном ускорителе."


/obj/item/gun/energy/recharge/kinetic_accelerator/shotgun
	name = "proto-kinetic shotgun"
	desc = "Прото-кинетический дробовик, вот и всё."
	icon = 'modular_bandastation/weapon/icons/ranged/mining.dmi'
	icon_state = "kineticshotgun"
	base_icon_state = "kineticshotgun"
	inhand_icon_state = "kineticgun"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/shotgun)
	item_flags = NONE
	obj_flags = UNIQUE_RENAME
	weapon_weight = WEAPON_LIGHT
	max_mod_capacity = 60

/obj/item/gun/energy/recharge/kinetic_accelerator/shotgun/examine_more(mob/user)
	. = ..()
	. += "Во время очередной пицце вечеринки, один работник MR&D принёс с собой игрушечный дробовик с пластиковыми пульками, и в итоге случайно попал в трёх коллег "
	. += "одним выстрелом. К директору MR&D пришла гениальная идея, создать прото-кинетический дробовик. "
	. += "В прото-кинетическом дробовике уменьшено время перезарядки и место для модификаторов в пользу трех "
	. += "одновременных выстрелов, но с меньшой дальностью и уроном. "
	. += "В общем урон будет больше чем у обычного КА, но индивидуальные попадания будут слабей."

/obj/item/gun/energy/recharge/kinetic_accelerator/pistol
	name = "proto-kinetic pistol"
	desc = "Уменьшенная версия прото-кинетического ускорителя, имеет в раза больше места для модификаторов."
	icon = 'modular_bandastation/weapon/icons/ranged/mining.dmi'
	icon_state = "kineticpistol"
	base_icon_state = "kineticpistol"
	inhand_icon_state = "kineticgun"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/pistol)
	item_flags = NONE
	obj_flags = UNIQUE_RENAME
	weapon_weight = WEAPON_LIGHT
	max_mod_capacity = 200

/obj/item/gun/energy/recharge/kinetic_accelerator/pistol/examine_more(mob/user)
	. = ..()
	. += "Данная версия прото-кинетического ускорителя появилась по просьбе шахтёров, мол они хотят сделать свой КА на их вкус и цвет"

/obj/item/gun/energy/recharge/kinetic_accelerator/shockwave
	name = "proto-kinetic shockwave"
	desc = "Версия прото-кинетического ускорителя которая создаёт ударную волну вокруг пользователя."
	icon = 'modular_bandastation/weapon/icons/ranged/mining.dmi'
	icon_state = "kineticshockwave"
	base_icon_state = "kineticshockwave"
	inhand_icon_state = "kineticgun"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/shockwave)
	item_flags = NONE
	obj_flags = UNIQUE_RENAME
	weapon_weight = WEAPON_LIGHT
	max_mod_capacity = 60

/obj/item/gun/energy/recharge/kinetic_accelerator/shockwave/examine_more(mob/user)
	. = ..()
	. += "Честно говоря, мы абсолютно не представляем, как команда MR&D придумала это — всё, что мы знаем, это то, что было много пива. "
	. += "Эта версия КА бьёт по земле, создавая ударную волну вокруг пользователя, мощностью не уступающую базовому КА. "
	. += "Единственные минусы — уменьшенная вместимость модификаторов, ограниченная дальность и более долгая перезарядка. Но для горных работ он хорош."

/obj/item/ammo_casing/energy/kinetic/railgun
	projectile_type = /obj/projectile/kinetic/railgun
	select_name = "kinetic"
	e_cost = BASIC_KA_ENERGY_COST
	fire_sound = 'sound/items/weapons/beam_sniper.ogg'

/obj/item/ammo_casing/energy/kinetic/repeater
	projectile_type = /obj/projectile/kinetic/repeater
	select_name = "kinetic"
	e_cost = REPEATER_ENERGY_COST
	fire_sound = 'sound/items/weapons/kinetic_accel.ogg'

/obj/item/ammo_casing/energy/kinetic/shotgun
	projectile_type = /obj/projectile/kinetic/shotgun
	select_name = "kinetic"
	e_cost = BASIC_KA_ENERGY_COST
	pellets = 3
	variance = 50
	fire_sound = 'sound/items/weapons/kinetic_accel.ogg'

/obj/item/ammo_casing/energy/kinetic/pistol
	projectile_type = /obj/projectile/kinetic/pistol
	select_name = "kinetic"
	e_cost = BASIC_KA_ENERGY_COST
	fire_sound = 'sound/items/weapons/kinetic_accel.ogg'

/obj/item/ammo_casing/energy/kinetic/shockwave
	projectile_type = /obj/projectile/kinetic/shockwave
	select_name = "kinetic"
	e_cost = BASIC_KA_ENERGY_COST
	pellets = 8
	variance = 360
	fire_sound = 'sound/items/weapons/gun/general/cannon.ogg'

/obj/projectile/kinetic/railgun
	name = "hyper kinetic force"
	icon_state = null
	damage = 100
	damage_type = BRUTE
	armor_flag = BOMB
	range = 7
	log_override = TRUE
	pressure_decrease = 0.10
	speed = 5
	projectile_piercing = PASSMOB

/obj/projectile/kinetic/repeater
	name = "rapid kinetic force"
	icon_state = null
	damage = 20
	damage_type = BRUTE
	armor_flag = BOMB
	range = 4
	log_override = TRUE

/obj/projectile/kinetic/shotgun
	name = "split kinetic force"
	icon_state = null
	damage = 20
	damage_type = BRUTE
	armor_flag = BOMB
	range = 3
	log_override = TRUE

/obj/projectile/kinetic/pistol
	name = "light kinetic force"
	icon_state = null
	damage = 10
	damage_type = BRUTE
	armor_flag = BOMB
	range = 3
	log_override = TRUE

/obj/projectile/kinetic/shockwave
	name = "concussive kinetic force"
	icon_state = null
	damage = 40
	damage_type = BRUTE
	armor_flag = BOMB
	range = 1
	log_override = TRUE
//pins
/obj/item/firing_pin/wastes
	name = "Wastes firing pin"
	desc = "Этот предохранительный ударник позволяет стрелять из оружия только снаружи, на пустошах лаваленда или на его спутнике."
	fail_message = "Проверка на пустоши не удалась! - Сначала попробуйте отойти подальше от станции."
	pin_hot_swappable = FALSE
	pin_removable = FALSE
	var/list/wastes = list(/area/icemoon/underground/unexplored/rivers,
							/area/icemoon/surface/outdoors,
							/area/icemoon/surface/outdoors/unexplored/rivers/no_monsters,
							/area/icemoon/underground/unexplored/rivers/deep/shoreline,
							/area/icemoon/underground/explored,
							/area/lavaland/surface/outdoors,
							/area/lavaland/surface/outdoors/unexplored/danger,
							/area/lavaland/surface/outdoors/unexplored,
							/area/lavaland/surface/outdoors/explored,
							/area/ruin/)

/obj/item/firing_pin/wastes/pin_auth(mob/living/user)
	if(!istype(user))
		return FALSE
	if (is_type_in_list(get_area(user), wastes))
		return TRUE
	return FALSE
