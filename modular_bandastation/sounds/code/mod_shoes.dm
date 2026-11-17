/obj/item/clothing/shoes/mod
	var/step_volume = 30

/obj/item/clothing/shoes/mod/update_footstep_sounds()
	switch(slowdown)
		if(0.3 to INFINITY)
			AddComponent(/datum/component/shoe_footstep, list('sound/items/modsuit/rigstep_chonk.ogg'), volume = step_volume)
		if(0.2 to 0.3)
			AddComponent(/datum/component/shoe_footstep, list('sound/items/modsuit/rigstep_heavy.ogg'), volume = step_volume)
		if(0.1 to 0.2)
			AddComponent(/datum/component/shoe_footstep, list('sound/items/modsuit/rigstep_medium.ogg'), volume = step_volume)
		if(-INFINITY to 0.1)
			AddComponent(/datum/component/shoe_footstep, list('sound/items/modsuit/rigstep.ogg'), volume = step_volume)
