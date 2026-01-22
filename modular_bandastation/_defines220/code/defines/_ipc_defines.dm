
// ============================================
// ТИПЫ ЯДРА IPC
// ============================================

#define IPC_BRAIN_POSITRONIC "positronic"
#define IPC_BRAIN_MMI "mmi"
#define IPC_BRAIN_BORG "borg_module"

// ============================================
// ТЕМПЕРАТУРНЫЕ КОНСТАНТЫ
// ============================================

#define IPC_TEMP_CRITICAL_LOW 20
#define IPC_TEMP_OPTIMAL_LOW 20
#define IPC_TEMP_OPTIMAL_HIGH 40
#define IPC_TEMP_NEUTRAL_HIGH 80
#define IPC_TEMP_OVERHEAT_LOW 80
#define IPC_TEMP_OVERHEAT_MID 90
#define IPC_TEMP_OVERHEAT_HIGH 120
#define IPC_TEMP_CRITICAL_HIGH 130

// Состояния температуры
#define IPC_TEMP_STATE_COLD "cold"
#define IPC_TEMP_STATE_OPTIMAL "optimal"
#define IPC_TEMP_STATE_NEUTRAL "neutral"
#define IPC_TEMP_STATE_WARM "warm"
#define IPC_TEMP_STATE_HOT "hot"
#define IPC_TEMP_STATE_CRITICAL "critical"
#define IPC_TEMP_STATE_BURNING "burning"

#define BODYTYPE_IPC (1<<9)
