/datum/modpack/tooltypes
	/// A string name for the modpack. Used for looking up other modpacks in init.
	name = "tooltypes"
	/// A string desc for the modpack. Can be used for modpack verb list as description.
	desc = "Файл хранения add_context() для различных объектов при взаимодействии."
	/// A string with authors of this modpack.
	author = "Voyaker"

/datum/modpack/tooltypes/pre_initialize()
	. = ..()

/datum/modpack/tooltypes/initialize()
	. = ..()

/datum/modpack/tooltypes/post_initialize()
	. = ..()
