/*
## Здесь будет находиться все связанное с ритуалами вампиров.
*/

/datum/antagonist/bloodsucker/proc/ritual_blood_update()
	ritual_blood = list() // Clear existing rituals

	// Basic rituals available to all bloodsuckers
	ritual_blood["Task"] = 1
/*
	var/total_rank = bloodsucker_level + bloodsucker_level_unspent

	// Mid rank rituals (Rank 3+)
	if(total_rank >= 3)

	// High rank rituals (Rank 7+)
	if(total_rank >= 7)

	// Ancient rank rituals (Rank 13+)
	if(total_rank >= 13)

*/

/obj/structure/bloodsucker/bloodaltar/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!.)
		return
	if(!IS_BLOODSUCKER(user)) //not bloodsucker
		to_chat(user, span_warning("You can't figure out how this works."))
		return

	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	bloodsuckerdatum.ritual_blood_update()
	var/list/options = bloodsuckerdatum.ritual_blood
	var/list/tasks = list(
		"Проверить выполнение задачи" = 1,
		"Взять задачу" = 2
	)
	var/choice = tgui_input_list(user, "Выберите исполняемый ритуал", "Выбор ритуала", options)
	if(!choice || !Adjacent(user) || QDELETED(src))
		return

	switch(options[choice])
		if(1)
			choice = tgui_input_list(user, "Проверьте или возьмите задачу", "Задачи", tasks)
			if(!choice || !Adjacent(user) || QDELETED(src))
				return
			switch(tasks[choice])
				if(1)
					if(!bloodsuckerdatum.has_task)
						to_chat(user, span_warning("You don't have a task!"))
						return
					if(!check_completion(user))
						to_chat(user, span_notice("You haven't completed the task yet!"))
						return
				if(2)
					if(bloodsuckerdatum.has_task)
						to_chat(user, span_warning("You already have a task!"))
						return
					if(bloodsuckerdatum.altar_uses >= ALTAR_RANKS_PER_DAY)
						to_chat(user, span_notice("You have done all tasks for the night, come back tomorrow for more."))
						return
					if(bloodsuckerdatum.bloodsucker_blood_volume < 50)
						to_chat(user, span_danger("You don't have enough blood to gain a task!"))
						return
					generate_task(user)


/*
 Задачи для повышения ранга
*/
/obj/structure/bloodsucker/bloodaltar/proc/generate_task(mob/living/user)
	var/task //just like amongus
	var/mob/living/carbon/crewmate = user
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = crewmate.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	suckamount = bloodsuckerdatum.task_blood_required
	heartamount = bloodsuckerdatum.task_heart_required
	if(!suckamount && !heartamount) // Generate random amounts if we don't already have them set
		switch(bloodsuckerdatum.bloodsucker_level + bloodsuckerdatum.bloodsucker_level_unspent)
			if(0 to 3)
				suckamount = rand(100, 300)
				heartamount = rand(1,2)
			if(4 to 6)
				suckamount = rand(300, 600)
				heartamount = rand(3,4)
			if(7 to 12)
				suckamount = rand(500, 1200)
				heartamount = rand(5,6)
			if(13)
				to_chat(user, span_danger("Ты достиг максимального могущества! Ты больше не можешь поднимать ранг"))
	switch(rand(1, 3))
		if(1,2)
			bloodsuckerdatum.task_blood_required = suckamount
			task = "Suck [suckamount] units of pure blood."
		if(3)
			bloodsuckerdatum.task_heart_required = heartamount
			task = "Sacrifice [heartamount] hearts by using them on the altar."
			sacrificialtask = TRUE
	bloodsuckerdatum.task_memory += "<B>Current Rank Up Task</B>: [task]<br>"
	bloodsuckerdatum.has_task = TRUE
	to_chat(user, span_boldnotice("You have gained a new Task! [task] Remember to collect it by using the blood altar!"))

/obj/structure/bloodsucker/bloodaltar/proc/check_completion(mob/living/user)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum.task_blood_drank < bloodsuckerdatum.task_blood_required || sacrifices < bloodsuckerdatum.task_heart_required)
		return FALSE
	bloodsuckerdatum.task_memory = null
	bloodsuckerdatum.has_task = FALSE
	bloodsuckerdatum.bloodsucker_level_unspent++
	bloodsuckerdatum.altar_uses++
	bloodsuckerdatum.task_blood_drank = 0
	bloodsuckerdatum.task_blood_required = 0
	bloodsuckerdatum.task_heart_required = 0
	sacrifices = 0
	to_chat(user, span_notice("You have sucessfully done a task and gained a rank!"))
	sacrificialtask = FALSE
	return TRUE

/obj/structure/bloodsucker/bloodaltar/examine(mob/user)
	. = ..()
	if(sacrificialtask)
		if(sacrifices)
			. += span_boldnotice("It currently contains [sacrifices] [organ_name].")
	else
		return ..()

/obj/structure/bloodsucker/bloodaltar/attackby(obj/item/H, mob/user, params)
	if(!IS_BLOODSUCKER(user) && !IS_VASSAL(user))
		return ..()
	if(sacrificialtask)
		if(istype(H, /obj/item/organ/heart))
			if(istype(H, /obj/item/organ/heart/gland))
				to_chat(usr, span_warning("This type of organ doesn't have blood to sustain the altar!"))
				return ..()
			organ_name = H.name
			balloon_alert(user, "heart fed!")
			qdel(H)
			sacrifices++
			return
	return ..()

/*
Эффекты
*/

/*
предметы
*/

/*
Погода
*/
