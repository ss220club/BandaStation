# Windows rust-g: исправление времени жизни DLL

Этот документ фиксирует историческую проверку исходной объединённой ветки Vox/IPC (snapshot `486f06245df75f7aeb56ade4111287f3a6563d4c`). Числа 116/116 и 92/92, а также приведённые игровые и ordinary-прогоны относятся к той ветке, а не к новым `species-runtime-shared`, `vox-independent` или `ipc-paradise-upstream`. Результаты новых отдельных рас записываются в документацию соответствующей расы. Native harness в `tools/vox` не зависит от расы; путь сохранён для минимального diff.

Исправленная DLL установлена в корне сборки и проверена native-host тестами,
40 standalone-процессами и полным игровым прогоном. Обычный сервер прошёл
**4/4 сценария** с естественным exit 0: восемь эпох мира и четыре реальных
`world.Reboot()` в двух warm-процессах с сохранением PID. Runtime errors,
Application Faults, timeouts и forced exits отсутствуют.
Результаты и команды: [VALIDATION.md](VALIDATION.md).
Hash и исходники установленной версии: [runtime-manifest.json](runtime-manifest.json).

`windows-lifetime.patch` применяется к rust-g 7.0.0, commit
`7ba42e2cb84c0fe28862b830d95fa095933f86f4`.
Патч закрепляет Windows-модуль при входе в FFI, до разбора аргументов и работы
с TLS, чтобы worker threads и TLS destructors не остались в выгруженном DLL.
`GetModuleHandleExW(FROM_ADDRESS | PIN)` сохраняет модуль до завершения процесса;
это не остановка worker threads. Семантика `PIN` описана в
[Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/api/libloaderapi/nf-libloaderapi-getmodulehandleexw).
Нет собственного `DllMain`, задержек или скрытия ошибок завершения процесса.
Для других платформ guard возвращает `true`; Linux-библиотека не заменяется.
Обоснование и исходный
минимальный пример: [WINDOWS_RUSTG_SHUTDOWN.md](../vox/WINDOWS_RUSTG_SHUTDOWN.md).

## Сборка

Нужны Windows, Git, Rust **1.93.1** с target `i686-pc-windows-msvc`, MSVC C/C++
tools и Windows SDK. Сам скрипт инструменты не устанавливает и серверную DLL
не заменяет. BYOND для компиляции rust-g не нужен.

```powershell
.\tools\rustg\build-windows.ps1
```

Скрипт создаёт новый каталог `tmp/rustg-build-*`, делает shallow fetch точного
commit, отключает `core.autocrlf` в этом временном checkout, проверяет патч через
`git apply --check` и собирает default features:

```text
cargo +1.93.1 build --locked --release --target i686-pc-windows-msvc
```

Используется upstream `.cargo/config.toml` с `+crt-static`. Внешние
`RUSTFLAGS`, `CARGO_ENCODED_RUSTFLAGS`, `CARGO_BUILD_RUSTFLAGS`,
`CARGO_TARGET_I686_PC_WINDOWS_MSVC_RUSTFLAGS` и `CARGO_TARGET_DIR` отклоняются, чтобы
не подменить рецепт сборки. Отсутствующий Rust не загружается автоматически.
`-OutputDirectory` позволяет явно выбрать новый каталог результата.

## CI и результат

[Windows workflow](../../.github/workflows/rustg-windows.yml) запускается при
изменениях патча, рецепта сборки или самого workflow в ветках `vox-port`, `vox-independent`, `ipc-paradise-upstream`,
а также через `workflow_dispatch`.
Rust/Cargo homes находятся в каталоге временных файлов job. Используется MSVC
готового Windows runner; установка инструментов на компьютер игрока не нужна.

Основной artifact `rustg-windows-i686-msvc` содержит DLL, MIT license upstream,
точный применённый patch, сгенерированный `rust_g.dm` и `manifest.json`:

- upstream commit и SHA256 Cargo.lock;
- SHA256 patch и upstream Cargo config;
- Rust/Cargo/Git versions, target, features и команду сборки;
- SHA256 и размер DLL, PDB и сопутствующих файлов.

Соответствующий PDB загружается отдельно в
`rustg-windows-i686-msvc-symbols`. Исходники и рецепт закреплены; побайтовое
совпадение независимых сборок с разными версиями MSVC/Windows runner не обещается.

Установленная DLL получена из CI run `40140261314`, artifact `12578767019` и
имеет SHA256 `8461311659929524301299d7a6a754e5ffe51c6d326ce7f2a8850143c5ee24db`.
Её результаты записаны в [VALIDATION.md](VALIDATION.md); любая новая пересборка
сначала является кандидатом и требует тех же проверок. Default hash standalone
harness остаётся официальным. Для этой DLL требуется явный
`-Sha256 '8461311659929524301299d7a6a754e5ffe51c6d326ce7f2a8850143c5ee24db'`;
полный пример приведён в validation.

Для замены pinned DLL нужен **полный останов и новый процесс DreamDaemon**.
`world.Reboot()` внутри того же процесса оставляет прежний модуль загруженным.
Перед заменой tracked `rust_g.dll` сверяется checksum с manifest; в PR попадают
проверенный DLL и source/patch/build metadata. Upstream PR или публикация релиза
этим workflow не создаются. PDB и сырые журналы не добавляются в Git.
