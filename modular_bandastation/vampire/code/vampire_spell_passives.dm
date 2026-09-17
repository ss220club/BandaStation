/// A progression passive that grants and owns one vampire spell action.
/datum/vampire_passive/grant_spell
	var/spell_type
	var/datum/weakref/vampire_ref
	var/datum/weakref/granted_spell_ref

/datum/vampire_passive/grant_spell/on_apply(datum/antagonist/vampire/vampire)
	. = ..()
	if(!spell_type)
		return
	vampire_ref = WEAKREF(vampire)
	var/datum/action/cooldown/spell/spell = vampire.force_add_ability(spell_type)
	granted_spell_ref = WEAKREF(spell)

/datum/vampire_passive/grant_spell/proc/get_granted_spell() as /datum/action/cooldown/spell
	return granted_spell_ref?.resolve()

/datum/vampire_passive/grant_spell/Destroy(force, ...)
	var/datum/antagonist/vampire/vampire = vampire_ref?.resolve()
	var/datum/action/cooldown/spell/spell = granted_spell_ref?.resolve()
	if(vampire && spell && !QDELETED(spell))
		vampire.remove_ability(spell)
	vampire_ref = null
	granted_spell_ref = null
	return ..()

/datum/vampire_passive/grant_spell/rejuvenate
	spell_type = /datum/action/cooldown/spell/vampire_rejuvenate
	gain_desc = "Теперь вы можете использовать омоложение."

/datum/vampire_passive/grant_spell/glare
	spell_type = /datum/action/cooldown/spell/aoe/vampire_glare
	gain_desc = "Теперь вы можете использовать взгляд."

/datum/vampire_passive/grant_spell/specialize
	spell_type = /datum/action/cooldown/spell/vampire_specialize
	gain_desc = "Теперь вы можете выбрать вампирскую специализацию для развития."

/datum/vampire_passive/grant_spell/lair
	spell_type = /datum/action/cooldown/spell/pointed/vampire_lair
	gain_desc = "Теперь вы можете создать логово."

/datum/vampire_passive/grant_spell/vamp_claws
	spell_type = /datum/action/cooldown/spell/vampire_vamp_claws
	gain_desc = "Вы обрели способность превращать руки в вампирские когти."

/datum/vampire_passive/grant_spell/blood_tendrils
	spell_type = /datum/action/cooldown/spell/pointed/vampire_blood_tendrils
	gain_desc = "Вы обрели способность призывать кровавые щупальца, замедляющие людей в выбранной области."

/datum/vampire_passive/grant_spell/blood_barrier
	spell_type = /datum/action/cooldown/spell/pointed/vampire_blood_barrier
	gain_desc = "Вы обрели способность призывать между двумя точками кристаллическую стену из крови. Барьер легко разрушить, но вы можете свободно проходить сквозь него."

/datum/vampire_passive/grant_spell/blood_pool
	spell_type = /datum/action/cooldown/spell/jaunt/ethereal_jaunt/vampire_blood_pool
	gain_desc = "Вы обрели способность превращаться в лужу крови, чтобы с высокой мобильностью уходить от преследователей."

/datum/vampire_passive/grant_spell/predator_senses
	spell_type = /datum/action/cooldown/spell/vampire_predator_senses
	gain_desc = "Ваши чувства обострились: теперь от вас никто не скроется."

/datum/vampire_passive/grant_spell/blood_eruption
	spell_type = /datum/action/cooldown/spell/aoe/vampire_blood_eruption
	gain_desc = "Вы обрели способность превращать лужи крови в оружие против стоящих на них."

/datum/vampire_passive/grant_spell/blood_spill
	spell_type = /datum/action/cooldown/spell/vampire_blood_spill
	gain_desc = "Вы обрели способность вырывать из людей саму жизненную силу и поглощать её, исцеляясь."

/datum/vampire_passive/grant_spell/cloak
	spell_type = /datum/action/cooldown/spell/vampire_cloak
	gain_desc = "Вы обрели способность «Покров тьмы»: во тьме она делает вас почти невидимым и очень ловким."

/datum/vampire_passive/grant_spell/shadow_snare
	spell_type = /datum/action/cooldown/spell/pointed/vampire_shadow_snare
	gain_desc = "Вы обрели способность призывать ловушку, ослепляющую, опутывающую и гасящую свет у пересёкших её."

/datum/vampire_passive/grant_spell/soul_anchor
	spell_type = /datum/action/cooldown/spell/vampire_soul_anchor
	gain_desc = "Вы обрели способность запоминать точку в пространстве и возвращаться к ней по желанию. Если не вернуться добровольно за две минуты, вас вернёт принудительно."

/datum/vampire_passive/grant_spell/dark_passage
	spell_type = /datum/action/cooldown/spell/pointed/vampire_dark_passage
	gain_desc = "Вы обрели способность перемещаться на небольшое расстояние к выбранной клетке."

/datum/vampire_passive/grant_spell/extinguish
	spell_type = /datum/action/cooldown/spell/aoe/vampire_extinguish
	gain_desc = "Вы обрели способность гасить ближайшие источники света."

/datum/vampire_passive/grant_spell/shadow_boxing
	spell_type = /datum/action/cooldown/spell/pointed/vampire_shadow_boxing
	gain_desc = "Вы обрели способность заставлять свою тень сражаться за вас."

/datum/vampire_passive/grant_spell/eternal_darkness
	spell_type = /datum/action/cooldown/spell/vampire_eternal_darkness
	gain_desc = "Вы обрели способность окутывать область вокруг себя тьмой. Лишь самый яркий свет способен пробить ваши нечестивые силы."

/datum/vampire_passive/grant_spell/blood_swell
	spell_type = /datum/action/cooldown/spell/vampire_blood_swell
	gain_desc = "Вы обрели способность временно сопротивляться сильному оглушению и физическому урону."

/datum/vampire_passive/grant_spell/stomp
	spell_type = /datum/action/cooldown/spell/vampire_stomp
	gain_desc = "Вы обрели способность отбрасывать людей мощным топотом."

/datum/vampire_passive/grant_spell/overwhelming_force
	spell_type = /datum/action/cooldown/spell/vampire_overwhelming_force
	gain_desc = "Вы обрели способность выбивать двери ценой небольшого количества крови."

/datum/vampire_passive/grant_spell/blood_rush
	spell_type = /datum/action/cooldown/spell/vampire_blood_rush
	gain_desc = "Вы обрели способность временно двигаться с высокой скоростью."

/datum/vampire_passive/grant_spell/demonic_grasp
	spell_type = /datum/action/cooldown/spell/pointed/projectile/vampire_demonic_grasp
	gain_desc = "Вы обрели способность опутывать и сбивать людей с толку демоническими отростками."

/datum/vampire_passive/grant_spell/charge
	spell_type = /datum/action/cooldown/spell/pointed/vampire_charge
	gain_desc = "Теперь вы можете нестись к цели на экране, нанося огромный урон и разрушая постройки."

/datum/vampire_passive/grant_spell/arena
	spell_type = /datum/action/cooldown/spell/pointed/vampire_arena
	gain_desc = "Теперь вы можете прыгнуть к цели и запереть её на призванной арене."

/datum/vampire_passive/grant_spell/enthrall
	spell_type = /datum/action/cooldown/spell/pointed/vampire_enthrall
	gain_desc = "Вы обрели способность подчинять людей своей воле."

/datum/vampire_passive/grant_spell/commune
	spell_type = /datum/action/cooldown/spell/vampire_commune
	gain_desc = "Вы обрели способность общаться со своими рабами телепатически."

/datum/vampire_passive/grant_spell/pacify
	spell_type = /datum/action/cooldown/spell/pointed/vampire_pacify
	gain_desc = "Вы обрели способность усмирять чьи-то агрессивные наклонности, не позволяя причинять физический вред."

/datum/vampire_passive/grant_spell/switch_places
	spell_type = /datum/action/cooldown/spell/pointed/vampire_switch_places
	gain_desc = "Вы обрели способность меняться местами с выбранным существом."

/datum/vampire_passive/grant_spell/decoy
	spell_type = /datum/action/cooldown/spell/vampire_decoy
	gain_desc = "Вы обрели способность становиться невидимым и создавать иллюзии-приманки."

/datum/vampire_passive/grant_spell/rally_thralls
	spell_type = /datum/action/cooldown/spell/aoe/vampire_rally_thralls
	gain_desc = "Вы обрели способность снимать все обездвиживающие эффекты с ближайших рабов."

/datum/vampire_passive/grant_spell/blood_bond
	spell_type = /datum/action/cooldown/spell/vampire_blood_bond
	gain_desc = "Вы обрели способность делить урон между собой и рабами."

/datum/vampire_passive/grant_spell/hysteria
	spell_type = /datum/action/cooldown/spell/aoe/vampire_hysteria
	gain_desc = "Вы обрели способность после краткого ослепления заставлять всех поблизости видеть друг друга случайными животными."

/datum/vampire_passive/grant_spell/raise_vampires
	spell_type = /datum/action/cooldown/spell/aoe/vampire_raise_vampires
	gain_desc = "Вы обрели способность поднимать вампиров. Эта чрезвычайно мощная способность по области действует на всех людей рядом: вампиры и рабы исцеляются, трупы становятся вампирами, остальные оглушаются, получают повреждения мозга и погибают."
