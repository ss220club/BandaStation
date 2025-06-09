#define CHAT_BADGES_DMI 'modular_bandastation/chat/icons/chatbadges.dmi'

GLOBAL_LIST(badge_icons_cache)

/client/proc/get_ooc_badged_name()
	var/icon/donator_badge_icon = get_badge_icon(get_donator_badge())
	var/icon/worker_badge_icon = get_badge_icon(get_worker_badge())

	var/list/badge_parts = list()
	if(donator_badge_icon)
		badge_parts += icon2base64html(donator_badge_icon)

	if(worker_badge_icon)
		badge_parts += icon2base64html(worker_badge_icon)

	var/list/parts = list()
	if(length(badge_parts))
		parts += badge_parts

	if(donator_level && prefs.read_preference(/datum/preference/toggle/donor_public) || prefs.unlock_content && (prefs.toggles & MEMBER_PUBLIC))
		var/donor_color = prefs.read_preference(/datum/preference/color/ooc_color) || GLOB.normal_ooc_colour
		var/donor_shine = get_donator_level() >= 3 && prefs.read_preference(/datum/preference/toggle/donor_chat_shine) ? "class='shine'" : ""
		parts += "<span [donor_shine] style='[donor_shine ? "--shine-color: [donor_color];" : "color: [donor_color];"]'>[key]</span>"
	else
		parts += "[key]"

	return jointext(parts, "<div style='display: inline-block; width: 3px;'></div>")

/client/proc/get_donator_badge()
	if(prefs.unlock_content && (prefs.toggles & MEMBER_PUBLIC))
		return "ByondMember"

	if(donator_level && prefs.read_preference(/datum/preference/toggle/donor_public))
		return "Tier_[min(donator_level, 5)]"

/client/proc/get_worker_badge()
	var/static/list/rank_badge_map = list(
		"Максон" = "Wycc",
		"Банда" = "Streamer",
		"Друг Банды" = "Streamer",
		"Хост" = "Host",
		"Ведущий Разработчик" = "Host",
		"Старший Разработчик" = "HeadDeveloper",
		"Разработчик" = "Developer",
		"Начальный Разработчик" = "MiniDeveloper",
		"Ведущий Маппер" = "HeadMapper",
		"Маппер" = "Mapper",
		"Спрайтер" = "Spriceter",
		"Ведущий редактор Вики" = "HeadWiki",
		"Редактор Вики" = "WikiLore",
		"Главный Администратор" = "HeadAdmin",
		"Администратор" = "GameAdmin",
		"Триал Администратор" = "TrialAdmin",
		"Тестовый Администратор" = "TestAdmin",
		"Ментор" = "Mentor"
	)
	return rank_badge_map["[holder?.ranks[1]]"]

/client/proc/get_badge_icon(badge)
	if(isnull(badge))
		return null

	var/icon/badge_icon = LAZYACCESS(GLOB.badge_icons_cache, badge)
	if(isnull(badge_icon))
		badge_icon = icon(CHAT_BADGES_DMI, badge)
		LAZYSET(GLOB.badge_icons_cache, badge, badge_icon)

	return badge_icon

#undef CHAT_BADGES_DMI
