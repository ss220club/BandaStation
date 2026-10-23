/// Integrated positronic chassis, adapted from Paradise-SS220's /datum/species/machine.
/datum/species/ipc
	name = "КПБ"
	plural_form = "КПБ"
	id = SPECIES_IPC
	inherent_biotypes = MOB_ROBOTIC | MOB_HUMANOID
	inherent_traits = list(
		TRAIT_DEFIB_BLACKLISTED,
		TRAIT_GENELESS,
		TRAIT_LIVERLESS_METABOLISM,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
		TRAIT_NOCRITDAMAGE,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_PLASMA_TRANSFORM,
		TRAIT_TOXIMMUNE,
		TRAIT_VIRUSIMMUNE,
	)
	exotic_bloodtype = /datum/blood_type/oil
	meat = null
	skinned_type = /obj/item/stack/sheet/iron
	knife_butcher_results = null
	species_language_holder = /datum/language_holder/ipc
	mutantbrain = /obj/item/organ/brain/ipc
	mutantheart = /obj/item/organ/heart/ipc
	mutanteyes = /obj/item/organ/eyes/robotic/ipc
	mutantears = /obj/item/organ/ears/cybernetic/ipc
	mutanttongue = /obj/item/organ/tongue/robot/ipc
	mutantlungs = null
	mutantliver = null
	mutantstomach = null
	mutantappendix = null
	mutant_organs = list(/obj/item/organ/cyberimp/arm/power_cord/ipc)
	changesource_flags = MIRROR_BADMIN | ERT_SPAWN
	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/robot/ipc,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/robot/ipc,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/robot/ipc,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/robot/ipc,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/robot/ipc,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/robot/ipc,
	)
	survival_box_overrides = list(
		SURVIVAL_MASK_TYPE = /obj/item/weldingtool/mini,
		SURVIVAL_INTERNALS_TYPE = /obj/item/stack/cable_coil/ipc_survival,
		SURVIVAL_MEDIPEN_TYPE = /obj/item/flashlight/glowstick,
	)
	/// Owned by the species so a transformation also removes its action button.
	var/datum/action/innate/ipc_display/display_action

/datum/species/ipc/Destroy()
	QDEL_NULL(display_action)
	return ..()

/datum/species/ipc/on_species_gain(mob/living/carbon/human/human, datum/species/old_species, pref_load, regenerate_icons = TRUE, replace_missing = TRUE)
	. = ..()
	display_action = new
	display_action.Grant(human)
	RegisterSignal(human, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_electrocute))
	RegisterSignal(human, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(human, COMSIG_LIVING_DEATH, PROC_REF(on_status_change))
	RegisterSignal(human, COMSIG_LIVING_REVIVE, PROC_REF(on_status_change))
	RegisterSignals(human, list(
		COMSIG_LIVING_HEALTH_UPDATE,
		COMSIG_LIVING_UPDATE_NUTRITION,
		COMSIG_CARBON_GAIN_ORGAN,
		COMSIG_CARBON_LOSE_ORGAN,
		COMSIG_MOB_STATCHANGE,
		SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT),
		SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT),
	), PROC_REF(update_diagnostics))
	RegisterSignal(human, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	// Species can be applied both before and after the human's initial HUD setup.
	if(!human.hud_list)
		human.prepare_huds()
	for(var/hud_type in list(DIAG_HUD, DIAG_STAT_HUD, DIAG_BATT_HUD))
		if(!human.hud_list[hud_type])
			var/image/holder = image(DEFAULT_HUDS_DMI, human, "")
			holder.appearance_flags = RESET_COLOR | PIXEL_SCALE | KEEP_APART
			human.hud_list[hud_type] = holder
		human.set_hud_image_active(hud_type)
	update_diagnostics(human)

/datum/species/ipc/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	. = ..()
	QDEL_NULL(display_action)
	UnregisterSignal(human, list(
		COMSIG_LIVING_ELECTROCUTE_ACT,
		COMSIG_LIVING_LIFE,
		COMSIG_LIVING_DEATH,
		COMSIG_LIVING_REVIVE,
		COMSIG_LIVING_HEALTH_UPDATE,
		COMSIG_LIVING_UPDATE_NUTRITION,
		COMSIG_CARBON_GAIN_ORGAN,
		COMSIG_CARBON_LOSE_ORGAN,
		COMSIG_MOB_STATCHANGE,
		SIGNAL_ADDTRAIT(TRAIT_KNOCKEDOUT),
		SIGNAL_REMOVETRAIT(TRAIT_KNOCKEDOUT),
		COMSIG_ATOM_EXAMINE,
	))
	human.set_hud_image_inactive(DIAG_HUD)
	human.set_hud_image_inactive(DIAG_STAT_HUD)
	human.set_hud_image_inactive(DIAG_BATT_HUD)

/datum/species/ipc/proc/on_electrocute(mob/living/carbon/human/human, shock_damage, atom/power_source, siemens_coeff, flags)
	SIGNAL_HANDLER
	if(flags & SHOCK_ILLUSION)
		return NONE
	var/obj/item/organ/heart/ipc/battery = human.get_organ_slot(ORGAN_SLOT_HEART)
	if(istype(battery) && !(battery.organ_flags & (ORGAN_FAILING | ORGAN_EMP)))
		battery.adjust_charge(max(0, shock_damage * siemens_coeff * GET_PHYSIOLOGY(human, PHYS_COEFF_ELEC_CONDUCTIVITY)))
	return COMPONENT_LIVING_BLOCK_SHOCK

/datum/species/ipc/handle_radiation(mob/living/carbon/human/source, time_since_irradiated, seconds_per_tick)
	// Positronic circuits accumulate errors instead of biological mutations.
	source.adjust_organ_loss(ORGAN_SLOT_BRAIN, 0.5 * seconds_per_tick)
	if(SPT_PROB(5, seconds_per_tick))
		source.adjust_confusion(2 SECONDS)

/datum/species/ipc/proc/on_life(mob/living/carbon/human/human, seconds_per_tick)
	SIGNAL_HANDLER
	if(!istype(human.get_organ_slot(ORGAN_SLOT_HEART), /obj/item/organ/heart/ipc) && !HAS_TRAIT(human, TRAIT_GODMODE))
		human.death()
		return
	try_restart(human)

/// Repairs must restore both the chassis and its vital components before it can boot.
/datum/species/ipc/proc/try_restart(mob/living/carbon/human/human)
	if(QDELETED(human) || human.dna.species != src || human.stat != DEAD)
		return FALSE
	if(human.health <= human.crit_threshold || human.nutrition <= 0 || HAS_TRAIT(human, TRAIT_SUICIDED))
		return FALSE
	var/obj/item/organ/brain/brain = human.get_organ_slot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/heart/ipc/battery = human.get_organ_slot(ORGAN_SLOT_HEART)
	if(!brain || brain.suicided || (brain.organ_flags & (ORGAN_FAILING | ORGAN_EMP)))
		return FALSE
	if(!istype(battery) || (battery.organ_flags & (ORGAN_FAILING | ORGAN_EMP)) || !human.can_be_revived())
		return FALSE
	if(!human.revive())
		return FALSE
	human.visible_message(span_notice("[human] издаёт короткий сигнал и возобновляет работу."), span_notice("Самодиагностика завершена. Системы восстановлены."))
	return TRUE

/datum/species/ipc/proc/on_status_change(mob/living/carbon/human/human)
	SIGNAL_HANDLER
	human.update_body_parts()
	update_diagnostics(human)

/datum/species/ipc/proc/update_diagnostics(mob/living/carbon/human/human)
	SIGNAL_HANDLER
	human.set_hud_image_state(DIAG_HUD, hud_state = "huddiag[human.stat == DEAD ? "dead" : RoundDiagBar(human.health / human.maxHealth)]")
	human.set_hud_image_state(DIAG_STAT_HUD, hud_state = human.stat == DEAD ? "huddead2" : (IS_UNCONSCIOUS(human) ? "hudoffline" : "hudstat"))
	var/obj/item/organ/heart/ipc/battery = human.get_organ_slot(ORGAN_SLOT_HEART)
	human.set_hud_image_state(DIAG_BATT_HUD, hud_state = istype(battery) ? "hudbatt[RoundDiagBar(human.nutrition / NUTRITION_LEVEL_FULL)]" : "hudnobatt")

/datum/species/ipc/proc/on_examine(mob/living/carbon/human/human, mob/examiner, list/examine_text)
	SIGNAL_HANDLER
	if(human.stat == DEAD)
		examine_text += span_notice("Корпус можно восстановить сваркой и проводами. Для перезапуска также нужны исправные позитронный мозг и батарея с зарядом.")
	else if(examiner == human)
		examine_text += span_notice("Заряд батареи: [round(100 * human.nutrition / NUTRITION_LEVEL_FULL)]%.")

/datum/species/ipc/get_features()
	var/list/features = ..().Copy()
	features |= list(FEATURE_IPC_CHASSIS, FEATURE_IPC_CHASSIS_COLOR, FEATURE_IPC_HEAD, FEATURE_IPC_SCREEN, FEATURE_IPC_SCREEN_COLOR, FEATURE_IPC_SCREEN_COLOR_SECONDARY, FEATURE_IPC_ANTENNA, FEATURE_IPC_ANTENNA_COLOR)
	return features

/datum/species/ipc/get_physical_attributes()
	return "Синтетический гуманоид с позитронным мозгом в груди. Не дышит и не питается органической пищей; заряжается от ЛКП или станции зарядки киборгов. Корпус ремонтируется сваркой и проводами."

/datum/species/ipc/get_species_description()
	return "КПБ — самостоятельная синтетическая личность в роботизированном корпусе с позитронным мозгом. В отличие от станционных киборгов, КПБ не связаны набором законов ИИ."

/datum/species/ipc/get_species_lore()
	return list("Позитронные личности создавались для выполнения опасной и монотонной работы. Они обладают самосознанием, способны учиться и выбирать собственную профессию. Корпуса разных производителей отличаются внешностью, а мониторные головы позволяют менять изображение на экране.")

/datum/species/ipc/create_pref_unique_perks()
	return list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "battery-half",
			SPECIES_PERK_NAME = "Электропитание",
			SPECIES_PERK_DESC = "Встроенный кабель заряжает батарею от ЛКП. Можно пользоваться зарядной станцией киборгов. При разряде батарея повреждается, а системы начинают отказывать.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "screwdriver-wrench",
			SPECIES_PERK_NAME = "Ремонтопригодный корпус",
			SPECIES_PERK_DESC = "Сварка устраняет вмятины, провода — ожоги. Исправный заряженный корпус с работоспособным мозгом автоматически перезапускается после ремонта. Дефибриллятор не подходит для запуска КПБ.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Уязвимая электроника",
			SPECIES_PERK_DESC = "ЭМИ повреждает корпус и внутренние компоненты. Радиация повреждает позитронный мозг. Обычный электрический разряд заряжает батарею.",
		),
	)

/datum/language_holder/ipc
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM), /datum/language/machine = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM), /datum/language/machine = list(LANGUAGE_ATOM))

/obj/item/stack/cable_coil/ipc_survival
	amount = 10
