///Smoke coming from cigarettes and fires
/datum/pollutant/smoke //and mirrors
	name = "Smoke"
	pollutant_flags = POLLUTANT_APPEARANCE | POLLUTANT_SMELL | POLLUTANT_BREATHE_ACT
	smell_intensity = 1
	descriptor = SCENT_DESC_SMELL
	scent = "дымом"

/datum/pollutant/smoke/breathe_act(mob/living/carbon/victim, amount)
	if(amount <= 50)
		return
	if(prob(20))
		victim.emote("cough")

///From smoking weed
/datum/pollutant/smoke/cannabis
	name = "Cannabis"
	smell_intensity = 2 //Stronger than the normal smoke
	scent = "каннабисом"

/datum/pollutant/smoke/vape
	name = "Vape Cloud"
	thickness = 2
	scent = "приятным и мягким паром"

///Dust from mining drills
/datum/pollutant/dust
	name = "Dust"
	pollutant_flags = POLLUTANT_APPEARANCE | POLLUTANT_BREATHE_ACT
	thickness = 2
	color = "#ffed9c"

/datum/pollutant/dust/breathe_act(mob/living/carbon/victim, amount)
	if(amount <= 10)
		return
	if(prob(40))
		victim.losebreath += 3 //Get in your lungs real bad
		victim.emote("cough")

///Sulphur coming from igniting matches
/datum/pollutant/sulphur
	name = "Sulphur"
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 5 //Very pronounced smell (and good too, sniff sniff)
	descriptor = SCENT_DESC_SMELL
	scent = "серой"

///Organic waste and garbage makes this
/datum/pollutant/decaying_waste
	name = "Decaying Waste"
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 3
	descriptor = SCENT_DESC_ODOR
	scent = "мусоркой"

///A special "Quick Dispersal" smoke for special cigars
/datum/pollutant/bright_cosmos
	name = "Cosmic Smoke"
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 1
	descriptor = SCENT_DESC_SMELL
	scent = "освежающей мятой и безобидным дымом"

///Green goo piles and medicine chemical reactions make this
/datum/pollutant/chemical_vapors
	name = "Chemical Vapors"
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 1
	descriptor = SCENT_DESC_SMELL
	scent = "химикатами"

///Dangerous fires release this from the waste they're burning
/datum/pollutant/carbon_air_pollution
	name = "Carbon Air Pollution"
	pollutant_flags = POLLUTANT_BREATHE_ACT

/datum/pollutant/carbon_air_pollution/breathe_act(mob/living/carbon/victim, amount)
	if(victim.body_position == LYING_DOWN)
		amount *= 0.35 //The victim is inhaling roughly a third when laying down
	if(amount <= 10)
		return
	victim.adjust_oxy_loss(rand(5,10))
	victim.adjust_tox_loss(1)
	if(prob(amount))
		victim.losebreath += 3

//Food related smells
/datum/pollutant/food
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 0.5 //Low intensity because we want to carry it farther with more amounts
	descriptor = SCENT_DESC_SMELL

/datum/pollutant/food/fried_meat
	name = "Fried Meat"
	scent = "жареным мясом"

/datum/pollutant/food/fried_bacon
	name = "Fried Bacon"
	scent = "жареным беконом"

/datum/pollutant/food/fried_fish
	name = "Fried Fish"
	scent = "жареной рыбой"

/datum/pollutant/food/pancakes
	name = "Pancakes"
	scent = "панкейками"

/datum/pollutant/food/coffee
	name = "Coffee"
	scent = "кофе"

/datum/pollutant/food/tea
	name = "Tea"
	scent = "чаем"

/datum/pollutant/food/chocolate
	name = "Chocolate"
	scent = "шоколадом"

/datum/pollutant/food/spicy_noodles
	name = "Spicy Noodles"
	scent = "острой лапшой"

//Fragrances that we spray on thing to make them smell nice
/datum/pollutant/fragrance
	pollutant_flags = POLLUTANT_SMELL
	smell_intensity = 1
	descriptor = SCENT_DESC_FRAGRANCE

/datum/pollutant/fragrance/air_refresher
	name = "Air Refresher"
	scent = "сильным цветочным араматом"
	smell_intensity = 3

//Simple fragrances
/datum/pollutant/fragrance/cologne
	name = "Cologne Water"
	scent = "туалетной водой"

/datum/pollutant/fragrance/wood
	name = "Wood Perfume"
	scent = "старой древесиной"

/datum/pollutant/fragrance/rose
	name = "Rose Perfume"
	scent = "розами"

/datum/pollutant/fragrance/jasmine
	name = "Jasmine Perfume"
	scent = "жасмином"

/datum/pollutant/fragrance/mint
	name = "Mint Perfume"
	scent = "мятой"

/datum/pollutant/fragrance/vanilla
	name = "Vanilla Perfume"
	scent = "ванилью"

/datum/pollutant/fragrance/pear
	name = "Pear Perfume"
	scent = "грушой"

/datum/pollutant/fragrance/strawberry
	name = "Strawberry Perfume"
	scent = "клубникой"

/datum/pollutant/fragrance/cherry
	name = "Cherry Perfume"
	scent = "вишней"

/datum/pollutant/fragrance/amber
	name = "Amber Perfume"
	scent = "сладким ароматом"
