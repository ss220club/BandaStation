/datum/species
	var/hunger_icon = 'modular_bandastation/vampire/icons/screen_hunger.dmi'

/atom/movable/screen/hunger/proc/update_food_icon(mob/living/hud_owner)
	var/mob/living/carbon/carbon = astype(hud_owner, /mob/living/carbon)
	if(!carbon)
		return
	food_icon = carbon.dna.species.hunger_icon

/datum/species/proc/update_hunger_hud(mob/living/carbon/owner)
	var/atom/movable/screen/hunger/hunger_bar = owner.hud_used?.screen_objects[HUD_MOB_HUNGER]
	hunger_bar.update_food_icon(owner)

/datum/species/proc/set_food_icon(mob/living/carbon/owner, h_icon)
	hunger_icon = h_icon
	update_hunger_hud(owner)

/datum/species/proc/reset_food_icon(mob/living/carbon/owner)
	hunger_icon = initial(hunger_icon)
	update_hunger_hud(owner)

/atom/movable/screen/hunger/Initialize(mapload, datum/hud/hud_owner)
	update_food_icon()
	. = ..()

