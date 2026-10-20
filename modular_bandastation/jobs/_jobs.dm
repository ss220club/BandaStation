/datum/modpack/jobs
	name = "Расширение и дополнение работ"
	desc = "Добавляет новые работы, расширяет и изменяет имеющиеся."
	author = "dj-34, gaxeer, Ez-Briz, PhantornRU"

/datum/modpack/jobs/initialize()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/modpack/jobs/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	job.apply_job_variant_identity(spawned)

/datum/modpack/jobs/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN)
	return ..()
