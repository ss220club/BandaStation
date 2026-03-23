#define BODYTYPE_IPC (1<<9)

// ============================================
// КАТЕГОРИИ ФАБРИКАТОРА ДЛЯ КПБ
// ============================================

#define RND_CATEGORY_IPC "/КПБ"
#define RND_SUBCATEGORY_IPC_BODYPARTS "/Части тела"
#define RND_SUBCATEGORY_IPC_ORGANS "/Органы"
#define RND_SUBCATEGORY_IPC_EQUIPMENT "/Оборудование"

//	============================================
//  Define Panel states
// ============================================

#define IPC_PANEL_CLOSED 0
#define IPC_PANEL_OPEN   1
#define IPC_ELECTRONICS_PREPARED 2

#define COMSIG_IPC_BATTERY_UPDATED "ipc_battery_updated"

/// Доля брут-урона от max_damage, при которой корпус считается вскрытым
#define IPC_CHASSIS_BREACH_THRESHOLD 0.25
/// Источник трейта защиты от давления — интактный корпус КПБ
#define TRAIT_SOURCE_IPC_CHASSIS "ipc_chassis_intact"
