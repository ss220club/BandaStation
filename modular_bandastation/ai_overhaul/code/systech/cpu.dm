#define OVERCLOCK_MIN_POWER_MULT -0.5

#define SUCCESSFUL_OVERCLOCK "success"
#define FAILED_OVERCLOCK_SPEED "Слишком высокая частота"
#define FAILED_OVERCLOCK_POWER "Слишком высокий множитель питания"
#define FAILED_OVERCLOCK_NO_POWER "Слишком низкий множитель питания"

/** Физический нейропроцессор с индивидуальной устойчивостью разгона и историей проверок. */
/obj/item/ai_cpu
	name = "neural processing unit"
	desc = "Процессор для нейронных вычислений ИИ. Используется только в серверных модулях."

	icon = 'modular_bandastation/ai_overhaul/icons/module.dmi'
	icon_state = "cpuboard"

	w_class = WEIGHT_CLASS_SMALL

	/// Текущая частота процессора в ТГц.
	var/speed = 1
	/// Предельная частота экземпляра процессора в ТГц.
	var/max_speed = 10
	/// Базовое потребление процессора в ваттах.
	var/base_power_usage = AI_BASE_POWER_PER_CPU
	/// Выбранный множитель питания для текущего разгона.
	var/power_multiplier = 1
	/// Индивидуальный порог безопасного множителя питания.
	var/max_power_multiplier = 1

	/// Индивидуальный коэффициент устойчивости разгона по частоте.
	var/growth_scale = 1

	/// Нижняя граница случайного порога питания нового процессора.
	var/minimum_max_power = 1.25
	/// Верхняя граница случайного порога питания нового процессора.
	var/maximum_max_power = 2

	/// Нижняя граница случайного коэффициента устойчивости нового процессора.
	var/minimum_growth = 0.7
	/// Верхняя граница случайного коэффициента устойчивости нового процессора.
	var/maximum_growth = 3.5

	/// Последние пять проверок: частота, питание и результат устойчивости.
	var/list/last_overclocking_values = list()

/obj/item/ai_cpu/Initialize(mapload)
	growth_scale = rand(minimum_growth * 100, maximum_growth * 100) / 100
	max_power_multiplier = (rand(minimum_max_power * 100, maximum_max_power * 100) / 100) * power_multiplier

	return ..()

/** Проверяет устойчивость заданных частоты и питания; возвращает результат либо причину неудачи. */
/obj/item/ai_cpu/proc/valid_overclock()
	if(power_multiplier == initial(power_multiplier) && speed == initial(speed))
		return SUCCESSFUL_OVERCLOCK

	if((power_multiplier - 1) < OVERCLOCK_MIN_POWER_MULT)
		return FAILED_OVERCLOCK_NO_POWER

	var/optimal_speed_mult = 2 / (1 + NUM_E ** (-growth_scale*(power_multiplier - 1)))

	if(power_multiplier > max_power_multiplier)
		return FAILED_OVERCLOCK_POWER

	if(speed >= initial(speed) * optimal_speed_mult)
		return FAILED_OVERCLOCK_SPEED
	return SUCCESSFUL_OVERCLOCK

/** Возвращает потребление установленного оборудования в ваттах. */
/obj/item/ai_cpu/proc/get_power_usage()
	return base_power_usage * power_multiplier

/** Возвращает относительную эффективность процессора при его текущих настройках. */
/obj/item/ai_cpu/proc/get_efficiency()
	return 1 / (power_multiplier / initial(power_multiplier)) * 100

/** Сохраняет проверявшиеся настройки и результат, оставляя пять последних попыток. */
/obj/item/ai_cpu/proc/record_overclock_result(valid)
	while(length(last_overclocking_values) >= 5)
		popleft(last_overclocking_values)
	last_overclocking_values += list(list("speed" = speed, "power" = power_multiplier, "valid" = valid))

/** Улучшенный нейропроцессор с повышенной базовой производительностью. */
/obj/item/ai_cpu/advanced
	name = "advanced neural processing unit"
	desc = "Процессор для нейронных вычислений ИИ. Используется в серверных модулях. Улучшенное предсказание ветвлений и оптимизированный доступ к памяти."
	icon_state = "cpuboard_adv"

	speed = 2
	power_multiplier = /obj/item/ai_cpu::power_multiplier * 1.75

/** Экспериментальный нейропроцессор с отдельными пределами питания и разгона. */
/obj/item/ai_cpu/experimental
	name = "experimental neural processing unit"
	desc = "Процессор для нейронных вычислений ИИ. Используется в серверных модулях. Из-за ослабленного контроля качества параметры разгона сильнее различаются между экземплярами."
	icon_state = "cpuboard_adv"

	speed = 2
	base_power_usage = /obj/item/ai_cpu::base_power_usage * 2

	minimum_max_power = 1.1
	maximum_max_power = 2.5

	minimum_growth = 0.5
	maximum_growth = 4.5

/** Блюспейс-процессор верхнего технологического уровня. */
/obj/item/ai_cpu/bluespace
	name = "bluespace neural processing unit"
	desc = "Процессор для нейронных вычислений ИИ. Используется в серверных модулях. Блюспейс-технологии позволили ещё сильнее уменьшить компоненты."
	icon_state = "cpuboard_super"

	speed = 3
	base_power_usage = /obj/item/ai_cpu::base_power_usage * 2.5

#undef OVERCLOCK_MIN_POWER_MULT
