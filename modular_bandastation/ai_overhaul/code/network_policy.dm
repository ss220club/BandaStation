/** Меняет общую политику управления только при совпадении ожидаемых состояния и ревизии. */
/datum/ai_os/proc/set_human_lock(amount, expected, expected_revision)
	if(QDELETED(network) || !isnum(expected_revision) || expected_revision != network.resource_policy_revision)
		return FALSE
	if(!isnum(amount) || !(amount in list(FALSE, TRUE)) || !isnum(expected) || expected != human_lock)
		return FALSE
	if(human_lock != amount)
		network.resource_policy_revision++
	human_lock = amount
	return TRUE

/** Меняет политику через нейросервис после проверки прав человека и текущего подключения. */
/datum/computer_file/program/neural_service/proc/set_network_policy(list/params, mob/user, datum/ai_network/network)
	if(!can_transfer(user) || local_network() != network || !network.resources.set_human_lock(params["human_only"], params["expected_human_only"], params["expected_revision"]))
		return FALSE
	log_silicon("[key_name(user)] set resource policy for [network.name] to [network.resources.human_lock ? "human operators only" : "authorized silicon allowed"] through Neural Service", list(computer))
	return TRUE

/** Проверяет право пользователя работать с консолью при текущей политике сети. */
/obj/machinery/computer/ai_resource_distribution/proc/can_operate_resources(mob/user)
	if(QDELETED(user) || user.incapacitated || !can_interact(user) || (machine_stat & (NOPOWER | BROKEN | EMPED)) || (!allowed(user) && !(obj_flags & EMAGGED)))
		return FALSE
	if(ishuman(user))
		return user.Adjacent(src)
	if(issilicon(user))
		var/mob/living/silicon/silicon = user
		return !silicon.control_disabled && user.can_interact_with(src)
	return FALSE
