/obj/effect/mob_spawn/corpse/human/tsf/marine
	name = "TSF Marine Body"
	outfit = /datum/outfit/tsf/marine_unarmed

/obj/effect/mob_spawn/corpse/human/tsf/marine_officer
	name = "TSF Marine Squad Leader"
	outfit = /datum/outfit/tsf/marine_officer

/obj/effect/mob_spawn/corpse/human/tsf/marsoc
	name = "TSF MARSOC"
	outfit = /datum/outfit/tsf/marsoc_unarmed

/obj/effect/mob_spawn/corpse/human/ussp/ryadovoy
	name = "USSP Ryadovoy"
	outfit = /datum/outfit/ussp/soldier_unarmed

/obj/effect/mob_spawn/corpse/human/ussp/spetsnaz
	name = "USSP SPETSNAZ"
	outfit = /datum/outfit/ussp/spetsnaz_unarmed

/obj/effect/mob_spawn/corpse/human/ussp/officer
	name = "USSP Officer"
	outfit = /datum/outfit/ussp/ussp_officer

/obj/effect/mob_spawn/corpse/human/irs_agent
	name = "IRS Agent"
	outfit = /datum/outfit/pirate/irs

/obj/effect/mob_spawn/corpse/human/special(mob/living/carbon/human/spawned_human, mob/mob_possessor, apply_prefs)
	spawned_human.ignore_raid_death = TRUE
	. = ..()
