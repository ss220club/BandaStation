// Insurance tiers and costs per payday tick

#define INSURANCE_NONE 0
#define INSURANCE_STANDARD 1
#define INSURANCE_PREMIUM 2

#define INSURANCE_COST_NONE 0
#define INSURANCE_COST_STANDARD 10
#define INSURANCE_COST_PREMIUM 40

// Macro helpers
#define INSURANCE_TIER_TO_COST(T) \
	((T) == INSURANCE_PREMIUM ? INSURANCE_COST_PREMIUM : \
	(T) == INSURANCE_STANDARD ? INSURANCE_COST_STANDARD : \
	INSURANCE_COST_NONE)

#define INSURANCE_TIER_TO_TEXT(T) \
	((T) == INSURANCE_PREMIUM ? "Premium" : \
	(T) == INSURANCE_STANDARD ? "Standard" : \
	"None")

// Billing: pending medical bill expiry duration
#define INSURANCE_BILL_EXPIRE (10 MINUTES)

// --- Bandastation: simple insurance benefits ---
// Medical kiosk discount percent by tier (0-100)
#define INSURANCE_DISCOUNT_STANDARD 50
#define INSURANCE_DISCOUNT_PREMIUM 100

// Helper: tier -> kiosk discount percent
#define INSURANCE_TIER_TO_MED_KIOSK_DISCOUNT(T) \
	((T) == INSURANCE_PREMIUM ? INSURANCE_DISCOUNT_PREMIUM : \
	(T) == INSURANCE_STANDARD ? INSURANCE_DISCOUNT_STANDARD : \
	0)

// --- Surgery pricing (auto) ---
// Base price and modifiers to estimate operation complexity cost (credits)
#define SURGERY_PRICE_BASE 80
#define SURGERY_PRICE_PER_STEP 40
#define SURGERY_PRICE_ADVANCED_BONUS 150
#define SURGERY_PRICE_HEAD_BONUS 100
#define SURGERY_PRICE_CHEST_BONUS 60
#define SURGERY_PRICE_WOUND_BONUS 40
#define SURGERY_PRICE_MIN 50
#define SURGERY_PRICE_MAX 2000
