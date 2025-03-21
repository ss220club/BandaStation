GLOBAL_LIST_INIT_TYPED(paper_replacements, /datum/paper_replacement, init_paper_replacements())

/proc/init_paper_replacements()
	var/list/paper_replacements = list()
	for(var/paper_replacement_type in subtypesof(/datum/paper_replacement))
		var/datum/paper_replacement/paper_replacement = new paper_replacement_type()
		paper_replacements[paper_replacement.key] = paper_replacement
	return paper_replacements


/datum/paper_replacement
	var/key = null
	var/name = "Undentified"

/datum/paper_replacement/proc/get_replacement(mob/user)
	CRASH("Paper replacement get_replacement not implemented.")

/datum/paper_replacement/sign
	key = "sign"
	name = "Подпись"

/datum/paper_replacement/sign/get_replacement(mob/user)
	return "<font face=\"[SIGNATURE_FONT]\"><i>[user.real_name || "неизвестный"]</i></font>"

/datum/paper_replacement/time
	key = "time"
	name = "Текущее время"

/datum/paper_replacement/time/get_replacement(mob/user)
	return station_time_timestamp()

/datum/paper_replacement/date
	key = "date"
	name = "Текущая дата"

/datum/paper_replacement/date/get_replacement(mob/user)
	return "[time2text(world.timeofday, "DD/MM")]/[CURRENT_STATION_YEAR]"

/datum/paper_replacement/station_name
	key = "station_name"
	name = "Название станции"

/datum/paper_replacement/station_name/get_replacement(mob/user)
	return station_name()

/datum/paper_replacement/bank_id
	key = "bank_id"
	name = "Номер банковского счета"

/datum/paper_replacement/bank_id/get_replacement(mob/user)
	var/datum/memory/key/account/user_key = user?.mind?.memories?[/datum/memory/key/account]
	return isnull(user_key?.remembered_id) ? "отсутствует" : "[user_key.remembered_id]"

/datum/paper_replacement/job
	key = "job"
	name = "Должность"

/datum/paper_replacement/job/get_replacement(mob/user)
	return istype(user) ? job_title_ru(user.job) : "отсутствует"

/datum/paper_replacement/species
	key = "species"
	name = "Раса"

/datum/paper_replacement/species/get_replacement(mob/user)
	if(!iscarbon(user))
		return "неизвестная"

	var/mob/living/carbon/carbon = user
	return isnull(carbon?.dna.species) ? "неизвестная" : carbon.dna.species.name

/datum/paper_replacement/gender
	key = "gender"
	name = "Пол"

/datum/paper_replacement/gender/get_replacement(mob/user)
	return istype(user) ? user.gender : "неизвестный"
