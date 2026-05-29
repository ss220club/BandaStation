/mob/living/basic/carp
	density = FALSE
	pass_flags = PASSMOB | PASSTABLE

/mob/living/basic/carp/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/swarming, 20, 20)
