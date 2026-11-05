// Native start landmarks select canonical jobs; variants share their job's vacancies.
/obj/effect/landmark/start/donor
	icon = 'modular_bandastation/donor_jobs/icons/landmarks.dmi'
	icon_state = null

/obj/effect/landmark/start/donor/waiter
	name = /datum/job/donor/waiter::title
	icon_state = "bar"

/obj/effect/landmark/start/donor/waiter/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/donor/acolyte
	name = /datum/job/donor/acolyte::title
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "Chaplain"

/obj/effect/landmark/start/donor/acolyte/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/donor/musician
	name = /datum/job/donor/musician::title
	icon_state = "art"

/obj/effect/landmark/start/donor/musician/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/donor/actor
	name = /datum/job/donor/actor::title
	icon_state = "art"

/obj/effect/landmark/start/donor/actor/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/donor/service_administrator
	name = /datum/job/donor/service_administrator::title
	icon_state = "bar"

/obj/effect/landmark/start/donor/service_administrator/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/donor/tourist_tsf
	name = /datum/job/donor/tourist_tsf::title
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "Assistant"

/obj/effect/landmark/start/donor/tourist_tsf/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/donor/tourist_ussp
	name = /datum/job/donor/tourist_ussp::title
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "Assistant"

/obj/effect/landmark/start/donor/tourist_ussp/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/donor/service_guard
	name = /datum/job/donor/service_guard::title
	icon_state = "bar"

/obj/effect/landmark/start/donor/service_guard/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/donor/migrant
	name = /datum/job/donor/migrant::title
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "Assistant"

/obj/effect/landmark/start/donor/migrant/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/donor/unemployed
	name = /datum/job/donor/unemployed::title
	icon_state = "uncertain"

/obj/effect/landmark/start/donor/unemployed/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/donor/representative_tsf
	name = /datum/job/donor/representative_tsf::title
	icon_state = "vip"

/obj/effect/landmark/start/donor/representative_tsf/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/donor/representative_ussp
	name = /datum/job/donor/representative_ussp::title
	icon_state = "vip"

/obj/effect/landmark/start/donor/representative_ussp/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/donor/merchant
	name = /datum/job/donor/merchant::title
	icon_state = "dealer"

/obj/effect/landmark/start/donor/merchant/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/donor/vip_guest
	name = /datum/job/donor/vip_guest::title
	icon_state = "vip"

/obj/effect/landmark/start/donor/vip_guest/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/donor/banker
	name = /datum/job/donor/banker::title
	icon_state = "vip"

/obj/effect/landmark/start/donor/banker/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/donor/security_clown
	name = /datum/job/donor/security_clown::title
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "Clown"

/obj/effect/landmark/start/donor/security_clown/override
	jobspawn_override = TRUE
	delete_after_roundstart = FALSE
