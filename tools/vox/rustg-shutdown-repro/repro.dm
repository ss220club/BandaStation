/world/New()
	..()
	var/mode = world.params["mode"]
	world.log << "MODE=[mode]"
	var/version = call_ext("rust_g", "get_version")()
	world.log << "VERSION=[version]"
	if(mode != "control")
		var/list/sprites = list("result" = list("icon_file" = "input.dmi", "icon_state" = "probe", "dir" = 2, "frame" = 1, "transform" = list()))
		var/raw = call_ext("rust_g", "iconforge_generate_headless")("output.dmi", json_encode(sprites), "1")
		world.log << "RESULT=[raw]"
		var/list/result = json_decode(raw)
		if(result["error"] || result["file_path"] != "output.dmi" || !fexists("output.dmi"))
			world.log << "INVALID_RESULT"
			text2file("failed", "invalid.marker")
	if(mode == "cleanup")
		var/cleanup = call_ext("rust_g", "iconforge_cleanup")()
		world.log << "CLEANUP=[cleanup]"
	spawn(1)
		world.log << "BEFORE_DEL"
		text2file("ready", "ready.marker")
		del(src)
