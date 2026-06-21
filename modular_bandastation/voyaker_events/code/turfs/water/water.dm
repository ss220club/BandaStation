/turf/open/water/alternative/muddy/no_fishing/radiation_lake
	light_range = 2
	light_power = 0.7
	light_color = "#7BAF3A"
	base_lighting_alpha

/turf/open/water/alternative/muddy/no_fishing/radiation_lake/Entered(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		var/mob/living/carbon/human = AM
		SSradiation.irradiate(AM)



