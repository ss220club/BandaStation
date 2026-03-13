// ============================================
// БРЕНДИРОВАННЫЕ ЧАСТИ ТЕЛА IPC
// ============================================
// Подтипы bodypart с встроенным визуалом бренда.
// Создаются в MECHFAB; при присоединении к IPC
// автоматически отображают визуал своего бренда.
//
// Все файлы брендированных спрайтов используют ipc_* состояния.
// icon_state наследуется от базового типа (ipc_chest_m, ipc_head и т.д.).
// Бренды без кастомного DMI визуально идентичны unbranded.
// ============================================

// ============================================
// 1. MORPHEUS CYBERKINETICS
// ============================================

#define IPC_DMI_MORPHEUS 'icons/bandastation/mob/species/ipc/bodyparts_morpheus.dmi'

/obj/item/bodypart/chest/ipc/morpheus
	name = "Morpheus Cyberkinetics IPC chassis"
	desc = "Корпус IPC производства Morpheus Cyberkinetics. Расширенные слоты для органических и кибернетических имплантов."
	icon = IPC_DMI_MORPHEUS
	icon_static = IPC_DMI_MORPHEUS
	icon_greyscale = null
	chassis_type = "Morpheus"

/obj/item/bodypart/head/ipc/morpheus
	name = "Morpheus Cyberkinetics IPC head"
	desc = "Голова IPC производства Morpheus Cyberkinetics."
	icon = IPC_DMI_MORPHEUS
	icon_static = IPC_DMI_MORPHEUS
	icon_greyscale = null
	icon_state = "ipc_monitor"
	ipc_visual_state = "monitor"

/obj/item/bodypart/arm/left/ipc/morpheus
	name = "Morpheus Cyberkinetics IPC left arm"
	desc = "Левая рука IPC производства Morpheus Cyberkinetics."
	icon = IPC_DMI_MORPHEUS
	icon_static = IPC_DMI_MORPHEUS
	icon_greyscale = null
	chassis_type = "Morpheus"

/obj/item/bodypart/arm/right/ipc/morpheus
	name = "Morpheus Cyberkinetics IPC right arm"
	desc = "Правая рука IPC производства Morpheus Cyberkinetics."
	icon = IPC_DMI_MORPHEUS
	icon_static = IPC_DMI_MORPHEUS
	icon_greyscale = null
	chassis_type = "Morpheus"

/obj/item/bodypart/leg/left/ipc/morpheus
	name = "Morpheus Cyberkinetics IPC left leg"
	desc = "Левая нога IPC производства Morpheus Cyberkinetics."
	icon = IPC_DMI_MORPHEUS
	icon_static = IPC_DMI_MORPHEUS
	icon_greyscale = null
	chassis_type = "Morpheus"

/obj/item/bodypart/leg/right/ipc/morpheus
	name = "Morpheus Cyberkinetics IPC right leg"
	desc = "Правая нога IPC производства Morpheus Cyberkinetics."
	icon = IPC_DMI_MORPHEUS
	icon_static = IPC_DMI_MORPHEUS
	icon_greyscale = null
	chassis_type = "Morpheus"

#undef IPC_DMI_MORPHEUS

// ============================================
// 2. ETAMIN INDUSTRY
// ============================================

#define IPC_DMI_ETAMIN 'icons/bandastation/mob/species/ipc/bodyparts_etamin.dmi'

/obj/item/bodypart/chest/ipc/etamin
	name = "Etamin Industry IPC chassis"
	desc = "Корпус IPC производства Etamin Industry. Оптимизирован для боевого применения."
	icon = IPC_DMI_ETAMIN
	icon_static = IPC_DMI_ETAMIN
	icon_greyscale = null
	chassis_type = "Etamin"

/obj/item/bodypart/head/ipc/etamin
	name = "Etamin Industry IPC head"
	desc = "Голова IPC производства Etamin Industry."
	icon = IPC_DMI_ETAMIN
	icon_static = IPC_DMI_ETAMIN
	icon_greyscale = null

/obj/item/bodypart/arm/left/ipc/etamin
	name = "Etamin Industry IPC left arm"
	desc = "Левая рука IPC производства Etamin Industry."
	icon = IPC_DMI_ETAMIN
	icon_static = IPC_DMI_ETAMIN
	icon_greyscale = null
	chassis_type = "Etamin"

/obj/item/bodypart/arm/right/ipc/etamin
	name = "Etamin Industry IPC right arm"
	desc = "Правая рука IPC производства Etamin Industry."
	icon = IPC_DMI_ETAMIN
	icon_static = IPC_DMI_ETAMIN
	icon_greyscale = null
	chassis_type = "Etamin"

/obj/item/bodypart/leg/left/ipc/etamin
	name = "Etamin Industry IPC left leg"
	desc = "Левая нога IPC производства Etamin Industry."
	icon = IPC_DMI_ETAMIN
	icon_static = IPC_DMI_ETAMIN
	icon_greyscale = null
	chassis_type = "Etamin"

/obj/item/bodypart/leg/right/ipc/etamin
	name = "Etamin Industry IPC right leg"
	desc = "Правая нога IPC производства Etamin Industry."
	icon = IPC_DMI_ETAMIN
	icon_static = IPC_DMI_ETAMIN
	icon_greyscale = null
	chassis_type = "Etamin"

#undef IPC_DMI_ETAMIN

// ============================================
// 3. BISHOP CYBERNETICS
// ============================================

#define IPC_DMI_BISHOP 'icons/bandastation/mob/species/ipc/bodyparts_bishop.dmi'

/obj/item/bodypart/chest/ipc/bishop
	name = "Bishop Cybernetics IPC chassis"
	desc = "Корпус IPC производства Bishop Cybernetics. Встроенная медицинская диагностика и улучшенный хирургический модуль."
	icon = IPC_DMI_BISHOP
	icon_static = IPC_DMI_BISHOP
	icon_greyscale = null
	chassis_type = "Bishop"

/obj/item/bodypart/head/ipc/bishop
	name = "Bishop Cybernetics IPC head"
	desc = "Голова IPC производства Bishop Cybernetics."
	icon = IPC_DMI_BISHOP
	icon_static = IPC_DMI_BISHOP
	icon_greyscale = null

/obj/item/bodypart/arm/left/ipc/bishop
	name = "Bishop Cybernetics IPC left arm"
	desc = "Левая рука IPC производства Bishop Cybernetics."
	icon = IPC_DMI_BISHOP
	icon_static = IPC_DMI_BISHOP
	icon_greyscale = null
	chassis_type = "Bishop"

/obj/item/bodypart/arm/right/ipc/bishop
	name = "Bishop Cybernetics IPC right arm"
	desc = "Правая рука IPC производства Bishop Cybernetics."
	icon = IPC_DMI_BISHOP
	icon_static = IPC_DMI_BISHOP
	icon_greyscale = null
	chassis_type = "Bishop"

/obj/item/bodypart/leg/left/ipc/bishop
	name = "Bishop Cybernetics IPC left leg"
	desc = "Левая нога IPC производства Bishop Cybernetics."
	icon = IPC_DMI_BISHOP
	icon_static = IPC_DMI_BISHOP
	icon_greyscale = null
	chassis_type = "Bishop"

/obj/item/bodypart/leg/right/ipc/bishop
	name = "Bishop Cybernetics IPC right leg"
	desc = "Правая нога IPC производства Bishop Cybernetics."
	icon = IPC_DMI_BISHOP
	icon_static = IPC_DMI_BISHOP
	icon_greyscale = null
	chassis_type = "Bishop"

#undef IPC_DMI_BISHOP

// ============================================
// 4. HESPHIASTOS INDUSTRIES
// ============================================

#define IPC_DMI_HESPHIASTOS 'icons/bandastation/mob/species/ipc/bodyparts_hephaestus.dmi'

/obj/item/bodypart/chest/ipc/hesphiastos
	name = "Hesphiastos Industries IPC chassis"
	desc = "Корпус IPC производства Hesphiastos Industries. Повышенная прочность и боевые характеристики."
	icon = IPC_DMI_HESPHIASTOS
	icon_static = IPC_DMI_HESPHIASTOS
	icon_greyscale = null
	chassis_type = "Hesphiastos"

/obj/item/bodypart/head/ipc/hesphiastos
	name = "Hesphiastos Industries IPC head"
	desc = "Голова IPC производства Hesphiastos Industries."
	icon = IPC_DMI_HESPHIASTOS
	icon_static = IPC_DMI_HESPHIASTOS
	icon_greyscale = null

/obj/item/bodypart/arm/left/ipc/hesphiastos
	name = "Hesphiastos Industries IPC left arm"
	desc = "Левая рука IPC производства Hesphiastos Industries."
	icon = IPC_DMI_HESPHIASTOS
	icon_static = IPC_DMI_HESPHIASTOS
	icon_greyscale = null
	chassis_type = "Hesphiastos"

/obj/item/bodypart/arm/right/ipc/hesphiastos
	name = "Hesphiastos Industries IPC right arm"
	desc = "Правая рука IPC производства Hesphiastos Industries."
	icon = IPC_DMI_HESPHIASTOS
	icon_static = IPC_DMI_HESPHIASTOS
	icon_greyscale = null
	chassis_type = "Hesphiastos"

/obj/item/bodypart/leg/left/ipc/hesphiastos
	name = "Hesphiastos Industries IPC left leg"
	desc = "Левая нога IPC производства Hesphiastos Industries."
	icon = IPC_DMI_HESPHIASTOS
	icon_static = IPC_DMI_HESPHIASTOS
	icon_greyscale = null
	chassis_type = "Hesphiastos"

/obj/item/bodypart/leg/right/ipc/hesphiastos
	name = "Hesphiastos Industries IPC right leg"
	desc = "Правая нога IPC производства Hesphiastos Industries."
	icon = IPC_DMI_HESPHIASTOS
	icon_static = IPC_DMI_HESPHIASTOS
	icon_greyscale = null
	chassis_type = "Hesphiastos"

#undef IPC_DMI_HESPHIASTOS

// ============================================
// 5. WARD-TAKAHASHI
// ============================================

#define IPC_DMI_WARD 'icons/bandastation/mob/species/ipc/bodyparts_wardtakahashi.dmi'

/obj/item/bodypart/chest/ipc/ward_takahashi
	name = "Ward-Takahashi IPC chassis"
	desc = "Корпус IPC производства Ward-Takahashi. Ускоренный саморемонт и высокая надёжность компонентов."
	icon = IPC_DMI_WARD
	icon_static = IPC_DMI_WARD
	icon_greyscale = null
	chassis_type = "Ward-Takahashi"

/obj/item/bodypart/head/ipc/ward_takahashi
	name = "Ward-Takahashi IPC head"
	desc = "Голова IPC производства Ward-Takahashi."
	icon = IPC_DMI_WARD
	icon_static = IPC_DMI_WARD
	icon_greyscale = null

/obj/item/bodypart/arm/left/ipc/ward_takahashi
	name = "Ward-Takahashi IPC left arm"
	desc = "Левая рука IPC производства Ward-Takahashi."
	icon = IPC_DMI_WARD
	icon_static = IPC_DMI_WARD
	icon_greyscale = null
	chassis_type = "Ward-Takahashi"

/obj/item/bodypart/arm/right/ipc/ward_takahashi
	name = "Ward-Takahashi IPC right arm"
	desc = "Правая рука IPC производства Ward-Takahashi."
	icon = IPC_DMI_WARD
	icon_static = IPC_DMI_WARD
	icon_greyscale = null
	chassis_type = "Ward-Takahashi"

/obj/item/bodypart/leg/left/ipc/ward_takahashi
	name = "Ward-Takahashi IPC left leg"
	desc = "Левая нога IPC производства Ward-Takahashi."
	icon = IPC_DMI_WARD
	icon_static = IPC_DMI_WARD
	icon_greyscale = null
	chassis_type = "Ward-Takahashi"

/obj/item/bodypart/leg/right/ipc/ward_takahashi
	name = "Ward-Takahashi IPC right leg"
	desc = "Правая нога IPC производства Ward-Takahashi."
	icon = IPC_DMI_WARD
	icon_static = IPC_DMI_WARD
	icon_greyscale = null
	chassis_type = "Ward-Takahashi"

#undef IPC_DMI_WARD

// ============================================
// 6. XION MANUFACTURING GROUP
// ============================================

#define IPC_DMI_XION 'icons/bandastation/mob/species/ipc/bodyparts_xion.dmi'

/obj/item/bodypart/chest/ipc/xion
	name = "Xion Manufacturing Group IPC chassis"
	desc = "Корпус IPC производства Xion Manufacturing Group. Повышенная огнеупорность и термическая устойчивость."
	icon = IPC_DMI_XION
	icon_static = IPC_DMI_XION
	icon_greyscale = null
	chassis_type = "Xion"

/obj/item/bodypart/head/ipc/xion
	name = "Xion Manufacturing Group IPC head"
	desc = "Голова IPC производства Xion Manufacturing Group."
	icon = IPC_DMI_XION
	icon_static = IPC_DMI_XION
	icon_greyscale = null

/obj/item/bodypart/arm/left/ipc/xion
	name = "Xion Manufacturing Group IPC left arm"
	desc = "Левая рука IPC производства Xion Manufacturing Group."
	icon = IPC_DMI_XION
	icon_static = IPC_DMI_XION
	icon_greyscale = null
	chassis_type = "Xion"

/obj/item/bodypart/arm/right/ipc/xion
	name = "Xion Manufacturing Group IPC right arm"
	desc = "Правая рука IPC производства Xion Manufacturing Group."
	icon = IPC_DMI_XION
	icon_static = IPC_DMI_XION
	icon_greyscale = null
	chassis_type = "Xion"

/obj/item/bodypart/leg/left/ipc/xion
	name = "Xion Manufacturing Group IPC left leg"
	desc = "Левая нога IPC производства Xion Manufacturing Group."
	icon = IPC_DMI_XION
	icon_static = IPC_DMI_XION
	icon_greyscale = null
	chassis_type = "Xion"

/obj/item/bodypart/leg/right/ipc/xion
	name = "Xion Manufacturing Group IPC right leg"
	desc = "Правая нога IPC производства Xion Manufacturing Group."
	icon = IPC_DMI_XION
	icon_static = IPC_DMI_XION
	icon_greyscale = null
	chassis_type = "Xion"

#undef IPC_DMI_XION

// ============================================
// 7. ZENG-HU PHARMACEUTICALS
// ============================================

#define IPC_DMI_ZENGHU 'icons/bandastation/mob/species/ipc/bodyparts_zenghu.dmi'

/obj/item/bodypart/chest/ipc/zeng_hu
	name = "Zeng-Hu Pharmaceuticals IPC chassis"
	desc = "Корпус IPC производства Zeng-Hu Pharmaceuticals. Синтетическая кожа с особыми свойствами биорегенерации."
	icon = IPC_DMI_ZENGHU
	icon_static = IPC_DMI_ZENGHU
	icon_greyscale = null
	chassis_type = "Zeng-Hu"

/obj/item/bodypart/head/ipc/zeng_hu
	name = "Zeng-Hu Pharmaceuticals IPC head"
	desc = "Голова IPC производства Zeng-Hu Pharmaceuticals."
	icon = IPC_DMI_ZENGHU
	icon_static = IPC_DMI_ZENGHU
	icon_greyscale = null

/obj/item/bodypart/arm/left/ipc/zeng_hu
	name = "Zeng-Hu Pharmaceuticals IPC left arm"
	desc = "Левая рука IPC производства Zeng-Hu Pharmaceuticals."
	icon = IPC_DMI_ZENGHU
	icon_static = IPC_DMI_ZENGHU
	icon_greyscale = null
	chassis_type = "Zeng-Hu"

/obj/item/bodypart/arm/right/ipc/zeng_hu
	name = "Zeng-Hu Pharmaceuticals IPC right arm"
	desc = "Правая рука IPC производства Zeng-Hu Pharmaceuticals."
	icon = IPC_DMI_ZENGHU
	icon_static = IPC_DMI_ZENGHU
	icon_greyscale = null
	chassis_type = "Zeng-Hu"

/obj/item/bodypart/leg/left/ipc/zeng_hu
	name = "Zeng-Hu Pharmaceuticals IPC left leg"
	desc = "Левая нога IPC производства Zeng-Hu Pharmaceuticals."
	icon = IPC_DMI_ZENGHU
	icon_static = IPC_DMI_ZENGHU
	icon_greyscale = null
	chassis_type = "Zeng-Hu"

/obj/item/bodypart/leg/right/ipc/zeng_hu
	name = "Zeng-Hu Pharmaceuticals IPC right leg"
	desc = "Правая нога IPC производства Zeng-Hu Pharmaceuticals."
	icon = IPC_DMI_ZENGHU
	icon_static = IPC_DMI_ZENGHU
	icon_greyscale = null
	chassis_type = "Zeng-Hu"

#undef IPC_DMI_ZENGHU

// ============================================
// 8. SHELLGUARD MUNITIONS
// ============================================

#define IPC_DMI_SHELLGUARD 'icons/bandastation/mob/species/ipc/bodyparts_shellguard.dmi'

/obj/item/bodypart/chest/ipc/shellguard
	name = "Shellguard Munitions IPC chassis"
	desc = "Корпус IPC производства Shellguard Munitions. Максимальная броневая защита от механических и огневых повреждений."
	icon = IPC_DMI_SHELLGUARD
	icon_static = IPC_DMI_SHELLGUARD
	icon_greyscale = null
	chassis_type = "Shellguard"

/obj/item/bodypart/head/ipc/shellguard
	name = "Shellguard Munitions IPC head"
	desc = "Голова IPC производства Shellguard Munitions."
	icon = IPC_DMI_SHELLGUARD
	icon_static = IPC_DMI_SHELLGUARD
	icon_greyscale = null

/obj/item/bodypart/arm/left/ipc/shellguard
	name = "Shellguard Munitions IPC left arm"
	desc = "Левая рука IPC производства Shellguard Munitions."
	icon = IPC_DMI_SHELLGUARD
	icon_static = IPC_DMI_SHELLGUARD
	icon_greyscale = null
	chassis_type = "Shellguard"

/obj/item/bodypart/arm/right/ipc/shellguard
	name = "Shellguard Munitions IPC right arm"
	desc = "Правая рука IPC производства Shellguard Munitions."
	icon = IPC_DMI_SHELLGUARD
	icon_static = IPC_DMI_SHELLGUARD
	icon_greyscale = null
	chassis_type = "Shellguard"

/obj/item/bodypart/leg/left/ipc/shellguard
	name = "Shellguard Munitions IPC left leg"
	desc = "Левая нога IPC производства Shellguard Munitions."
	icon = IPC_DMI_SHELLGUARD
	icon_static = IPC_DMI_SHELLGUARD
	icon_greyscale = null
	chassis_type = "Shellguard"

/obj/item/bodypart/leg/right/ipc/shellguard
	name = "Shellguard Munitions IPC right leg"
	desc = "Правая нога IPC производства Shellguard Munitions."
	icon = IPC_DMI_SHELLGUARD
	icon_static = IPC_DMI_SHELLGUARD
	icon_greyscale = null
	chassis_type = "Shellguard"

#undef IPC_DMI_SHELLGUARD

// ============================================
// 9. CYBERSUN INDUSTRIES
// ============================================

#define IPC_DMI_CYBERSUN 'icons/bandastation/mob/species/ipc/bodyparts_cybersun.dmi'

/obj/item/bodypart/chest/ipc/cybersun
	name = "Cybersun Industries IPC chassis"
	desc = "Корпус IPC производства Cybersun Industries. Улучшенные шумопоглотители и расширенные карманные модули."
	icon = IPC_DMI_CYBERSUN
	icon_static = IPC_DMI_CYBERSUN
	icon_greyscale = null
	chassis_type = "Cybersun"

/obj/item/bodypart/head/ipc/cybersun
	name = "Cybersun Industries IPC head"
	desc = "Голова IPC производства Cybersun Industries."
	icon = IPC_DMI_CYBERSUN
	icon_static = IPC_DMI_CYBERSUN
	icon_greyscale = null

/obj/item/bodypart/arm/left/ipc/cybersun
	name = "Cybersun Industries IPC left arm"
	desc = "Левая рука IPC производства Cybersun Industries."
	icon = IPC_DMI_CYBERSUN
	icon_static = IPC_DMI_CYBERSUN
	icon_greyscale = null
	chassis_type = "Cybersun"

/obj/item/bodypart/arm/right/ipc/cybersun
	name = "Cybersun Industries IPC right arm"
	desc = "Правая рука IPC производства Cybersun Industries."
	icon = IPC_DMI_CYBERSUN
	icon_static = IPC_DMI_CYBERSUN
	icon_greyscale = null
	chassis_type = "Cybersun"

/obj/item/bodypart/leg/left/ipc/cybersun
	name = "Cybersun Industries IPC left leg"
	desc = "Левая нога IPC производства Cybersun Industries."
	icon = IPC_DMI_CYBERSUN
	icon_static = IPC_DMI_CYBERSUN
	icon_greyscale = null
	chassis_type = "Cybersun"

/obj/item/bodypart/leg/right/ipc/cybersun
	name = "Cybersun Industries IPC right leg"
	desc = "Правая нога IPC производства Cybersun Industries."
	icon = IPC_DMI_CYBERSUN
	icon_static = IPC_DMI_CYBERSUN
	icon_greyscale = null
	chassis_type = "Cybersun"

#undef IPC_DMI_CYBERSUN
