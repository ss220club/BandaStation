/obj/item/organ/brain/cybernetic/vox
	name = "Vox cortical stack"
	desc = "A brain which has been in some part mechanized. The components are seamlessly integrated into the flesh."
	icon = 'icons/bandastation/mob/species/vox/organs.dmi'
	icon_state = "cortical-stack"

/obj/item/organ/eyes/vox
	name = "vox eyeballs"
	icon = 'icons/bandastation/mob/species/vox/organs.dmi'

	eye_icon = 'icons/bandastation/mob/species/vox/vox_eyes.dmi'

/obj/item/organ/heart/vox
	name = "vox heart"
	icon = 'icons/bandastation/mob/species/vox/organs.dmi'

/obj/item/organ/stomach/vox
	name = "vox stomach"
	icon = 'icons/bandastation/mob/species/vox/organs.dmi'

/obj/item/organ/liver/vox
	name = "vox liver"
	icon = 'icons/bandastation/mob/species/vox/organs.dmi'
	alcohol_tolerance = ALCOHOL_RATE * 1.6

/obj/item/organ/lungs/vox
	name = "vox lungs"
	icon = 'icons/bandastation/mob/species/vox/organs.dmi'

	safe_oxygen_min = 0
	safe_oxygen_max = 2
	oxy_damage_type = TOX

	safe_nitro_min = 10

/obj/item/organ/tongue/vox
	name = "vox tongue"
	icon = 'icons/bandastation/mob/species/vox/organs.dmi'
	languages_native = list(/datum/language/vox)
	liked_foodtypes = BUGS | TECH
	disliked_foodtypes = NONE

//	VOX EDIBLE CIRCUITS
/obj/item/circuitboard
	max_integrity = 60
	integrity_failure = 0
	var/obj/item/food/circuitboard/vox_snack

/obj/item/food/circuitboard
	name = "temporary vox snack item"
	spawn_blacklisted = TRUE
	bite_consumption = 1
	food_reagents = list(/datum/reagent/consumable/nutriment = INFINITY)
	tastes = list("кремний" = 1, "медь" = 1)
	foodtypes = TECH

	var/datum/weakref/circuitboard

/obj/item/food/circuitboard/make_edible()
	. = ..()
	AddComponentFrom(SOURCE_EDIBLE_INNATE, /datum/component/edible, after_eat = CALLBACK(src, PROC_REF(after_eat)))

/obj/item/food/circuitboard/proc/after_eat(mob/eater)
	var/obj/item/circuitboard/real_circuitboard = circuitboard.resolve()
	if (real_circuitboard)
		real_circuitboard.take_damage(15, sound_effect = FALSE, damage_flag = CONSUME)
	else
		qdel(src)

/obj/item/circuitboard/attack(mob/living/target, mob/living/user, list/modifiers, list/attack_modifiers)
	if(user.combat_mode || !isvox(user)) //|| ispickedupmob(src)
		return ..()
	if(isnull(vox_snack))
		create_vox_snack()
	vox_snack.attack(target, user, modifiers)

/obj/item/circuitboard/proc/create_vox_snack()
	vox_snack = new
	vox_snack.name = name
	vox_snack.circuitboard = WEAKREF(src)
