/// Personal details supplement the selected setting and stay in the same character slot.
/datum/preference/text/sierra_background_notes
	abstract_type = /datum/preference/text/sierra_background_notes
	savefile_identifier = PREFERENCE_CHARACTER
	category = "sierra_background_notes"
	priority = PREFERENCE_PRIORITY_NAMES
	can_randomize = FALSE
	should_update_preview = FALSE
	maximum_value_length = 4001
	var/notes_prompt

/datum/preference/text/sierra_background_notes/deserialize(input, datum/preferences/preferences)
	if(!istext(input))
		return create_default_value()
	return STRIP_HTML_FULL(input, maximum_value_length)

/datum/preference/text/sierra_background_notes/is_valid(value, datum/preferences/preferences)
	// The native sanitizer counts characters; the native text validator counts bytes.
	return istext(value) && length_char(value) < maximum_value_length

/datum/preference/text/sierra_background_notes/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	target.dna.features[savefile_key] = value

/datum/preference/text/sierra_background_notes/culture
	savefile_key = "sierra_culture_notes"
	notes_prompt = "Какие традиции и привычки сохранил ваш персонаж? Что он принимает или переосмысливает в своей культуре?"

/datum/preference/text/sierra_background_notes/homeworld
	savefile_key = "sierra_homeworld_notes"
	notes_prompt = "Где и в каких условиях жил ваш персонаж? Почему он уехал и какие связи с домом поддерживает?"

/datum/preference/text/sierra_background_notes/faction
	savefile_key = "sierra_faction_notes"
	notes_prompt = "Как ваш персонаж связан с этой фракцией? Какие обязательства, убеждения или разногласия для него важны?"

/datum/preference/text/sierra_background_notes/religion
	savefile_key = "sierra_religion_notes"
	notes_prompt = "Как убеждения проявляются в повседневной жизни вашего персонажа? Какие практики или сомнения для него значимы?"
