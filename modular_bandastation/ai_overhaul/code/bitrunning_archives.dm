/** Исследовательский архив из основного ящика битрана. */
/obj/item/disk/ai_research_archive/bitrunning
	name = "standard bitrunning research archive"
	desc = "Исследовательские данные о нейронном оборудовании из виртуального домена. Сервер ИИ может восстановить их и один раз выдать очки исследований ИИ."

/** Архив повышенной ценности за более сложный битран-домен. */
/obj/item/disk/ai_research_archive/bitrunning/advanced
	name = "advanced bitrunning research archive"
	decryption_cost = 90
	research_reward = 240

/** Ценный архив за битран-домен высокой сложности. */
/obj/item/disk/ai_research_archive/bitrunning/high_grade
	name = "high-grade bitrunning research archive"
	decryption_cost = 120
	research_reward = 360

/** Дополняет основной ящик битрана единственным архивом исследований ИИ. */
/obj/structure/closet/crate/secure/bitrunning/decrypted
	/// Предотвращает повторную выдачу архива за один ящик битрана.
	var/ai_archive_added = FALSE

/** Добавляет в основной ящик один архив, выбрав его ценность по сложности completed_domain. */
/obj/structure/closet/crate/secure/bitrunning/decrypted/proc/add_ai_research_archive(datum/lazy_template/virtual_domain/completed_domain)
	if(ai_archive_added || QDELETED(completed_domain))
		return FALSE
	var/archive_type
	switch(completed_domain.difficulty)
		if(BITRUNNER_DIFFICULTY_LOW)
			archive_type = /obj/item/disk/ai_research_archive/bitrunning
		if(BITRUNNER_DIFFICULTY_MEDIUM)
			archive_type = /obj/item/disk/ai_research_archive/bitrunning/advanced
		if(BITRUNNER_DIFFICULTY_HIGH)
			archive_type = /obj/item/disk/ai_research_archive/bitrunning/high_grade
	if(!archive_type)
		return FALSE
	ai_archive_added = TRUE
	new archive_type(src)
	return TRUE
