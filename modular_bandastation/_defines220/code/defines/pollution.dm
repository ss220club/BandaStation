#define REGISTER_POLLUTION(pollution) SSpollution.all_pollution[pollution] = TRUE
#define UNREGISTER_POLLUTION(pollution) SSpollution.all_pollution -= pollution
#define SET_ACTIVE_POLLUTION(pollution) SSpollution.active_pollution[pollution] = TRUE
#define SET_UNACTIVE_POLLUTION(pollution) SSpollution.active_pollution -= pollution
#define SET_PROCESSED_THIS_RUN(pollution) SSpollution.processed_this_run[pollution] = TRUE
#define REMOVE_POLLUTION_CURRENTRUN(pollution) SSpollution.current_run -= pollution

#define TICKS_TO_DISSIPATE 20

#define POLLUTION_TASK_PROCESS 1
#define POLLUTION_TASK_DISSIPATE 2

#define POLLUTION_DISSIPATION_PLANETARY_MULTIPLIER 4

//Bitflags for pollutants
#define POLLUTANT_APPEARANCE (1<<0) //Pollutant has an appearance
#define POLLUTANT_TOUCH_ACT (1<<1) //Pollutant calls touch_act() on unprotected people touched by it
#define POLLUTANT_BREATHE_ACT (1<<2) //Pollutant calls breathe_act() on people breathing it in

#define POLLUTANT_APPEARANCE_THICKNESS_THRESHOLD 30
#define THICKNESS_ALPHA_COEFFICIENT 0.0025
