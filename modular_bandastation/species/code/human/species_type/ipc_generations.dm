// ============================================
// IPC: СИСТЕМА ПОКОЛЕНИЙ — DEFINES И ЯДРО
// ============================================

// ---- Поколения ----
#define IPC_GEN_MODULAR   "gen1_modular"
#define IPC_GEN_STANDARD  "gen2_standard"
#define IPC_GEN_HUMANITY  "gen3_humanity"
#define IPC_GEN_CYBERDECK "gen4_cyberdeck"

// ---- Модули Поколения I ----
#define IPC_MODULE_MEDICAL      "medical"
#define IPC_MODULE_ENGINEERING  "engineering"
#define IPC_MODULE_SECURITY     "security"
#define IPC_MODULE_RESEARCH     "research"

// ---- Пороги Человечности (Поколение III) ----
#define HUMANITY_PEAK   80   // 80-100: пик, бонус к эффективности
#define HUMANITY_NORMAL 60   // 60-80: норма, без эффектов
#define HUMANITY_LOW    40   // 40-60: лёгкие периодические глитчи
#define HUMANITY_CRIT   20   // 20-40: сильные глитчи, замедление
// 0-20: дезориентация, частичная потеря контроля

// Снижение человечности: каждые N секунд
#define HUMANITY_DECAY_INTERVAL 60
// Кол-во снижения за тик
#define HUMANITY_DECAY_AMOUNT   1

// ---- Кибердека (Поколение IV) ----
#define CYBERDECK_MAX_HEAT    100
#define CYBERDECK_OVERHEAT_AT 80   // Выше этого: начинаются эффекты
// Рассеивание тепла в покое (за тик spec_life)
#define CYBERDECK_IDLE_DISSIPATE 3
// Тепло от хака
#define CYBERDECK_HEAT_HACK_DOOR    10
#define CYBERDECK_HEAT_HACK_CONSOLE 15
// Радиус сканирования целей
#define CYBERDECK_SCAN_RANGE 7

// ============================================
// ПРИМЕНЕНИЕ ПОКОЛЕНИЯ
// ============================================

/// Вызывается из on_species_gain после создания OS.
/// Применяет черты и механики выбранного поколения.
/datum/species/ipc/proc/apply_generation(mob/living/carbon/human/H)
	switch(ipc_generation)
		if(IPC_GEN_MODULAR)
			apply_gen1_modular(H)
		if(IPC_GEN_STANDARD)
			apply_gen2_standard(H)
		if(IPC_GEN_HUMANITY)
			apply_gen3_humanity(H)
		if(IPC_GEN_CYBERDECK)
			apply_gen4_cyberdeck(H)

/// Убирает эффекты поколения при смене вида (on_species_loss).
/datum/species/ipc/proc/remove_generation(mob/living/carbon/human/H)
	switch(ipc_generation)
		if(IPC_GEN_MODULAR)
			remove_gen1_modular(H)
		if(IPC_GEN_STANDARD)
			remove_gen2_standard(H)
		if(IPC_GEN_HUMANITY)
			remove_gen3_humanity(H)
		if(IPC_GEN_CYBERDECK)
			remove_gen4_cyberdeck(H)

// ============================================
// ПОКОЛЕНИЕ II: СТАНДАРТНОЕ
// ============================================
// + Обе руки (next_move_modifier * 0.5 = мгновенная смена рук)
// + Повышенная скорость передвижения (+10%) и действий (+15%)
// - ЭМИ оглушает 1-3 сек и наносит ожоги (без паралича)

#define IPC_GEN2_TRAIT_SOURCE "ipc_gen2"

/datum/actionspeed_modifier/ipc_gen2_speed
	id = "ipc_gen2_speed"
	variable = FALSE
	multiplicative_slowdown = -0.15  // +15% скорости действий

/datum/movespeed_modifier/ipc_gen2_speed
	id = "ipc_gen2_speed"
	multiplicative_slowdown = -0.1   // +10% скорости передвижения

/datum/species/ipc/proc/apply_gen2_standard(mob/living/carbon/human/H)
	// Обе руки — сокращаем задержку кликов вдвое
	H.next_move_modifier *= 0.5
	// Скорость передвижения и действий
	H.add_movespeed_modifier(/datum/movespeed_modifier/ipc_gen2_speed)
	H.add_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen2_speed)

/datum/species/ipc/proc/remove_gen2_standard(mob/living/carbon/human/H)
	H.next_move_modifier /= 0.5
	H.remove_movespeed_modifier(/datum/movespeed_modifier/ipc_gen2_speed)
	H.remove_actionspeed_modifier(/datum/actionspeed_modifier/ipc_gen2_speed)

/// ЭМИ для Gen II: оглушение 1-3 сек + ожоги. Без паралича и брутального урона.
/datum/species/ipc/proc/gen2_handle_emp(mob/living/carbon/human/H, severity)
	var/stun_duration
	var/burn_damage
	switch(severity)
		if(EMP_HEAVY)
			stun_duration = rand(1, 3) SECONDS
			burn_damage = rand(10, 20) * emp_vulnerability
			to_chat(H, span_userdanger("ЭМИ: Стандартная система управления перегружена! Кратковременное оглушение."))
		if(EMP_LIGHT)
			stun_duration = rand(1, 2) SECONDS
			burn_damage = rand(3, 8) * emp_vulnerability
			to_chat(H, span_danger("ЭМИ: Незначительное электромагнитное возмущение."))
		else
			stun_duration = 1 SECONDS
			burn_damage = 5
	H.Stun(stun_duration)
	H.apply_damage(burn_damage, BURN, forced = TRUE)
	cpu_temperature = min(cpu_temperature + (burn_damage * 0.5), cpu_temp_critical)

// ============================================
// ИНТЕГРАЦИЯ С spec_life И on_species_loss
// ============================================

// Хук в spec_life — вызываем логику поколения каждый тик
/datum/species/ipc/proc/handle_generation_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	switch(ipc_generation)
		if(IPC_GEN_MODULAR)
			handle_gen1_life(H, seconds_per_tick, times_fired)
		if(IPC_GEN_HUMANITY)
			handle_gen3_life(H, seconds_per_tick, times_fired)
		if(IPC_GEN_CYBERDECK)
			handle_gen4_life(H, seconds_per_tick, times_fired)
