/// A component that plays a random footstep sound from a list for nearby players when the parent mob moves, optionally ignoring walls.
/datum/component/queen_walk
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// List of sound files to play when the mob moves.
	var/list/possible_sounds
	/// Volume of the played sound (0 to 100).
	var/sound_volume
	/// Range in tiles within which the sound is audible.
	var/sound_range
	/// Whether the sound ignores walls when played.
	var/ignore_walls
	/// Percentage chance of playing the sound on each move.
	var/sound_play_chance

/// Initializes the component with a list of sounds and playback settings.
/datum/component/queen_walk/Initialize(
	list/possible_sounds = list(
		'modular_bandastation/xeno_rework/sound/alien_footstep_large1.ogg',
		'modular_bandastation/xeno_rework/sound/alien_footstep_large2.ogg',
		'modular_bandastation/xeno_rework/sound/alien_footstep_large3.ogg'
	),
	sound_volume = 100,
	sound_range = 7,
	ignore_walls = TRUE,
	sound_play_chance = 100
)
	. = ..()
	if (!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.possible_sounds = possible_sounds
	src.sound_volume = sound_volume
	src.sound_range = sound_range
	src.ignore_walls = ignore_walls
	src.sound_play_chance = sound_play_chance

/// Registers the component to listen for movement signals.
/datum/component/queen_walk/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(play_step_sound), override = TRUE)

/// Unregisters the movement signal when the component is removed.
/datum/component/queen_walk/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

/// Plays a random footstep sound for nearby players when the mob moves.
/datum/component/queen_walk/proc/play_step_sound(atom/movable/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	if (QDELETED(src))
		return

	var/turf/current_turf = source.loc
	if (!isturf(current_turf) || isclosedturf(current_turf) || isgroundlessturf(current_turf))
		return

	if (!prob(sound_play_chance))
		return

	var/sound_played = pick(possible_sounds)

	var/list/viewers = view(sound_range, source)
	for (var/mob/living/viewer in viewers)
		if (viewer.client) // Only for players with an active client
			playsound(viewer, sound_played, sound_volume, FALSE, ignore_walls = ignore_walls)
