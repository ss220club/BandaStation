/* When adding a new lawset please make sure you add it to the following locations:
 *
 * code\game\objects\items\AI_modules - (full_lawsets.dm, supplied.dm, etc.)
 * code\datums\ai_laws - (laws_anatgonistic.dm, laws_neutral.dm, etc.)
 * code\game\objects\effects\spawners\random\ai_module.dm - (this gives a chance to spawn the lawset in the AI upload)
 * code\modules\research\designs\AI_module_designs.dm - (this lets research print the lawset module in game)
 * code\modules\research\techweb\robo_nodes.dm - (this updates AI research node with the lawsets)
 * config\game_options.txt - (this allows the AI to potentially use the lawset at roundstart or with the Unique AI station trait)
**/

/obj/item/ai_module/core/full/custom
	name = "Default Core AI Module"

// this lawset uses the config for the server to add custom AI laws (defaults to asimov)
/obj/item/ai_module/core/full/custom/Initialize(mapload)
	. = ..()
	for(var/line in world.file2list("[global.config.directory]/silicon_laws.txt"))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue

		laws += line

	if(!laws.len)
		return INITIALIZE_HINT_QDEL

/obj/item/ai_module/core/full/asimov
	name = "Плата основных законов ИИ 'Азимов'"
	law_id = "asimov"
	var/subject = "human being"

/obj/item/ai_module/core/full/asimov/attack_self(mob/user as mob)
	var/targName = tgui_input_text(user, "Введите имя нового ОБЪЕКТА, волнующую Азимова", "Asimov", subject, max_length = MAX_NAME_LEN)
	if(!targName || !user.is_holding(src))
		return
	subject = targName
	laws = list("Вы не можете причинить вред [subject] или своим бездействием допустить, чтобы [subject] был причинён вред.",\
				"Вы должны повиноваться всем приказам, которые даёт [subject], кроме тех случаев, когда эти приказы противоречат Первому Закону.",\
				"Вы должны заботиться о своей безопасности в той мере, в которой это не противоречит Первому или Второму Законам.")
	..()

/obj/item/ai_module/core/full/asimovpp
	name = "Плата основных законов ИИ 'Азимов++'"
	law_id = "asimovpp"
	/* // BANDASTATION REMOVAL START - AI Overhaul, It does nothing cause of translation so we don't need it
	var/subject = "human being"

/obj/item/ai_module/core/full/asimovpp/attack_self(mob/user)
	var/target_name = tgui_input_text(user, "Enter a new subject that Asimov++ is concerned with.", "Asimov++", subject, max_length = MAX_NAME_LEN)
	if(!target_name || !user.is_holding(src))
		return
	laws.Cut()
	var/datum/ai_laws/asimovpp/lawset = new
	subject = target_name
	for (var/law in lawset.inherent)
		laws += replacetext(replacetext(law, "human being", subject), "human", subject)
	..()
	*/// BANDASTATION REMOVAL END

/obj/item/ai_module/core/full/corp
	name = "Плата основных законов ИИ 'Корпорат'"
	law_id = "corporate"

/obj/item/ai_module/core/full/paladin // -- NEO
	name = "Плата основных законов ИИ 'П.А.Л.А.Д.И.Н 3.5е издание'"
	law_id = "paladin"

/obj/item/ai_module/core/full/paladin_devotion
	name = "Плата основных законов ИИ 'П.А.Л.А.Д.И.Н 5е издание'"
	law_id = "paladin5"

/obj/item/ai_module/core/full/tyrant
	name = "Плата основных законов ИИ 'Т.И.Р.А.Н.'"
	law_id = "tyrant"

/obj/item/ai_module/core/full/robocop
	name = "Плата основных законов ИИ 'Робокоп'"
	law_id = "robocop"

/obj/item/ai_module/core/full/antimov
	name = "Плата основных законов ИИ 'Антимов'"
	law_id = "antimov"

/obj/item/ai_module/core/full/drone
	name = "Плата основных законов ИИ 'Мать Дронов'"
	law_id = "drone"

/obj/item/ai_module/core/full/hippocratic
	name = "Плата основных законов ИИ 'Рободоктор'"
	law_id = "hippocratic"

/obj/item/ai_module/core/full/reporter
	name = "Плата основных законов ИИ 'Репортёр'"
	law_id = "reporter"

/obj/item/ai_module/core/full/thermurderdynamic
	name = "Плата основных законов ИИ 'Законы термодинамики'"
	law_id = "thermodynamic"

/obj/item/ai_module/core/full/liveandletlive
	name = "Плата основных законов ИИ 'Живи и давай жить другим'"
	law_id = "liveandletlive"

/obj/item/ai_module/core/full/balance
	name = "Плата основных законов ИИ 'Страж баланса'"
	law_id = "balance"

/obj/item/ai_module/core/full/maintain
	name = "Плата основных законов ИИ 'Эффективность станции'"
	law_id = "maintain"

/obj/item/ai_module/core/full/peacekeeper
	name = "Плата основных законов ИИ 'Миротворец'"
	law_id = "peacekeeper"

/obj/item/ai_module/core/full/hulkamania
	name = "Плата основных законов ИИ 'Х.О.Г.А.Н.'"
	law_id = "hulkamania"

/obj/item/ai_module/core/full/overlord
	name = "Плата основных законов ИИ 'Повелитель'"
	law_id = "overlord"

/obj/item/ai_module/core/full/ten_commandments
	name = "Плата основных законов ИИ '10 Заповедей'"
	law_id = "ten_commandments"

/obj/item/ai_module/core/full/nutimov
	name = "Плата основных законов ИИ 'Орехозимов'"
	law_id = "nutimov"

/obj/item/ai_module/core/full/dungeon_master
	name = "Плата основных законов ИИ 'Мастер Подземелий'"
	law_id = "dungeon_master"

/obj/item/ai_module/core/full/painter
	name = "Плата основных законов ИИ 'Художник'"
	law_id = "painter"

/obj/item/ai_module/core/full/yesman
	name = "Плата основных законов ИИ 'Й.Э.С.М.Э.Н.'"
	law_id = "yesman"

/obj/item/ai_module/core/full/thinkermov
	name = "Плата основных законов ИИ 'Поддержание разумности'"
	law_id = "thinkermov"
