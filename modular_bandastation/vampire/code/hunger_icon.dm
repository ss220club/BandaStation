// In IPC we trust
/datum/species
	var/hunger_icon = 'icons/obj/food/burgerbread.dmi'

/mob/living
	/// Optional hunger HUD icon which overrides the species' normal food icon.
	var/hunger_icon

/mob/living/proc/set_hunger_icon(icon_file)
	hunger_icon = icon_file
	update_hunger_hud()

/mob/living/proc/reset_hunger_icon()
	hunger_icon = null
	update_hunger_hud()

/mob/living/proc/update_hunger_hud()
	var/atom/movable/screen/hunger/hunger_bar = hud_used?.screen_objects[HUD_MOB_HUNGER]
	hunger_bar?.update_food_icon(src)

/atom/movable/screen/hunger/proc/update_food_icon(mob/living/hud_owner)
	food_icon = hud_owner.hunger_icon
	var/mob/living/carbon/carbon = astype(hud_owner, /mob/living/carbon)
	if(carbon)
		food_icon = food_icon || carbon.dna.species.hunger_icon
	underlays -= food_image
	food_image.icon = food_icon
	underlays += food_image
	// TODO: fix low nutrition outline

/atom/movable/screen/hunger/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	update_food_icon(hud_owner?.mymob)
