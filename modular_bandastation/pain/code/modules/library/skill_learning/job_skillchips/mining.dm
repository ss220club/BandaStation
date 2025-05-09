// -- Modular job skillchips. --
// Skillchip for miners that gives pain resistance when off the station's Z level.
/obj/item/skillchip/job/off_z_pain_resistance
	name = "D1GGY skillchip"
	auto_traits = list(TRAIT_OFF_STATION_PAIN_RESISTANCE)
	skill_name = "Off Station Pain Resistance"
	skill_description = "For the adventurous in life, this skillchip provides a reduction in pain recieved when off the station."
	skill_icon = "fist-raised"
	activate_message = "<span class='notice'>You feel like you can safely take on the unknown.</span>"
	deactivate_message = "<span class='notice'>You feel more vulnerable to the unknown.</span>"

/obj/item/skillchip/job/off_z_pain_resistance/on_deactivate(mob/living/carbon/user, silent = FALSE)
	user.unset_pain_mod(PAIN_MOD_OFF_STATION)
	return ..()

/datum/outfit/job/miner
	skillchips = list(/obj/item/skillchip/job/off_z_pain_resistance)

/obj/item/storage/box/skillchips/cargo
	name = "box of cargo skillchips"
	desc = "Contains spares of every cargo job skillchip."

/obj/item/storage/box/skillchips/cargo/PopulateContents()
	new /obj/item/skillchip/job/off_z_pain_resistance(src)
	new /obj/item/skillchip/job/off_z_pain_resistance(src)

/obj/structure/closet/secure_closet/quartermaster/PopulateContents()
	..()
	new /obj/item/storage/box/skillchips/cargo(src)
