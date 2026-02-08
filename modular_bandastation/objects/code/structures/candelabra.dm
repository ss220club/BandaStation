/obj/structure/candelabra
	name = "канделябр"
	desc = "Роскошный настенный канделябр из золота. Свечи не зажжены."
	icon = 'modular_bandastation/objects/icons/obj/structures/candelier_trio.dmi'
	icon_state = "candelier"
	anchored = TRUE
	density = FALSE
	pixel_y = 5

	var/lit = FALSE

	light_range = 3
	light_power = 1.5
	light_color = "#FFD7A3"

	attack_hand(mob/user)
		lit = !lit
		update_candle()

	proc/update_candle()
		if(lit)
			icon_state = "candelier_burning"
			set_light(TRUE)
			desc = "Роскошный настенный канделябр из золота. Свечи зажжены.."
		else
			icon_state = "candelier"
			set_light(FALSE)
			desc = "Роскошный настенный канделябр из золота. Свечи не зажжены."
