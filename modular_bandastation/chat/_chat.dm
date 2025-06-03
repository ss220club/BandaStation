/datum/modpack/chat
	/// A string name for the modpack. Used for looking up other modpacks in init.
	name = "Плюшки для чата"
	/// A string desc for the modpack. Can be used for modpack verb list as description.
	desc = "Добавляет разные мелкие фичи для чата. Например иконки для OOC ролей."
	/// A string with authors of this modpack.
	author = "Aylong, Furior"

/datum/modpack/chat/pre_initialize()
	. = ..()

/datum/modpack/chat/initialize()
	. = ..()

/datum/modpack/chat/post_initialize()
	. = ..()
