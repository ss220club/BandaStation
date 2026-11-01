/datum/quirk/pyrophobia
	name = "Pyrophobia"
	desc = "Вы боитесь огня и пламени."
	icon = FA_ICON_FIRE_EXTINGUISHER
	value = -3
	medical_record_text = "Пациент демонстрирует страх перед огнём."
	medical_symptom_text = "При нахождении рядом с открытым огнём наблюдаются панические атаки и одышка. \
		Приём препаратов, таких как псикодин, может снизить тяжесть реакции."
	hardcore_value = 5
	quirk_flags = QUIRK_TRAUMALIKE

/datum/quirk/pyrophobia/add(client/client_source)
	. = ..()
	quirk_holder.AddComponentFrom(type, /datum/component/fearful, list( \
		/datum/terror_handler/force_stop_drop_roll, \
		/datum/terror_handler/is_stop_drop_rolling, \
		/datum/terror_handler/simple_source/pyrophobia, \
	))

/datum/quirk/pyrophobia/remove()
	. = ..()
	quirk_holder.RemoveComponentSource(type, /datum/component/fearful)

/datum/mood_event/pyrophobia
	description = "Я вижу огонь, и мне это не нравится!"
	mood_change = -1
	event_flags = MOOD_EVENT_FEAR

/datum/mood_event/pyrophobia/add_effects(fire_size = 0)
	mood_change = -1 * fire_size

/datum/mood_event/pyrophobia/be_replaced(datum/mood/home, datum/mood_event/new_event, fire_size = 0)
	mood_change = min(mood_change, -1 * fire_size)
	return BLOCK_NEW_MOOD
