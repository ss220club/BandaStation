/obj/item/food/cookie/wormy
	name = "червивое печенье"
	desc = "На вид обычное печенье, но внутри что-то подозрительно шевелится."

/obj/item/food/cookie/wormy/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_FOOD_EATEN, PROC_REF(on_first_bite))

/obj/item/food/cookie/wormy/proc/on_first_bite(obj/item/food/source, mob/living/eater, mob/living/feeder, bitecount, bite_consumption,)
	SIGNAL_HANDLER
	if(bitecount != 0)
		return
	if(!eater.mind)
		return
	if(eater.mind.has_antag_datum(/datum/antagonist/changeling))
		return
	if(eater.mind.has_antag_datum(/datum/antagonist/vampire))
		to_chat(eater, span_warning("Древняя кровь и генокрад несовместимы. Вы не можете обрести силу генокрада!"))
		return
	eater.mind.add_antag_datum(/datum/antagonist/changeling/halloween)
	to_chat(eater, span_userdanger("Что-то шевельнулось внутри вас... Вы чувствуете, что ваше тело изменилось!"))

/datum/reagent/blood/vampire
	name = "древняя кровь Врахиров"
	description = "Густая кровь древнего происхождения. Кажется, она обладает собственной волей."
	color = "#641020"

/datum/reagent/blood/vampire/on_mob_life(mob/living/carbon/M, seconds_per_tick, times_fired)
	. = ..()
	if(!ishuman(M) || !M.mind)
		return
	if(M.mind.has_antag_datum(/datum/antagonist/vampire))
		return
	if(M.mind.has_antag_datum(/datum/antagonist/changeling))
		return
	M.mind.add_antag_datum(/datum/antagonist/vampire/halloween)
	to_chat(M, span_userdanger("Древняя кровь пробуждает в вас жажду. Вы чувствуете, как пробуждается вампирская сущность!"))

/obj/item/reagent_containers/cup/golden_mug/strange
	name = "поцарапанная золотая кружка"
	desc = "Кажется по одному только виду кружки можно понять, что она повидала совсем древние времена. В такие не нальют простое вино..."
	icon = 'modular_bandastation/objects/icons/obj/items/reagent_containers.dmi'
	icon_state = "golden_mug"
	fill_icon_thresholds = list(25, 50)
	fill_icon_state = "golden_mug"
	fill_icon = 'modular_bandastation/objects/icons/obj/effects/reagent_fillings.dmi'
	resistance_flags = NONE
	list_reagents = list(/datum/reagent/blood/vampire = 50)
