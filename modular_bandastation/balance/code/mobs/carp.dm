/mob/living/basic/carp
	density = FALSE
	pass_flags = PASSMOB | PASSTABLE | PASSSTRUCTURE | PASSMACHINE

/mob/living/basic/carp/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/swarming, 20, 20)
