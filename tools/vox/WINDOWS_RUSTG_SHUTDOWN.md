# Windows: исправление времени жизни rust-g DLL

Этот документ фиксирует историческую проверку исходной объединённой ветки Vox/IPC (snapshot `486f06245df75f7aeb56ade4111287f3a6563d4c`). Числа 116/116 и 92/92, а также приведённые игровые и ordinary-прогоны относятся к той ветке, а не к новым `species-runtime-shared`, `vox-independent` или `ipc-paradise-upstream`. Результаты новых отдельных рас записываются в документацию соответствующей расы. Native harness в `tools/vox` не зависит от расы; путь сохранён для минимального diff.

Исправленная DLL проверена native-host тестом обеих FFI-веток, серией 40/40
standalone-процессов и финальным игровым прогоном после всех production-фиксов:
116/116 групп, 92/92 скриншота, естественный exit 0, `Success!`, без runtimes
(`tmp/vox-test-70bba0244a73`). Обычный сервер также прошёл **4/4 сценария**:
все native exit 0, driver exit 0, восемь эпох и четыре реальных reboot в двух
warm-процессах с тем же PID. Нет raw runtimes, Application Faults, ошибок
event query, timeouts и forced exits. Точные результаты:
[tools/rustg/VALIDATION.md](../rustg/VALIDATION.md).

Исторический ordinary-прогон `tmp/server-lifecycle-1a1f0a2dca43` также подтвердил
три startup-исправления: пустой sticky-ban набор, `research_costs=null` у
абстрактного cyber-узла и `nearstation=null` в mapping/ruins. Cyber 8/8 и mapping
branches 24/24 прошли; конкретный узел стоит 60 при ожидаемых 60, registry и trait
восстановлены. Инициализировано 147 подсистем,
включая test probe; компиляция ordinary fixture — 0 errors / 0 warnings.

Установленная DLL: SHA256
`8461311659929524301299d7a6a754e5ffe51c6d326ce7f2a8850143c5ee24db`,
`get_version() = 7.0.0`. Проверенные исходники, patch и рецепт сборки записаны в
[runtime-manifest.json](../rustg/runtime-manifest.json).

## Что изменено

Guard в обеих формах `byond_fn!` закрепляет собственный Windows-модуль при входе
в FFI, до разбора аргументов, panic hook и обращения к TLS. Используется
`GetModuleHandleExW(FROM_ADDRESS | PIN)` с адресом функции внутри DLL и
`OnceLock`. Согласно [документации Microsoft](https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getmodulehandleexw),
`PIN` сохраняет модуль загруженным до завершения всего процесса, независимо от
вызовов `FreeLibrary`.

Патч не останавливает и не делает `join` Rayon/async workers: он сохраняет их
код и TLS destructors отображёнными в память на время жизни процесса. В нём
нет собственного `DllMain`, задержек или игнорирования ненулевого exit code.
При неудаче pin FFI возвращает статическую ошибку до работы с TLS. На Linux
guard возвращает `true`, Win32-вызов не компилируется; Linux-библиотека не заменена.

После pin новая DLL загружается только в **новом процессе** DreamDaemon.
Для замены нужно остановить весь процесс, заменить файл и запустить заново;
перезагрузка мира внутри того же процесса этого не делает.

## История исходного сбоя

25 октября 2026 года обнаружен отдельный native-сбой завершения процесса.
Основной прогон прошёл 116/116 групп DM-тестов и 92/92 сравнения скриншотов,
записал `Success!` и `Shutdown complete`, однако DreamDaemon завершился с
`-1073741819` (`0xC0000005`). Такой прогон нельзя считать полностью успешным.

Минимальный standalone-пример воспроизвёл тот же Windows fault signature без
кода станции, одежды, тел и других игровых ресурсов. Это локализует проблему
в native-пути BYOND/rust-g при выгрузке; точная цепочка вызовов требует стека.
Ниже описана диагностика исходной официальной DLL до применения native-патча.

## Исходная DLL и среда

- Windows, portable BYOND `516.1685` (`dm.exe` и `dd.exe`).
- DLL побайтово совпала с официальным [asset релиза 7.0.0](https://github.com/tgstation/rust-g/releases/tag/7.0.0).
- SHA256 `rust_g.dll`: `51130b5597a992b01c06fa620ec3b45862247f7aa8d5e85285f271d15ac83b24`.
- `get_version()` этого официального asset возвращает `6.2.0`; это не основание
  считать локальный файл подменённым. [Release workflow](https://github.com/tgstation/rust-g/blob/7.0.0/.github/workflows/release.yml)
  загружает Windows build artifact из ветки `master`.

Windows Application Error, event 1000:

```text
Faulting application: dd.exe 5.0.516.1685
Faulting module: rust_g.dll_unloaded
Exception code: c00001a5
Fault offset: 0065b640
```

Этот signature совпал с одним из сбоев основного прогона. В основном прогоне
также наблюдались `c0000005` и offset `006ba354`.

## Минимальный сценарий и повторение

[repro.dm](rustg-shutdown-repro/repro.dm) загружает только DLL, выполняет
`get_version()`, а в режиме `forge` синхронно вызывает
`iconforge_generate_headless`. Вход — один свежий DMI state `probe`, 32×32,
четыре направления с однотонными красным, зелёным, синим и жёлтым кадрами.
Поля UniversalIcon: `icon_file`, `icon_state`, `dir`, `frame`, `transform`.

Перед удалением мира проверяются JSON-результат без `error`, путь результата
и существование выходного DMI. `BEFORE_DEL`/`ready.marker` означают достижение
`del(world)`, а не успешный native-выход. Режим `control` вызывает только
`get_version`; режим `cleanup` после генерации вызывает `iconforge_cleanup`.

Текущий runner дополнительно проверяет режим `warm`: три эпохи мира в одном
процессе. Нужны Python с Pillow, проверенная DLL и BYOND 516.1685. По умолчанию
runner ожидает hash старой официальной DLL, поэтому для исправления hash
передаётся явно:

```powershell
.\tools\vox\rustg-shutdown-repro\run.ps1 `
  -ByondBin 'D:\path\to\byond\bin' `
  -Python '.\tmp\bootstrap-cache\python-3.11.0\python.exe' `
  -RustGDll '.\rust_g.dll' `
  -Sha256 '8461311659929524301299d7a6a754e5ffe51c6d326ce7f2a8850143c5ee24db' `
  -Repeat 5 -WaitMs 45000
```

[Runner](rustg-shutdown-repro/run.ps1) проверяет hash DLL и версию BYOND,
компилирует standalone-файл и запускает процессы скрыто. Для каждой пары
`control/forge/cleanup/warm` и CLI `-close`/без `-close` создаётся отдельный каталог
с новой DLL-копией, входным DMI и DMB. Данные предыдущих прогонов не копируются.
Артефакты сохраняются в `tmp/rustg-shutdown-*`: `results.json`, `events.json`,
исходник, compile log и console logs. События Windows отбираются по PID этих
процессов. Ненулевой exit, timeout, неверный результат или native error event
дают ошибку runner; timeout сохраняется как `exitCode: null`, а не как ноль.

## Исторические результаты исходной DLL

Первая изолированная серия: `tmp/rustg-minimal-86a5f23053`, три повторения
каждой пары, watchdog 3 секунды. Во всех случаях вход и результат валидны.

| Сценарий | Exit 0 | Watchdog | Подтверждённые event 1000 |
| --- | ---: | ---: | ---: |
| Только get_version, оба CLI-варианта | 6/6 | 0 | 0 |
| Sync iconforge, оба CLI-варианта | 4/6 | 2 | 2 |
| Sync iconforge + cache cleanup, оба CLI-варианта | 3/6 | 3 | 2 |

Подтверждённые fault PID: `518392`, `528912`, `529224`, `526916`. Они относятся
именно к standalone-процессам; чужие параллельные события исключены. Падения
были и без `-close`, и с ним, включая случай `CLEANUP=Ok`. Один из пяти
watchdog-случаев этой серии остаётся timeout без подтверждённого crash event.
Watchdog завершал зависший процесс; естественный exit code для этих случаев
не приписывается.

Сбой непостоянный: последующие три `forge`/без `-close` с watchdog 15 секунд
в `tmp/rustg-minimal-3d457d9426` завершились с exit 0. Финальная проверка
сохранённого runner, шесть случаев с watchdog 15 секунд, также прошла 6/6
с exit 0 и без error events (`tmp/rustg-shutdown-772a37e7a6`). Повторный полный
игровой прогон с этой официальной DLL прошёл 116/116 с exit 0 и 92/92 сравнениями; старый
baseline прошёл 111/111 с exit 0. DLL во всех этих запусках идентичны.
Успешные повторения не отменяют ранее сопоставленные PID и native fault signature.

## Точное сопоставление PDB исходной DLL

PDB исходного официального asset совпал с его DLL по GUID/age. По приватным procedure records
RVA `0x006ba354` основного access violation находится **внутри** функции:

```text
rayon_core::sleep::Sleep::sleep<rayon_core::registry::impl$10::wait_until_cold::closure_env$0>
function RVA: 0x006ba150
function size: 0x345
range: [0x006ba150, 0x006ba495)
displacement: 0x204
```

Это сопоставление по границам процедуры, а не ближайший соседний символ.
Сохранённый результат: `tmp/rust-g-shutdown-audit/private-symbol-results.json`.
RVA `0x0065b640` пока не разрешён; имя функции для него не приписывается.

## Почему очистка кэша не решала проблему

- В rust-g tags 6.2.0 и 7.0.0 файлы `jobs.rs`, `lib.rs`, `iconforge.rs`,
  `log.rs`, `byond.rs` совпадают побайтово. В [iconforge_cleanup](https://github.com/tgstation/rust-g/blob/7.0.0/src/iconforge.rs)
  есть очистка image/icon cache и отказ при активном cache; остановки worker
  threads и общего `join` нет. `log_close_all` закрывает файлы.
- Cargo.lock фиксирует iconforge 1.0.3 и rayon-core 1.13.0. Их скачанные crate
  checksums совпали с lockfile. GAGS/spritesheet используют Rayon `par_iter`
  без отдельного scoped pool. Документация `rayon-core/src/lib.rs` прямо
  говорит, что global pool живёт до завершения всего процесса.
- [Rayon #1242](https://github.com/rayon-rs/rayon/issues/1242) описывает тот же
  класс проблем Windows DLL unload. В [Rayon #688](https://github.com/rayon-rs/rayon/issues/688)
  объясняется, что даже `drop` обычного pool сам по себе не гарантирует join
  потоков и завершение TLS destructors.
- [rust-g PR155](https://github.com/tgstation/rust-g/pull/155) с общим shutdown
  закрыт без merge. В [review](https://github.com/tgstation/rust-g/pull/155#issuecomment-1785424535)
  прямо отмечено, что detached threads после выгрузки модуля могут вызвать crash.

Минимальный пример и точный PDB подтверждают локализацию в native-завершении
rust-g/Rayon, независимо от игрового кода. Полная последовательность unload
race остаётся гипотезой без стека потоков в момент сбоя.
В exported API не найден надёжный способ остановить и дождаться всех
rust-g/Rayon worker threads. Поэтому применено закрепление модуля на время
жизни процесса; `iconforge_cleanup`, `log_close_all`, `sleep` и CLI `-close`
сами по себе исправлением не являются. Результаты исправленной DLL вынесены в
[VALIDATION.md](../rustg/VALIDATION.md), отдельно от этой истории диагностики.
