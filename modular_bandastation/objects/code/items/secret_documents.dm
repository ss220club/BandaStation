/// Original documents for a paired agent exchange. Ordinary documents and photocopies are separate types.
/// Exchange objectives must retain a reference to the issued instance so another pair's originals cannot substitute for it.
/obj/item/documents/syndicate/exchange_red
	name = "красные документы для обмена"
	desc = "Секретные документы Синдиката для обмена между агентами, заверенные красной сургучной печатью."
	icon_state = "docs_red"

/obj/item/documents/syndicate/exchange_blue
	name = "синие документы для обмена"
	desc = "Секретные документы Синдиката для обмена между агентами, заверенные синей сургучной печатью."
	icon_state = "docs_blue"


/obj/item/storage/briefcase/secure/document_exchange

/obj/item/storage/briefcase/secure/document_exchange/Initialize(mapload)
	. = ..()
	// Set the code after the component registers its appearance handler.
	var/datum/component/lockable_storage/lock = GetComponent(/datum/component/lockable_storage)
	lock.set_lock_code("[rand(10000, 99999)]")

/obj/item/storage/briefcase/secure/document_exchange/PopulateContents()
	return

/// Keeps the assigned case across power toggles without a second tracking device.
/obj/item/pinpointer/document_exchange
	var/datum/weakref/briefcase_ref

/obj/item/pinpointer/document_exchange/scan_for_target()
	target = briefcase_ref?.resolve()

/obj/item/pinpointer/document_exchange/Destroy()
	briefcase_ref = null
	return ..()
