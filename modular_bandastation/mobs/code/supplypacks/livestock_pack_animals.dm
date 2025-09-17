// Dogs
/datum/supply_pack/critter/corgi
	name = "Corgi Crate"
	desc = "Considered the optimal dog breed by thousands of research scientists, this Corgi is but one dog from the millions of Ian's noble bloodline."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/pet/dog/corgi)
	crate_name = "corgi crate"

/datum/supply_pack/critter/pug
	name = "Pug Crate"
	desc = "Like a normal dog, but... squished. Contains one pug."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/pet/dog/pug)
	crate_name = "pug crate"

/datum/supply_pack/critter/dog_bullterrier
	name = "Bull Terrier Crate"
	desc = "Like a normal dog, but with a head the shape of an egg. Contains one bull terrier."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/pet/dog/bullterrier)
	crate_name = "bull terrier crate"

/datum/supply_pack/critter/dog_tamaskan
	name = "Tamaskan Crate"
	desc = "A wolf-like dog breed known for its intelligence and loyalty. Contains one tamaskan."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/pet/dog/tamaskan)
	crate_name = "tamaskan crate"

/datum/supply_pack/critter/dog_german
	name = "German Shepherd Crate"
	desc = "A strong, intelligent working dog often used by security forces. Contains one german shepherd."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/pet/dog/german)
	crate_name = "german shepherd crate"

/datum/supply_pack/critter/dog_brittany
	name = "Brittany Crate"
	desc = "An energetic hunting dog with a friendly disposition. Contains one brittany."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/pet/dog/brittany)
	crate_name = "brittany crate"

// Cats
/datum/supply_pack/critter/cat
	name = "Cat Crate"
	desc = "The cat goes meow! Comes with a collar and a nice cat toy!"
	cost = CARGO_CRATE_VALUE * 4
	contains = list(
		/mob/living/basic/pet/cat,
		/obj/item/clothing/neck/petcollar,
		/obj/item/toy/cattoy,
	)
	crate_name = "cat crate"

/datum/supply_pack/critter/cat/generate()
	. = ..()
	if(prob(5))
		var/mob/living/basic/pet/cat/delete_cat = locate() in .
		if(isnull(delete_cat))
			return
		qdel(delete_cat)
		new /mob/living/basic/pet/cat/fat(.)

/datum/supply_pack/critter/cat_white
	name = "White Cat Crate"
	desc = "A pristine white feline companion. Contains one white cat."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/pet/cat/white)
	crate_name = "white cat crate"

/datum/supply_pack/critter/cat_birman
	name = "Birman Cat Crate"
	desc = "A sacred cat breed with striking blue eyes. Contains one birman cat."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/mob/living/basic/pet/cat/birman)
	crate_name = "birman cat crate"

// Foxes
/datum/supply_pack/critter/fox
	name = "Fox Crate"
	desc = "The fox goes...? Contains one fox."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/pet/dog/fox)
	crate_name = "fox crate"

/datum/supply_pack/critter/fox/generate()
	. = ..()
	if(prob(30))
		var/mob/living/basic/pet/dog/fox/delete_fox = locate() in .
		if(isnull(delete_fox))
			return
		qdel(delete_fox)
		new /mob/living/basic/pet/dog/fox/forest(.)

/datum/supply_pack/critter/fennec
	name = "Fennec Crate"
	desc = "A tiny desert fox with enormous ears. Contains one fennec fox."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/mob/living/basic/pet/dog/fox/fennec)
	crate_name = "fennec crate"

// Amphibians
/datum/supply_pack/critter/frog
	name = "Frog Crate"
	desc = "Ribbit! Contains 1-3 frogs."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/mob/living/basic/frog)
	crate_name = "frog crate"

/datum/supply_pack/critter/frog/generate()
	. = ..()
	for(var/i in 1 to rand(1, 3))
		new /mob/living/basic/frog(.)

/datum/supply_pack/critter/frog/toxic
	name = "Toxic Frog Crate"
	desc = "Handle with care! Contains 1-3 poisonous frogs."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/mob/living/basic/frog/toxic)
	crate_name = "toxic frog crate"
	hidden = TRUE

/datum/supply_pack/critter/frog/toxic/generate()
	. = ..()
	if(prob(25))
		var/mob/living/basic/frog/toxic/delete_frog = locate() in .
		if(isnull(delete_frog))
			return
		qdel(delete_frog)
		new /mob/living/basic/frog/toxic/scream(.)

/datum/supply_pack/critter/frog/scream
	name = "Screaming Frog Crate"
	desc = "AAAAAAH! Contains 1-3 very loud frogs."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/frog/scream)
	crate_name = "screaming frog crate"
	hidden = TRUE

/datum/supply_pack/critter/snail
	name = "Snail Crate"
	desc = "Slow and steady wins the race. Contains 1-5 snails."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/mob/living/basic/snail)
	crate_name = "snail crate"

/datum/supply_pack/critter/snail/generate()
	. = ..()
	for(var/i in 1 to rand(1, 5))
		new /mob/living/basic/snail(.)

/datum/supply_pack/critter/turtle
	name = "Turtle Crate"
	desc = "Cute flora turtles that'll emit good vibes to nearby plants!"
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/mob/living/basic/turtle)
	crate_name = "turtle crate"

// Lizards
/datum/supply_pack/critter/iguana
	name = "Iguana Crate"
	desc = "A large herbivorous lizard. Handle with care! Contains one iguana."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/hostile/lizard)
	crate_name = "iguana crate"

/datum/supply_pack/critter/gator
	name = "Alligator Crate"
	desc = "A dangerous reptilian predator. Handle with extreme care! Contains one alligator."
	cost = CARGO_CRATE_VALUE * 8
	contains = list(/mob/living/basic/hostile/lizard/gator)
	crate_name = "alligator crate"

/datum/supply_pack/critter/croco
	name = "Crocodile Crate"
	desc = "An even more dangerous reptilian predator. Handle with extreme care! Contains one crocodile."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/mob/living/basic/hostile/lizard/croco)
	crate_name = "crocodile crate"

// Misc
/datum/supply_pack/critter/sloth
	name = "Sloth Crate"
	desc = "A slow-moving arboreal mammal. Contains one sloth."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/pet/sloth)
	crate_name = "sloth crate"

/datum/supply_pack/critter/goose
	name = "Goose Crate"
	desc = "A waterfowl known for its aggressive behavior. Contains one goose."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/mob/living/basic/goose)
	crate_name = "goose crate"

/datum/supply_pack/critter/gosling
	name = "Gosling Crate"
	desc = "Baby geese that will grow into terrifying adults. Contains 1-3 goslings."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/mob/living/basic/goose/gosling)
	crate_name = "gosling crate"

/datum/supply_pack/critter/gosling/generate()
	. = ..()
	for(var/i in 1 to rand(1, 3))
		new /mob/living/basic/goose/gosling(.)

/datum/supply_pack/critter/hamster
	name = "Hamster Crate"
	desc = "Small, furry rodents that make great pets. Contains 1-5 hamsters."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/mob/living/basic/mouse/hamster)
	crate_name = "hamster crate"

/datum/supply_pack/critter/hamster/generate()
	. = ..()
	for(var/i in 1 to rand(1, 5))
		new /mob/living/basic/mouse/hamster(.)

/datum/supply_pack/critter/possum
	name = "Possum Crate"
	desc = "North America's only marsupial. Contains 1-5 possums."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/mob/living/basic/possum)
	crate_name = "possum crate"

/datum/supply_pack/critter/possum/generate()
	. = ..()
	for(var/i in 1 to rand(1, 5))
		new /mob/living/basic/possum(.)

// /datum/supply_pack/critter/moth
// 	name = "Moth Crate"
// 	desc = "A crate containing 1-5 moths. May include some... damaged clothing."
// 	cost = CARGO_CRATE_VALUE * 5
// 	contains = list(/mob/living/basic/moth)
// 	crate_name = "moth crate"

// /datum/supply_pack/critter/moth/generate()
// 	. = ..()
// 	var/moth_count = rand(1, 5)
// 	for(var/i in 1 to moth_count)
// 		if(prob(50))
// 			new /mob/living/basic/nian_caterpillar(.)
// 		else
// 			new /mob/living/basic/moth(.)

// 	if(prob(50))
// 		var/clothes_amount = rand(1, 8)
// 		var/static/list/possible_clothes = list(
// 			/obj/item/clothing/suit/pimpcoat = 50,
// 			/obj/item/clothing/suit/tailcoat = 25,
// 			/obj/item/clothing/suit/victcoat = 25,
// 			/obj/item/clothing/suit/victcoat/red = 25,
// 			/obj/item/clothing/suit/draculacoat = 25,
// 			/obj/item/clothing/suit/browntrenchcoat = 25,
// 			/obj/item/clothing/suit/blacktrenchcoat = 25,
// 			/obj/item/clothing/suit/storage/blueshield = 5,
// 			/obj/item/clothing/suit/sovietcoat = 5,
// 			/obj/item/clothing/suit/armor/vest/capcarapace/jacket = 1,
// 			/obj/item/clothing/suit/armor/vest/capcarapace/jacket/tunic = 1,
// 			/obj/item/clothing/suit/armor/vest/capcarapace/coat = 1,
// 			/obj/item/clothing/suit/armor/vest/capcarapace/coat/white = 1,
// 		)
// 		for(var/i in 1 to clothes_amount)
// 			var/picked = pick(possible_clothes)
// 			new picked(.)
