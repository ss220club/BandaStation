// ============================================
// ДИАГНОСТИЧЕСКИЙ СТОЛ ДЛЯ СИНТЕТИКОВ
// ============================================
// Специализированный стол для IPC с дополнительными функциями:
// - Зарядка батареи
// - Охлаждение CPU
// - Сетевое подключение (для NET-door приложения ОС)
// ============================================

/obj/structure/table/optable/synthetic
	name = "synthetic diagnostic table"
	desc = "Специализированный диагностический стол для синтетических организмов. Оснащён системами зарядки, охлаждения и сетевым портом."
	icon = 'modular_bandastation/MachAImpDe/icons/net_table.dmi'
	icon_state = "ipc_net_table"

	/// Скорость зарядки батареи (units/тик)
	var/charge_rate = 50
	/// Скорость охлаждения CPU (°C/тик)
	var/cooling_rate = 2
	/// Текущий IPC-пациент (для отслеживания сетевого подключения)
	var/mob/living/carbon/human/current_ipc_patient = null

/obj/structure/table/optable/synthetic/Initialize(mapload, obj/structure/table_frame/frame_used, obj/item/stack/stack_used)
	. = ..()

	// Переопределяем привязку к компьютеру — ищем synthetic terminal
	if(computer)
		// Родительский Initialize уже нашёл обычный operating computer
		// Если это не synthetic — сбрасываем
		if(!istype(computer, /obj/machinery/computer/operating/synthetic))
			computer.table = null
			computer = null

	// Ищем synthetic diagnostic terminal рядом
	if(!computer)
		for(var/direction in GLOB.alldirs)
			var/obj/machinery/computer/operating/synthetic/synth_comp = locate(/obj/machinery/computer/operating/synthetic) in get_step(src, direction)
			if(synth_comp)
				computer = synth_comp
				synth_comp.table = src
				break

	START_PROCESSING(SSmachines, src)

/obj/structure/table/optable/synthetic/Destroy()
	// Сбрасываем сетевое подключение если IPC уходит
	disconnect_ipc_network()
	STOP_PROCESSING(SSmachines, src)
	return ..()

/obj/structure/table/optable/synthetic/process(seconds_per_tick)
	if(!patient)
		// Пациент ушёл — отключаем сеть
		if(current_ipc_patient)
			disconnect_ipc_network()
		return

	// Проверяем что пациент — IPC
	var/mob/living/carbon/human/H = patient
	if(!istype(H) || !istype(H.dna?.species, /datum/species/ipc))
		if(current_ipc_patient)
			disconnect_ipc_network()
		return

	var/datum/species/ipc/ipc_species = H.dna.species

	// Запоминаем текущего IPC-пациента
	if(current_ipc_patient != H)
		disconnect_ipc_network() // Отключаем предыдущего
		current_ipc_patient = H
		connect_ipc_network(H) // Подключаем нового

	// --- ЗАРЯДКА БАТАРЕИ ---
	var/obj/item/organ/heart/ipc_battery/battery = H.get_organ_slot(ORGAN_SLOT_HEART)
	if(battery && battery.charge < battery.maxcharge)
		battery.charge = min(battery.charge + charge_rate * seconds_per_tick, battery.maxcharge)

	// --- ОХЛАЖДЕНИЕ CPU ---
	if(ipc_species.cpu_temperature > ipc_species.cpu_temp_optimal_min)
		ipc_species.cpu_temperature = max(ipc_species.cpu_temperature - cooling_rate * seconds_per_tick, ipc_species.cpu_temp_optimal_min)

/// Подключаем IPC к сети через стол
/obj/structure/table/optable/synthetic/proc/connect_ipc_network(mob/living/carbon/human/H)
	if(!H)
		return
	var/datum/species/ipc/ipc_species = H.dna?.species
	if(!istype(ipc_species) || !ipc_species.ipc_os)
		return
	ipc_species.ipc_os.network_connected = TRUE

/// Отключаем IPC от сети при уходе со стола
/obj/structure/table/optable/synthetic/proc/disconnect_ipc_network()
	if(!current_ipc_patient)
		return
	var/datum/species/ipc/ipc_species = current_ipc_patient.dna?.species
	if(istype(ipc_species) && ipc_species.ipc_os)
		ipc_species.ipc_os.network_connected = FALSE
	current_ipc_patient = null

/// Переопределяем set_patient чтобы отслеживать смену пациента
/obj/structure/table/optable/synthetic/set_patient(mob/living/carbon/new_patient)
	// Отключаем старого IPC-пациента от сети
	if(current_ipc_patient && current_ipc_patient != new_patient)
		disconnect_ipc_network()
	. = ..()
	// Если новый пациент — IPC, подключаем к сети
	if(new_patient)
		var/mob/living/carbon/human/H = new_patient
		if(istype(H) && istype(H.dna?.species, /datum/species/ipc))
			current_ipc_patient = H
			connect_ipc_network(H)
