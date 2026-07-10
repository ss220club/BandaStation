/obj/item/ammo_box/magazine/c9x25mm_pistol/bs
	name = "pistol magazine (9x25mm NT BS)"
	desc = parent_type::desc + "<br>Содержит экспериментальные патроны с БС пулями."
	ammo_band_color = COLOR_AMMO_ICEBLOX
	ammo_type = /obj/item/ammo_casing/c9x25mm/bs

/obj/item/ammo_box/magazine/c9x25mm_pistol/stendo/bs
	name = "extended pistol magazine (9x25mm NT BS)"
	desc = parent_type::desc + "<br>Содержит эксперементальные патроны с БС пулями."
	ammo_band_color = COLOR_AMMO_ICEBLOX
	ammo_type = /obj/item/ammo_casing/c9x25mm/bs

/obj/item/ammo_box/magazine/c9x25mm_pistol/bs/admin
	name = "pistol magazine (9x25mm NT BS-M)"
	desc = parent_type::desc + "<br>Содержит эксперементальные патроны с БС пулями. Почему-то они пушистые и кажется, жужжат как моли? Странно."
	ammo_band_color = COLOR_ADMIN_PINK
	ammo_type = /obj/item/ammo_casing/c9x25mm/bs/admin

/obj/item/ammo_box/magazine/c9x25mm_pistol/bs/admin/rubber
	name = "pistol magazine (9x25mm NT BS-MR)"
	ammo_type = /obj/item/ammo_casing/c9x25mm/bs/admin/rubber

/obj/item/ammo_box/magazine/cm5/bs
	name = "SMG magazine (9x25mm NT BS)"
	desc = parent_type::desc + "<br>Содержит эксперементальные патроны с БС пулями."
	ammo_band_color = COLOR_AMMO_TRUESTRIKE
	ammo_type = /obj/item/ammo_casing/c9x25mm/bs

/obj/item/ammo_box/magazine/smgm9mm
	icon = 'modular_bandastation/weapon/icons/ranged/ammo.dmi'
	ammo_band_icon = "+smg9mm_ammo_band"
	ammo_band_color = null

/obj/item/ammo_box/magazine/smgm9mm/rubber
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c9mm/rubber

/obj/item/ammo_box/magazine/smgm9mm/hp
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c9mm/hp

// MARK: 4.6x30mm
/obj/item/ammo_box/magazine/wt550m9/wtrubber
	name = "WT-550 magazine (4.6x30mm rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c46x30mm/rubber

// MARK: Eland / Takbok - TSF revolvers
/obj/item/ammo_box/magazine/internal/cylinder/eland
	ammo_type = /obj/item/ammo_casing/c35sol
	caliber = CALIBER_SOL35SHORT
	max_ammo = 8

/obj/item/ammo_box/magazine/internal/cylinder/eland/army
	ammo_type = /obj/item/ammo_casing/c38
	caliber = CALIBER_38
	max_ammo = 6

/obj/item/ammo_box/magazine/internal/cylinder/takbok
	ammo_type = /obj/item/ammo_casing/a50ae
	caliber = CALIBER_50AE
	max_ammo = 5

// MARK: .50 pistol/smg mags
/obj/item/ammo_box/magazine/c585sol
	name = "pistol magazine (.585 Sol)"
	desc = "Магазин стандартного размера для пистолетов ТСФ калибра .585 Sol, вмещает 10 патронов. Подходит для пистолетов Skild."
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "pistol_585_standart"
	base_icon_state = "pistol_585_standart"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_SMALL
	ammo_type = /obj/item/ammo_casing/c585sol
	caliber = CALIBER_585SOL
	max_ammo = 10
	ammo_band_icon = "+c585sol_mag_ammo_band"
	ammo_band_color = null

/obj/item/ammo_box/magazine/c585sol/ap
	name = "pistol magazine (.585 Sol AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c585sol/ap

/obj/item/ammo_box/magazine/c585sol/rubber
	name = "pistol magazine (.585 Sol rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c585sol/rubber

/obj/item/ammo_box/magazine/c585sol/hp
	name = "pistol magazine (.585 Sol HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c585sol/hp

/obj/item/ammo_box/magazine/c585sol/incendiary
	name = "pistol magazine (.585 Sol incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c585sol/incendiary

/obj/item/ammo_box/magazine/c585sol/extended
	name = "extended pistol magazine (.585 Sol)"
	desc = "Увеличенный магазин для пистолетов ТСФ калибра .585 Sol, вмещает 25 патронов."
	icon_state = "pistol_585_extended"
	base_icon_state = "pistol_585_extended"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 25

/obj/item/ammo_box/magazine/c585sol/extended/ap
	name = "extended pistol magazine (.585 Sol AP)"
	MAGAZINE_TYPE_ARMORPIERCE
	ammo_type = /obj/item/ammo_casing/c585sol/ap

/obj/item/ammo_box/magazine/c585sol/extended/rubber
	name = "extended pistol magazine (.585 Sol rubber)"
	desc = parent_type::desc + "<br>Содержит нелетальные травматические патроны с резиновой пулей."
	ammo_band_color = COLOR_AMMO_RUBBER
	ammo_type = /obj/item/ammo_casing/c585sol/rubber

/obj/item/ammo_box/magazine/c585sol/extended/hp
	name = "extended pistol magazine (.585 Sol HP)"
	MAGAZINE_TYPE_HOLLOWPOINT
	ammo_type = /obj/item/ammo_casing/c585sol/hp

/obj/item/ammo_box/magazine/c585sol/extended/incendiary
	name = "extended pistol magazine (.585 Sol incendiary)"
	MAGAZINE_TYPE_INCENDIARY
	ammo_type = /obj/item/ammo_casing/c585sol/incendiary

/obj/item/ammo_box/magazine/c585sol/spawns_empty
	start_empty = TRUE

// MARK: .980 TSF GL
/obj/item/ammo_box/magazine/c980_grenade
	name = "Kiboko grenade box (.980 Tydhouer)"
	desc = "Магазин стандартного размера для гранат .980 \"Тайдхойер\", вмещает четыре снаряда."
	icon = 'modular_bandastation/voyaker_events/icons/weapon/ammo.dmi'
	icon_state = "granata_standard"
	multiple_sprites = AMMO_BOX_FULL_EMPTY
	w_class = WEIGHT_CLASS_SMALL
	ammo_type = /obj/item/ammo_casing/c980grenade
	caliber = CALIBER_980TYDHOUER
	max_ammo = 4

/obj/item/ammo_box/magazine/c980_grenade/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c980_grenade/phosphor
	name = "Kiboko grenade box (.980 Tydhouer Phosphor)"
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel/phosphor

/obj/item/ammo_box/magazine/c980_grenade/shrapnel
	name = "Kiboko grenade box (.980 Tydhouer Shrapnel)"
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel

/obj/item/ammo_box/magazine/c980_grenade/shrapnel/stingball
	name = "Kiboko grenade box (.980 Tydhouer Stingball)"
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel/stingball

/obj/item/ammo_box/magazine/c980_grenade/smoke
	name = "Kiboko grenade box (.980 Tydhouer Smoke)"
	ammo_type = /obj/item/ammo_casing/c980grenade/smoke

/obj/item/ammo_box/magazine/c980_grenade/gas
	name = "Kiboko grenade box (.980 Tydhouer Teargas)"
	ammo_type = /obj/item/ammo_casing/c980grenade/riot

/obj/item/ammo_box/magazine/c980_grenade/drum
	name = "Kiboko grenade drum (.980 Tydhouer)"
	desc = "Барабан для гранат калибра .980 \"Тайдхойер\", вмещает шесть снарядов."
	icon_state = "granata_drum"
	w_class = WEIGHT_CLASS_NORMAL
	max_ammo = 6

/obj/item/ammo_box/magazine/c980_grenade/drum/starts_empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/c980_grenade/drum/phosphor
	name = "Kiboko grenade drum (.980 Tydhouer Phosphor)"
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel/phosphor

/obj/item/ammo_box/magazine/c980_grenade/drum/shrapnel/stingball
	name = "Kiboko grenade drum (.980 Tydhouer Stingball)"
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel/stingball

/obj/item/ammo_box/magazine/c980_grenade/drum/shrapnel
	name = "Kiboko grenade drum (.980 Tydhouer Shrapnel)"
	ammo_type = /obj/item/ammo_casing/c980grenade/shrapnel

/obj/item/ammo_box/magazine/c980_grenade/drum/smoke
	name = "Kiboko grenade drum (.980 Tydhouer Smoke)"
	ammo_type = /obj/item/ammo_casing/c980grenade/smoke

/obj/item/ammo_box/magazine/c980_grenade/drum/gas
	name = "Kiboko grenade drum (.980 Tydhouer Teargas)"
	ammo_type = /obj/item/ammo_casing/c980grenade/riot

// MARK: Shotguns
/obj/item/ammo_box/magazine/internal/shot/large
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 8

/obj/item/ammo_box/magazine/internal/shot/super
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/milspec
	max_ammo = 10

// MARK: Taipan
/obj/item/ammo_box/magazine/taipan
	name = "antimaterial sniper rifle magazine (20x138mm)"
	desc = "Магазин калибра 20x138мм, подходящий антиматериальным снайперским винтовкам."
	icon_state = ".50mag"
	base_icon_state = ".50mag"
	ammo_type = /obj/item/ammo_casing/mm20x138
	max_ammo = 3
	caliber = CALIBER_50BMG
