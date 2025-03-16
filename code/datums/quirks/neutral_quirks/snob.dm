/datum/quirk/snob
	name = "Snob"
	desc = "У вас утончённый вкус, и если комната выглядит некрасиво, она того не стоит, не так ли?"
	icon = FA_ICON_USER_TIE
	value = 0
	gain_text = span_notice("Вы ощущаете, что прекрасно понимаете, как должно выглядеть окружение.")
	lose_text = span_notice("Да кого вообще волнует как тут все выглядит?")
	medical_record_text = "Пациент выглядит довольно замороченным."
	mob_trait = TRAIT_SNOB
	mail_goodies = list(/obj/item/chisel, /obj/item/paint_palette)
