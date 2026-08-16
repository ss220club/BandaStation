/// Sent to a registered field listener when its canonical tile changes.
/// Arguments: (cell, old_value, new_value, old_state, new_state, reason)
/// Profile is intentionally omitted because one cell may combine several sources.
#define COMSIG_REDSPACE_FIELD_CHANGED "redspace_field_changed"

/// Sent directly to an atom or datum that was affected by a redspace event.
/// Arguments: (event, profile_id, source_id, amount, reason)
#define COMSIG_REDSPACE_EXPOSURE "redspace_exposure"

/// Sent by a registered source after its position, strength, radius or lifecycle changes.
/// Arguments: (change_kind, profile_id, old_value, new_value, reason)
#define COMSIG_REDSPACE_SOURCE_CHANGED "redspace_source_changed"

/// Sent to registered scenario listeners when an explicit event starts.
/// Arguments: (event, event_context, reason); context has target_turf, zone_key, profile_id and optional source_id.
#define COMSIG_REDSPACE_EVENT_STARTED "redspace_event_started"

/// Sent to registered scenario listeners when an explicit event finishes.
/// Arguments: (event, event_context, reason); context has target_turf, zone_key, profile_id and optional source_id.
#define COMSIG_REDSPACE_EVENT_FINISHED "redspace_event_finished"

#define REDSPACE_SOURCE_CHANGE_ADDED "added"
#define REDSPACE_SOURCE_CHANGE_STRENGTH "strength"
#define REDSPACE_SOURCE_CHANGE_POSITION "position"
#define REDSPACE_SOURCE_CHANGE_RADIUS "radius"
#define REDSPACE_SOURCE_CHANGE_REMOVED "removed"
