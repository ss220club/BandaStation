// MARK: Sledgehammer
/datum/uplink_item/weapon_kits/low_cost/syndiesledge
	name = "Syndicate Breaching Sledgehammer (Hard)"
	desc = "Contains a plastitanium sledgehammer made for destruction and chaos. Great for tearing down unnecessary walls or bystanders. Comes with a welding helmet for your safety on the workplace!"
	item = /obj/item/storage/toolbox/guncase/syndiesledge
	purchasable_from = UPLINK_ALL_SYNDIE_OPS
	surplus = 0

/datum/uplink_item/role_restricted/syndiesledge
	name = "Syndicate Breaching Sledgehammer"
	desc = "Plastitanium sledgehammer made for destruction and chaos. Great for tearing down unnecessary walls or bystanders."
	item = /obj/item/sledgehammer/syndie
	cost = 10
	restricted_roles = list(JOB_STATION_ENGINEER, JOB_CHIEF_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN)

// MARK: Black Market
/datum/market_item/weapon/colorful_grenades
	name = "EXTREMELY DANGEROUS MASS DESTRUCTION GRENADES"
	desc = "ЭТО ОЧЕНЬ ОПАСНЫЕ ГРАНАТЫ МАССОВОГО УНИЧТОЖЕНИЯ, НЕ ЗАКАЗЫВАЙТЕ ИХ ЕСЛИ ВАМ НЕ ТРЕБУЕТСЯ УНИЧТОЖИТЬ СТАНЦИЮ ЛЮБОЙ ЦЕНОЙ!!! МЫ ВАС ПРЕДУПРЕДИЛИ!!!"
	item = /obj/effect/spawner/random/entertainment/colorful_grenades
	price_min = CARGO_CRATE_VALUE * 1250
	price_max = CARGO_CRATE_VALUE * 5000
	stock_max = 1
	availability_prob = 50
