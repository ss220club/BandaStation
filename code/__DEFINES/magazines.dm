/// Appended to the description of magazines that spawn with old-fashioned incendiary ammo, which generally leave fire trails and give firestacks in return for less base damage.
#define MAGAZINE_DESC_INC "<br>Содержит патроны, которые поджигают цели и иногда оставляют за собой огненный след, но наносят меньше повреждений."
/// Appended to the description of magazines that spawn with hollow-point ammo, which generally has higher base damage but is weak against armor.
#define MAGAZINE_DESC_HOLLOWPOINT "<br>Содержит экспансивные патроны, которые эффективны против небронированных целей, но сильно неэффективны против бронированных целей."
/// Appended to the description of magazines that spawn with armor-piercing ammo, which generally has less base damage but penetrates armor.
#define MAGAZINE_DESC_ARMORPIERCE "<br>Содержит бронебойные патроны, которые эффективны против бронированных целей, но менее эффективны против небронированных целей."

/// Defines a magazine to, visually, be for incendiary ammo by setting the ammo band color and appending a short blurb to the description.
#define MAGAZINE_TYPE_INCENDIARY \
	ammo_band_color = COLOR_AMMO_INCENDIARY; \
	desc = parent_type::desc + MAGAZINE_DESC_INC;

/// Defines a magazine to, visually, be for hollow-point ammo by setting the ammo band color and appending a short blurb to the description.
#define MAGAZINE_TYPE_HOLLOWPOINT \
	ammo_band_color = COLOR_AMMO_HOLLOWPOINT; \
	desc = parent_type::desc + MAGAZINE_DESC_HOLLOWPOINT;

/// Defines a magazine to, visually, be for armor-piercing ammo by setting the ammo band color and appending a short blurb to the description.
#define MAGAZINE_TYPE_ARMORPIERCE \
	ammo_band_color = COLOR_AMMO_ARMORPIERCE; \
	desc = parent_type::desc + MAGAZINE_DESC_ARMORPIERCE;
