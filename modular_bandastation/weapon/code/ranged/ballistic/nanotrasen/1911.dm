/obj/item/gun/ballistic/automatic/pistol/m1911
	desc = "Классический пистолет калибра .45 с небольшой емкостью магазина."
	icon = 'modular_bandastation/weapon/icons/ranged/ballistic40x32.dmi'
	recoil = 0.5
	unique_reskin = list(
		"Default" = "m1911",
		"Blue" = "m1911blue",
	)

/obj/item/gun/ballistic/automatic/pistol/m1911/chimpgun
	desc = "Для обезьяны-мафиози, которая всегда в движении. Использует патроны калибра .45 и имеет характерный запах бананов."
	icon_state = "m1911gold"
	recoil = 0.1

/obj/item/gun/ballistic/automatic/pistol/m1911/gold
	name = "gold trimmed m1911"
	desc = parent_type::desc + " Теперь отделанный золотом."
	icon_state = "m1911gold"
	unique_reskin = list(
		"Default" = "m1911gold",
		"Blue" = "m1911gold_blue",
	)
/obj/item/gun/ballistic/automatic/pistol/m1911/m45a5
	name = "M45A5 'Rowland'"
	desc = "Модернизированная версия легендарного M1911 в калибре .456 Magnum, в настоящее время широко распространенная среди высокопоставленных сотрудников Нанотрейзен."
	icon_state = "m45a5"
	accepted_magazine_type = /obj/item/ammo_box/magazine/m45a5
	recoil = 1
