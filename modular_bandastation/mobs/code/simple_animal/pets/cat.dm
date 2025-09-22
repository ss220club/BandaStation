/mob/living/basic/pet/cat
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	// holder_type = /obj/item/holder/cat2

/mob/living/basic/pet/cat/runtime
	// holder_type = /obj/item/holder/cat

/mob/living/basic/pet/cat/cak
	// holder_type = /obj/item/holder/cak

/mob/living/basic/pet/cat/fat
	name = "толстокот"
	desc = "Упитана. Счастлива."
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	icon_state = "iriska"
	icon_living = "iriska"
	icon_dead = "iriska_dead"
	gender = FEMALE
	mob_size = MOB_SIZE_LARGE // THICK!!!
	//canmove = FALSE
	butcher_results = list(/obj/item/food/meat = 8)
	maxHealth = 40 // Sooooo faaaat...
	health = 40
	speed = 20 // TOO FAT
	resting = TRUE
	// holder_type = /obj/item/holder/fatcat


/obj/item/mmi/posibrain/sphere/relaymove(mob/living/user, direction)
	return	// LAZY

/mob/living/basic/pet/cat/white
	name = "white cat"
	desc = "Белоснежная шерстка. Плохо различается на белой плитке, зато отлично виден в темноте!"
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	icon_state = "penny"
	icon_living = "penny"
	icon_dead = "penny_dead"
	gender = MALE
	// holder_type = /obj/item/holder/cak

/mob/living/basic/pet/cat/birman
	name = "birman cat"
	real_name = "birman cat"
	desc = "Священная порода Бирма."
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	icon_state = "crusher"
	icon_living = "crusher"
	icon_dead = "crusher_dead"
	gender = MALE
	// holder_type = /obj/item/holder/crusher


/mob/living/basic/pet/cat/black
	name = "black cat"
	real_name = "black cat"
	desc = "Он ужас летящий на крыльях ночи! Он - тыгыдык и спотыкание во тьме ночной! Бойся не заметить черного кота в тени!"
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	icon_state = "salem"
	icon_living = "salem"
	icon_dead = "salem_dead"
	gender = MALE
	// holder_type = /obj/item/holder/cat

/mob/living/basic/pet/cat/spacecat
	name = "spacecat"
	desc = "Space Kitty!!"
	icon_state = "spacecat"
	icon_living = "spacecat"
	icon_dead = "spacecat_dead"
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = TCMB
	maximum_survivable_temperature = T0C + 40
	// holder_type = /obj/item/holder/spacecat

//named
/mob/living/basic/pet/cat/floppa
	name = "Большой Шлёпа"
	desc = "Он выглядит так, будто собирается совершить военное преступление."
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	icon_state = "floppa"
	icon_living = "floppa"
	icon_dead = "floppa_dead"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/cat/fat/iriska
	name = "Ириска"
	desc = "Упитана. Счастлива. Бюрократы её обожают. И похоже даже черезчур сильно."
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/cat/white/penny
	name = "Копейка"
	desc = "Любит таскать монетки и мелкие предметы. Успевайте прятать их!"
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	resting = TRUE

/mob/living/basic/pet/cat/birman/crusher
	name = "Бедокур"
	desc = "Любит крушить всё что не прикручено. Нужно вовремя прибираться."
	icon = 'modular_bandastation/mobs/icons/mob/pets.dmi'
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	resting = TRUE

/mob/living/basic/pet/cat/spacecat/musya
	name = "Муся"
	desc = "Любимая почтенная кошка отдела токсинов. Всегда готова к вылетам!"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/basic/pet/cat/black/salem
	name = "Салем"
	real_name = "Салем"
	desc = "Говорят что это бывший колдун, лишенный всех своих сил и превратившейся в черного кота Советом Колдунов из-за попытки захватить мир, а в руки НТ попал чтобы отбывать своё наказание. Судя по его скверному нраву, это может быть похоже на правду."
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
