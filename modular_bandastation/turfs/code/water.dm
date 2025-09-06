/turf/open/water/no_fishing
	fishing_datum = null // There's no fish in it

/turf/open/water/alternative
	desc = "Прозрачная вода."
	icon = 'modular_bandastation/turfs/icons/water.dmi'
	icon_state = "water"
	base_icon_state = "water"
	baseturfs = /turf/open/water/alternative
	immerse_overlay_color = "#7799AA"

/turf/open/water/alternative/no_fishing
	fishing_datum = null // There's no fish in it

/turf/open/water/alternative/muddy
	desc = "Очень старая стоячая вода. Туда страшно даже ногу опустить."
	icon_state = "water_sewer"
	base_icon_state = "water_sewer"
	baseturfs = /turf/open/water/alternative/muddy
	immerse_overlay_color = "#92aa77"

/turf/open/water/alternative/muddy/no_fishing
	fishing_datum = null // There's no fish in it

/turf/open/water/alternative/muddy/deep
	name = "болотина"
	desc = "Болотистая вода. Если быть неосторожным - утянет."
	icon_state = "water_swamp"
	base_icon_state = "water_swamp"
	baseturfs = /turf/open/water/alternative/muddy/deep
	immerse_overlay_color = "#303c22"
	is_swimming_tile = TRUE
	stamina_entry_cost = 25
	ticking_stamina_cost = 15
	ticking_oxy_damage = 2
	exhaust_swimmer_prob = 100
