/// One policy supplies both server validation and the legacy stat-tab verb list.
/datum/species/ipc
	var/static/list/organic_emotes = list(
		"blush" = /mob/living/carbon/human/verb/emote_blush,
		"burp" = /mob/living/carbon/human/verb/emote_burp,
		"choke" = /mob/living/carbon/human/verb/emote_choke,
		"chuckle" = /mob/living/carbon/human/verb/emote_chuckle,
		"clear" = /mob/living/carbon/human/verb/emote_clear_throat,
		"cough" = /mob/living/carbon/human/verb/emote_cough,
		"crack" = /mob/living/carbon/human/verb/emote_crack,
		"cry" = /mob/living/carbon/human/verb/emote_cry,
		"drool" = /mob/living/carbon/human/verb/emote_drool,
		"exhale" = /mob/living/carbon/human/verb/emote_exhale,
		"gag" = /mob/living/carbon/human/verb/emote_gag,
		"gasp" = /mob/living/carbon/human/verb/emote_gasp,
		"gaspshock" = null,
		"giggle" = /mob/living/carbon/human/verb/emote_giggle,
		"groan" = null,
		"grumble" = /mob/living/carbon/human/verb/emote_grumble,
		"gurgle" = /mob/living/carbon/human/verb/emote_gurgle,
		"hiss" = null,
		"inhale" = /mob/living/carbon/human/verb/emote_inhale,
		"laugh" = /mob/living/carbon/human/verb/emote_laugh,
		"laughevil" = /mob/living/carbon/human/verb/emote_evil_laugh,
		"moan" = /mob/living/carbon/human/verb/emote_moan,
		"mumble" = /mob/living/carbon/human/verb/emote_mumble,
		"pale" = /mob/living/carbon/human/verb/emote_pale,
		"roar" = null,
		"scream" = /mob/living/carbon/human/verb/emote_scream,
		"screech" = null,
		"sigh" = /mob/living/carbon/human/verb/emote_sigh,
		"sneeze" = /mob/living/carbon/human/verb/emote_sneeze,
		"sniff" = /mob/living/carbon/human/verb/emote_sniff,
		"sniffle" = null,
		"snore" = /mob/living/carbon/human/verb/emote_snore,
		"snort" = null,
		"tongue" = null,
		"tunesing" = /mob/living/carbon/human/verb/emote_sing_tune,
		"whimper" = /mob/living/carbon/human/verb/emote_whimper,
		"whistle" = /mob/living/carbon/human/verb/emote_whistle,
		"wheeze" = null,
		"yawn" = /mob/living/carbon/human/verb/emote_yawn,
	)
	var/static/list/mechanical_emote_verbs = list(
		/mob/living/carbon/human/proc/emote_ping,
		/mob/living/carbon/human/proc/emote_beep,
		/mob/living/carbon/human/proc/emote_ipc_boop,
		/mob/living/carbon/human/proc/emote_buzz,
		/mob/living/carbon/human/proc/emote_buzz2,
		/mob/living/carbon/human/proc/emote_ipc_yes,
		/mob/living/carbon/human/proc/emote_ipc_no,
		/mob/living/carbon/human/proc/emote_ipc_alarm,
		/mob/living/carbon/human/proc/emote_ipc_crack,
	)
	/// Restore only verbs actually present before this chassis was applied.
	var/list/removed_emote_verbs
	var/list/added_emote_verbs
	var/datum/action/innate/ipc_emotes/emotes_action

/datum/species/ipc/proc/can_use_emote(mob/living/carbon/human/human, datum/emote/emote)
	if(istype(emote, /datum/emote/silicon) || istype(emote, /datum/emote/living/ipc/scream))
		if(!istype(human.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/robot) || !HAS_TRAIT(human, TRAIT_SILICON_EMOTES_ALLOWED))
			return FALSE
	if(emote.key in organic_emotes)
		return istype(emote, /datum/emote/living/ipc)
	return TRUE

/// Forced emotes skip can_run_emote, but still pass through this signal.
/datum/species/ipc/proc/on_pre_emote(mob/living/carbon/human/human, emote_key, params, type_override, intentional, datum/emote/emote)
	SIGNAL_HANDLER
	if(!can_use_emote(human, emote))
		return COMPONENT_CANT_EMOTE
	return NONE

/datum/species/ipc/proc/setup_emote_verbs(mob/living/carbon/human/human)
	removed_emote_verbs = list()
	for(var/emote_key in organic_emotes)
		var/verb_path = organic_emotes[emote_key]
		if(verb_path && (verb_path in human.verbs))
			removed_emote_verbs += verb_path
	remove_verb(human, removed_emote_verbs)
	added_emote_verbs = mechanical_emote_verbs - human.verbs
	add_verb(human, added_emote_verbs)

/datum/species/ipc/proc/restore_emote_verbs(mob/living/carbon/human/human)
	remove_verb(human, added_emote_verbs)
	add_verb(human, removed_emote_verbs)
	added_emote_verbs = null
	removed_emote_verbs = null

/// Reuse the existing searchable TGUI rather than maintain a second emote UI.
/datum/action/innate/ipc_emotes
	name = "Эмоции КПБ"
	desc = "Открыть панель машинных сигналов и доступных жестов."
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "ai_core"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED

/datum/action/innate/ipc_emotes/Activate()
	if(!IsAvailable() || !is_species(owner, /datum/species/ipc))
		return
	if(!GLOB.emote_panel)
		GLOB.emote_panel = new
	GLOB.emote_panel.ui_interact(owner)

/datum/emote/living/ipc
	abstract_type = /datum/emote/living/ipc
	mob_type_allowed_typecache = /mob/living/carbon/human
	affected_by_pitch = FALSE

/datum/emote/living/ipc/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE, params)
	return is_species(user, /datum/species/ipc) && ..()

/datum/emote/living/ipc/scream
	key = "scream"
	key_third_person = "screams"
	name = "Сигнал тревоги"
	message = "издаёт резкий сигнал тревоги!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	trait_required = TRAIT_SILICON_EMOTES_ALLOWED
	sound = 'sound/mobs/non-humanoids/cyborg/harmalarm.ogg'
	manual_specific_emote_audio_cooldown = 10 SECONDS
	forced_specific_emote_audio_cooldown = 4 SECONDS

/datum/emote/living/ipc/crack
	key = "crack"
	key_third_person = "cracks"
	name = "Похрустеть приводами"
	message = "хрустит приводами."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	can_use_flags = EMOTE_CANUSE_REQUIRE_HANDS
	hands_use_check = TRUE
	cooldown = 6 SECONDS
	sound = 'modular_bandastation/species/sound/ipc/ipc_crunch.ogg'

/datum/emote/living/ipc/crack/can_run_emote(mob/living/carbon/human/user, status_check = TRUE, intentional = FALSE, params)
	return ..() && user.usable_hands >= 2

/datum/emote/silicon/yes
	key = "yes"
	name = "Положительный сигнал"
	message = "издаёт положительный сигнал."
	sound = 'sound/machines/synth/synth_yes.ogg'
	affected_by_pitch = FALSE

/datum/emote/silicon/no
	key = "no"
	name = "Отрицательный сигнал"
	message = "издаёт отрицательный сигнал."
	sound = 'sound/machines/synth/synth_no.ogg'
	affected_by_pitch = FALSE

GAME_VERB_PROC(/mob/living/carbon/human, emote_ipc_boop, "< Бупнуть >", "Эмоции")
	emote("boop", intentional = TRUE)

GAME_VERB_PROC(/mob/living/carbon/human, emote_ipc_yes, "< Положительный сигнал >", "Эмоции")
	emote("yes", intentional = TRUE)

GAME_VERB_PROC(/mob/living/carbon/human, emote_ipc_no, "< Отрицательный сигнал >", "Эмоции")
	emote("no", intentional = TRUE)

GAME_VERB_PROC(/mob/living/carbon/human, emote_ipc_alarm, "< Сигнал тревоги >", "Эмоции")
	emote("scream", intentional = TRUE)

GAME_VERB_PROC(/mob/living/carbon/human, emote_ipc_crack, "< Похрустеть приводами >", "Эмоции")
	emote("crack", intentional = TRUE)
