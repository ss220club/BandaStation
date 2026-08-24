/datum/uplink_item/stealthy_weapons/holster_uniform
	name = "Syndicate Holster (uniform)"
	desc = "Эта кобура была специально разработана лучшими технологами компании Cybersun Inc. На первый взгляд - это обычная коробочка для ручек, которая крепится к униформе. На деле же она способна вмещать нечто гораздо более крупное. Несмотря на единственный карман, кобура подходит почти для любого небольшого лазера или пистолета. Одурачь службу безопасности одним лишь её видом."
	item = /obj/item/clothing/accessory/holster/chameleon
	cost = 1

/datum/uplink_item/role_restricted/gbs
	name = "GBS culture bottle"
	desc = "A small bottle containing a culture of Gravitokinetic Bipotential SADS+."
	item = /obj/item/reagent_containers/cup/bottle/gbs
	category = /datum/uplink_category/role_restricted
	restricted_roles = list(
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_CORONER,
		JOB_MEDICAL_DOCTOR,
		JOB_PARAMEDIC,
		JOB_CHEMIST,
	)
	cost = 16

/datum/uplink_item/role_restricted/gbs/can_be_bought(datum/uplink_handler/source)
	if(!..())
		return FALSE
	return locate(/datum/objective/martyr) in source.primary_objectives || locate(/datum/objective/hijack) in source.primary_objectives

/datum/uplink_item/dangerous/ekatanka
	name = "Тактическая катана 'Багровый порез'"
	desc = "Энергетическая катана, созданная при помощи новых технологий Синдиката."
	item = /obj/item/melee/energy/ekatanka
	category = /datum/uplink_category/dangerous
	cost = 14

/datum/uplink_item/stealthy_weapons/spacejacker
	name = "Хакерское устройство 'Богатый Еврей'"
	desc = "Это устройство позволяет вам тайно снимать кредиты с банковских счетов других членов экипажа и прикреплять к их устройствам вирус, который передаёт деньги на ваш сифон. Также имеет выгодный обменник кредитов на ТК, но будьте осторожны, ТК ограничены, а также слишком частое использование может вызвать подозрения у других членов экипажа."
	item = /obj/item/spacejacker
	category = /datum/uplink_category/role_restricted
	restricted_roles = list(
		JOB_QUARTERMASTER,
		JOB_CARGO_TECHNICIAN,
		JOB_BITRUNNER,
		JOB_SHAFT_MINER,
	)
	cost = 5
