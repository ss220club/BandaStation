// ============================================
// МЕНТАНИЛ — НЕЙРОХИМИЧЕСКИЙ СТИМУЛЯТОР КПБ
// ============================================
// Синтетический препарат для КПБ III поколения.
// Повышает параметр человечности на 20%.
// При многократном применении вызывает зависимость:
//   ≥3 использований: предупреждение о риске
//   ≥5 использований: синдром отмены после каждой дозы
//
// Продаётся в карго за 100 кредитов/инъектор.
// ============================================

#define MENTALIN_HUMANITY_BOOST   20   // сколько % человечности добавляет одна доза
#define MENTALIN_WITHDRAWAL_DELAY (5 MINUTES)  // через сколько наступает синдром отмены
#define MENTALIN_ADDICTION_THRESHOLD 3  // с этого числа доз начинается риск зависимости

/// Одноразовый инъектор ментанила.
/obj/item/mentalin_injector
	name = "ментанил"
	desc = "Одноразовый нейрохимический инъектор. Содержит ментанил — вещество, временно стимулирующее эмоциональный контур позитронного ядра КПБ III поколения. Повышает параметр человечности. При злоупотреблении вызывает привыкание."
	icon = 'modular_bandastation/MachAImpDe/icons/stack_medical.dmi'
	icon_state = "mentalin_injector"
	w_class = WEIGHT_CLASS_TINY
	/// Флаг — был ли инъектор уже использован
	var/used = FALSE

/obj/item/mentalin_injector/interact(mob/living/user)
	. = ..()
	if(used)
		to_chat(user, span_warning("Инъектор пуст."))
		return
	if(!istype(user, /mob/living/carbon/human))
		return
	var/mob/living/carbon/human/H = user
	if(!istype(H.dna?.species, /datum/species/ipc))
		to_chat(H, span_warning("Ментанил разработан исключительно для позитронных ядер КПБ."))
		return
	var/datum/species/ipc/S = H.dna.species
	if(S.ipc_generation != IPC_GEN_HUMANITY)
		to_chat(H, span_warning("Ментанил эффективен только для КПБ III поколения (с эмоциональным ядром)."))
		return

	used = TRUE
	icon_state = "mentalin_injector_empty"
	name = "ментанил (пустой)"

	S.mentalin_uses++
	S.humanity = min(100, S.humanity + MENTALIN_HUMANITY_BOOST)
	to_chat(H, span_notice("ОС: Ментанил введён. Человечность: +[MENTALIN_HUMANITY_BOOST]% → [round(S.humanity)]%."))

	if(S.mentalin_uses >= MENTALIN_ADDICTION_THRESHOLD)
		to_chat(H, span_warning("ПРЕДУПРЕЖДЕНИЕ: Обнаружена высокая частота применения ментанила. Риск зависимости повышен."))

	// При злоупотреблении — регистрируем синдром отмены
	if(S.mentalin_uses > MENTALIN_ADDICTION_THRESHOLD + 1)
		addtimer(CALLBACK(S, TYPE_PROC_REF(/datum/species/ipc, mentalin_withdrawal), H), MENTALIN_WITHDRAWAL_DELAY)

// ============================================
// СИНДРОМ ОТМЕНЫ МЕНТАНИЛА
// ============================================

/// Синдром отмены — наступает через MENTALIN_WITHDRAWAL_DELAY после дозы при злоупотреблении.
/datum/species/ipc/proc/mentalin_withdrawal(mob/living/carbon/human/H)
	if(!istype(H) || H.stat == DEAD)
		return
	if(!istype(H.dna?.species, /datum/species/ipc) || H.dna.species != src)
		return
	to_chat(H, span_userdanger("СИСТЕМА: Эффект ментанила угасает. Нейрохимический дисбаланс. Синдром отмены."))
	H.Stun(rand(2, 4) SECONDS)
	H.set_dizzy_if_lower(5 SECONDS)
	if(H.client)
		H.overlay_fullscreen("ipc_glitch", /atom/movable/screen/fullscreen/flash/static)
		addtimer(CALLBACK(H, TYPE_PROC_REF(/mob, clear_fullscreen), "ipc_glitch", FALSE), 2 SECONDS)
	humanity = max(0, humanity - 10)
	H.say(pick(
		"Ещё одна доза... мне нужна ещё одна доза...",
		"ОШИБКА 0x3F: нейронная нестабильность... всё в порядке...",
	), forced = "mentalin_withdrawal")

#undef MENTALIN_HUMANITY_BOOST
#undef MENTALIN_WITHDRAWAL_DELAY
#undef MENTALIN_ADDICTION_THRESHOLD

// ============================================
// КАРГО: ЗАКАЗ МЕНТАНИЛА
// ============================================

/datum/supply_pack/medical/mentalin
	name = "Ментанил"
	desc = "Одноразовый нейрохимический инъектор для КПБ III поколения. Повышает параметр человечности. Отпускается по заказу медицинского отдела. При злоупотреблении вызывает синдром отмены."
	cost = 100
	contains = list(/obj/item/mentalin_injector)
	crate_name = "контейнер ментанила"
	crate_type = /obj/structure/closet/crate/medical
