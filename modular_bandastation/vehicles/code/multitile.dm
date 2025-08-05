/**
 * Multutile vehicles use hitboxes to properly work with damage and opacity
 * They can only by sealed/armored, because I can't think about such vehicles without interiors
*/

/obj/vehicle/sealed/armored/multitile
	///Holds hitbox type that will spawn with vehicle. 3x3 by default
	var/obj/hitbox/hitbox = /obj/hitbox

/obj/vehicle/sealed/armored/multitile/Initialize(mapload)
	. = ..()
	if(hitbox)
		hitbox = new hitbox(loc, src)
