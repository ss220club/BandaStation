/datum/species
	var/hunger_icon = 'icons/obj/food/burgerbread.dmi'

/datum/species/vulpkanin
	hunger_icon = 'modular_bandastation/vampire/icons/screen_hunger_vampire.dmi'

/datum/species/proc/update_hunger_hud(mob/living/carbon/owner)
	var/atom/movable/screen/hunger/hunger_bar = owner.hud_used?.screen_objects[HUD_MOB_HUNGER]
	if(hunger_bar)
		hunger_bar.update_food_icon(owner)

/datum/species/proc/set_food_icon(mob/living/carbon/owner, h_icon)
	hunger_icon = h_icon
	update_hunger_hud(owner)

/datum/species/proc/reset_food_icon(mob/living/carbon/owner)
	hunger_icon = initial(hunger_icon)
	update_hunger_hud(owner)

/atom/movable/screen/hunger/proc/update_food_icon(mob/living/hud_owner)
	var/mob/living/carbon/carbon = astype(hud_owner, /mob/living/carbon)
	if(!carbon)
		return
	food_icon = carbon.dna.species.hunger_icon
	underlays -= food_image
	food_image.icon = food_icon
	underlays += food_image

/atom/movable/screen/hunger/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	update_food_icon(hud_owner?.mymob)
