# GURREN LAGANN → «Голден-Гардрен»: аудит исходников (этап 1)

База: `SpaceStation220/Primera`, ветка `master`, коммит `2bd17f92`. Форк: `ZloyPe4eneg/primera`, рабочая ветка `golden-gardren`.
Исходный код на этом этапе не менялся. Все пути, типы и процедуры ниже найдены в текущем дереве.

Соответствие названий ТЗ и проекта:

| ТЗ | Проект | Роль |
| --- | --- | --- |
| GURREN | **Голден** (`golden`) | пилот №1: движение, руки, ближний бой |
| LAGANN | **Гардрен** (`gardren`) | пилот №2: щиты, тяжёлое оружие |
| GURREN LAGANN | **Голден-Гардрен** (`golden_gardren`) | объединённая машина 2×2 |

---

## 1. Краткие выводы

1. **Двухпилотная архитектура есть и подходит.** Savana — это `/obj/vehicle/sealed/mecha/savannah_ivanov`. Права раздаются флагами `VEHICLE_CONTROL_*` на сервере, кнопки действий выдаются по флагу. Это закрывает требование ТЗ «проверки только на сервере».
2. **Базовый обработчик клика не допускает места «только ближний бой».** `/obj/vehicle/sealed/mecha/proc/on_mouseclick` прерывается с сообщением «wrong seat for equipment!», если у пилота нет `VEHICLE_CONTROL_EQUIPMENT`, ещё до проверки ближнего боя. Для пилота №1 нужен override в нашем типе.
3. **Многотайловое перемещение в ядре BandaStation уже доработано.** Это правки `BANDASTATION EDIT` в `/atom/movable/proc/doMove` и в `/turf/open/Entered`, плюс юнит-тест `movement_order_sanity` на объект 2×2. Мехов размером 2×2 в коде нет. Смежность, урон по «чужим» тайлам и катапультирование придётся доделать в нашем типе.
4. **TGUI меха не проверяет роли.** В `/obj/vehicle/sealed/mecha/ui_act` любой человек внутри может снять оборудование, сменить доступ и т.д. Нужен override с проверкой роли.
5. **Принудительный выброс при уничтожении уже есть,** но он высаживает пилотов на тайл якоря без проверки безопасности. Подходящая проверка есть в проекте: `is_safe_turf()`.
6. **Щит Durand нельзя переиспользовать напрямую:** `/obj/durand_shield` жёстко типизирован на `/obj/vehicle/sealed/mecha/durand`. Переиспользуем его схему, но пишем своё.
7. **Админ-спавн писать не нужно.** Штатный `ADMIN_VERB(spawn_atom, …, "Spawn", …)` в `code/modules/admin/admin.dm` создаёт любой тип по пути.

---

## 2. Savana (`code/modules/vehicles/mecha/combat/savannah_ivanov.dm`)

**Тип:** `/obj/vehicle/sealed/mecha/savannah_ivanov`.
- `max_occupants = 2`, `max_drivers` = 1 (по умолчанию, `code/modules/vehicles/_vehicle.dm`).
- `mech_type = EXOSUIT_MODULE_SAVANNAH`; спрайт `icons/mob/rideables/coop_mech.dmi`, кадр 32×40, то есть физически 1 тайл.

**Распределение ролей** (`auto_assign_occupant_flags`):
- первый вошедший получает `VEHICLE_CONTROL_DRIVE | VEHICLE_CONTROL_SETTINGS`;
- второй получает `VEHICLE_CONTROL_MELEE | VEHICLE_CONTROL_EQUIPMENT`.

Это не совпадает с ТЗ: у нас ближний бой принадлежит водителю.

**Действия** (`generate_actions`):
- `initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/swap_seat)`;
- `initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/skyfall, VEHICLE_CONTROL_DRIVE)`;
- `initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/ivanov_strike, VEHICLE_CONTROL_EQUIPMENT)`.

**Спрайт по состоянию экипажа** (`get_mecha_occupancy_state`) строится как `"[base_icon_state]_[leap_][gunner]_[driver]"`. Нам подходит та же схема: `golden_gardren_<p2>_<p1>`.

**Что можно переиспользовать безопасно:**

| Что | Как |
| --- | --- |
| Схема `auto_assign_occupant_flags` + `generate_actions` по флагам | Копируем подход, флаги свои |
| `/datum/action/vehicle/sealed/mecha/ivanov_strike` | Обобщённое действие (`chassis` любого меха, кулдаун `COOLDOWN_MECHA_MISSILE_STRIKE`). Подходит как спецатака пилота №2 без изменений |
| `get_mecha_occupancy_state` | Та же схема имён состояний |

**Что нельзя переиспользовать:**
- `/datum/action/vehicle/sealed/mecha/swap_seat` (`mecha_actions.dm`, строки 127–159) жёстко прописывает флаги Savana. С нашими ролями он раздаст неверные права. Смену мест либо не даём, либо пишем своё действие.
- `skyfall` — механика прыжка, к ТЗ не относится.

---

## 3. Базовые классы мехов и экипаж

| Файл | Что важно |
| --- | --- |
| `code/modules/vehicles/_vehicle.dm` | `/obj/vehicle`: `occupants` (assoc mob → флаги), `add_occupant`, `remove_occupant` (`SHOULD_CALL_PARENT`), `add_control_flags`/`remove_control_flags` выдают и отбирают кнопки по флагу, `return_controllers_with_flag`, `is_driver` |
| `code/modules/vehicles/sealed.dm` | `/obj/vehicle/sealed`: `mob_try_enter`, `enter_checks`, `mob_enter`, `mob_exit`, `exit_location` (по умолчанию `drop_location()`), `dump_mobs` (выброс + `Paralyze(40)`), `Destroy()` → `dump_mobs()` |
| `code/modules/vehicles/vehicle_actions.dm` | `initialize_passenger_action_type`, `initialize_controller_action_type`, `grant_controller_actions_by_flag` |
| `code/modules/vehicles/mecha/_mecha.dm` | `/obj/vehicle/sealed/mecha`; см. ниже |
| `code/modules/vehicles/mecha/mecha_mob_interaction.dm` | `mob_try_enter` (только `ishuman`), `enter_checks`, `moved_inside`, `mob_exit(M, silent, randomstep, forced)`, `add_occupant`/`remove_occupant` (регистрация сигналов клика), `container_resist_act` (обычный выход с `exit_delay`) |
| `code/modules/vehicles/mecha/mecha_movement.dm` | `relaymove` (только водители), `vehicle_move`, `can_move` (энергия на шаг), `Bump`/`try_bumpsmash` |
| `code/modules/vehicles/mecha/mecha_actions.dm` | `mech_eject`, `mech_view_stats`, `mech_toggle_safeties`, `strafe`, `swap_seat`, `equipment` |

**Ключевые процедуры `_mecha.dm`:**
- `auto_assign_occupant_flags`: по умолчанию `FULL_MECHA_CONTROL` первому вошедшему.
- `generate_actions`: `mech_eject` получают все, остальное выдаётся по флагам `SETTINGS`/`DRIVE`.
- `generate_equipment_actions` / `on_equipment_attach`: кнопки оборудования получают **все владельцы `VEHICLE_CONTROL_SETTINGS`**. Для нас это значит фильтровать по роли, иначе пилот №1 получит кнопки оружия пилота №2.
- `on_mouseclick` (строки ~675–722): ЛКМ — `MECHA_L_ARM`, ПКМ — `MECHA_R_ARM`, ближний бой через `target.mech_melee_attack(src, user)`. Проблема с порядком проверок описана в п. 1.2.
- `atom_destruction` (`mecha_defense.dm`): каждый пилот выходит через `mob_exit(…, forced = TRUE)` и получает `SetSleeping(destruction_sleep_duration)`; создаётся `wreckage`, оборудование с шансом 30% уходит в обломки.
- `Destroy`: выбрасывает всех мобов из `contents | occupants`, то есть удаление админом пилотов не убивает.

**Флаги ролей** (`code/__DEFINES/vehicles.dm`): `VEHICLE_CONTROL_DRIVE`, `_KIDNAPPED`, `_MELEE`, `_EQUIPMENT`, `_SETTINGS`, `FULL_MECHA_CONTROL = ALL`.

---

## 4. Multitile (размер 2×2)

**Что есть:**
- `bound_width`/`bound_height` и макрос `is_multi_tile_object()` (`code/__DEFINES/is_helpers.dm`).
- `/atom/movable/proc/doMove` (`code/game/atoms_movable.dm`, ~1208–1265): правки BandaStation корректно считают старый и новый «след» объекта и вызывают `Entered`/`Exited` для каждого тайла.
- `/turf/open/Entered` и `transfer_occupant` (`code/game/turfs/open/_open.dm`): переход между z-уровнями для крупных объектов.
- Юнит-тест `code/modules/unit_tests/movement_order_sanity.dm` прогоняет объект `ICON_SIZE_X * 2` (2×2) в обычном и принудительном движении.
- Подвижных многотайловых объектов в игре нет: всё с `bound_width = 64` неподвижно (ворота, двигатели шаттлов, стенды, двери трамвая).

**Чего нет и что придётся решать в нашем типе:**

| Проблема | Где | Решение |
| --- | --- | --- |
| Смежность считается только от тайла-якоря | `/atom/movable/Adjacent` (`code/_onclick/adjacent.dm:68`) смотрит только `loc` | Override `Adjacent()` в `golden_gardren` с перебором `locs` |
| «Перед» меха и направление атаки | `on_mouseclick` → `get_dir(src, target)` от якоря (левый нижний тайл) | Флаг `OMNIDIRECTIONAL_ATTACKS` или расчёт от центра |
| Высадка внутрь меха | `mob_exit` ставит моба на `get_turf(src)`, это тайл под мехом | Свой выбор тайла по периметру (см. п. 9) |
| Снаряды и взрывы по «не якорным» тайлам | `/obj/projectile/proc/select_target` перебирает содержимое тайла; `/turf/contents_explosion` тоже. Попадает ли мех, зависит от того, числит ли BYOND многотайловый объект в `contents` всех тайлов | **CHECK:** юнит-тест в CI на этапе 3. Риски — промахи по 3 из 4 тайлов либо **четырёхкратный** урон от одного взрыва |
| Двери | Шлюзы 1 тайл шириной; мех 2×2 через них не пройдёт | Ограничение геймплея: машина для ивентов на открытых пространствах. Решение за тобой |
| Поворот | Квадратный «след» при повороте не меняется | Проблемы нет |
| Спрайт | Кадр 64×64 с привязкой к левому нижнему углу совпадает с bounds без смещения | Проблемы нет |

**Вывод:** настоящий 2×2 реализуем без правки ядра, перекрытиями в нашем типе. Поведение снарядов и взрывов нужно доказать тестом до того, как строить на нём остальное.

---

## 5. Урон и энергия

- `take_damage` / `run_atom_armor` (`mecha_defense.dm`): урон зависит от стороны удара (`facing_modifiers`: перед 0.5, бок 1, тыл 1.5), есть `try_deal_internal_damage`, урон по оборудованию через `try_damage_component`.
- Броня задаётся через `/datum/armor/...` (пример: `/datum/armor/mecha_savannah_ivanov`).
- Энергия: один `cell` на мех; `use_energy`, `has_charge`, расход на шаг (`step_energy_drain`) и на удар (`melee_energy_drain`).
- Юнит-тест `mecha_damage.dm` проверяет урон на `marauder/mauler/loaded`, наши типы не затрагивает.

**Для щитов** самый простой и полный перехват — override `take_damage` в объединённом мехе. Через него проходят все источники урона, тогда как Durand перехватывает пять разных процедур. Щит берёт урон из своего запаса, остаток идёт в корпус.

---

## 6. Оружие и оборудование

- База: `/obj/item/mecha_parts/mecha_equipment` (`code/modules/vehicles/mecha/equipment/mecha_equipment.dm`). Важные части: `equipment_slot`, `range` (`MECHA_MELEE`/`MECHA_RANGED`), `mech_flags`, `action()`, `action_checks()`, `attach()`/`detach()`, `can_attach()`.
- Слоты: `MECHA_L_ARM`, `MECHA_R_ARM`, `MECHA_UTILITY`, `MECHA_POWER`, `MECHA_ARMOR` (`code/__DEFINES/mecha.dm`). Оружие (`MECHA_WEAPON`) встаёт только в руки.
- Совместимость: `default_can_attach` проверяет `mech_flags & mech.mech_type`. **Рекомендация:** выставить нашим мехам `mech_type = EXOSUIT_MODULE_SAVANNAH`. Боевое оборудование входит в `EXOSUIT_MODULE_COMBAT`, а новый бит пришлось бы вносить в `code/__DEFINES/exosuit_fab.dm`, то есть править ядро.
- Предустановка: `equip_by_category` в типе. В `Initialize` предметы ставятся через `attach()` в обход `can_attach`; так сделаны `marauder/loaded/ert` и `gygax/loaded` в `modular_bandastation/objects/code/mecha/mecha.dm`.
- Кулаки встроены в базу: `/mob/living/mech_melee_attack` (`mech_melee_attack.dm`) зависит от `force`. При `force > 35` срабатывает тяжёлый эффект `melee_attack_effect(heavy = TRUE)`, плюс `step_away` и проверка блока.

**Готовое оружие под варианты из обсуждения:**

| Назначение | Тип |
| --- | --- |
| Тяжёлый лазер | `/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy` |
| Ракеты | `.../weapon/ballistic/missile_rack`, `.../missile_rack/breaching` |
| Пулемёт | `.../weapon/ballistic/lmg` |
| Нелетальное | `.../weapon/energy/disabler`, `.../ballistic/launcher/flashbang`, `.../weapon/energy/ion` |
| Индустриальное | `.../weapon/energy/plasma`, `/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp`, `.../rcd`, `.../extinguisher`, `.../gravcatapult` |
| Захват | `.../weapon/paddy_claw` |

**Схема управления оружием, которая ложится на базу без правок ядра:**
- **Пилот №2** (`EQUIPMENT`): ЛКМ/ПКМ стреляют оружием в `MECHA_L_ARM`/`MECHA_R_ARM`. Выбор активного оружия — это выбор кнопки мыши. Третье оружие (ракетный удар) — действие `ivanov_strike`.
- **Пилот №1** (`DRIVE | MELEE`): кулаки через `force` и спецприёмы ближнего боя (таран и т.п.) как действия меха. Нужен override `on_mouseclick`: если у пилота есть `MELEE` без `EQUIPMENT`, сразу идти в ветку ближнего боя. Остальное отдаётся в `..()`.

---

## 7. TGUI

- DM-сторона: `code/modules/vehicles/mecha/mecha_ui.dm`.
  - `ui_interact` открывает интерфейс `"Mecha"`.
  - `ui_status` проверяет только «внутри / руки свободны / живой».
  - `ui_data(mob/user)` уже получает пользователя, поэтому роль можно передать в данные.
  - `ui_act` без проверки ролей: `equip_act` → `gear.ui_act` (включая `detach`), доступы, DNA-замок, имя, безопасность.
- Фронтенд: `tgui/packages/tgui/interfaces/Mecha/` (`index.tsx`, `ModulesPane.tsx`, `AlertPane.tsx`, `data.ts`).
- Открывает окно действие `mech_view_stats`, его получают владельцы `VEHICLE_CONTROL_SETTINGS`.

**Рекомендация:**
1. Override `ui_act` в наших типах: белый список действий для каждой роли. Это обязательно и закрывает требование ТЗ.
2. Добавить роль в `ui_data`.
3. Для двух интерфейсов ТЗ сделать отдельный компактный TGUI-интерфейс кабины (щиты, оружие, боезапас, аварийный выброс у пилота №2; движение, руки, состояние у пилота №1). Общий `Mecha` не трогать: правило проекта — не заменять интерфейс целиком ради дополнения.

---

## 8. Административный спавн

- `ADMIN_VERB(spawn_atom, R_SPAWN, "Spawn", …)` и `ADMIN_VERB(spawn_atom_pod, …, "PodSpawn", …)` (`code/modules/admin/admin.dm`) создают любой тип по пути. Мехи будут доступны как `/obj/vehicle/sealed/mecha/golden`, `/gardren`, `/golden_gardren`.
- В мехфабрикатор и техно-дерево ничего не добавляем, как требует п. 11 ТЗ.

---

## 9. Катапультирование и выход

**Что есть:**
- Обычный выход: `container_resist_act` → `do_after(exit_delay)` → `mob_exit`. Действие `mech_eject` есть у всех пассажиров.
- Выброс при уничтожении: `atom_destruction` → `mob_exit(forced = TRUE)` + `SetSleeping`.
- Сброс всех: `/obj/vehicle/sealed/proc/dump_mobs` (бросок на случайный соседний тайл + `Paralyze(40)`).
- Проверка безопасного тайла: `/proc/is_safe_turf(turf, extended_safety_checks, dense_atoms, no_teleport)` (`code/datums/helper_datums/teleport.dm:174`). Проверяет пол, газы, температуру, давление, лаву (при `extended_safety_checks`) и плотные объекты.
- В модуле космоподов (`modular_bandastation/spacepods/`) есть свои `eject_pilot`/`exit_pod` с повторной проверкой состояния после `do_after`. Безопасных тайлов там нет, но там хорошо оформлена проверка «после ожидания всё ещё внутри».

**Чего нет:** выбора безопасного тайла, предупреждений при критическом уроне, задержки аварийного выброса, отдельной команды EMERGENCY EJECT.

**План для нашего типа:**
1. Перебрать кольцо тайлов вокруг «следа» меха (для 2×2 это 12 тайлов).
2. Сначала искать `is_safe_turf(T, extended_safety_checks = TRUE)` и не плотный тайл.
3. Если такого нет, взять любой не плотный открытый тайл.
4. Если нет и его, отдать штатному `mob_exit` (тайл меха). Это и есть «резервный механизм проекта».

Телепортов не добавляем.

---

## 10. Модульная структура и проверки

- Новые фичи кладутся в модпак: `modular_bandastation/<module>/_<module>.dme` + `_<module>.dm` (`/datum/modpack/...`) + `code/`. Подключение — строкой в `modular_bandastation/modular_bandastation.dme`. Образец: `modular_bandastation/example/`.
- Юнит-тесты модпаков подключаются строкой `#include "../../../modular_bandastation/..."` в `code/modules/unit_tests/_unit_tests.dm`; так сделаны тесты IPC и вокса.
- **Тесты, которые затронут наши типы автоматически:**
  - `create_and_destroy`: каждый тип создаётся и удаляется. Нельзя оставлять ссылки и рантаймы.
  - `missing_icons` / `icon_state`: каждое `icon_state` должно существовать в DMI. Временные спрайты обязаны иметь все состояния.
- Русские имена: `modular_bandastation/translations/public/ru_names/*.toml`. Сгенерированный `ru_names.toml` руками не правится.
- Стиль: `.github/guides/STYLE.md`, `STANDARDS.md`, `AUTODOC.md`. Без комментариев `SS220 EDIT`/`BANDASTATION EDIT` в новых правках (`.AGENTS/WORKFLOW_RULES.md`).
- Сборка: `BUILD.cmd` → `tools/build/build.bat`. CI: `.github/workflows/ci_suite.yml` запускается на `pull_request` в `master`. Версия BYOND: `516.1685` (`dependencies.sh`).

---

## 11. Архитектурные рекомендации

1. **Модпак `modular_bandastation/golden_gardren/`.** Ядро не трогаем, кроме двух строк include (модпак и тесты).
2. **Три типа от общего предка:**
   - `/obj/vehicle/sealed/mecha/golden` — 1×1, один пилот, роль №1;
   - `/obj/vehicle/sealed/mecha/gardren` — 1×1, один пилот, роль №2;
   - `/obj/vehicle/sealed/mecha/golden_gardren` — 2×2 (`bound_width = bound_height = 64`), `max_occupants = 2`, свои `auto_assign_occupant_flags`, `generate_actions`, `on_mouseclick`, `ui_act`, `Adjacent`, `take_damage`, `atom_destruction`, `exit_location`.
3. **Объединение «стыковкой», без пересоздания.** Голден и Гардрен уходят внутрь объединённого меха как отключённые объекты (`completely_disabled`, `STOP_PROCESSING`) и возвращаются при разделении. Это гарантирует:
   - никакого дублирования объектов, оборудования и ячеек;
   - откат при ошибке, потому что исходники не удаляются;
   - при уничтожении одного компонента нельзя получить его бесплатно, потому что новый не создаётся.
   Порядок транзакции:
   1. Проверить условия.
   2. Подтверждение от обоих пилотов (`tgui_alert` с таймаутом).
   3. **Повторная проверка после ожидания.**
   4. Блокировка.
   5. Создание 2×2 с проверкой места.
   6. Перенос пилотов: `remove_occupant` → `forceMove` → `add_occupant`.
   7. Стыковка компонентов.
   При ошибке на любом шаге — откат.
4. **Общее здоровье:** `max_integrity` = сумма максимумов компонентов, текущее = сумма текущих. При разделении урон делится пропорционально максимумам.
5. **Общая энергия и щиты:** `cell` Голдена питает машину, `cell` Гардрена становится отдельным запасом щита. Так получается «собственный запас энергии щита» из ТЗ без нового предмета.
6. **Роли:**
   - Пилот №1: `DRIVE | MELEE | SETTINGS`, где кнопки оборудования отфильтрованы по роли.
   - Пилот №2: `EQUIPMENT`, плюс отдельные действия: щит, `ivanov_strike`, EMERGENCY EJECT.
   - Смена мест не даётся.
   - Если пилот №2 выбыл, щиты и тяжёлое оружие отключаются автоматически: кнопки уходят вместе с флагами, клики без `EQUIPMENT` отклоняются базой. Если выбыл пилот №1, движение блокирует `relaymove` (только водители), ближний бой блокирует наш `on_mouseclick`.

---

## 12. Последовательность реализации

| Этап | Содержание | Проверка |
| --- | --- | --- |
| 2 | Модпак; Голден и Гардрен (1×1, временные спрайты, обломки, роли одиночек); спавн через `Spawn` | CI: компиляция, `create_and_destroy`, `missing_icons` |
| 3 | Тип 2×2, `Adjacent`, высадка по периметру; **юнит-тест «след 2×2, снаряд по дальнему тайлу, число вызовов `ex_act` от взрыва»**; объединение | CI + твой ручной тест |
| 4 | Роли, `on_mouseclick`, `ui_act` с белым списком, действия, компактный TGUI кабины | CI + тест вдвоём |
| 5 | Кулаки, спецатака пилота №1, оружие пилота №2 по выбранной версии, щиты с восстановлением и кулдауном | CI + тест вдвоём |
| 6 | Предупреждения, EMERGENCY EJECT с задержкой, безопасная высадка, обработка смерти и выхода одного пилота | Ручные сценарии из п. 9 ТЗ |
| 7 | Разделение: возврат компонентов, урон, проверка места | CI + ручной |
| 8 | Полный прогон аварийных сценариев | Тест вдвоём |

---

## 13. Открытые вопросы

1. Версия вооружения (A «Штурмовой», B «Охранный», C «Индустриальный» или смесь).
2. Устраивает ли, что 2×2 не проходит через обычные шлюзы.
3. Где у разработчиков сервера принято хранить такие ивентовые мехи. По умолчанию — модпак.

## 14. Что не проверено

- Поведение снарядов и взрывов по многотайловому движущемуся объекту: только чтение кода, нужен тест в рантайме (этап 3).
- Компиляция не запускалась: на этапе 1 кода нет.
