/datum/emergency_call/upp
	// name for admins
	name = "Soviet Naval Infantry (Test)"
	// antag datum
	team = /datum/team/ert
	///Alternate antag datum given to the leader of the squad.
	leader_role = /datum/antagonist/ert/commander
	///A list of roles distributed to the selected candidates that are not the leader.
	roles = list(/datum/antagonist/ert/security, /datum/antagonist/ert/medic, /datum/antagonist/ert/engineer)
	///The custom name assigned to this team, for their antag datum/roundend reporting.
	rename_team = "Soviet Naval Infantry"
	///The "would you like to play as XXX" message used when polling for players.
	polldesc = "Soviet Naval Infantry"
	///The mission given to this ERT type in their flavor text.
	mission = "Оказывайте помощь силам NT, не вступайте в бой с силами NT. Слушайте своих старших офицеров."
	///The mission given to this ERT type if they are hostile.
	hostile_mission = ""
	dispatch_message = "С ближайшего судна получен зашифрованный сигнал. Ожидайте."
	arrival_message = ""
	chance_hidden = 20
	///The max number of players
	mob_max = 5
	// min candidates to activate
	mob_min = 1
	/// If TRUE, gives the team members "[role] [random last name]" style names
	random_names = TRUE
	/// If TRUE, we try and pick one of the most experienced players who volunteered to fill the leader slot
	leader_experience = TRUE
	/// A shuttle map template to spawn the ERT at. Must present
	shuttle_id = "hunter_bounty"
	/// if null or false - no base
	base_template = "generic_ert_base"
	/// Used for spawning bodies for your ERT. Unless customized in the Summon-ERT verb settings, will be overridden and should not be defined at the datum level.
	weight = 10
	// obj to show in ghost poll, or will show leader dummy if null or false
	alert_pic = null
	// chance to be hostile from 0 to 100
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
