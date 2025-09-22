// // Custom mob holder implementations

// // Base mob holder functionality
// /mob/living
// 	/// Type of holder to create when this mob is picked up
// 	var/holder_type = /obj/item/mob_holder

// /mob/living/proc/mob_pickup(mob/living/user)
// 	if(!holder_type)
// 		return FALSE

// 	var/obj/item/mob_holder/holder = new holder_type(get_turf(src), src, held_state, head_icon, held_lh, held_rh, worn_slot_flags)
// 	user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] подбирает [declent_ru(ACCUSATIVE)]!"))
// 	if(!user.put_in_hands(holder))
// 		qdel(holder)
// 		return FALSE
// 	return TRUE


// // Special holder types
// /obj/item/mob_holder/snail
// 	name = "snail"
// 	desc = "Slooooow"
// 	icon_state = "snail"
// 	held_state = "snail"
// 	worn_slot_flags = ITEM_SLOT_HEAD

// /obj/item/mob_holder/snail/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
// 	if(!istype(interacting_with, /obj/machinery/hydroponics))
// 		return NONE

// 	. = ITEM_INTERACT_BLOCKING
// 	if(held_mob.stat == DEAD)
// 		user.balloon_alert(user, "it's dead!")
// 		return

// 	if(locate(type) in interacting_with)
// 		user.balloon_alert(user, "already has snail!")
// 		return

// 	if(!do_after(user, 2 SECONDS, interacting_with))
// 		return

// 	forceMove(interacting_with)
// 	return ITEM_INTERACT_SUCCESS

// // Eating behavior for holders
// /obj/item/mob_holder/attack(mob/living/target, mob/living/user)
// 	if(!held_mob)
// 		return ..()

// 	var/mob/living/basic/animal = held_mob
// 	var/mob/living/carbon/devourer = target

// 	if(!istype(animal) || !istype(devourer))
// 		return ..()

// 	if(user.a_intent != INTENT_HARM)
// 		return ..()

// 	if(!is_type_in_list(animal, devourer.dna.species.allowed_consumed_mobs))
// 		if(user != devourer)
// 			to_chat(user, span_notice("Вряд ли это понравится [devourer]..."))
// 		else if(ishuman(devourer))
// 			to_chat(user, span_notice("Интересно, каков на вкус [animal]? Но проверять не будем."))
// 		return

// 	if(!user.canUnEquip(src, FALSE))
// 		to_chat(user, span_notice("[src] никак не отлипает от руки!"))
// 		return

// 	if(user != devourer)
// 		visible_message(span_danger("[user] пытается скормить [devourer] [animal]!"))
// 	else
// 		visible_message(span_danger("[user] пытается съесть [animal]!"))

// 	if(!do_after(user, 3 SECONDS, target = devourer))
// 		return

// 	visible_message(span_danger("[devourer] съедает [animal]!"))
// 	if(animal.mind)
// 		add_attack_logs(devourer, animal, "Devoured")

// 	if(istype(animal, /mob/living/basic/poison/bees))
// 		var/obj/item/organ/external/mouth = devourer.get_organ(BODY_ZONE_PRECISE_MOUTH)
// 		var/mob/living/basic/poison/bees/bee = animal
// 		mouth.receive_damage(1)
// 		if(bee.beegent)
// 			bee.beegent.reaction_mob(devourer, REAGENT_INGEST)
// 			devourer.reagents.add_reagent(bee.beegent.id, rand(1, 5))
// 		else
// 			devourer.reagents.add_reagent("spidertoxin", 5)
// 		devourer.visible_message(
// 			span_warning("Рот [devourer] опух."),
// 			span_danger("Ваш рот ужален, он теперь опухает!"))

// 	animal.forceMove(devourer)
// 	LAZYADD(devourer.stomach_contents, animal)
// 	icon = null
// 	user.dropItemToGround(src)
// 	qdel(src)


// // Special holder types for different mobs

// // pAI
// /obj/item/mob_holder/pai
// 	name = "pAI"
// 	desc = "It's a little robot."
// 	worn_slot_flags = ITEM_SLOT_HEAD | ITEM_SLOT_BOTH_EARS

// // Bees
// /obj/item/mob_holder/bee
// 	name = "bee"
// 	desc = "Buzzy buzzy bee, stingy sti- Ouch!"
// 	icon_state = "queen_item"
// 	worn_slot_flags = null

// // Bunnies
// /obj/item/mob_holder/bunny
// 	worn_slot_flags = ITEM_SLOT_HEAD | ITEM_SLOT_BOTH_EARS

// // Butterflies
// /obj/item/mob_holder/butterfly
// 	name = "butterfly"
// 	desc = "A colorful butterfly, how'd it get up here?"
// 	icon_state = "butterfly"
// 	worn_slot_flags = ITEM_SLOT_HEAD | ITEM_SLOT_BOTH_EARS

// // Mice
// /obj/item/mob_holder/mouse
// 	name = "mouse"
// 	desc = "It's a small, disease-ridden rodent."
// 	icon_state = "mouse_gray"
// 	worn_slot_flags = ITEM_SLOT_HEAD | ITEM_SLOT_BOTH_EARS

// // Maintenance Drones
// /obj/item/mob_holder/drone
// 	name = "maintenance drone"
// 	desc = "It's a small maintenance robot."
// 	icon_state = "drone"

// /obj/item/mob_holder/drone/emagged
// 	name = "maintenance drone"
// 	icon_state = "drone-emagged"

// // Monkeys
// /obj/item/mob_holder/monkey
// 	name = "monkey"
// 	desc = "It's a monkey"
// 	icon_state = "monkey"

// /obj/item/mob_holder/farwa
// 	name = "farwa"
// 	desc = "It's a farwa"
// 	icon_state = "farwa"

// /obj/item/mob_holder/stok
// 	name = "stok"
// 	desc = "It's a stok"
// 	icon_state = "stok"

// /obj/item/mob_holder/neara
// 	name = "neara"
// 	desc = "It's a neara"
// 	icon_state = "neara"

// // Dogs
// /obj/item/mob_holder/corgi
// 	name = "corgi"
// 	desc = "It's a corgi"
// 	icon_state = "corgi"

// /obj/item/mob_holder/lisa
// 	name = "lisa"
// 	desc = "It's a lisa"
// 	icon_state = "lisa"

// /obj/item/mob_holder/old_corgi
// 	name = "old corgi"
// 	desc = "It's an old corgi"
// 	icon_state = "old_corgi"

// /obj/item/mob_holder/borgi
// 	name = "borgi"
// 	desc = "It's a borgi"
// 	icon_state = "borgi"

// /obj/item/mob_holder/void_puppy
// 	name = "void puppy"
// 	desc = "It's a void puppy"
// 	icon_state = "void_puppy"

// /obj/item/mob_holder/slime_puppy
// 	name = "slime puppy"
// 	desc = "It's a slime puppy"
// 	icon_state = "slime_puppy"

// /obj/item/mob_holder/narsian
// 	name = "narsian"
// 	desc = "It's a narsian"
// 	icon_state = "narsian"
// 	worn_slot_flags = null

// /obj/item/mob_holder/pug
// 	name = "pug"
// 	desc = "It's a pug"
// 	icon_state = "pug"

// /obj/item/mob_holder/fox
// 	name = "fox"
// 	desc = "It's a fox"
// 	icon_state = "fox"

// // Sloths
// /obj/item/mob_holder/sloth
// 	name = "sloth"
// 	desc = "It's a sloth"
// 	icon_state = "sloth"
// 	worn_slot_flags = null

// // Cats
// /obj/item/mob_holder/cat
// 	name = "cat"
// 	desc = "It's a cat"
// 	icon_state = "cat"

// /obj/item/mob_holder/cat2
// 	name = "cat"
// 	desc = "It's a cat"
// 	icon_state = "cat2"

// /obj/item/mob_holder/cak
// 	name = "cak"
// 	desc = "It's a cak"
// 	icon_state = "cak"

// /obj/item/mob_holder/fatcat
// 	name = "fat cat"
// 	desc = "It's a fat cat"
// 	icon_state = "iriska"
// 	worn_slot_flags = null

// /obj/item/mob_holder/crusher
// 	name = "crusher"
// 	desc = "It's a crusher"
// 	icon_state = "crusher"

// /obj/item/mob_holder/spacecat
// 	name = "space cat"
// 	desc = "It's a space cat"
// 	icon_state = "spacecat"

// /obj/item/mob_holder/bullterrier
// 	name = "bull terrier"
// 	desc = "It's a bull terrier"
// 	icon_state = "bullterrier"
// 	worn_slot_flags = null

// // Crabs
// /obj/item/mob_holder/crab
// 	name = "crab"
// 	desc = "It's a crab"
// 	icon_state = "crab"

// /obj/item/mob_holder/evilcrab
// 	name = "evil crab"
// 	desc = "It's an evil crab"
// 	icon_state = "evilcrab"

// // Other animals
// /obj/item/mob_holder/snake
// 	name = "snake"
// 	desc = "It's a snake"
// 	icon_state = "snake"

// /obj/item/mob_holder/parrot
// 	name = "parrot"
// 	desc = "It's a parrot"
// 	icon_state = "parrot_fly"

// /obj/item/mob_holder/axolotl
// 	name = "axolotl"
// 	desc = "It's an axolotl"
// 	icon_state = "axolotl"

// /obj/item/mob_holder/lizard
// 	name = "lizard"
// 	desc = "It's a lizard"
// 	icon_state = "lizard"

// // Birds
// /obj/item/mob_holder/chick
// 	name = "chick"
// 	desc = "It's a small chicken"
// 	icon_state = "chick"

// /obj/item/mob_holder/chicken
// 	name = "chicken"
// 	desc = "It's a chicken"
// 	icon_state = "chicken_brown"
// 	worn_slot_flags = null

// /obj/item/mob_holder/cock
// 	name = "cock"
// 	desc = "It's a cock"
// 	icon_state = "cock"
// 	worn_slot_flags = null

// // Small animals
// /obj/item/mob_holder/hamster
// 	name = "hamster"
// 	desc = "It's a hamster"
// 	icon_state = "hamster"

// /obj/item/mob_holder/hamster_rep
// 	name = "Представитель Алексей"
// 	desc = "Уважаемый хомяк"
// 	icon_state = "hamster_rep"

// /obj/item/mob_holder/fennec
// 	name = "fennec"
// 	desc = "It's a fennec. Yiff!"
// 	icon_state = "fennec"

// // Insects
// /obj/item/mob_holder/moth
// 	name = "moth"
// 	desc = "Bzzzz"
// 	icon_state = "moth"

// // Special creatures
// /obj/item/mob_holder/headslug
// 	name = "headslug"
// 	desc = "It's a headslug. Ewwww..."
// 	icon_state = "headslug"

// /obj/item/mob_holder/possum
// 	name = "possum"
// 	desc = "It's a possum. Ewwww..."
// 	icon_state = "possum"

// /obj/item/mob_holder/possum/poppy
// 	name = "poppy"
// 	desc = "It's a possum Poppy. Ewwww..."
// 	icon_state = "possum_poppy"

// // Amphibians
// /obj/item/mob_holder/frog
// 	name = "frog"
// 	desc = "It's a wednesday, my dudes."
// 	icon_state = "frog"

// /obj/item/mob_holder/frog/toxic
// 	name = "rare frog"
// 	desc = "It's a toxic wednesday, my dudes."
// 	icon_state = "rare_frog"

// // Snails
// /obj/item/mob_holder/snail
// 	name = "snail"
// 	desc = "Slooooow"
// 	icon_state = "snail"

// // Turtles
// /obj/item/mob_holder/turtle
// 	name = "yeeslow"
// 	desc = "Slooooow"
// 	icon_state = "yeeslow"

// // Special
// /obj/item/mob_holder/clowngoblin
// 	name = "clowngoblin"
// 	desc = "Honk honk"
// 	icon_state = "clowngoblin"
