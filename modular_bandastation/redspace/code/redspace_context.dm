/// Round state for the redspace field: background, active z-levels, influence profile
/// and zone susceptibility coefficients. The subsystem reads this datum instead of
/// branching on specific events, round traits or admin tooling.
/datum/redspace_context
	/// Whether the field should run at all. Any provider may veto the system.
	var/enabled = TRUE
	/// Slowly changing round background value.
	var/background_value = REDSPACE_DEFAULT_VALUE
	/// Z-levels covered by the field.
	var/list/active_z_levels = list()
	/// Identifier of the influence profile selected for the round.
	var/active_profile_id
	/// Profile data selected for the round. The id remains available for compact payloads.
	var/datum/redspace_profile/active_profile
	/// Associative list of provider id -> /datum/redspace_context_provider.
	var/list/providers = list()
	/// Cached susceptibility coefficients by hex key. Rebuilt on refresh().
	var/list/zone_coefficients = list()

/datum/redspace_context/New(list/initial_providers)
	. = ..()
	for(var/datum/redspace_context_provider/provider as anything in initial_providers)
		add_provider(provider)

/datum/redspace_context/Destroy()
	QDEL_NULL(active_profile)
	for(var/provider_key in providers)
		qdel(providers[provider_key])
	providers.Cut()
	zone_coefficients.Cut()
	return ..()

/// Registers a provider. Duplicate ids are rejected so refresh stays deterministic.
/datum/redspace_context/proc/add_provider(datum/redspace_context_provider/provider)
	if(!provider || (provider.provider_id in providers))
		return FALSE
	providers[provider.provider_id] = provider
	return TRUE

/datum/redspace_context/proc/remove_provider(provider_id)
	var/datum/redspace_context_provider/provider = providers[provider_id]
	if(!provider)
		return FALSE
	providers -= provider_id
	qdel(provider)
	zone_coefficients.Cut()
	return TRUE

/// Collects background, active z-levels, profile and enabled flag from all providers.
/// Later background and profile proposals override earlier defaults, z-levels are
/// unioned, and any explicit FALSE disables the system.
/datum/redspace_context/proc/refresh()
	var/resolved_background
	var/list/resolved_z_levels = list()
	var/resolved_profile
	var/resolved_enabled = TRUE

	for(var/provider_key in providers)
		var/datum/redspace_context_provider/provider = providers[provider_key]
		if(!provider)
			continue
		if(provider.get_enabled() == FALSE)
			resolved_enabled = FALSE
		var/provider_background = provider.get_background_value()
		if(isnum(provider_background))
			resolved_background = provider_background
		var/list/provider_z_levels = provider.get_active_z_levels()
		if(length(provider_z_levels))
			resolved_z_levels |= provider_z_levels
		var/provider_profile = provider.get_profile_id()
		if(!isnull(provider_profile))
			resolved_profile = provider_profile

	enabled = resolved_enabled
	if(isnum(resolved_background))
		background_value = min(resolved_background, REDSPACE_MAX_NORMAL_VALUE)
	active_z_levels = resolved_z_levels
	if(!isnull(resolved_profile) && (!active_profile || active_profile.profile_id != resolved_profile))
		QDEL_NULL(active_profile)
		active_profile = redspace_profile_from_id(resolved_profile)
	if(active_profile)
		active_profile_id = active_profile.profile_id
	zone_coefficients.Cut()

/// Returns the susceptibility coefficient for a hex, asking providers on the first
/// request and caching the result. The strongest proposed restriction wins.
/datum/redspace_context/proc/get_zone_coefficient(z_level, q, r)
	var/key = redspace_hex_key(z_level, q, r)
	var/cached_coefficient = zone_coefficients[key]
	if(isnum(cached_coefficient))
		return cached_coefficient

	var/turf/representative_turf = redspace_hex_representative_turf(z_level, q, r)
	var/coefficient
	for(var/provider_key in providers)
		var/datum/redspace_context_provider/provider = providers[provider_key]
		if(!provider)
			continue
		var/proposed_coefficient = provider.get_zone_coefficient(z_level, q, r, representative_turf)
		if(!isnum(proposed_coefficient))
			continue
		coefficient = isnum(coefficient) ? min(coefficient, proposed_coefficient) : proposed_coefficient

	if(!isnum(coefficient))
		coefficient = REDSPACE_DEFAULT_COEFFICIENT
	zone_coefficients[key] = coefficient
	return coefficient

/// Supplies part of the round context. Providers must stay cheap: they are consulted
/// on refresh() and on every uncached zone coefficient lookup. Returning null means
/// the provider has no opinion and the next provider decides.
/datum/redspace_context_provider
	var/provider_id = "abstract"

/datum/redspace_context_provider/proc/get_enabled()
	return null

/datum/redspace_context_provider/proc/get_background_value()
	return null

/datum/redspace_context_provider/proc/get_active_z_levels()
	return null

/datum/redspace_context_provider/proc/get_profile_id()
	return null

/datum/redspace_context_provider/proc/get_zone_coefficient(z_level, q, r, turf/representative_turf)
	return null

/// MVP defaults: station z-levels, calm background, the demonic profile and the single
/// bridge susceptibility exception resolved through the hex representative point.
/datum/redspace_context_provider/default
	provider_id = "default"

/datum/redspace_context_provider/default/get_background_value()
	return REDSPACE_DEFAULT_VALUE

/datum/redspace_context_provider/default/get_active_z_levels()
	return SSmapping.levels_by_trait(ZTRAIT_STATION)

/datum/redspace_context_provider/default/get_profile_id()
	return REDSPACE_PROFILE_DEMONIC

/datum/redspace_context_provider/default/get_zone_coefficient(z_level, q, r, turf/representative_turf)
	if(!representative_turf)
		return null
	if(!istype(representative_turf.loc, /area/station/command/bridge))
		return null
	return REDSPACE_BRIDGE_COEFFICIENT
