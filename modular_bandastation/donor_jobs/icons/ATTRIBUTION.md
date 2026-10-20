# Donor job assets

The retained pixels are from [Paradise-SS220 revision 71c8bb1b88e29c352875865b362a1f8a99a205cc](https://github.com/ss220club/Paradise-SS220/tree/71c8bb1b88e29c352875865b362a1f8a99a205cc). BandaStation commit 596ec374da3302b0391218d7536b4b32916979f1 is a historical snapshot before cleanup, not the import commit. Original contributors retain authorship.

These icons use [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/), as recorded in the [source README](https://github.com/ss220club/Paradise-SS220/blob/71c8bb1b88e29c352875865b362a1f8a99a205cc/README.md#license). Only the states below are retained; unrelated clothing, gun and trainee/HONK-squad HUD states have been removed. Frame pixels, directions and animation metadata are unchanged for clothing, guns and landmarks. The uniform state was renamed from security_clown_s to security_clown by the original BandaStation import. HUD glyphs retain their eight-by-eight pixels and move down eight pixels within the 32-by-32 frame to match TG's existing HUD crop and Orbit positioning.

| Local file | Original path | Local states (source names where different) |
| --- | --- | --- |
| seclown_uniform.dmi | modular_ss220/jobs/icons/clothing/uniforms.dmi | security_clown (source: security_clown_s) |
| seclown_uniform_worn.dmi | modular_ss220/jobs/icons/clothing/mob/uniform.dmi | security_clown (source: security_clown_s) |
| honk_rifle.dmi | modular_ss220/jobs/icons/custom_gun/custom_guns.dmi | honkrifle_security |
| honk_rifle_lefthand.dmi | modular_ss220/jobs/icons/custom_gun/mob/custom_guns_lefthand.dmi | honkrifle_security0–4 |
| honk_rifle_righthand.dmi | modular_ss220/jobs/icons/custom_gun/mob/custom_guns_righthand.dmi | honkrifle_security0–4 |
| job_hud.dmi | modular_ss220/jobs/icons/hud.dmi | 22 canonical donor roles; prisoner, deliverer, painter, apprentice, butler, maid |
| landmarks.dmi | modular_ss220/jobs/icons/landmarks.dmi | prisoner, prisoner_arrive, bath, dealer, uncertain, barber, vip, art, bar |
| id_trims.dmi | modular_ss220/aesthetics/better_ids/icons/better_ids.dmi | 27 source donor/variant face badges adapted to native advanced-card trims; no Prisoner override |

ID badges retain the 60 visible pixels within the source `(4,12)-(12,20)` crop, remove its four card-background corners and move to `(7,12)` on a transparent 32x32 frame. Native `department` and `subdepartment` frames are reused from `icons/obj/card.dmi` without pixel changes. The full Paradise card face and its renderer are not imported. Source missing-state references `deliverer` and `cleaningmanager` use the existing `courier` and `managerjanitor` badges respectively. The native card base, assigned-name overlay, access and account handling remain unchanged.


## TSF and USSP clothing

The same pinned source and CC BY-SA 3.0 attribution apply to the faction clothing below. Five existing BS TSF uniforms are reused with their inventory/worn artwork, native female mask and carry renderer; near-identical imported states and their duplicate types are removed. The USSP sidecap reuses BS's exact `ussp_pilotka` inventory state while retaining its distinct source worn state. Original worn cap spelling `solgovcselitesoft` is normalized to `solgovcelitesoft`; retained source pixels and frame metadata are unchanged. Only states consumed by native clothing types are included.

| Local file | Original path | Local states (source names where different) |
| --- | --- | --- |
| tsf_uniforms.dmi | icons/obj/clothing/under/centcom.dmi | navy_gold |
| tsf_uniforms_worn.dmi | icons/mob/clothing/under/centcom.dmi | navy_gold (source: navy_gold_s) |
| tsf_hats.dmi | icons/obj/clothing/hats.dmi | solgovsoft, solgovsoft_flipped, solgovcsoft, solgovcsoft_flipped, solgovelitesoft, solgovelitesoft_flipped, solgovcelitesoft, solgovcelitesoft_flipped, solgovcberet, solgovceliteberet, hardsuit0-solgovmarine, hardsuit0-solgovcommand |
| tsf_hats_worn.dmi | icons/mob/clothing/head.dmi | solgovsoft, solgovsoft_flipped, solgovcsoft, solgovcsoft_flipped, solgovelitesoft, solgovelitesoft_flipped, solgovcelitesoft, solgovcelitesoft_flipped, solgovcberet, solgovceliteberet, hardsuit0-solgovmarine, hardsuit0-solgovcommand |
| tsf_suits.dmi | icons/obj/clothing/suits.dmi | solgovcommander, ert_solgov_marine, ert_solgov_command |
| tsf_suits_worn.dmi | icons/mob/clothing/suit.dmi | solgovcommander, ert_solgov_marine, ert_solgov_command |
| tsf_uniforms_lefthand.dmi | icons/mob/inhands/clothing_lefthand.dmi | navy_gold |
| tsf_uniforms_righthand.dmi | icons/mob/inhands/clothing_righthand.dmi | navy_gold |
| ussp_uniforms.dmi | icons/obj/clothing/under/ussp.dmi | soviet, sovietofficer, sovietadmiral |
| ussp_uniforms_worn.dmi | icons/mob/clothing/under/ussp.dmi | soviet (source: soviet_s), sovietofficer (source: sovietofficer_s), sovietadmiral (source: sovietadmiral_s) |
| ussp_hats.dmi | icons/obj/clothing/hats.dmi | sovietofficerhat, sovietadmiralhat, hardsuit0-soviet, hardsuit0-soviet-commander |
| ussp_hats_worn.dmi | icons/mob/clothing/head.dmi | sovietsidecap, sovietofficerhat, sovietadmiralhat, hardsuit0-soviet, hardsuit0-soviet-commander |
| ussp_suits.dmi | icons/obj/clothing/suits.dmi | sovietcoat, sovietofficercoat, hardsuit-soviet, hardsuit-soviet-commander |
| ussp_suits_worn.dmi | icons/mob/clothing/suit.dmi | sovietcoat, sovietofficercoat, hardsuit-soviet, hardsuit-soviet-commander |
| ussp_suits_lefthand.dmi | icons/mob/inhands/clothing_lefthand.dmi | hardsuit-soviet, hardsuit-soviet-commander |
| ussp_suits_righthand.dmi | icons/mob/inhands/clothing_righthand.dmi | hardsuit-soviet, hardsuit-soviet-commander |

`tsf_map_icons.dmi` contains the native BS zip-up hoodie preview generated by `hoodie_zipup` GAGS in the source outfit's `#02519a` palette. It keeps the mapper preview inside this module; runtime inventory/worn/hood behaviour continues to use the existing native hoodie and GAGS assets.
