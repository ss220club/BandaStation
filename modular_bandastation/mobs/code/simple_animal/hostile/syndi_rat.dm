/mob/living/basic/mouse/rat/syndirat
	name = "Синди-мышь"
	desc = "Мышь на службе синдиката?"
	icon = 'modular_bandastation/mobs/icons/animal.dmi'
	icon_state = "syndirat"
	icon_living = "syndirat"
	icon_dead = "syndirat_dead"
	icon_resting = "syndirat_sleep"
	body_color = ""
	colored_mob = null
	possible_colors = null
	health = 50
	maxHealth = 50

	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	unsuitable_atmos_damage = 0

	melee_damage_lower = 5
	melee_damage_upper = 15

	ai_controller = /datum/ai_controller/basic_controller/mouse/rat/syndi
