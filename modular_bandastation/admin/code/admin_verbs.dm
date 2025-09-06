ADMIN_VERB_ONLY_CONTEXT_MENU(spawn_debug_outfit, R_SPAWN, "(Debug) Debug Outfit", mob/admin in world)
	if(tgui_alert(admin,"Это заспавнит вас в специальном Debug прикиде, удаляя при этом ваше старое тело если оно было. Вы уверены?", "Debug Outfit", list("Да", "Нет")) != "Да")
		return
	var/mob/living/carbon/human/admin_body = admin.change_mob_type(/mob/living/carbon/human, delete_old_mob = TRUE)
	admin_body.equipOutfit(/datum/outfit/debug)

ADMIN_VERB_ONLY_CONTEXT_MENU(download_flaticon, R_ADMIN, "(Special) Download Icon", atom/thing in world)
	var/icon/image = getFlatIcon(thing, no_anim = TRUE)
	var/image_width = max(image.Width(), 32)
	var/image_height = max(image.Height(), 32)

	var/resize_answer = tgui_alert(usr, "Хотите ли вы изменить размер иконки? Оригинальный размер: [image_width]x[image_height]", "Download Icon", list("Да", "Нет", "Удвоить"))
	if(resize_answer != "Нет" && !isnull(resize_answer))
		switch(resize_answer)
			if("Да")
				var/new_width = tgui_input_number(usr, "Оригинальная ширина: [image_width]px", "Изменение ширины", image_width, 1024, 16)
				if(!isnull(new_width))
					image_width = new_width

				var/new_height = tgui_input_number(usr, "Оригинальная высота: [image_height]px", "Изменение высоты", image_height, 1024, 16)
				if(!isnull(new_height))
					image_height = new_height

			if("Удвоить")
				image_width *= 2
				image_height *= 2

		image.Scale(image_width, image_height)

	usr << ftp(image, "[thing.name]_[image_width]x[image_height].png")

ADMIN_VERB_AND_CONTEXT_MENU(man_up, R_ADMIN, "Man Up", "Tells mob to man up and deal with it.", ADMIN_CATEGORY_FUN, mob/living/target in world)
	if(QDELETED(target))
		return
	to_chat(target, boxed_message(span_notice("<div align='center'><b><font size=8>Man up.<br>Deal with it.</font></b><br>Move on.</div>")))
	SEND_SOUND(target, sound('modular_bandastation/admin/sound/manup1.ogg'))

	log_admin("[key_name(user)] told [key_name(target)] to man up and deal with it.")
	message_admins("[key_name_admin(user)] told [key_name(target)] to man up and deal with it.")

ADMIN_VERB(global_man_up, R_ADMIN, "Global Man Up", "Tells everyone to man up and deal with it.", ADMIN_CATEGORY_FUN)
	if(tgui_alert(user, "Вы уверены что хотите отправить глобальное сообщение?", "Подтверждение глобального Man Up", list("Да", "Нет")) != "Нет")
		for(var/sissy in GLOB.player_list)
			to_chat(sissy, boxed_message(span_notice("<div align='center'><b><font size=8>Man up.<br>Deal with it.</font></b><br>Move on.</div>")))
			SEND_SOUND(sissy, sound('modular_bandastation/admin/sound/manup1.ogg'))

		log_admin("[key_name(user)] told everyone to man up and deal with it.")
		message_admins("[key_name_admin(user)] told everyone to man up and deal with it.")
