# Windows: сбой rust-g при завершении DreamDaemon

25 октября 2026 года обнаружен отдельный native-сбой завершения процесса.
Основной прогон прошёл 116/116 групп DM-тестов и 92/92 сравнения скриншотов,
записал `Success!` и `Shutdown complete`, однако DreamDaemon завершился с
`-1073741819` (`0xC0000005`). Такой прогон нельзя считать полностью успешным.

Минимальный standalone-пример воспроизвёл тот же Windows fault signature без
кода станции, одежды, тел и других игровых ресурсов. Это локализует проблему
в native-пути BYOND/rust-g при выгрузке; точная цепочка вызовов требует стека.
Изменений production-кода или замены DLL для обхода сбоя не сделано.

## Зафиксированная среда

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

Нужны Python с Pillow, проверенная DLL в корне checkout и BYOND 516.1685:

```powershell
.\tools\vox\rustg-shutdown-repro\run.ps1 `
  -ByondBin 'D:\path\to\byond\bin' `
  -Python '.\tmp\bootstrap-cache\python-3.11.0\python.exe' `
  -Repeat 3 -WaitMs 15000
```

[Runner](rustg-shutdown-repro/run.ps1) проверяет hash DLL и версию BYOND,
компилирует standalone-файл и запускает процессы скрыто. Для каждой пары
`control/forge/cleanup` и CLI `-close`/без `-close` создаётся отдельный каталог
с новой DLL-копией, входным DMI и DMB. Данные предыдущих прогонов не копируются.
Артефакты сохраняются в `tmp/rustg-shutdown-*`: `results.json`, `events.json`,
исходник, compile log и console logs. События Windows отбираются по PID этих
процессов. Ненулевой exit, timeout, неверный результат или native error event
дают ошибку runner; timeout сохраняется как `exitCode: null`, а не как ноль.

## Реальные результаты

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
прогон текущего DMB прошёл 116/116 с exit 0 и 92/92 сравнениями; старый
baseline прошёл 111/111 с exit 0. DLL во всех этих запусках идентичны.
Успешные повторения не отменяют ранее сопоставленные PID и native fault signature.

## Точное сопоставление PDB

Официальный PDB совпал с DLL по GUID/age. По приватным procedure records
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

## Что подтверждают первичные исходники

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
В текущем exported API не найден надёжный способ остановить и дождаться всех
rust-g/Rayon worker threads. `iconforge_cleanup`, `log_close_all`, `sleep` и
CLI `-close` не следует объявлять исправлением этой проблемы.
