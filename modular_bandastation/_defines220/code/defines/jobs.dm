#define JOB_DISPLAY_ORDER_NANOTRASEN_REPRESENTATIVE 2.5
#define JOB_DISPLAY_ORDER_MAGISTRATE 3.5
#define JOB_DISPLAY_ORDER_EXPLORER 22.5
#define JOB_DISPLAY_ORDER_BLUESHIELD 35.5

/// From jobs/controller/roundstart, before equipment and handover: (mob/living/character).
#define COMSIG_MIND_ROUNDSTART_CHARACTER_CREATED "mind_roundstart_character_created"
	#define COMPONENT_CANCEL_CHARACTER_SPAWN (1<<0)

/// Additional admission failures; consumers belong to the job modules.
#define JOB_UNAVAILABLE_JOB_LOCK 8
#define JOB_UNAVAILABLE_CHARACTER_PROFILE 9
