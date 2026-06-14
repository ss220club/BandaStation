#define TRADER_DEBUG "debug"

#define TRADER_SAMOPAL "samopal"
#define TRADER_TERESA "teresa"
#define TRADER_FASHION "fashion"
#define TRADER_SURVIVOR "survivor"
#define TRADER_VISITOR "visitor"
#define TRADER_ROBINSON "robinson"
#define TRADER_KEKSUHA "keksuha"

/mob/living/carbon/human
	var/list/trader_rep = list()
	var/list/trader_rep_progress = list()

/mob/living/carbon/human/proc/add_trader_rep(trader_id, amount)
	trader_rep[trader_id] = (trader_rep[trader_id] || 0) + amount

/mob/living/carbon/human/proc/get_trader_level(trader_id)
	var/rep = trader_rep[trader_id] || 0
	if(rep >= 100)
		return 4
	if(rep >= 50)
		return 3
	if(rep >= 10)
		return 2

	return 1

/mob/living/carbon/human/proc/add_trader_sale(trader_id, credits)
	if(!trader_rep_progress)
		trader_rep_progress = list()
	trader_rep_progress[trader_id] = (trader_rep_progress[trader_id] || 0) + credits

	while(trader_rep_progress[trader_id] >= 100)
		trader_rep_progress[trader_id] -= 100
		add_trader_rep(trader_id, 1)
