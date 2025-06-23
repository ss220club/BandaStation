/datum/emergency_call/upp
	name = "Soviet Naval Infantry (Test)"
	team = /datum/team/ert
	leader_role = /datum/antagonist/ert/commander
	roles = list(/datum/antagonist/ert/security, /datum/antagonist/ert/medic, /datum/antagonist/ert/engineer)
	rename_team = "Soviet Naval Infantry"
	mission = "Оказывайте помощь силам NT, не вступайте в бой с силами NT. Слушайте своих старших офицеров."
	hostile_mission = ""
	dispatch_message = "С ближайшего судна получен зашифрованный сигнал. Ожидайте."
	arrival_message = ""
	chance_hidden = 20
	mob_max = 5
	mob_min = 1
	random_names = TRUE
	shuttle_id = "hunter_bounty"
	base_template = LAZY_TEMPLATE_KEY_TSF_BASE
	weight = 10
	alert_pic = null
	hostility = 0

/datum/emergency_call/upp/New()
	. = ..()
	hostile_mission = "Уничтожьте силы NT, чтобы обеспечить дальнейшее пристуствие СПН в этом секторе. Слушайтесь свои старших офицеров и любой ценой захватите [station_name()]"
	arrival_message = "[station_name()], э*то ф^от ОП*. уДа*аЯ ГруппА, #*раз*%нИе на ст*ко*%^у. орУ#%е в б@евую гт**%сть... ок@зт$ть по#@щь."

/datum/antagonist/ert/upp
	name = "Soviet Solder"
	role = "Rifleman"
	outfit = /datum/outfit/centcom/ert/security
	ert_job_path = /datum/job/upp_generic

/datum/job/upp_generic
	title = "СПН солдат"

/datum/antagonist/ert/upp/greet()
	if(!ert_team)
		return

	to_chat(owner, "<span class='warningplain'><B><font size=3 color=red>Ты — боец отряда [name].</font></B></span>")

	var/missiondesc = "Ваш отряд направлен на объект [station_name()] Особым Отделом Министерства Обороны СПН."
	if(leader)
		missiondesc += " <b>Товарищ командир!</b> Возглавьте отряд для выполнения боевой задачи. Отправляйтесь на шаттле по готовности."
	else
		missiondesc += " Четко выполняйте приказы товарища командира."
	if(!rip_and_tear)
		missiondesc += " Минимизируйте потери среди гражданского персонала."

	missiondesc += "<span class='warningplain'><BR><B>Боевая задача</B> : [ert_team.mission.explanation_text]</span>"
	to_chat(owner, missiondesc)
