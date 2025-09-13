/proc/get_holders_with_rights(rights)
	var/list/valid_holders = list()
	for(var/client/holder as anything in GLOB.admins)
		if(check_rights_for(holder, rights))
			valid_holders += holder

	return valid_holders

/proc/prepare_admin_sound(vol, sound/sound_file)
	var/sound/admin_sound = new
	admin_sound.file = sound_file
	admin_sound.priority = 250
	admin_sound.channel = CHANNEL_ADMIN
	admin_sound.frequency = 1
	admin_sound.wait = 1
	admin_sound.repeat = FALSE
	admin_sound.status = SOUND_STREAM
	admin_sound.volume = vol
	return admin_sound
