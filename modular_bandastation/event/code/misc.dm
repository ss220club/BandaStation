// MARK: Misc
// Труба
/obj/structure/old_tube
	name = "tube"
	desc = "Bunch of tubes."
	icon = 'modular_bandastation/event/icons/obj/misc/misc32x64.dmi'
	anchored = TRUE
	density = TRUE
	icon_state = "old_tube"
	bound_width = 64

// Полочки с говном
/obj/structure/shelf
	name = "shelf"
	desc = "A sturdy wooden shelf to store a variety of items on."
	icon = 'modular_bandastation/event/icons/obj/misc/furniture.dmi'
	icon_state = "empty_shelf_1"
	density = TRUE
	anchored = TRUE
	max_integrity = 50

/obj/structure/shelf/crates
	desc = "A sturdy wooden shelf with a bunch of crates on it."
	icon_state = "shelf_1"

/obj/structure/shelf/milkjugs
	desc = "A sturdy wooden shelf with a jugs and cartons of skimmed, semi-skimmed and full fat milk."
	icon_state = "shelf_2"

/obj/structure/shelf/alcohol
	desc = "A sturdy wooden shelf with a bunch of probably alcoholic drinks on it."
	icon_state = "shelf_3"

/obj/structure/shelf/soda
	desc = "A sturdy wooden shelf with a bunch of soft drinks on it. This planet's version of coca cola?"
	icon_state = "shelf_4"

/obj/structure/shelf/soda_multipacks
	desc = "A sturdy wooden shelf with a bunch of multipack soft drinks."
	icon_state = "shelf_5"

/obj/structure/shelf/crates1
	desc = "A sturdy wooden shelf with a bunch of crates on it. How... generic?"
	icon_state = "shelf_6"

/obj/structure/shelf/soda_milk
	desc = "A sturdy wooden shelf with an assortment of boxes. Multipack soft drinks and some milk."
	icon_state = "shelf_7"

/obj/structure/shelf/milk
	desc = "A sturdy wooden shelf with a variety of small milk cartons. Great for those who live alone!"
	icon_state = "shelf_8"

/obj/structure/shelf/milk_big
	desc = "A sturdy wooden shelf with lots of larger milk cartons."
	icon_state = "shelf_9"

/obj/structure/shelf/alcohol_small
	desc = "A sturdy wooden shelf with lots of alcohol."
	icon_state = "shelf_10"

/obj/structure/shelf/alcohol_assortment
	desc = "A sturdy wooden shelf with a variety of branded alcoholic drinks."
	icon_state = "shelf_11"

// Деревянный заборчик и ворота by FF

/obj/structure/railing/wooden_fencing
	name = "wooden fence"
	desc = "A basic wooden fence meant to prevent people like you either in or out of somewhere."
	icon = 'modular_bandastation/event/icons/obj/misc/wooden_fence.dmi'
	icon_state = "fence"
	resistance_flags = FLAMMABLE
	flags_1 = ON_BORDER_1
	/// If we randomize our icon on spawning
	var/random_icons = TRUE

/obj/structure/railing/wooden_fencing/Initialize(mapload)
	. = ..()
	if(!random_icons)
		return
	icon_state = pick(
		"fence",
		"fence_2",
		"fence_3",
	)
	update_appearance()

/obj/structure/railing/wooden_fencing/atom_deconstruct(disassembled)
	var/obj/plank = new /obj/item/stack/sheet/mineral/wood(drop_location(), 5)
	transfer_fingerprints_to(plank)

// formerly NO_DECONSTRUCTION
/obj/structure/railing/wooden_fencing/wirecutter_act(mob/living/user, obj/item/tool)
	return NONE

/obj/structure/railing/wooden_fencing/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	to_chat(user, span_warning("You pry apart the railing."))
	tool.play_tool_sound(src, 100)
	deconstruct()
	return TRUE

// Fence gates for the above mentioned fences

/obj/structure/railing/wooden_fencing/gate
	name = "wooden fence gate"
	desc = "A basic wooden gate meant to prevent animals like you escaping."
	icon_state = "gate"
	random_icons = FALSE
	/// Has the gate been opened or not?
	var/opened = FALSE

/obj/structure/railing/wooden_fencing/gate/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	return open_or_close(user)

/// Proc that checks if the gate is open or not, then closes/opens the gate repsectively
/obj/structure/railing/wooden_fencing/gate/proc/open_or_close(mob/user)
	if(!user.can_interact_with(src))
		balloon_alert(user, "can't interact")
		return
	opened = !opened
	set_density(!opened)
	icon_state = "[opened ? "gate_open" : "gate"]"
	playsound(src, (opened ? 'sound/machines/closet/wooden_closet_open.ogg' : 'sound/machines/closet/wooden_closet_close.ogg'), 100, TRUE)
	update_appearance()

/obj/structure/railing/wooden_fencing/gate/update_icon()
	. = ..()
	if(!opened)
		return

// MARK: Photo
/obj/structure/sharlotta
	name = "портрет девушки"
	desc = "Молодая светловолосая девушка в белом халате. Смотрит так, как будто сейчас расплачется. Подпись снизу - Шарлотта П-Б."
	icon = 'modular_bandastation/event/icons/obj/misc/photo.dmi'
	icon_state = "sharlotta"
	density = FALSE
	anchored = TRUE
	max_integrity = 30

/obj/structure/sharlotta/victor
	name = "портрет мужчины"
	desc = "Молодой светловолосый мужчина жилетке и галстуке. Смотрит так, как будто сейчас расхохочется. Подпись снизу - Виктор П-Б."
	icon_state = "victor"

/obj/structure/fluff/angel
	name = "статуя ангела"
	desc = "Мраморная статуя ангела, сложившего руки в молитве. \
	Надпись на табличке гласит: \"От тех, кто пал прежде. Тем, кто придёт после.\" \
	На его пьедистале выцарапаны десять насечек, одна из которых перечёркнута."
	icon = 'modular_bandastation/event/icons/obj/statue.dmi'
	icon_state = "angel"
	density = TRUE
	deconstructible = FALSE
	layer = EDGED_TURF_LAYER

/obj/structure/fluff/obelisk
	name = "чёрный обелиск"
	icon = 'modular_bandastation/event/icons/obj/misc/misc32x64.dmi'
	desc = "Разрушенный чёрный обелиск, несущий запретные знания в своих письменах. \
	Вам неизвестен этот язык, однако вы точно видели его во снах. \
	Единственное, что вы можете разобрать - это десять насечек, одна из которых уже перечёркнута..."
	icon_state = "obelisk"
