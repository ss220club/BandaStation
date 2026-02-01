/datum/job/vulp_ashtar_engi_officer
	title = "Полевой старший инженер Аштара"
	supervisors = "командиром операцией"
	description = "Командуйте своим отделением лучших инженеров, постройте лучшие из возможных укрепленний. Приведите свой Клан к победе в этой битве!"
	departments_list = list(
		/datum/job_department/security,
	)
	outfit = /datum/outfit/vulpa_ashtar/engi/officer
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	event_description = "В ваши обязанности входит следование приказам командира операцией и исполнение долга перед cвоим Кланом. Вам не рекомендуется покидать пределы своей базы без разрешения командира в одиночку. Обязательно посетите брифинг в основном здании базы, после - получите свои задачи у командира операцией. Помните - это опасное место, поэтому будьте бдительны и верны своим соклановцам!"

	paycheck = PAYCHECK_ZERO
	bounty_types = CIV_JOB_BASIC
	department_for_prefs = /datum/job_department/security
	family_heirlooms = list(/obj/item/storage/toolbox/mechanical/old/heirloom, /obj/item/clothing/gloves/cut/heirloom)
	job_flags = STATION_JOB_FLAGS
