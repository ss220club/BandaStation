// ============================================
// БРЕНДИРОВАННЫЕ ЧАСТИ ТЕЛА IPC
// ============================================
// Подтипы bodypart с встроенным визуалом бренда.
// Создаются в MECHFAB; при присоединении к IPC
// автоматически отображают визуал своего бренда.
//
// Грудная клетка обновляет icon_state с суффиксом
// пола (_m/_f) в момент присоединения к мобу.
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
	icon_state = "morpheus_chest_m"
	chassis_type = "Morpheus"
	brand_visual_prefix = "morpheus"

/obj/item/bodypart/head/ipc/morpheus
	name = "Morpheus Cyberkinetics IPC head"
	desc = "Голова IPC производства Morpheus Cyberkinetics."
	icon = IPC_DMI_MORPHEUS
	icon_static = IPC_DMI_MORPHEUS
	icon_greyscale = null
	icon_state = "morpheus_head"

/obj/item/bodypart/arm/left/ipc/morpheus
	name = "Morpheus Cyberkinetics IPC left arm"
	desc = "Левая рука IPC производства Morpheus Cyberkinetics."
	icon = IPC_DMI_MORPHEUS
	icon_static = IPC_DMI_MORPHEUS
	icon_greyscale = null
	icon_state = "morpheus_l_arm"

/obj/item/bodypart/arm/right/ipc/morpheus
	name = "Morpheus Cyberkinetics IPC right arm"
	desc = "Правая рука IPC производства Morpheus Cyberkinetics."
	icon = IPC_DMI_MORPHEUS
	icon_static = IPC_DMI_MORPHEUS
	icon_greyscale = null
	icon_state = "morpheus_r_arm"

/obj/item/bodypart/leg/left/ipc/morpheus
	name = "Morpheus Cyberkinetics IPC left leg"
	desc = "Левая нога IPC производства Morpheus Cyberkinetics."
	icon = IPC_DMI_MORPHEUS
	icon_static = IPC_DMI_MORPHEUS
	icon_greyscale = null
	icon_state = "morpheus_l_leg"

/obj/item/bodypart/leg/right/ipc/morpheus
	name = "Morpheus Cyberkinetics IPC right leg"
	desc = "Правая нога IPC производства Morpheus Cyberkinetics."
	icon = IPC_DMI_MORPHEUS
	icon_static = IPC_DMI_MORPHEUS
	icon_greyscale = null
	icon_state = "morpheus_r_leg"

#undef IPC_DMI_MORPHEUS

// ============================================
// 2. ETAMIN INDUSTRY
// ============================================

/obj/item/bodypart/chest/ipc/etamin
	name = "Etamin Industry IPC chassis"
	desc = "Корпус IPC производства Etamin Industry. Оптимизирован для боевого применения."
	icon_state = "etamin_chest_m"
	chassis_type = "Etamin"
	brand_visual_prefix = "etamin"

/obj/item/bodypart/head/ipc/etamin
	name = "Etamin Industry IPC head"
	desc = "Голова IPC производства Etamin Industry."
	icon_state = "etamin_head"

/obj/item/bodypart/arm/left/ipc/etamin
	name = "Etamin Industry IPC left arm"
	desc = "Левая рука IPC производства Etamin Industry."
	icon_state = "etamin_l_arm"

/obj/item/bodypart/arm/right/ipc/etamin
	name = "Etamin Industry IPC right arm"
	desc = "Правая рука IPC производства Etamin Industry."
	icon_state = "etamin_r_arm"

/obj/item/bodypart/leg/left/ipc/etamin
	name = "Etamin Industry IPC left leg"
	desc = "Левая нога IPC производства Etamin Industry."
	icon_state = "etamin_l_leg"

/obj/item/bodypart/leg/right/ipc/etamin
	name = "Etamin Industry IPC right leg"
	desc = "Правая нога IPC производства Etamin Industry."
	icon_state = "etamin_r_leg"

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
	icon_state = "ipc_chest_m"
	chassis_type = "Bishop"
	brand_visual_prefix = "ipc"

/obj/item/bodypart/head/ipc/bishop
	name = "Bishop Cybernetics IPC head"
	desc = "Голова IPC производства Bishop Cybernetics."
	icon = IPC_DMI_BISHOP
	icon_static = IPC_DMI_BISHOP
	icon_greyscale = null
	icon_state = "ipc_head"

/obj/item/bodypart/arm/left/ipc/bishop
	name = "Bishop Cybernetics IPC left arm"
	desc = "Левая рука IPC производства Bishop Cybernetics."
	icon = IPC_DMI_BISHOP
	icon_static = IPC_DMI_BISHOP
	icon_greyscale = null
	icon_state = "ipc_l_arm"

/obj/item/bodypart/arm/right/ipc/bishop
	name = "Bishop Cybernetics IPC right arm"
	desc = "Правая рука IPC производства Bishop Cybernetics."
	icon = IPC_DMI_BISHOP
	icon_static = IPC_DMI_BISHOP
	icon_greyscale = null
	icon_state = "ipc_r_arm"

/obj/item/bodypart/leg/left/ipc/bishop
	name = "Bishop Cybernetics IPC left leg"
	desc = "Левая нога IPC производства Bishop Cybernetics."
	icon = IPC_DMI_BISHOP
	icon_static = IPC_DMI_BISHOP
	icon_greyscale = null
	icon_state = "ipc_l_leg"

/obj/item/bodypart/leg/right/ipc/bishop
	name = "Bishop Cybernetics IPC right leg"
	desc = "Правая нога IPC производства Bishop Cybernetics."
	icon = IPC_DMI_BISHOP
	icon_static = IPC_DMI_BISHOP
	icon_greyscale = null
	icon_state = "ipc_r_leg"

#undef IPC_DMI_BISHOP

// ============================================
// 4. HESPHIASTOS INDUSTRIES
// ============================================

/obj/item/bodypart/chest/ipc/hesphiastos
	name = "Hesphiastos Industries IPC chassis"
	desc = "Корпус IPC производства Hesphiastos Industries. Повышенная прочность и боевые характеристики."
	icon_state = "hesphiastos_chest_m"
	chassis_type = "Hesphiastos"
	brand_visual_prefix = "hesphiastos"

/obj/item/bodypart/head/ipc/hesphiastos
	name = "Hesphiastos Industries IPC head"
	desc = "Голова IPC производства Hesphiastos Industries."
	icon_state = "hesphiastos_head"

/obj/item/bodypart/arm/left/ipc/hesphiastos
	name = "Hesphiastos Industries IPC left arm"
	desc = "Левая рука IPC производства Hesphiastos Industries."
	icon_state = "hesphiastos_l_arm"

/obj/item/bodypart/arm/right/ipc/hesphiastos
	name = "Hesphiastos Industries IPC right arm"
	desc = "Правая рука IPC производства Hesphiastos Industries."
	icon_state = "hesphiastos_r_arm"

/obj/item/bodypart/leg/left/ipc/hesphiastos
	name = "Hesphiastos Industries IPC left leg"
	desc = "Левая нога IPC производства Hesphiastos Industries."
	icon_state = "hesphiastos_l_leg"

/obj/item/bodypart/leg/right/ipc/hesphiastos
	name = "Hesphiastos Industries IPC right leg"
	desc = "Правая нога IPC производства Hesphiastos Industries."
	icon_state = "hesphiastos_r_leg"

// ============================================
// 5. WARD-TAKAHASHI
// ============================================

/obj/item/bodypart/chest/ipc/ward_takahashi
	name = "Ward-Takahashi IPC chassis"
	desc = "Корпус IPC производства Ward-Takahashi. Ускоренный саморемонт и высокая надёжность компонентов."
	icon_state = "ward_chest_m"
	chassis_type = "Ward-Takahashi"
	brand_visual_prefix = "ward"

/obj/item/bodypart/head/ipc/ward_takahashi
	name = "Ward-Takahashi IPC head"
	desc = "Голова IPC производства Ward-Takahashi."
	icon_state = "ward_head"

/obj/item/bodypart/arm/left/ipc/ward_takahashi
	name = "Ward-Takahashi IPC left arm"
	desc = "Левая рука IPC производства Ward-Takahashi."
	icon_state = "ward_l_arm"

/obj/item/bodypart/arm/right/ipc/ward_takahashi
	name = "Ward-Takahashi IPC right arm"
	desc = "Правая рука IPC производства Ward-Takahashi."
	icon_state = "ward_r_arm"

/obj/item/bodypart/leg/left/ipc/ward_takahashi
	name = "Ward-Takahashi IPC left leg"
	desc = "Левая нога IPC производства Ward-Takahashi."
	icon_state = "ward_l_leg"

/obj/item/bodypart/leg/right/ipc/ward_takahashi
	name = "Ward-Takahashi IPC right leg"
	desc = "Правая нога IPC производства Ward-Takahashi."
	icon_state = "ward_r_leg"

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
	icon_state = "xion_chest_m"
	chassis_type = "Xion"
	brand_visual_prefix = "xion"

/obj/item/bodypart/head/ipc/xion
	name = "Xion Manufacturing Group IPC head"
	desc = "Голова IPC производства Xion Manufacturing Group."
	icon = IPC_DMI_XION
	icon_static = IPC_DMI_XION
	icon_greyscale = null
	icon_state = "xion_head"

/obj/item/bodypart/arm/left/ipc/xion
	name = "Xion Manufacturing Group IPC left arm"
	desc = "Левая рука IPC производства Xion Manufacturing Group."
	icon = IPC_DMI_XION
	icon_static = IPC_DMI_XION
	icon_greyscale = null
	icon_state = "xion_l_arm"

/obj/item/bodypart/arm/right/ipc/xion
	name = "Xion Manufacturing Group IPC right arm"
	desc = "Правая рука IPC производства Xion Manufacturing Group."
	icon = IPC_DMI_XION
	icon_static = IPC_DMI_XION
	icon_greyscale = null
	icon_state = "xion_r_arm"

/obj/item/bodypart/leg/left/ipc/xion
	name = "Xion Manufacturing Group IPC left leg"
	desc = "Левая нога IPC производства Xion Manufacturing Group."
	icon = IPC_DMI_XION
	icon_static = IPC_DMI_XION
	icon_greyscale = null
	icon_state = "xion_l_leg"

/obj/item/bodypart/leg/right/ipc/xion
	name = "Xion Manufacturing Group IPC right leg"
	desc = "Правая нога IPC производства Xion Manufacturing Group."
	icon = IPC_DMI_XION
	icon_static = IPC_DMI_XION
	icon_greyscale = null
	icon_state = "xion_r_leg"

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
	icon_state = "zenghu_chest_m"
	chassis_type = "Zeng-Hu"
	brand_visual_prefix = "zenghu"

/obj/item/bodypart/head/ipc/zeng_hu
	name = "Zeng-Hu Pharmaceuticals IPC head"
	desc = "Голова IPC производства Zeng-Hu Pharmaceuticals."
	icon = IPC_DMI_ZENGHU
	icon_static = IPC_DMI_ZENGHU
	icon_greyscale = null
	icon_state = "zenghu_head"

/obj/item/bodypart/arm/left/ipc/zeng_hu
	name = "Zeng-Hu Pharmaceuticals IPC left arm"
	desc = "Левая рука IPC производства Zeng-Hu Pharmaceuticals."
	icon = IPC_DMI_ZENGHU
	icon_static = IPC_DMI_ZENGHU
	icon_greyscale = null
	icon_state = "zenghu_l_arm"

/obj/item/bodypart/arm/right/ipc/zeng_hu
	name = "Zeng-Hu Pharmaceuticals IPC right arm"
	desc = "Правая рука IPC производства Zeng-Hu Pharmaceuticals."
	icon = IPC_DMI_ZENGHU
	icon_static = IPC_DMI_ZENGHU
	icon_greyscale = null
	icon_state = "zenghu_r_arm"

/obj/item/bodypart/leg/left/ipc/zeng_hu
	name = "Zeng-Hu Pharmaceuticals IPC left leg"
	desc = "Левая нога IPC производства Zeng-Hu Pharmaceuticals."
	icon = IPC_DMI_ZENGHU
	icon_static = IPC_DMI_ZENGHU
	icon_greyscale = null
	icon_state = "zenghu_l_leg"

/obj/item/bodypart/leg/right/ipc/zeng_hu
	name = "Zeng-Hu Pharmaceuticals IPC right leg"
	desc = "Правая нога IPC производства Zeng-Hu Pharmaceuticals."
	icon = IPC_DMI_ZENGHU
	icon_static = IPC_DMI_ZENGHU
	icon_greyscale = null
	icon_state = "zenghu_r_leg"

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
	icon_state = "shellguard_chest_m"
	chassis_type = "Shellguard"
	brand_visual_prefix = "shellguard"

/obj/item/bodypart/head/ipc/shellguard
	name = "Shellguard Munitions IPC head"
	desc = "Голова IPC производства Shellguard Munitions."
	icon = IPC_DMI_SHELLGUARD
	icon_static = IPC_DMI_SHELLGUARD
	icon_greyscale = null
	icon_state = "shellguard_head"

/obj/item/bodypart/arm/left/ipc/shellguard
	name = "Shellguard Munitions IPC left arm"
	desc = "Левая рука IPC производства Shellguard Munitions."
	icon = IPC_DMI_SHELLGUARD
	icon_static = IPC_DMI_SHELLGUARD
	icon_greyscale = null
	icon_state = "shellguard_l_arm"

/obj/item/bodypart/arm/right/ipc/shellguard
	name = "Shellguard Munitions IPC right arm"
	desc = "Правая рука IPC производства Shellguard Munitions."
	icon = IPC_DMI_SHELLGUARD
	icon_static = IPC_DMI_SHELLGUARD
	icon_greyscale = null
	icon_state = "shellguard_r_arm"

/obj/item/bodypart/leg/left/ipc/shellguard
	name = "Shellguard Munitions IPC left leg"
	desc = "Левая нога IPC производства Shellguard Munitions."
	icon = IPC_DMI_SHELLGUARD
	icon_static = IPC_DMI_SHELLGUARD
	icon_greyscale = null
	icon_state = "shellguard_l_leg"

/obj/item/bodypart/leg/right/ipc/shellguard
	name = "Shellguard Munitions IPC right leg"
	desc = "Правая нога IPC производства Shellguard Munitions."
	icon = IPC_DMI_SHELLGUARD
	icon_static = IPC_DMI_SHELLGUARD
	icon_greyscale = null
	icon_state = "shellguard_r_leg"

#undef IPC_DMI_SHELLGUARD

// ============================================
// 9. CYBERSUN INDUSTRIES
// ============================================

/obj/item/bodypart/chest/ipc/cybersun
	name = "Cybersun Industries IPC chassis"
	desc = "Корпус IPC производства Cybersun Industries. Улучшенные шумопоглотители и расширенные карманные модули."
	icon_state = "cybersun_chest_m"
	chassis_type = "Cybersun"
	brand_visual_prefix = "cybersun"

/obj/item/bodypart/head/ipc/cybersun
	name = "Cybersun Industries IPC head"
	desc = "Голова IPC производства Cybersun Industries."
	icon_state = "cybersun_head"

/obj/item/bodypart/arm/left/ipc/cybersun
	name = "Cybersun Industries IPC left arm"
	desc = "Левая рука IPC производства Cybersun Industries."
	icon_state = "cybersun_l_arm"

/obj/item/bodypart/arm/right/ipc/cybersun
	name = "Cybersun Industries IPC right arm"
	desc = "Правая рука IPC производства Cybersun Industries."
	icon_state = "cybersun_r_arm"

/obj/item/bodypart/leg/left/ipc/cybersun
	name = "Cybersun Industries IPC left leg"
	desc = "Левая нога IPC производства Cybersun Industries."
	icon_state = "cybersun_l_leg"

/obj/item/bodypart/leg/right/ipc/cybersun
	name = "Cybersun Industries IPC right leg"
	desc = "Правая нога IPC производства Cybersun Industries."
	icon_state = "cybersun_r_leg"
