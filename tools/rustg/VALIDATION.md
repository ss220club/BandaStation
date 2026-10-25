# Проверка Windows rust-g lifetime fix

Этот документ фиксирует историческую проверку исходной объединённой ветки Vox/IPC (snapshot `486f06245df75f7aeb56ade4111287f3a6563d4c`). Числа 116/116 и 92/92, а также приведённые игровые и ordinary-прогоны относятся к той ветке, а не к новым `species-runtime-shared`, `vox-independent` или `ipc-paradise-upstream`. Результаты новых отдельных рас записываются в документацию соответствующей расы. Native harness в `tools/vox` не зависит от расы; путь сохранён для минимального diff.

25 октября 2026 года исправленная DLL прошла native-host тест обеих FFI-веток,
ABI-проверку, 40/40 standalone-процессов и полный игровой прогон с естественным
exit 0. Исторический обычный сервер прошёл **4/4 сценария** запуска/закрытия,
включая warm reboot в том же процессе. Все проверки используют DLL с указанным
SHA256; игровой и ordinary-прогоны выполнены после трёх startup-исправлений.

## Проверенный бинарник

| Параметр | Значение |
| --- | --- |
| DLL SHA256 | `8461311659929524301299d7a6a754e5ffe51c6d326ce7f2a8850143c5ee24db` |
| Размер | 10 140 160 байт, PE32/i386 |
| `get_version()` | `7.0.0` |
| Upstream commit | `7ba42e2cb84c0fe28862b830d95fa095933f86f4` |
| Patch SHA256 | `246308b7f402fa046723cdd12ec1e17e3805192bbec1cc597a6ac59f0e5f8863` |
| Сборка | Rust 1.93.1, default features, `--locked --release --target i686-pc-windows-msvc` |
| CI | [run 40140261314](https://github.com/mo0niverse/PrimeDream-/actions/runs/40140261314), artifact `12578767019` |

GitHub archive digest, source commit, hash patch и hashes/размеры файлов
проверены перед установкой. [runtime-manifest.json](runtime-manifest.json) — копия
manifest именно этой CI-сборки. Лицензия upstream: [MIT](LICENSE.rust-g.txt).
Сырые PDB и журналы остаются в `tmp`, в Git не добавляются. Проверенная DLL в
корне проекта версионируется отдельно вместе с build metadata.

## Результаты

| Проверка | Результат | Доказательства |
| --- | --- | --- |
| Native-host: первый вызов `get_version`, без аргументов | **PASS / Pinned** | `tmp/rustg-lifetime-f6219c92c609/summary.json` |
| Native-host: первый вызов `file_exists`, с аргументом | **PASS / Pinned** | тот же summary, отдельный свежий x86-процесс |
| Официальная DLL: отрицательный контроль обеих веток | **PASS / Unloaded** | `tmp/rustg-lifetime-dbec66c671ec/summary.json` |
| ABI / зависимости | **PASS**: сохранены 78/78 старых экспортов; список импортируемых DLL не изменён, новых несистемных DLL нет | `tmp/rustg-ci-40140261314/abi-audit.json` |
| Standalone: 4 режима × 2 close flags × 5 повторов | **40/40 PASS**, естественный exit 0, без timeout и matching error events | `tmp/rustg-shutdown-88fef689e9/{manifest,results,event-audit}.json` |
| Warm world reload | **10/10 PASS** в составе тех же 40 процессов: 3 эпохи с тем же PID, всего 20 VM reboot | те же manifest/results и epoch records |
| Полный игровой прогон после всех production-исправлений | **116/116**, **92/92** PNG comparisons, script exit 0, `Success!`, `Shutdown complete`, без BYOND runtime errors | `tmp/vox-test-70bba0244a73` |
| Обычный сервер: 4 сценария запуска/закрытия | **4/4 PASS**, driver exit 0, все четыре native exit 0 | `tmp/server-lifecycle-1a1f0a2dca43/manifest.json`: `status=passed`, `success=true` |
| Обычный сервер: warm reboot | **PASS**: восемь эпох; два warm-процесса по три эпохи с тем же PID, четыре фактических `world.Reboot()` | тот же lifecycle-прогон |
| Обычный сервер: чистота завершения | **PASS**: 0 raw runtimes, Application Faults, event query errors, unparsed events, timeouts и forced exits | тот же lifecycle-прогон |
| Startup-регрессии | **PASS**: cyber **8/8**, цена конкретного узла 60 при ожидаемых 60; registry/trait восстановлены; mapping branches **24/24** | тот же lifecycle-прогон |
| Инициализация и компиляция ordinary fixture | **PASS**: 147 подсистем, включая test probe; compile 0 errors / 0 warnings | тот же lifecycle-прогон |

В финальную сборку входят три узких startup-исправления: guard пустого набора
sticky bans, обработка `research_costs=null` у абстрактного `/datum/techweb_node/cyber` и
`nearstation=null` в mapping/ruins. Сырые неуспешные промежуточные прогоны
сохранены как история; они не подменяют приведённый финальный PASS.

Native-host вызывает `FreeLibrary` и затем проверяет, что модуль остаётся
отображённым и export доступен; сам probe не делает PIN. Официальный контроль
с SHA256 `51130b5597a992b01c06fa620ec3b45862247f7aa8d5e85285f271d15ac83b24`
после `FreeLibrary` действительно выгружается. Так проверяется guard обеих
форм `byond_fn!`, а не только непостоянство прежнего crash.

ABI audit также отмечает прежнее отсутствие optional `noise_poisson_map` в
обеих DLL: новых отсутствующих API относительно официального baseline нет.
Список DLL imports сохранён; Win32 `GetModuleHandleExW` используется из Kernel32.

Standalone проверяет JSON contract, размеры/dirs/frames и все RGBA пиксели
выходного DMI, а не только наличие файла. В `warm` три эпохи и два
`world.Reboot()` происходят в том же процессе. Exit codes, timeouts и Windows
events остаются обязательными условиями успеха; задержки и игнорирование
ненулевого exit не используются как исправление.

## Что делает патч

При входе в любую FFI-ветку guard вызывает
`GetModuleHandleExW(FROM_ADDRESS | PIN)` для адреса внутри rust-g. Guard стоит
до аргументов/TLS и выполняет pin один раз через `OnceLock`; при неудаче
возвращается статическая ошибка. Собственного `DllMain` патч не добавляет.

Согласно [Microsoft](https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getmodulehandleexw),
`PIN` удерживает модуль до завершения процесса. Рабочие потоки не останавливаются:
их код и TLS destructors остаются доступными, пока жив процесс. В Linux guard
возвращает `true`, Win32 pin не компилируется; Linux-бинарник не заменён.
Для применения другой DLL требуется полный останов и новый процесс
DreamDaemon: reboot мира внутри старого процесса прежний модуль не заменяет.

## Повторение проверок

Default SHA256 standalone harness всё ещё указывает на старую официальную DLL.
Исправленная версия должна передаваться с явным проверенным hash:

```powershell
$testedSha = '8461311659929524301299d7a6a754e5ffe51c6d326ce7f2a8850143c5ee24db'
$byondBin = 'D:\path\to\byond\bin'

.\tools\rustg\test-module-lifetime.ps1 `
  -LibraryPath '.\rust_g.dll' -ExpectedState Pinned -ExpectedSha256 $testedSha

.\tools\vox\rustg-shutdown-repro\run.ps1 `
  -ByondBin $byondBin `
  -Python 'python' `
  -RustGDll '.\rust_g.dll' -Sha256 $testedSha -Repeat 5 -WaitMs 45000

.\tools\vox\test-server-lifecycle.ps1 `
  -ByondBin $byondBin `
  -Python 'python' `
  -RustGDll '.\rust_g.dll' -Sha256 $testedSha -Repeat 1 -TimeoutSeconds 240
```

История исходной ошибки, воспроизводившейся без игрового кода, и точное
сопоставление fault RVA с Rayon:
[WINDOWS_RUSTG_SHUTDOWN.md](../vox/WINDOWS_RUSTG_SHUTDOWN.md).
