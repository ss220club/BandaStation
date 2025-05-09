// -- Smites. --

#define PAIN_LITTLE "a little"
#define PAIN_LOT "a lot"
#define PAIN_MAX "max payne"

// Bonus smite that gives the person a 100 pain modifier
/datum/smite/glass_bones_and_paper_skin
	name = "Glass Bones and Paper Skin"
	/// Whether to also fill them with some pain
	var/apply_pain

/datum/smite/glass_bones_and_paper_skin/configure(client/user)
	var/static/list/how_much_hurt = list("no thanks, let them figure it out", PAIN_LITTLE, PAIN_LOT, PAIN_MAX)
	apply_pain = input(user, "Do you want to apply some pain to all their body parts, too?") in how_much_hurt

/datum/smite/glass_bones_and_paper_skin/effect(client/user, mob/living/carbon/target)
	. = ..()
	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return
	if(!target.pain_controller)
		to_chat(user,  span_warning("This mob doesn't have a pain datum, sadly."), confidential = TRUE)
		return

	var/pain_amount = 0
	switch(apply_pain)
		if(PAIN_LITTLE)
			pain_amount = 25
		if(PAIN_LOT)
			pain_amount = 60
		if(PAIN_MAX)
			pain_amount = 999

	target.cause_pain(BODY_ZONES_ALL, pain_amount)
	target.set_pain_mod("badmin", 100)

#undef PAIN_LITTLE
#undef PAIN_LOT
#undef PAIN_MAX
