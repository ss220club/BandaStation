/obj/item/implant/cqc
	name = "CQC Имплант"
	desc = "Обучает тебя навыкам боевого искусства Close Quarters Combat за 5 коротких видео-инструкций проецируемых прямо в глаза."
	icon = 'icons/obj/scrolls.dmi'
	icon_state ="scroll2"
	var/datum/martial_art/cqc/style

/obj/item/implant/cqc/get_data()
	var/dat = {"
		<b>Характеристики импланта:</b>

		<b>Название:</b> CQC Имплант

		<b>Срок службы:</b> Практически неограниченный

		<b>Важные замечания:</b> <font color='red'>Запрещено</font>

		<HR>
		<b>Подробности об импланте:</b>

		<b>Функция:</b> Обучает даже самого безнадёжного носителя навыкам боевого искусства Close Quarters Combat.

		<b>Отказ от ответственности:</b> Работоспособность может быть ограничена в зонах с сильными помехами или экранированием сигналов.
	"}
	return dat

/obj/item/implant/cqc/Initialize(mapload)
	. = ..()
	style = new()
	style.allow_temp_override = FALSE

/obj/item/implant/cqc/Destroy()
	QDEL_NULL(style)
	return ..()

/obj/item/implant/cqc/activate()
	. = ..()
	if(isnull(imp_in.mind))
		return
	if(style.fully_remove(imp_in))
		return

	style.teach(imp_in, TRUE)

/obj/item/implanter/cqc
	name = "Имплантер (CQC)"
	imp_type = /obj/item/implant/cqc

/obj/item/implantcase/cqc
	name = "Кейс с имплантами - 'Close Quarters Combat'"
	desc = "Стеклянный кейс содержащий имплант, который может обучить носителя навыкам боевого искусства Close Quarters Combat."
	imp_type = /obj/item/implant/cqc
