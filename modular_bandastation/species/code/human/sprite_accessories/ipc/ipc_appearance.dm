// Adapted from Paradise-SS220's robolimbs and IPC sprite accessories.
// Source revision and asset licenses: modular_bandastation/species/icons/ipc/attributions.txt.
GLOBAL_LIST_INIT(ipc_chassis, init_ipc_appearance_choices(/datum/ipc_chassis))
GLOBAL_LIST_INIT(ipc_displays, init_ipc_appearance_choices(/datum/sprite_accessory/ipc_display))
GLOBAL_LIST_INIT(ipc_antennae, init_ipc_appearance_choices(/datum/sprite_accessory/ipc_antenna))

/// Both preferences and in-round customization use these server-owned choices.
/proc/init_ipc_appearance_choices(base_type)
	var/list/choices = list()
	for(var/datum/sprite_accessory/choice_type as anything in subtypesof(base_type))
		var/datum/sprite_accessory/choice = new choice_type()
		if(isnull(choice.name))
			qdel(choice)
			continue
		choices[choice.name] = choice
	return choices

/datum/ipc_chassis
	parent_type = /datum/sprite_accessory
	var/has_body = TRUE
	var/has_head = TRUE
	var/is_monitor = FALSE

/datum/ipc_chassis/bishop
	name = "Bishop Cybernetics"
	icon = 'modular_bandastation/species/icons/ipc/bishop.dmi'

/datum/ipc_chassis/bishop_alt1
	name = "Bishop Cybernetics alt."
	icon = 'modular_bandastation/species/icons/ipc/bishop_alt1.dmi'
	has_body = FALSE

/datum/ipc_chassis/bishop_monitor
	name = "Bishop Cybernetics mtr."
	icon = 'modular_bandastation/species/icons/ipc/bishop_monitor.dmi'
	has_body = FALSE
	is_monitor = TRUE

/datum/ipc_chassis/hephaestus
	name = "Hephaestus Industries"
	icon = 'modular_bandastation/species/icons/ipc/hephaestus.dmi'

/datum/ipc_chassis/hephaestus_alt1
	name = "Hephaestus Industries alt."
	icon = 'modular_bandastation/species/icons/ipc/hephaestus_alt1.dmi'
	has_body = FALSE
	is_monitor = TRUE

/datum/ipc_chassis/hephaestus_monitor
	name = "Hephaestus Industries mtr."
	icon = 'modular_bandastation/species/icons/ipc/hephaestus_monitor.dmi'
	has_body = FALSE
	is_monitor = TRUE

/datum/ipc_chassis/morpheus
	name = "Morpheus Cyberkinetics"
	icon = 'modular_bandastation/species/icons/ipc/morpheus.dmi'
	is_monitor = TRUE

/datum/ipc_chassis/morpheus_alt1
	name = "Morpheus Cyberkinetics alt."
	icon = 'modular_bandastation/species/icons/ipc/morpheus_alt1.dmi'
	has_body = FALSE

/datum/ipc_chassis/wardtakahashi
	name = "Ward-Takahashi"
	icon = 'modular_bandastation/species/icons/ipc/wardtakahashi.dmi'

/datum/ipc_chassis/wardtakahashi_alt1
	name = "Ward-Takahashi alt."
	icon = 'modular_bandastation/species/icons/ipc/wardtakahashi_alt1.dmi'
	has_body = FALSE

/datum/ipc_chassis/wardtakahashi_monitor
	name = "Ward-Takahashi mtr."
	icon = 'modular_bandastation/species/icons/ipc/wardtakahashi_monitor.dmi'
	has_body = FALSE
	is_monitor = TRUE

/datum/ipc_chassis/xion
	name = "Xion Manufacturing Group"
	icon = 'modular_bandastation/species/icons/ipc/xion.dmi'

/datum/ipc_chassis/xion_alt1
	name = "Xion Manufacturing Group alt."
	icon = 'modular_bandastation/species/icons/ipc/xion_alt1.dmi'
	has_body = FALSE

/datum/ipc_chassis/xion_monitor
	name = "Xion Manufacturing Group mtr."
	icon = 'modular_bandastation/species/icons/ipc/xion_monitor.dmi'
	has_body = FALSE
	is_monitor = TRUE

/datum/ipc_chassis/zenghu
	name = "Zeng-Hu Pharmaceuticals"
	icon = 'modular_bandastation/species/icons/ipc/zenghu.dmi'

/datum/ipc_chassis/shellguard
	name = "Shellguard Munitions Standard Series"
	icon = 'modular_bandastation/species/icons/ipc/shellguard.dmi'

/datum/ipc_chassis/shellguard_alt1
	name = "Shellguard Munitions Elite Series"
	icon = 'modular_bandastation/species/icons/ipc/shellguard_alt1.dmi'
	has_body = FALSE

/datum/ipc_chassis/shellguard_monitor
	name = "Shellguard Munitions Monitor Series"
	icon = 'modular_bandastation/species/icons/ipc/shellguard_monitor.dmi'
	has_body = FALSE
	is_monitor = TRUE

/datum/ipc_chassis/etaminindustry
	name = "Etamin Industry Gold On Black"
	icon = 'modular_bandastation/species/icons/ipc/etaminindustry.dmi'

/datum/ipc_chassis/etaminindustry_etaminindustry_alt1
	name = "Etamin Industry Elite Series"
	icon = 'modular_bandastation/species/icons/ipc/etaminindustry_etaminindustry_alt1.dmi'
	has_body = FALSE

/datum/ipc_chassis/etaminindustry_etaminindustry_alt2
	name = "Etamin Industry SharpShooter Series"
	icon = 'modular_bandastation/species/icons/ipc/etaminindustry_etaminindustry_alt2.dmi'
	has_body = FALSE

/datum/ipc_chassis/etaminindustry_etaminindustry_alt3
	name = "Etamin Industry King Series"
	icon = 'modular_bandastation/species/icons/ipc/etaminindustry_etaminindustry_alt3.dmi'
	has_body = FALSE

/datum/ipc_chassis/cybersun
	name = "Cybersun Industries"
	icon = 'modular_bandastation/species/icons/ipc/cybersun.dmi'

/datum/ipc_chassis/cybersun_cybersun_redheavy
	name = "Cybersun Industries Heavy"
	icon = 'modular_bandastation/species/icons/ipc/cybersun_cybersun_redheavy.dmi'
	has_head = FALSE

/datum/ipc_chassis/cybersun_cybersun_blacklight
	name = "Cybersun Industries Black"
	icon = 'modular_bandastation/species/icons/ipc/cybersun_cybersun_blacklight.dmi'

/datum/ipc_chassis/cybersun_cybersun_blackheavy
	name = "Cybersun Industries Black Heavy"
	icon = 'modular_bandastation/species/icons/ipc/cybersun_cybersun_blackheavy.dmi'
	has_head = FALSE

/datum/sprite_accessory/ipc_display
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	/// Heads that can use this screen or optic arrangement.
	var/list/models_allowed
	/// A separate foreground channel used by two-color screens.
	var/secondary_state

/datum/sprite_accessory/ipc_display/off
	name = "Выключен"
	icon_state = SPRITE_ACCESSORY_NONE

/datum/sprite_accessory/ipc_display/ipc_screen_blank
	name = "Blank IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "None"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_pink
	name = "Pink IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "pink_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_red
	name = "Red IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "red_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_green
	name = "Green IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "green_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_blue
	name = "Blue IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "blue_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_breakout
	name = "Breakout IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "breakout_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_eight
	name = "Eight IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "eight_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_rainbow
	name = "Rainbow IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "rainbow_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_goggles
	name = "Goggles IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "goggles_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_heart
	name = "Heart IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "heart_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_monoeye
	name = "Monoeye IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "monoeye_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_blinkingeye
	name = "Blinking IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "blinkingeye_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_nature
	name = "Nature IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "nature_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_orange
	name = "Orange IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "orange_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_purple
	name = "Purple IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "purple_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_shower
	name = "Shower IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "shower_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_static
	name = "Static IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "static_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_yellow
	name = "Yellow IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "yellow_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_scrolling
	name = "Scanline IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "scroll_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_console
	name = "Console IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "console_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_rgb
	name = "RGB IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "rgb_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_glider
	name = "Glider IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "gol_glider_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_smoking
	name = "Smoking IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "smoking_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_test
	name = "Test IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "test_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_music
	name = "Music IPC screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "music_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_waiting
	name = "Waiting IPC screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "waiting_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/hephaestus_alt_off
	name = "Dark Hephaestus Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "off_hesp_alt_s"
	models_allowed = list("Hephaestus Industries alt.")

/datum/sprite_accessory/ipc_display/hephaestus_alt_pink
	name = "Pink Hephaestus Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "pink_hesp_alt_s"
	models_allowed = list("Hephaestus Industries alt.")

/datum/sprite_accessory/ipc_display/hephaestus_alt_orange
	name = "Orange Hephaestus Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "orange_hesp_alt_s"
	models_allowed = list("Hephaestus Industries alt.")

/datum/sprite_accessory/ipc_display/hephaestus_alt_goggle
	name = "Goggles Hephaestus Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "goggles_hesp_alt_s"
	models_allowed = list("Hephaestus Industries alt.")

/datum/sprite_accessory/ipc_display/hephaestus_alt_scroll
	name = "Scrolling Hephaestus Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "scroll_hesp_alt_s"
	models_allowed = list("Hephaestus Industries alt.")

/datum/sprite_accessory/ipc_display/hephaestus_alt_rgb
	name = "RGB Hephaestus Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "rgb_hesp_alt_s"
	models_allowed = list("Hephaestus Industries alt.")

/datum/sprite_accessory/ipc_display/hephaestus_alt_rainbow
	name = "Rainbow Hephaestus Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "rainbow_hesp_alt_s"
	models_allowed = list("Hephaestus Industries alt.")

/datum/sprite_accessory/ipc_display/ipc_screen_sinus
	name = "Sinus Rhythm IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "sinus_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")
	secondary_state = "sinus_fg_s"

/datum/sprite_accessory/ipc_display/ipc_screen_glasses
	name = "Glasses IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "glasses_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")
	secondary_state = "glasses_fg_s"

/datum/sprite_accessory/ipc_display/ipc_screen_star
	name = "Star IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "star_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")
	secondary_state = "star_fg_s"

/datum/sprite_accessory/ipc_display/ipc_screen_pong
	name = "Pong IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "pong_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")
	secondary_state = "pong_fg_s"

/datum/sprite_accessory/ipc_display/ipc_screen_crosshair
	name = "Crosshair IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "crosshair_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")
	secondary_state = "crosshair_fg_s"

/datum/sprite_accessory/ipc_display/ipc_screen_throbber
	name = "Throbber IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "throbber_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")
	secondary_state = "throbber_fg_s"

/datum/sprite_accessory/ipc_display/ipc_screen_mew
	name = "Mew IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "mew_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")
	secondary_state = "mew_fg_s"

/datum/sprite_accessory/ipc_display/ipc_screen_smile
	name = "Smile IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "smile_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")
	secondary_state = "smile_fg_s"

/datum/sprite_accessory/ipc_display/ipc_screen_skull
	name = "Skull IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "skull_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")
	secondary_state = "skull_fg_s"

/datum/sprite_accessory/ipc_display/ipc_screen_hal
	name = "HAL IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "hal_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")
	secondary_state = "hal_fg_s"

/datum/sprite_accessory/ipc_display/ipc_screen_paradise
	name = "Paradise IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "paradise_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/ipc_screen_paradise_alt
	name = "Paradise Alt. IPC Screen"
	icon = 'modular_bandastation/species/icons/ipc/screens.dmi'
	icon_state = "paradise_alt_s"
	models_allowed = list("Bishop Cybernetics mtr.", "Hephaestus Industries mtr.", "Morpheus Cyberkinetics", "Ward-Takahashi mtr.", "Xion Manufacturing Group mtr.", "Shellguard Munitions Monitor Series")

/datum/sprite_accessory/ipc_display/humanoid_optics
	name = "Humanoid Optics"
	icon = 'modular_bandastation/species/icons/ipc/optics.dmi'
	icon_state = "optics_s"
	models_allowed = list("Bishop Cybernetics", "Hephaestus Industries", "Ward-Takahashi", "Xion Manufacturing Group", "Zeng-Hu Pharmaceuticals")

/datum/sprite_accessory/ipc_display/bishop_alt
	name = "Bishop Alt. Optics"
	icon = 'modular_bandastation/species/icons/ipc/optics.dmi'
	icon_state = "bishop_alt_optics_s"
	models_allowed = list("Bishop Cybernetics alt.")

/datum/sprite_accessory/ipc_display/morpheus_alt
	name = "Morpheus Alt. Optics"
	icon = 'modular_bandastation/species/icons/ipc/optics.dmi'
	icon_state = "morpheus_alt_optics_s"
	models_allowed = list("Morpheus Cyberkinetics alt.")

/datum/sprite_accessory/ipc_display/wardtakahashi_alt
	name = "Ward-Takahashi Alt. Optics"
	icon = 'modular_bandastation/species/icons/ipc/optics.dmi'
	icon_state = "wardtakahashi_alt_optics_s"
	models_allowed = list("Ward-Takahashi alt.")

/datum/sprite_accessory/ipc_display/xion_alt
	name = "Xion Alt. Optics"
	icon = 'modular_bandastation/species/icons/ipc/optics.dmi'
	icon_state = "xion_alt_optics_s"
	models_allowed = list("Xion Manufacturing Group alt.")

/datum/sprite_accessory/ipc_display/etamin
	name = "EI Optics"
	icon = 'modular_bandastation/species/icons/ipc/etamin_optics.dmi'
	icon_state = "ei_standart_s"
	models_allowed = list("Etamin Industry King Series")

/datum/sprite_accessory/ipc_display/etamin_alt1
	name = "EI Optics Alt"
	icon = 'modular_bandastation/species/icons/ipc/etamin_optics.dmi'
	icon_state = "ei_alt1_s"
	models_allowed = list("Etamin Industry King Series")

/datum/sprite_accessory/ipc_display/etamin_alt2
	name = "EI Optics Alt 2"
	icon = 'modular_bandastation/species/icons/ipc/etamin_optics.dmi'
	icon_state = "ei_alt2_s"
	models_allowed = list("Etamin Industry King Series")

/datum/sprite_accessory/ipc_display/cybersun
	name = "Two Central Optics"
	icon = 'modular_bandastation/species/icons/ipc/cybersun_optics.dmi'
	icon_state = "two_cen_s"
	models_allowed = list("Cybersun Industries", "Cybersun Industries Black")

/datum/sprite_accessory/ipc_display/cybersun_tworight
	name = "Two Right Optics"
	icon = 'modular_bandastation/species/icons/ipc/cybersun_optics.dmi'
	icon_state = "two_right_s"
	models_allowed = list("Cybersun Industries", "Cybersun Industries Black")

/datum/sprite_accessory/ipc_display/cybersun_twoleft
	name = "Two Left Optics"
	icon = 'modular_bandastation/species/icons/ipc/cybersun_optics.dmi'
	icon_state = "two_left_s"
	models_allowed = list("Cybersun Industries", "Cybersun Industries Black")

/datum/sprite_accessory/ipc_display/cybersun_cyclop
	name = "Cyclops Optics"
	icon = 'modular_bandastation/species/icons/ipc/cybersun_optics.dmi'
	icon_state = "cyclops_s"
	models_allowed = list("Cybersun Industries", "Cybersun Industries Black")

/datum/sprite_accessory/ipc_display/cybersun_sniper
	name = "Sniper Optics"
	icon = 'modular_bandastation/species/icons/ipc/cybersun_optics.dmi'
	icon_state = "sniper_s"
	models_allowed = list("Cybersun Industries", "Cybersun Industries Black")

/datum/sprite_accessory/ipc_display/cybersun_tear
	name = "Tear Optics"
	icon = 'modular_bandastation/species/icons/ipc/cybersun_optics.dmi'
	icon_state = "tear_s"
	models_allowed = list("Cybersun Industries", "Cybersun Industries Black")

/datum/sprite_accessory/ipc_display/cybersun_veil
	name = "Veil Optics"
	icon = 'modular_bandastation/species/icons/ipc/cybersun_optics.dmi'
	icon_state = "veil_s"
	models_allowed = list("Cybersun Industries", "Cybersun Industries Black")

/datum/sprite_accessory/ipc_antenna
	icon = 'modular_bandastation/species/icons/ipc/antennae.dmi'

/datum/sprite_accessory/ipc_antenna/none
	name = "Нет"
	icon_state = SPRITE_ACCESSORY_NONE

/datum/sprite_accessory/ipc_antenna/ipc_antennae
	name = "Antennae"
	icon_state = "antennae_s"

/datum/sprite_accessory/ipc_antenna/ipc_winged_antennae
	name = "Winged Antennae"
	icon_state = "wings_s"

/datum/sprite_accessory/ipc_antenna/ipc_horns
	name = "Horns"
	icon_state = "horns_s"

/datum/sprite_accessory/ipc_antenna/ipc_ring
	name = "Orbital Ring"
	icon_state = "ring_s"

/datum/sprite_accessory/ipc_antenna/ipc_tv_antennae
	name = "T.V. Antennae"
	icon_state = "tvantennae_s"

/datum/sprite_accessory/ipc_antenna/ipc_tesla_antennae
	name = "Tesla Antennae"
	icon_state = "tesla_s"

/datum/sprite_accessory/ipc_antenna/ipc_light
	name = "Head Light"
	icon_state = "light_s"

/datum/sprite_accessory/ipc_antenna/ipc_side_lights
	name = "Side Lights"
	icon_state = "sidelights_s"

/datum/sprite_accessory/ipc_antenna/ipc_side_cyber_head
	name = "Cyber Pipes"
	icon_state = "cyberhead_s"

/datum/sprite_accessory/ipc_antenna/ipc_side_antlers
	name = "Antlers"
	icon_state = "antlers_s"

/datum/sprite_accessory/ipc_antenna/ipc_side_drone_eyes
	name = "Drone Eyes"
	icon_state = "droneeyes_s"

/datum/sprite_accessory/ipc_antenna/ipc_crowned
	name = "Crowned"
	icon_state = "crowned_s"
