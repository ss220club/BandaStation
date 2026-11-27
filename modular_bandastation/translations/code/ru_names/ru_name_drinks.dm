/datum/component/takes_reagent_appearance/update_name(datum/glass_style/style)
	. = ..()
	if(HAS_TRAIT(parent, TRAIT_WAS_RENAMED) || (style && !style.name))
		return .
	var/obj/item/container = parent
	container.ru_names_rename(ru_names_toml(container.name))

/datum/component/takes_reagent_appearance/UnregisterFromParent()
	. = ..()
	var/obj/item/container = parent
	container.ru_names_rename(ru_names_toml(container.name))
