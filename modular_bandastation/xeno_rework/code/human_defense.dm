/// banda MODULE banda_XENO_REDO

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	. = ..()
	if(!.)
		return

	if(LAZYACCESS(modifiers, RIGHT_CLICK)) //Always drop item in hand, if no item, get stun instead.
		var/obj/item/mob_held_item = get_active_held_item()
		var/disarm_damage = rand(user.melee_damage_lower * 1.5, user.melee_damage_upper * 1.5)

		if(mob_held_item)

			if(check_block(user, damage = 0, attack_text = "[user.name]"))
				playsound(loc, 'sound/items/weapons/parry.ogg', 25, TRUE, -1) //Audio feedback to the fact you just got blocked
				apply_damage(disarm_damage / 2, STAMINA)
				visible_message(span_danger("[user] пытается дотронуться до [src]!"), \
					span_danger("[user] пытается дотронуться до вас!"), span_hear("Вы слышите свистящий звук!"), null, user)
				to_chat(user, span_warning("Вы пытаетесь дотронуться до [src]!"))
				return FALSE

			playsound(loc, 'sound/items/weapons/thudswoosh.ogg', 25, TRUE, -1) //The sounds of these are changed so the xenos can actually hear they are being non-lethal
			Knockdown(3 SECONDS)
			apply_damage(disarm_damage, STAMINA)
			visible_message(span_danger("[user] валит [src] на землю!"), \
				span_userdanger("[user] валит вас на землю!"), span_hear("Вы слышите яростное шарканье, за которым следует громкий глухой удар!"), null, user)
			to_chat(user, span_danger("Вы опрокидываете [src] на землю!"))
			return TRUE

		else
			playsound(loc, 'sound/effects/hit_kick.ogg', 25, TRUE, -1)
			apply_damage(disarm_damage, STAMINA)
			log_combat(user, src, "tackled")
			visible_message(span_danger("[user] сбивает [src] с ног!"), \
							span_userdanger("[user] сбивает вас с ног!"), span_hear("Вы слышите яростное шарканье!"), null, user)
			to_chat(user, span_danger("Вы валите [src] на землю!"))

		return TRUE

	if(user.combat_mode)
		if(w_uniform)
			w_uniform.add_fingerprint(user)

		var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(user.zone_selected))

		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)

		var/armor_block = run_armor_check(affecting, MELEE,"","",10)

		playsound(loc, 'sound/items/weapons/slice.ogg', 25, TRUE, -1)
		visible_message(span_danger("[user] наносит когтями удар по [src]!"), \
						span_userdanger("[user] наносит вам удар когтями!"), span_hear("Вы слышите мерзкий звук разрезаемой плоти!"), null, user)
		to_chat(user, span_danger("Вы наносите удар когтями по [src]!"))
		log_combat(user, src, "attacked")

		if(!dismembering_strike(user, user.zone_selected)) //Dismemberment successful
			return TRUE

		apply_damage(damage, BRUTE, affecting, armor_block)
