/obj/item/cigarette/cigar/phantom
	name = "phantom cigar"
	desc = "полу-голографическая сигара, которая может быть использована для лечения некоторых повреждений. Она веет старым табаком и имеет приятный аромат. Имеет смесь лечебных трав, которые могут помочь в восстановлении здоровья. Однако, будьте осторожны, так как чрезмерное использование может вызвать привыкание."
	icon_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff"
	inhand_icon_state = "cigaron"
	inhand_icon_on = "cigaron"
	inhand_icon_off = "cigaroff"
	smoketime = 30 MINUTES
	var/healing_tick = 0

/obj/item/cigarette/cigar/phantom/process(seconds_per_tick)
	. = ..()
	if(!lit)
		return

	healing_tick++
	if(healing_tick < 5)
		return
	healing_tick = 0

	var/mob/living/smoker = isliving(loc) ? loc : null
	if(!smoker || smoker.stat == DEAD)
		return

	var/need_health_update = FALSE
	need_health_update |= smoker.adjust_brute_loss(-10, updating_health = FALSE)
	need_health_update |= smoker.adjust_fire_loss(-10, updating_health = FALSE)
	need_health_update |= smoker.adjust_tox_loss(-10, updating_health = FALSE, forced = TRUE)
	need_health_update |= smoker.adjust_oxy_loss(-10, updating_health = FALSE)
	need_health_update |= smoker.adjust_stamina_loss(-10, updating_stamina = FALSE)
	need_health_update |= smoker.adjust_organ_loss(ORGAN_SLOT_BRAIN, -10)
	if(need_health_update)
		smoker.updatehealth()
