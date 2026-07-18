#define TRADER_DEBUG "debug"

#define TRADER_SAMOPAL "samopal"
#define TRADER_TERESA "teresa"
#define TRADER_FASHION "fashion"
#define TRADER_SURVIVOR "survivor"
#define TRADER_VISITOR "visitor"
#define TRADER_ROBINSON "robinson"
#define TRADER_KAMILLA "kamilla"

/mob/living/carbon/human
	var/list/trader_rep = list()
	var/list/trader_rep_progress = list()

/mob/living/carbon/human/proc/add_trader_rep(trader_id, amount)
	trader_rep[trader_id] = (trader_rep[trader_id] || 0) + amount

/mob/living/carbon/human/proc/get_trader_level(trader_id)
	var/rep = trader_rep[trader_id] || 0
	if(trader_id == TRADER_TERESA)
		var/obj/item/card/id/I = get_idcard(TRUE)
		if(istype(I, /obj/item/card/id/advanced/blessed))
			rep = max(rep, 100)
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
