# Проверка отдельного IPC PR

Проверка выполнена 25.10.2026 в отдельном checkout ветки `ipc-paradise-upstream`,
без подключения модуля Vox. Финальный полный runner выполнен на коммите
`3fb45fcb15e29cd956b5b624b48523040b63e281`, после обновления трёх доказанно
устаревших эталонов и окончательной раскладки IPC defines/includes.
Общая runtime-основа включена обычным merge `species-runtime-shared`, HEAD
`2568eea248c2bc626c46248a5da83c8c2c86d85d`.

## Результаты

| Проверка | Результат |
| --- | --- |
| Штатная сборка `bun tools/build/build.ts build`, без `UNIT_TESTS` | PASS: BYOND 516.1685, 0 ошибок, 0 предупреждений; TGUI/Rspack собран |
| `test-ipc.ps1 -IncludeHumanoidScreenshots -TimeoutSeconds 600` | **Полный driver exit 0**; все 77 IPC и 11 общих `Run()` прошли: **88/88**; отсутствующих результатов нет |
| Нативное завершение DD | Код 0, `clean_run.lk = Success!` |
| Сырые runtime-логи | Все три файла существуют; совпадений ошибок в `dd.log`, `runtime.log.json`, `console.log` — 0 |
| Сравнение изображений внутри полного runner | **45/45**, код comparator 0: три IPC и 42 humanoid изображения |
| Регрессия provenance конвертера | `python tools/ipc/test_convert_assets.py -v`: 2/2; подставленные staged, unstaged и untracked статусы Git отклоняются до записи результатов |
| Контракт IPC runner | 10/10: здоровый набор допускается, native crash, потеря теста/лога/скриншота, runtime, assertion и нештатное завершение отклоняются |
| Обычный сервер: запуск, выключение и перезагрузка | **4/4 PASS**, driver и все четыре DD exit 0; компиляция 0 ошибок, 0 предупреждений |
| TypeScript | PASS, exit 0; `tgui-tsc` 20,6 секунды |
| Тесты TGUI | **25/25 PASS**, 40 assertions, exit 0 |
| Dreamchecker после окончательной раскладки | PASS, exit 0, **0 diagnostics** |

В wrapper выбраны 90 типов. Два `focus_only` — `invalid_research_designs` и
`invalid_emissives` — регистрируют ошибки из других процедур и не создают отдельный
успешный `Run`. Поэтому ожидаются именно 88 результатов, включая все 77 IPC-тестов.
Тестовая компиляция имеет 0 ошибок и четыре предупреждения инфраструктуры
`UNIT_TESTS`: tracking qdel, отключённые loop checks и две неиспользуемые переменные
тестовой карты. Обычная игровая сборка предупреждений не имеет.

## Исправления и границы проверки

Кулинарное улучшение теперь действительно расходует содержимое ложки через
существующий `consume_flavor()`. Вилка даёт вкус уже снятой с омлета порции.
Два новых теста проходят настоящие fork/spoon/ladle, самостоятельную еду и кормление,
полную и последнюю частичную порции, удаление и отказ процессора во время `do_after`.
Проверены отсутствие реагентов в теле и процессоре, седации и пополнения заряда.
Органический путь и запрет еды без исправного улучшения сохраняются.

Первый runner завершился кодом 1 на двух старых humanoid эталонах; его журналы и
старые PNG сохранены. Три lizard PNG совпали побайтово с независимым Linux CI artifact
`12580401262` и native контролем (97/5/5 изменённых RGBA-пикселей).
После обновления только этих трёх эталонов выполнен новый **полный** runner:
88/88 тестов, 45/45 изображений и итоговый код 0 без ручных промежуточных шагов.

| Эталон | SHA256 фактического PNG и Linux CI |
| --- | --- |
| `screenshot_humanoids__datum_species_lizard.png` | `27409b0719874c86ced316fca85036153b2f495c0371f8d3e3d83cc6f508160a` |
| `screenshot_humanoids__datum_species_lizard_ashwalker.png` | `c64548a599cbce1b955fc39f9c627f987ac9355465a7a5ce3344eeafa68fb9bc` |
| `screenshot_humanoids__datum_species_lizard_silverscale.png` | `74b61630691e10977e1c603718c46ced2c80d6967f08ea3713180ffc8bafb73f` |

Использована установленная `rust_g.dll` 7.0.0 с SHA256
`8461311659929524301299d7a6a754e5ffe51c6d326ce7f2a8850143c5ee24db`.
Происхождение DLL, ABI и проверки её lifetime описаны отдельно в
[tools/rustg/VALIDATION.md](../../tools/rustg/VALIDATION.md).
Разбор подтверждённых и отклонённых замечаний находится в
[tools/ipc/REVIEW_AUDIT.md](../../tools/ipc/REVIEW_AUDIT.md).

Обычный сервер проверен с `UNIT_TESTS` выключенным, на отдельной минимальной карте
и свежих изолированных data/config, без БД и публикации в Hub. Две ветки штатного
выключения и две ветки `world.Reboot()` проверены с `-close` и без него: восемь полных
инициализаций, четыре настоящих перезагрузки в прежнем PID. Все 147 подсистем, включая
test probe, инициализировались; cyber regression 8/8 и missing-area regression 24/24.
Сырых runtimes, Windows faults, ошибок event query, неопознанных или посторонних PID
событий, timeout и принудительных завершений нет.

Локальные артефакты финального runner: `tmp/ipc-test-46b82783aaac/` — `compile.log`,
`data/unit_tests.json`, три runtime-лога, PNG и `validation-summary.json`;
вывод команды — `tmp/ipc-native-final-replay.log`.
История исходного несовпадения и `baselines-before/`, `baseline-refresh-evidence.json`
сохранены в `tmp/ipc-test-07e74474ee3b/`, исходный вывод — в `tmp/ipc-native-final.log`.
Обычный сервер: `tmp/server-lifecycle-4536acc49911/manifest.json`,
`tmp/ipc-lifecycle-final.log`. Сборка: `tmp/ipc-build-final.log`,
`tmp/ipc-build-shared-final.log`. Проверки интерфейса: `tmp/split-tgui-tsc.log`,
`tmp/split-tgui-tests.log`; анализ DM: `tmp/split-dreamchecker.log`.
Эти локальные журналы не включены в Git; повторный запуск создаёт собственный каталог.

Подключение настоящего клиента, интерактивные окна настроек, переподключение и
раунд с игроками этим прогоном не проверялись. Сценарии ручной проверки перечислены
в [IPC_PORT.md](IPC_PORT.md#проверка-с-игроком).
