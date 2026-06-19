/datum/outfit/job/assistant
	uniform = /obj/item/clothing/under/costume/buttondown/slacks
	shoes = /obj/item/clothing/shoes/laceup
	id = /obj/item/card/id/advanced/ussp/passport
	id_trim = /datum/id_trim/job/ussp_assistant
	pda_slot = null
	belt = null
	ears = null

/datum/job/assistant
	title = "Житель ПГТ \"Зорька\""
	departments_list = list(
		/datum/job_department/assistant,
	)
	department_for_prefs = /datum/job_department/assistant
	event_description = "Возможно, вы были перемещены сюда во время переселения, возможно - родились тут, а может быть и переехали сами. Все это - не важно, ведь перед вами открыт удивительный мир советской провинции! Обязательно посетите собрание в местном райкоме на площади Революции. Вы можете устроиться в любое заведение на условиях коммунистического труженика и тем самым помочь вашим товарищам. Все необходимые товары вы можете получить в гастрономе или промтоварах по талонам, которые выдаются специальным автоматом на втором этаже райкома по курсу один талон - один товар. Помните, что залог светлого будущего - добродушное отношение к вашим близким и товарищам"

/datum/id_trim/job/ussp_assistant
	assignment = "Житель ПГТ \"Зорька\""
	trim_state = "trim_mime"
	department_color = COLOR_ASSISTANT_GRAY
	subdepartment_color = COLOR_ASSISTANT_GRAY
	sechud_icon_state = SECHUD_USSP
	job = /datum/job/assistant
