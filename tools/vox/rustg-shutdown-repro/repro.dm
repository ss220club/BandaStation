/world/New()
	..()
	var/mode = world.params["mode"]
	var/epoch = 1
	if(mode == "warm")
		var/pid_waits = 0
		while(!fexists("host-pid.txt") && pid_waits++ < 30)
			sleep(1)
		if(!fexists("host-pid.txt"))
			text2file("missing host PID", "invalid.marker")
			del(src)
			return
		if(fexists("epoch.txt"))
			epoch = text2num(file2text("epoch.txt")) + 1
		if(epoch < 1 || epoch > 3)
			text2file("invalid epoch", "invalid.marker")
			del(src)
			return
		fdel("epoch.txt")
		text2file("[epoch]", "epoch.txt")
	world.log << "MODE=[mode]"
	var/version = call_ext("rust_g", "get_version")()
	world.log << "VERSION=[version]"
	var/list/record = list("mode" = mode, "epoch" = epoch, "version" = version)
	if(mode == "warm")
		record["host_pid"] = text2num(file2text("host-pid.txt"))
	if(mode != "control")
		var/output_path = mode == "warm" ? "output-[epoch].dmi" : "output.dmi"
		var/list/sprites = list("result" = list("icon_file" = "input.dmi", "icon_state" = "probe", "dir" = 2, "frame" = 1, "transform" = list()))
		var/raw = call_ext("rust_g", "iconforge_generate_headless")(output_path, json_encode(sprites), "1")
		world.log << "RESULT=[raw]"
		var/list/result = json_decode(raw)
		record["result"] = result
		if(result["error"] || result["file_path"] != output_path || !fexists(output_path))
			world.log << "INVALID_RESULT"
			text2file("failed", "invalid.marker")
	if(mode == "cleanup")
		var/cleanup = call_ext("rust_g", "iconforge_cleanup")()
		world.log << "CLEANUP=[cleanup]"
		record["cleanup"] = cleanup
	text2file(json_encode(record), "epoch-[epoch].json")
	spawn(mode == "warm" ? 5 : 1)
		if(mode == "warm" && epoch < 3)
			world.log << "BEFORE_REBOOT=[epoch]"
			text2file("before_reboot", "reboot-[epoch].marker")
			world.Reboot()
			return
		world.log << "BEFORE_DEL"
		text2file("ready", "ready.marker")
		del(src)
