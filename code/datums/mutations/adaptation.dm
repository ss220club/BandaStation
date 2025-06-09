/datum/mutation/adaptation
	name = "Adaptation"
	desc = "Странная мутация, которая адаптирует иммунную систему организма к экстремальным температурам. Не защищает от вакуума."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = span_notice("Твоё тело окутывает тепло!")
	instability = NEGATIVE_STABILITY_MAJOR
	locked = TRUE // fake parent
	conflicts = list(/datum/mutation/adaptation)
	mutation_traits = list(TRAIT_WADDLING)
	/// Icon used for the adaptation overlay
	var/adapt_icon = "meow"

/datum/mutation/adaptation/New(datum/mutation/copymut)
	..()
	conflicts = typesof(/datum/mutation/adaptation)
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/mob/effects/genetics.dmi', adapt_icon, -MUTATIONS_LAYER))

/datum/mutation/adaptation/get_visual_indicator()
	return visual_indicators[type][1]

/datum/mutation/adaptation/cold
	name = "Cold Adaptation"
	desc = "Странная мутация, которая адаптирует иммунную систему организма к низким температурам. Она также предотвращает подсклазьзование на льду."
	text_gain_indication = span_notice("Твое тело наполняет освежающий холод.")
	instability = POSITIVE_INSTABILITY_MODERATE
	mutation_traits = list(TRAIT_RESISTCOLD, TRAIT_NO_SLIP_ICE)
	adapt_icon = "cold"
	locked = FALSE

/datum/mutation/adaptation/heat
	name = "Heat Adaptation"
	desc = "Странная мутация, которая адаптирует иммунную систему организма к высоким температурам, а также предотвращает возгорание её обладателя, хотя пламя всё ещё сжигает одежду. Также делает носителя невосприимчивым к пепельным штормам."
	text_gain_indication = span_notice("Твоё тело наполняет лёгкое тепло.")
	instability = POSITIVE_INSTABILITY_MODERATE
	mutation_traits = list(TRAIT_RESISTHEAT, TRAIT_ASHSTORM_IMMUNE)
	adapt_icon = "fire"
	locked = FALSE

/datum/mutation/adaptation/thermal
	name = "Thermal Adaptation"
	desc = "Странная мутация, которая даёт невосприимчивость к урону от высокой и низкой температур. Не защищает от высокого и низкого давления."
	difficulty = 32
	text_gain_indication = span_notice("Твоё тело ощущает комфорто-комнатную температуру.")
	instability = POSITIVE_INSTABILITY_MAJOR
	mutation_traits = list(TRAIT_RESISTHEAT, TRAIT_RESISTCOLD)
	adapt_icon = "thermal"
	locked = TRUE // recipe

/datum/mutation/adaptation/pressure
	name = "Pressure Adaptation"
	desc = "Странная мутация, которая адаптирует иммунную систему организма к низкому и высокому давлению. Не защищает от температуры и холодного космоса в том числе."
	text_gain_indication = span_notice("Ваше тело испытывает сильное давление.")
	instability = POSITIVE_INSTABILITY_MODERATE
	adapt_icon = "pressure"
	mutation_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE)
	locked = FALSE
