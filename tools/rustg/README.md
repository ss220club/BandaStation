# Windows rust-g: исправление времени жизни DLL

`windows-lifetime.patch` применяется к rust-g 7.0.0, commit
`7ba42e2cb84c0fe28862b830d95fa095933f86f4`.
Патч закрепляет Windows-модуль при входе в FFI, до разбора аргументов и работы
с TLS, чтобы worker threads и TLS destructors не остались в выгруженном DLL. Для других платформ
guard возвращает `true`; код Linux не закрепляет модуль. Обоснование и исходный
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
`RUSTFLAGS`, `CARGO_ENCODED_RUSTFLAGS` и `CARGO_TARGET_DIR` отклоняются, чтобы
не подменить рецепт сборки. Отсутствующий Rust не загружается автоматически.
`-OutputDirectory` позволяет явно выбрать новый каталог результата.

## CI и результат

[Windows workflow](../../.github/workflows/rustg-windows.yml) запускается при
изменениях патча, рецепта сборки или самого workflow в ветке `vox-port`,
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

CI создаёт **кандидат**, а не подтверждение исправления. Перед заменой tracked
`rust_g.dll` нужно сверить checksum с manifest, выполнить standalone проверки
запуска/завершения, повторные загрузки мира и полный игровой прогон. В PR должны
попасть проверенный DLL и его source/patch/build metadata. Ни upstream PR,
ни публикация релиза этим workflow не создаются.
