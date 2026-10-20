# Граница PR11 с ядром

База сравнения — `820de7f6ef9235d8417250cb01eec15da6735b18`. Проверяется весь diff PR, независимо от коммита. Штатные определения и порядок операций сохраняются. Новая политика живёт в `modular_bandastation/`: допустимый штатный маршрут проходит настоящего родителя, модуль дополняет результат/состояние либо отклоняет запрос до побочных эффектов. Исключения forced Dynamic и no-yield capacity описаны отдельно ниже. Внутри native процедуры допустим узкий адаптер входного значения либо проверка в момент, недоступный внешнему override.

Предыдущее правило об удалении исходных реализаций ради единственной последовательности отменено. Нельзя переносить штатный алгоритм в модуль, оставлять обрезанную прелюдию или скрывать исходник за безусловным ранним переходом. `. = ..()` не отменяет уже выполненных побочных эффектов; проверки допуска выполняются до назначения, переноса mind и экипировки. `JOB_AVAILABLE` равен нулю, поэтому результат сравнивается с кодом явно.

## Исполняемые маршруты

- **Допуск.** Native `check_job_eligibility` сохраняет mind/account/playtime/ban/age проверки. Модульный wrapper вызывает его один раз, проверяет прежнего requester/mind и правила профиля. В native age-ветку передаётся возраст выбранного профиля. После SQL нельзя обращаться к удалённому lobby/client.
- **Назначение.** Native `assign_role` перед изменением вакансии вызывает `prepare_job_assignment`: окончательные профиль, gate, вместимость и активный latejoin request. Добавленная поддержка `Spawn Debug Full Crew` снята: его lobby без клиента получает отказ назначения; штатная команда не изменена. Отсутствие клиента не даёт обхода обычному игроку.
- **Случайное назначение.** Native `give_random_job` сохраняет прежний `check_job_eligibility` и его `continue`. Отдельный следующий `if/continue` вызывает модульную проверку текущего explicit opt-in; она не выполняет SQL и не заменяет исходный допуск.
- **Приветствие.** Native `set_assigned_role_with_greeting`, `get_spawn_message` и `get_spawn_message_information` полностью сохранены. Модуль вызывает `. = ..()` и затем отправляет только дополнительные инструкции отдельным блоком, учитывая фактическое тело и выбранный вариант. Штатное назначение, форматирование и сообщение не копируются.
- **Создание.** Модульный `create_character` фиксирует и загружает профиль, затем вызывает родителя с выбранным forced slot и единым `job_character_creation`. Снимок захватывает точные mind/job/selection в модуле. Native сохраняет место constructor-фазы и вызывает `creation.create_body`: контекст ровно один раз вызывает исходный виртуальный `job.get_spawn_mob` и проверяет тело до возврата. Это необходимо при hard-delete lobby: BYOND прекращает исполняющиеся процедуры удалённого объекта, поэтому проверка после возврата в lobby уже не выполняется. Независимый frame завершает owned cleanup; специализированные constructors сохраняют virtual dispatch. Профиль, mind transfer, original slot и запись истории не перенесены из своих штатных фаз. Контекст переживает удаление selection/lobby и освобождается валидатором; native не содержит трёх локальных snapshot-присваиваний. Native AI constructor уже перемещает mind; rollback возвращает только захваченный mind из собственного тела. Семантика удаления — [DM Reference, del](https://www.byond.com/docs/ref/#/proc/del); отдельно подтверждена коротким DM probe и public-entry регрессией.
- **Поздний вход.** `AttemptLateSpawn` сохраняет штатные alerts, arrivals/RequireUndocked, очередь, назначение, телеметрию, создание, handover, экипировку и callbacks. Wrapper владеет typed request и блокировкой повторного запуска. Внутренние проверки после ожидания не выполняют второй SQL. Перед исходным CRASH компенсируется только своё назначение; лишь зафиксированный отказ допуска считается ожидаемым результатом.
- **Меню.** Native `ui_act` сохраняет авторизацию, switch и всю ветку `select_job`, включая round/load/queue/species checks. Модуль адаптирует источник species и выбранный профиль; исходные методы не удаляются. `fallback_ui` полностью совпадает с базой: обычный title screen открывает TGUI, а штатный builder старой кнопки fallback закомментирован. Random сохраняет native цикл и modal; внутренние guards защищают продолжение после ожиданий, а окончательный explicit opt-in проверяется модульным `get_random_job` после `. = ..()` до использования результата caller.
- **Preferences.** Native action map, handler и построение DTO восстановлены. После родителя модуль копирует карту экземпляра, отключает старую делегацию, преобразует полученные строки DTO. Прямой вызов прежнего handler отклоняется. Сохранённое `job_assigned_profiles` остаётся пустым совместимым полем, не вторым хранилищем и не ссылкой на `pref_job_slots`.
- **I/O.** Native read/sanitize/write сохранены. После legacy read, до возможного вложенного save, `load_job_profile_assignments` объединяет корректные legacy и canonical назначения в единственную `pref_job_slots` и очищает compatibility field. Явное canonical значение имеет приоритет, включая `0` и `-1`; неизвестные профессии и временно недоступные слоты сохраняются. `write_job_profile_assignments` подготавливает результат до единственного native flush. При повреждённом формате отдельный error-only снимок сохраняет оба исходных entries и их наличие при любых последующих saves; set/reset назначений отклоняются, остальные настройки работают. Это не второе runtime-хранилище назначений.
- **Prisoner.** Native `New`, global handler и `post_equip` восстановлены. Модуль после родителя снимает свою старую подписку и вызывает настоящий handler с сохранённым преступлением и точной первоначальной записью manifest. Native выполняет crime/memory/photo/tattoos один раз; нет вызова далёкого предка и копии алгоритма.
- **Экипировка.** Native outfit сохраняет исходную storage-операцию с `del_on_fail`. Только outfit с `preserve_backpack_supplies` обрабатывает предмет в модуле и сообщает handled; при переполнении он остаётся у персонажа или рядом. Shared variants меняют источник outfit, а не цикл экипировки.
- **Цвет.** Native auth/signal/switch и color modal сохранены. Две локальные проверки фиксируют editing slot до ожидания и проверяют пользователя/preferences/slot после него. Helper не содержит второй реализации modal.

## Состояние и отмена

`latejoin_profile_snapshot` хранит requester/mind, preferences identity, editing slot, копию назначений и toggle. Меню сравнивает всю карту, попытка — выбранную профессию. Это снимок маршрутизации, а не заморозка всех полей профиля. Состояние не хранится в singleton меню, global job datums или временно подменённых preferences.

Отмена требует совпадения selection, mind и конкретного созданного тела. Она освобождает свою вакансию и свою добавку native history; предшествующая история и чужое назначение сохраняются. После успешного handover созданное тело сохраняется при отключении клиента.

Roundstart захватывает selection до native создания тела. Для ручного назначения без подготовленного selection используется тот же синхронный resolver; удалённый или заменённый selection лишает старую попытку права отменять назначение.

Dynamic сохраняет обе inline native операции `prepare_for_role` и добавление blacklist. Две инъекции снимают состояние до/после них. `roundstart_job_changes` хранит только добавленные блокировки и изменение forced job; отмена сохраняет предшествующие и независимые последующие изменения. Native queued-selection veto действует для того же mind. Произвольное перекрытие одинаковых blacklist значений с обходом штатного выбора не объявляется reference counting.

Два узких исключения требуют отдельного внимания при upstream. Для Dynamic forced job `check_job_preferences` проверяет конкретное принудительное назначение до родителя: native ветка рассматривает только пустые обычные предпочтения и могла бы уже сбросить ready и отправить admin warning. Для остальных маршрутов вызывается настоящий родитель. Финальный `IsJobSlotUnavailable` повторяет небольшую capacity-политику native `IsJobUnavailable` без его SQL: дополнительный yielding вызов между окончательной проверкой и занятием вакансии был бы новой гонкой. При изменении upstream capacity правил нужно сверить оба участка; это осознанное дублирование условия, а не единственная общая реализация.

Общий цикл создания, handover и отмены находится в `jobs/code/player/character_creation.dm`; latejoin request, очередь и ограничения входа — в соседнем `latejoin_attempt.dm`. Подготовка variant context находится непосредственно в `prepare_spawn_character`, без forwarding helper. Outfit supplies расширяют исходную выдачу одним handled override. UI получает public title назначенного персонажа из того же profile DTO, без повторного выбора профиля в variants middleware.

## Владельцы

| Модуль | Ответственность |
| --- | --- |
| `jobs` | Допуск, lifecycle, initial record, Prisoner, нейтральные variants, outfit supplies и бесплатный Deliverer. |
| `job_slots_preferences` | Единственное хранилище назначений, загрузка профиля, snapshots и middleware. |
| `donor_jobs` | Subscription tiers/gate, собственные jobs, outfits/items, translations и ID templates. |
| `dynamic` | Допуск по назначенному профилю, отмена подготовки и фактический Blood Worm host. |
| `preferences`, `quirks`, `objects` | Проверки modal/handover и освобождение stale PDA reference. |

`tgstation.dme` → `modular_bandastation/modular_bandastation.dme` → module DME → реализации. Текстовый include graph не заменяет компиляцию. Общие fixes ID account, AI после name wait, nullable latejoin client и PDA/quirks действуют независимо от donor flags и обозначаются как предпосылки, а не скрываются за donor gate.

Canonical titles, ban keys, access, баланс, config tags и DMI states сохраняются. Внутренние typepaths и basenames уточнены; Security Clown outfit наследует clown. HONK cell сохраняется из-за отличий заряда/EMP от штатных типов. Все 129 прежних variant IDs переводятся при десериализации, см. [таблицу](../jobs/VARIANT_MIGRATION.md).

## Проверка

Для каждого оставшегося core-hunk ниже указываются назначение, владелец и причина внутренней инъекции. Полный diff `code/` проверяется, чтобы не переносить переработку из `code/modules/` в controllers/datums. Компиляция, внешние headless DM-регрессии, Python/Bun, TGUI/browser и настоящий игровой клиент — отдельные уровни доказательства.

Внешний regression bundle запускается в изолированном TEMP checkout и закрепляет исходники/hashes. Четыре сочетания donor flags проверяются независимо. Восстановление native определений и отключение старого runtime-протокола проверяются раздельно. Старые результаты сборки не переносятся на новый HEAD.

Production launcher/save root не подтверждены; реальные saves не изменяются. Корректный старый формат читается и переводится при первом native save без обязательной внешней миграции. [Offline migration/readiness](../../tools/migrate_job_slots/README.md) остаётся инструментом предварительной проверки, резервного копирования и массовой конверсии. Повреждённые данные требуют исправления оператором; runtime их не уничтожает. Headless проверки не доказывают подключение настоящего клиента, игровые modal или расстановку landmarks на DMM.

## Оставшиеся core-hunks

Позиции относятся к этому состоянию исходников; изменения аргумента учитываются как одна удалённая и одна добавленная строка. Полных удалений процедур и многострочных замен нет. Native middleware jobs полностью совпадает с базой.

| Core-hunk (текущая строка) | Владелец | Зачем нужна внутренняя точка |
| --- | --- | --- |
| `code/controllers/subsystem/dynamic/_dynamic_ruleset.dm:238` | dynamic | Снимки до/после inline prepare и blacklist. Wrapper prepare_for_role не видит последующее native добавление blacklist. |
| `code/controllers/subsystem/dynamic/_dynamic_ruleset.dm:241` | dynamic | Снимки до/после inline prepare и blacklist. Wrapper prepare_for_role не видит последующее native добавление blacklist. |
| `code/controllers/subsystem/dynamic/dynamic_ruleset_roundstart.dm:119` | dynamic | Адаптация species выбранного job profile до сохранённого trait check; wrapper после родителя не может отменить неверный native veto. |
| `code/controllers/subsystem/job.dm:250` | jobs / job_slots_preferences | Передача latejoin в штатный eligibility и окончательная подготовка до vacancy increment. Post-wrapper уже не предотвращает занятие вакансии. |
| `code/controllers/subsystem/job.dm:317` | jobs: random assignment | После сохранённого native eligibility if/continue отдельная инъекция проверяет только текущий explicit opt-in. Ни SQL, ни исходный допуск не заменяются. |
| `code/controllers/subsystem/job.dm:956` | jobs / job_slots_preferences | Контекст latejoin в сигнатуре нужен существующим внутренним age-check и вызовам selected-profile policy. |
| `code/controllers/subsystem/job.dm:980` | jobs / job_slots_preferences | После SQL lobby может быть удалён. Внутренний guard нужен до native чтения player.client. |
| `code/controllers/subsystem/job.dm:983` | jobs / job_slots_preferences | Проверка client после SQL и подстановка возраста выбранного профиля. Штатная age-ветка и код отказа сохраняются. |
| `code/controllers/subsystem/networks/id_access.dm:524` | jobs: ID templates prerequisite | Guard отсутствующего bank account в единственном native access алгоритме. Parent иначе обращается к null до возврата. |
| `code/controllers/subsystem/ticker.dm:468` | jobs / dynamic | Снимок selection/mind до создания и joined-list append. Внешний wrapper всего ticker не видит границу отдельного игрока. |
| `code/controllers/subsystem/ticker.dm:472` | jobs / dynamic | Освобождение снимка на штатном missing-destination continue; native ветка сохраняется. |
| `code/controllers/subsystem/ticker.dm:475` | jobs / dynamic | Проверка фактического тела и owned rollback сразу после constructor, до equip. Внешний post-wrapper слишком поздний. |
| `code/datums/outfit.dm:260` | jobs: outfit supplies | Handled hook перед сохранённой storage-операцией. Post-wrapper не возвращает удалённый del_on_fail предмет; весь цикл не копируется. |
| `code/datums/records/manifest.dm:21` | jobs: initial record | Первоначальная job-запись явно отмечается только в штатных spawn маршрутах; произвольный inject без подготовленного тела не запускает job effects. Повторы дополнительно защищены состоянием потребителя. |
| `code/datums/records/manifest.dm:106` | jobs: initial record | Первоначальная job-запись явно отмечается только в штатных spawn маршрутах; произвольный inject без подготовленного тела не запускает job effects. Повторы дополнительно защищены состоянием потребителя. |
| `code/datums/records/manifest.dm:141` | jobs: initial record | Ссылка на тот же единственный созданный record нужна callback; нового второго record нет. |
| `code/datums/records/manifest.dm:161` | jobs: initial record | Первоначальная job-запись явно отмечается только в штатных spawn маршрутах; произвольный inject без подготовленного тела не запускает job effects. Повторы дополнительно защищены состоянием потребителя. |
| `code/modules/client/preferences.dm:272` | preferences | Editing slot до modal и проверка контекста после ожидания, до write. Wrapper всей ui_act не может отменить уже записанный цвет. |
| `code/modules/client/preferences.dm:283` | preferences | Editing slot до modal и проверка контекста после ожидания, до write. Wrapper всей ui_act не может отменить уже записанный цвет. |
| `code/modules/client/preferences_savefile.dm:255` | job_slots_preferences | Конверсия legacy/canonical до вложенного keybindings save; повреждённые entries сохраняются. Post-wrapper уже опоздал бы к первому flush. |
| `code/modules/client/preferences_savefile.dm:350` | job_slots_preferences | Canonical запись или восстановление повреждённых entries после native set_entry и до единственного flush; parent I/O сохранён. |
| `code/modules/jobs/job_types/_job.dm:234` | jobs: variants / AI prerequisite | Модуль выбирает outfit до единственного native equip_outfit_and_loadout. Post-wrapper не отменит уже выданные вещи. |
| `code/modules/jobs/job_types/_job.dm:521` | jobs: variants / AI prerequisite | Захват lobby/mind до AI constructor, который сам переносит mind и может ждать. Внешний wrapper не видит локальное тело. |
| `code/modules/jobs/job_types/_job.dm:533` | jobs: variants / AI prerequisite | Возврат только захваченного AI mind до native qdel отклонённого тела; после родителя восстановление было бы поздним. |
| `code/modules/jobs/job_types/_job.dm:611` | jobs: variants / AI prerequisite | Client guard после yielding name lookup до native preference reads; алгоритм AI preferences сохранён. |
| `code/modules/jobs/job_types/_job.dm:658` | jobs: variants / AI prerequisite | Nullable client после spawn signal; штатные signal и overlay не копируются в модуль. |
| `code/modules/jobs/job_types/prisoner.dm:38` | jobs: Prisoner | Источник crime_name — сохранённое преступление этого тела; native handler продолжает memory/photo effects. |
| `code/modules/jobs/job_types/prisoner.dm:48` | jobs: Prisoner | Точная initial manifest record заменяет только local lookup result. Внешний wrapper не видит local target_record. |
| `code/modules/jobs/job_types/prisoner.dm:77` | jobs: Prisoner | Источник equipment crime синхронизирован с телом и once-only effects до native tattoo/equip; родитель выполняется. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:9` | jobs: latejoin UI | Подстановка species назначенного профиля без load; штатные config/trait проверки выполняются дальше. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:66` | jobs: latejoin UI | Requester захватывается до первого eligibility wait внутри native ui_data. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:98` | jobs: latejoin UI | После eligibility останавливается чтение удалённого либо сменившего client lobby. Post-wrapper не защищает внутренний цикл. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:102` | jobs: latejoin UI | Уже вычисленный availability входит в DTO; модулю не нужен второй SQL или сравнение текста ошибки. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:141` | jobs: latejoin UI | Guard удалённого lobby до следующей static-строки после SQL. Внешний post-wrapper не может остановить внутренний native цикл; исходный hidden-job conditional и порядок сохранены. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:160` | jobs: latejoin UI | Сохранённый ui_act прекращает обработку при handled результате настоящего parent authorization. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:172` | jobs: latejoin UI | Снимок профиля и edit_slot до исходной select_job ветки; её round/load/queue/species проверки сохранены. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:181` | jobs: latejoin UI | Повторная проверка того же selection после potentially yielding random chooser, до native spawn. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:234` | jobs: latejoin UI | Снимок запроса до штатного random цикла; безопасный receiver при утрате lobby. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:241` | jobs: latejoin UI | Explicit opt-in фильтрует кандидата перед штатной availability проверкой; random алгоритм не заменяется. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:244` | jobs: latejoin UI | Контекст и opt-in проверяются после eligibility wait до добавления кандидата; исходный unavailable continue сохранён. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:251` | jobs: latejoin UI | Guard после всего цикла покрывает rejected final SQL result; удалённый receiver не вызывается. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:265` | jobs: latejoin UI | Opt-in проверяется перед reroll modal, поскольку предпочтения могли измениться между подтверждениями. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:269` | jobs: latejoin UI | Подмена только отображаемой метки random job; исходные modal/options и цикл сохранены. |
| `code/modules/mob/dead/new_player/latejoin_menu.dm:271` | jobs: latejoin UI | После modal принимается ответ только прежнего requester/profile; безопасный receiver после hard-delete. |
| `code/modules/mob/dead/new_player/new_player.dm:137` | jobs: admission / player | Модульные причины отказа добавляются перед сохранённым generic fallback; штатный switch остаётся. |
| `code/modules/mob/dead/new_player/new_player.dm:152` | jobs: admission / player | Закрытая подпиской роль не считается альтернативной вакансией Assistant; исходный capacity цикл сохраняется. |
| `code/modules/mob/dead/new_player/new_player.dm:157` | jobs: admission / player | Передача latejoin в существующий eligibility вызов выбирает правильный профиль без повторного алгоритма. |
| `code/modules/mob/dead/new_player/new_player.dm:171` | jobs: admission / player | Respawn history проверяет назначенный slot; native localhost branch и history restriction остаются. |
| `code/modules/mob/dead/new_player/new_player.dm:188` | jobs: admission / player | Проверка request после arrivals/eligibility waits до native queue removal и role assignment. |
| `code/modules/mob/dead/new_player/new_player.dm:206` | jobs: admission / player | Компенсация своей вакансии перед сохранённым missing-destination CRASH. |
| `code/modules/mob/dead/new_player/new_player.dm:208` | jobs: admission / player | Только forced_slot input берётся из committed selection; native создание остаётся на месте. |
| `code/modules/mob/dead/new_player/new_player.dm:210` | jobs: admission / player | Зафиксированный admission rejection возвращается штатному caller; неожиданный null по-прежнему вызывает native CRASH. |
| `code/modules/mob/dead/new_player/new_player.dm:213` | jobs: admission / player | Результат handover проверяется до экипировки; неуспешный transfer не должен продолжать native tail. |
| `code/modules/mob/dead/new_player/new_player.dm:239` | jobs: admission / player | Client может исчезнуть после handover callbacks; nullable вызов сохраняет native init_verbs. |
| `code/modules/mob/dead/new_player/new_player.dm:270` | jobs: admission / player | Latejoin помечает первоначальную manifest job-запись для once-only callback. |
| `code/modules/mob/dead/new_player/new_player.dm:291` | jobs: character creation | Контекст создаёт модуль перед настоящим ..(); native принимает его только для внутренней проверки после yielding constructor. Захват состояния и его удаление находятся в модуле. |
| `code/modules/mob/dead/new_player/new_player.dm:299` | jobs: admission / player | Независимый context вызывает исходный виртуальный job constructor один раз и проверяет тело до возврата. При hard-delete lobby BYOND прерывает native proc; только frame контекста может закончить owned cleanup. Mind/history остаются в native. |
