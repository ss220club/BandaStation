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
#define CYBERDECK_HEAT_HACK_TURRET  20
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
		if(IPC_GEN_HUMANITY)
			remove_gen3_humanity(H)
		if(IPC_GEN_CYBERDECK)
			remove_gen4_cyberdeck(H)

// ============================================
// ПОКОЛЕНИЕ II: СТАНДАРТНОЕ
// ============================================

/datum/species/ipc/proc/apply_gen2_standard(mob/living/carbon/human/H)
	return  // Нет особых механик — базовый КПБ

// ============================================
// ИНТЕГРАЦИЯ С spec_life И on_species_loss
// ============================================

// Хук в spec_life — вызываем логику поколения каждый тик
/datum/species/ipc/proc/handle_generation_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	switch(ipc_generation)
		if(IPC_GEN_HUMANITY)
			handle_gen3_life(H, seconds_per_tick, times_fired)
		if(IPC_GEN_CYBERDECK)
			handle_gen4_life(H, seconds_per_tick, times_fired)
