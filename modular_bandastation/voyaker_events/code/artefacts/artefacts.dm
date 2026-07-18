#define STONE_EYE_TRAIT "stone_eye"

/obj/item/artifact
	name = "Артефакт"
	desc = "Предмет неизвестного происхождения."
	icon = 'modular_bandastation/voyaker_events/icons/artefacts.dmi'
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF | UNACIDABLE
	light_range = 2
	light_power = 0.7
	light_color = "#88FFFF"
	var/float_speed = 2

/obj/item/artifact/Initialize(mapload)
	. = ..()
	add_filter("artifact_float", 2, wave_filter(
		x = 0,
		y = 2,
		size = 1,
		offset = rand(0, 360)
	))

/obj/item/artifact/fire_wing
	name = "Огненное крыло"
	desc = "Хрупкий артефакт, внутри которого бушует пламя."
	icon_state = "magma_wing"
	light_color = "#FF6600"
	light_range = 3

/obj/item/artifact/fire_wing/attack_self(mob/living/user)
	. = ..()
	to_chat(user, span_warning("Артефакт рассыпается в ваших руках, создавая поток огненного пламени вокруг вас!"))
	new /datum/fire_ring(user)
	qdel(src)

/datum/fire_ring
	var/mob/living/owner
	var/list/flames = list()
	var/lifetime = 5 SECONDS
	New(mob/living/L)
		owner = L
		create_ring()
		addtimer(CALLBACK(src, PROC_REF(update_ring)), 0.5 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(remove_ring)), lifetime)

/datum/fire_ring/proc/create_ring()
	var/turf/center = get_turf(owner)
	for(var/turf/T in RANGE_TURFS(3, center))
		if(get_dist(center, T) != 3)
			continue
		var/obj/effect/fire_ring/F = new(T)
		F.owner = owner
		flames += F

/datum/fire_ring/proc/update_ring()
	if(QDELETED(owner))
		return
	var/turf/center = get_turf(owner)
	var/i = 1
	for(var/turf/T in RANGE_TURFS(3, center))
		if(get_dist(center, T) != 3)
			continue
		if(i > flames.len)
			break
		var/obj/effect/fire_ring/F = flames[i]
		if(QDELETED(F))
			i++
			continue
		F.forceMove(T)
		F.damage_nearby()
		i++

	addtimer(CALLBACK(src, PROC_REF(update_ring)), 0.5 SECONDS)

/datum/fire_ring/proc/remove_ring()
	for(var/obj/effect/fire_ring/F in flames)
		qdel(F)
	qdel(src)

/obj/effect/fire_ring
	name = "огонь"
	icon = 'icons/effects/fire.dmi'
	icon_state = "medium"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_LAYER
	var/mob/living/owner

/obj/effect/fire_ring/proc/damage_nearby()
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T)
		if(L == owner)
			continue
		L.apply_damage(8, BURN)
		L.adjust_fire_stacks(2)
		L.ignite_mob()

/obj/item/artifact/ice_crystal
	name = "Ледяной кристалл"
	desc = "Холодный артефакт, внутри которого словно застыло само пространство."
	icon_state = "ice_crystal"
	light_color = "#7FDFFF"
	light_range = 3

/obj/item/artifact/ice_crystal/attack_self(mob/living/user)
	. = ..()
	if(!ishuman(user))
		return
	if(!length(GLOB.hub_return_landmarks))
		to_chat(user, span_warning("Артефакт не смог найти точку назначения."))
		return
	var/obj/effect/landmark/hub_return/L = pick(GLOB.hub_return_landmarks)
	to_chat(user, span_notice("Ледяной кристалл рассыпается в ваших руках..."))
	to_chat(user, span_notice("Пространство вокруг начинает покрываться инеем..."))
	if(!do_after(user, 1 SECONDS, src))
		return
	playsound(user, 'sound/effects/phasein.ogg', 70, TRUE)
	var/turf/old_turf = get_turf(user)
	do_sparks(1, FALSE, old_turf)
	user.forceMove(get_turf(L))
	user.set_static_vision(2 SECONDS)
	user.set_temp_blindness(1 SECONDS)
	qdel(src)

/obj/item/artifact/stone_eye
	name = "Каменный Глаз"
	desc = "Артефакт, внутри которого ощущается невероятная плотность."
	icon_state = "stone_eye"
	light_color = "#A0A0A0"
	light_range = 2

/obj/item/artifact/stone_eye/attack_self(mob/living/user)
	. = ..()
	to_chat(user, span_notice("Каменный глаз рассыпается в ваших руках!"))
	to_chat(user, span_boldwarning("Каменная оболочка покрывает ваше тело!"))
	playsound(user, 'sound/effects/parry.ogg', 70, TRUE)
	new /datum/stone_eye_effect(user)
	qdel(src)

/datum/stone_eye_effect
	var/mob/living/owner
	var/obj/effect/shield/shield

/datum/stone_eye_effect/New(mob/living/L)
	. = ..()
	owner = L
	ADD_TRAIT(owner, TRAIT_GODMODE, STONE_EYE_TRAIT)
	ADD_TRAIT(owner, TRAIT_PACIFISM, STONE_EYE_TRAIT)
	shield = new /obj/effect/shield(get_turf(owner))
	shield.vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE
	owner.vis_contents += shield
	addtimer(CALLBACK(src, PROC_REF(expire)), 10 SECONDS)

/datum/stone_eye_effect/proc/expire()
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_GODMODE, STONE_EYE_TRAIT)
		REMOVE_TRAIT(owner, TRAIT_PACIFISM, STONE_EYE_TRAIT)
		if(shield)
			owner.vis_contents -= shield
			qdel(shield)
	qdel(src)


