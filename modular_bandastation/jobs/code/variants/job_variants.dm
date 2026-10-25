/datum/job
	/// Stable variant ID -> list(public title, outfit path).
	var/list/job_variant_specs
	var/list/job_variants

/datum/job_variant
	var/id
	var/public_title
	var/outfit_type

/datum/job_variant/New(new_id, new_title, new_outfit)
	id = new_id
	public_title = new_title
	outfit_type = new_outfit
	return ..()

/datum/job/proc/get_job_variants()
	if(!isnull(job_variants))
		return job_variants
	var/list/variants = list()
	for(var/id in job_variant_specs)
		var/list/spec = job_variant_specs[id]
		if(!istext(id) || !length(id) || !islist(spec) || length(spec) != 2 || !istext(spec[1]) || !length(spec[1]) || !ispath(spec[2], /datum/outfit/job))
			CRASH("Invalid job variant declaration: [type]/[id]")
		var/datum/outfit/job/outfit_path = spec[2]
		var/datum/id_trim/job/trim_path = initial(outfit_path.id_trim)
		if(initial(outfit_path.jobtype) != type || !ispath(trim_path, /datum/id_trim/job) || initial(trim_path.job) != type)
			CRASH("Variant outfit/trim belongs to another job: [type]/[id]")
		variants[id] = new /datum/job_variant(id, spec[1], spec[2])
	if(length(variants) && !variants["default"])
		CRASH("Job variants require a default: [type]")
	job_variants = variants
	return job_variants

/datum/job/proc/resolve_job_variant(variant_id) as /datum/job_variant
	var/list/variants = get_job_variants()
	return variants[variant_id] || variants["default"]
