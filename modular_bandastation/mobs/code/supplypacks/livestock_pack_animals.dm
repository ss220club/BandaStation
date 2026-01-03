// --------------------
// 🐶 Dogs
// --------------------

/datum/supply_pack/critter/corgi
	name = "Ящик с корги"
	crate_name = "ящик с корги"
	desc = "Считается оптимальной породой собак по мнению тысяч учёных. Содержит одного корги."

/datum/supply_pack/critter/pug
	name = "Ящик с мопсом"
	crate_name = "ящик с мопсом"
	desc = "Как обычная собака, но… приплюснутая. Содержит одного мопса."

/datum/supply_pack/critter/bullterrier
	name = "Ящик с бультерьером"
	desc = "Собака с яйцеобразной головой. Содержит одного бультерьера."
	crate_name = "ящик с бультерьером"

// New dogs
/datum/supply_pack/critter/dog_tamaskan
	name = "Ящик с тамасканом"
	desc = "Похож на волка, известен умом и верностью. Содержит одного тамаскана."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/pet/dog/tamaskan)
	crate_name = "ящик с тамасканом"

/datum/supply_pack/critter/dog_german
	name = "Ящик с овчаркой"
	desc = "Сильная и умная собака, часто используется в охране. Содержит одну овчарку."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/pet/dog/german)
	crate_name = "ящик с овчаркой"

/datum/supply_pack/critter/dog_brittany
	name = "Ящик с бретонцем"
	desc = "Энергичная охотничья собака с дружелюбным характером. Содержит одного бретонца."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/pet/dog/brittany)
	crate_name = "ящик с бретонцем"

// --------------------
// 🐱 Cats
// --------------------

/datum/supply_pack/critter/cat
	name = "Ящик с кошкой"
	desc = "Кошка говорит 'мяу'! В комплекте ошейник и игрушка."
	crate_name = "ящик с кошкой"

/datum/supply_pack/critter/cat/generate()
	. = ..()
	// 5% chance to replace with fat cat
	if(prob(5))
		var/mob/living/basic/pet/cat/delete_cat = locate() in .
		if(isnull(delete_cat))
			return
		qdel(delete_cat)
		new /mob/living/basic/pet/cat/fat(.)

/datum/supply_pack/critter/cat_white
	name = "Ящик с белой кошкой"
	desc = "Белоснежная кошка-компаньон. Содержит одну белую кошку."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/pet/cat/white)
	crate_name = "ящик с белой кошкой"

/datum/supply_pack/critter/cat_birman
	name = "Ящик с бирманской кошкой"
	desc = "Священная порода с ярко-голубыми глазами. Содержит одну бирманскую кошку."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/mob/living/basic/pet/cat/birman)
	crate_name = "ящик с бирманской кошкой"

// --------------------
// 🦊 Foxes
// --------------------

/datum/supply_pack/critter/fox
	name = "Ящик с лисой"
	desc = "Что говорит лиса? Содержит одну лису."
	crate_name = "ящик с лисой"

/datum/supply_pack/critter/fox/generate()
	. = ..()
	// 30% chance to replace with forest fox
	if(prob(30))
		var/mob/living/basic/pet/fox/delete_fox = locate() in .
		if(isnull(delete_fox))
			return
		qdel(delete_fox)
		new /mob/living/basic/pet/fox/forest(.)

/datum/supply_pack/critter/fennec
	name = "Ящик с фенеком"
	desc = "Маленькая пустынная лисица с огромными ушами. Содержит одного фенека."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/mob/living/basic/pet/fox/fennec)
	crate_name = "ящик с фенеком"

// --------------------
// 🐸 Amphibians
// --------------------

/datum/supply_pack/critter/frog
	name = "Ящик с лягушками"
	desc = "Ква-ква! Содержит от 1 до 3 лягушек."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/mob/living/basic/frog)
	crate_name = "ящик с лягушками"

/datum/supply_pack/critter/frog/generate()
	. = ..()
	for(var/i in 1 to rand(1, 3))
		new /mob/living/basic/frog(.)

/datum/supply_pack/critter/frog/toxic
	name = "Ящик с ядовитыми лягушками"
	desc = "Осторожно! Содержит от 1 до 3 ядовитых лягушек."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/mob/living/basic/frog/rare/toxic)
	crate_name = "ящик с ядовитыми лягушками"
	order_flags = ORDER_INVISIBLE

/datum/supply_pack/critter/frog/toxic/generate()
	. = ..()
	// 25% chance to do screaming toxic frog
	if(prob(25))
		new /mob/living/basic/frog/rare/toxic/scream(.)
	for(var/i in 1 to rand(1, 2))
		new /mob/living/basic/frog/rare/toxic(.)

/datum/supply_pack/critter/frog/scream
	name = "Ящик с кричащими лягушками"
	desc = "ААААААА! Содержит пару очень громких лягушек."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/frog/scream)
	crate_name = "ящик с кричащими лягушками"
	order_flags = ORDER_INVISIBLE

/datum/supply_pack/critter/frog/scream/generate()
	. = ..()
	for(var/i in 1 to rand(1, 3))
		new /mob/living/basic/frog/scream(.)

/datum/supply_pack/critter/snail
	name = "Ящик с улитками"
	desc = "Медленно, но верно. Содержит кучу улиток."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/mob/living/basic/snail)
	crate_name = "ящик с улитками"

/datum/supply_pack/critter/snail/generate()
	. = ..()
	for(var/i in 1 to rand(1, 5))
		new /mob/living/basic/snail(.)

/datum/supply_pack/critter/turtle
	name = "Ящик с черепахой"
	desc = "Милые черепашки с положительным вайбом! Содержит одну черепаху."
	crate_name = "ящик с черепахой"

// --------------------
// 🦎 Lizards
// --------------------

/datum/supply_pack/critter/iguana
	name = "Ящик с игуаной"
	cost = CARGO_CRATE_VALUE * 4
	desc = "Крупная травоядная ящерица. Обращайтесь осторожно! Содержит одну игуану."
	contains = list(/mob/living/basic/lizard/big)
	crate_name = "ящик с игуаной"

/datum/supply_pack/critter/gator
	name = "Ящик с аллигатором"
	cost = CARGO_CRATE_VALUE * 8
	desc = "Опасный хищник. Обращайтесь с экстремальной осторожностью! Содержит одного аллигатора."
	contains = list(/mob/living/basic/lizard/big/gator)
	crate_name = "ящик с аллигатором"

/datum/supply_pack/critter/croco
	name = "Ящик с крокодилом"
	cost = CARGO_CRATE_VALUE * 6
	desc = "Ещё более опасный хищник. Обращайтесь с экстремальной осторожностью! Содержит одного крокодила."
	contains = list(/mob/living/basic/lizard/big/croco)
	crate_name = "ящик с крокодилом"

// --------------------
// 🐾 Misc
// --------------------

/datum/supply_pack/critter/sloth
	name = "Ящик с ленивцем"
	desc = "Медлительное древесное млекопитающее. Содержит одного ленивца."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/sloth)
	crate_name = "ящик с ленивцем"

/datum/supply_pack/critter/goose
	cost = CARGO_CRATE_VALUE * 3
	name = "Ящик с гусём"
	desc = "Водоплавающая птица, известная своей агрессивностью. Содержит одного гуся."
	contains = list(/mob/living/basic/goose)
	crate_name = "ящик с гусем"

/datum/supply_pack/critter/gosling
	name = "Ящик с гусятами"
	desc = "Маленькие гуси, которые вырастут в устрашающих взрослых. Содержит от 1 до 3 гусят."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/mob/living/basic/goose/gosling)
	crate_name = "ящик с гусятами"

/datum/supply_pack/critter/gosling/generate()
	. = ..()
	for(var/i in 1 to rand(1, 3))
		new /mob/living/basic/goose/gosling(.)

/datum/supply_pack/critter/hamster
	name = "Ящик с хомяками"
	cost = CARGO_CRATE_VALUE * 2
	desc = "Маленькие пушистые грызуны, отличные питомцы. Содержит 1-5 хомяков."
	contains = list(/mob/living/basic/mouse/hamster)
	crate_name = "ящик с хомяками"

/datum/supply_pack/critter/hamster/generate()
	. = ..()
	for(var/i in 1 to rand(1, 5))
		new /mob/living/basic/mouse/hamster(.)

/datum/supply_pack/critter/possum
	name = "Ящик с опоссумами"
	desc = "Единственный сумчатый Северной Америки. Содержит от 1 до 5 опоссумов."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/mob/living/basic/possum)
	crate_name = "ящик с опоссумами"

/datum/supply_pack/critter/possum/generate()
	. = ..()
	for(var/i in 1 to rand(1, 5))
		new /mob/living/basic/possum(.)

/datum/supply_pack/critter/pig/generate()
	. = ..()
	var/rand_int = rand(1, 30)
	switch(rand_int)
		if(5 to 10) // начинаем с пяти, меньше - значит не выпало
			new /mob/living/basic/pig/baby(.)
		if(11 to 15)
			new /mob/living/basic/pig/baby/teen(.)
		if(16 to 19)
			new /mob/living/basic/pig/baby/young(.)
		if(20 to 23)
			new /mob/living/basic/pig/adult(.)
		if(24 to 26)
			new /mob/living/basic/pig/old(.)
		if(27 to 30)
			new /mob/living/basic/pig/old/ancient(.)
