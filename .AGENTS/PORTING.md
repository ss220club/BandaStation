# Git-защита и перенос

`AGENTS.md`, `.AGENTS/` и `tools/agents/` — общие исходники. Машинный `.codex/`, рабочий `task_state/` и старый `.AGENTS/local/` исключены из Git. Установка добавляет runtime-исключения в `.git/info/exclude` и локальный hook; проверка не откатывает индекс сама.

```powershell
tools/agents/local-only.ps1 -Action install
tools/agents/local-only.ps1 -Action check
```

Guard разрешает общие исходники и отвергает staged локальные данные. Не обходи его через force-add или no-verify. Custom hook, `core.hooksPath`, конфиг и чужой cache сохраняются; для их совмещения нужна явная интеграция. Hook — локальная защита, не серверная политика.

## Другой checkout

Обычный путь — получить эту ветку через Git и выполнить `tools/agents/setup-tools.ps1`. Для передачи исходников без Git доступен экспорт:

```powershell
tools/agents/export-toolkit.ps1 -Destination (Join-Path $env:TEMP 'BandaStation-agent-toolkit')
# В созданном каталоге:
py -3 -B payload/tools/agents/toolkit.py verify --bundle .
./Install.ps1 -Repository '<путь к BandaStation checkout>'
```

Экспорт создаёт новую папку и отказывается заменять существующую. Внутри: `payload/` с общими исходниками, `Install.ps1`, короткий README и SHA256 manifest. Истории задач, машинного конфига, зависимостей, ревью и Git metadata там нет. Незаявленные файлы, редиректы и несовпадающие хеши отвергаются.

Install проверяет BandaStation entrypoints и Git root до записи. Существующие совпадающие файлы допускают повторный запуск, различающиеся не перезаписываются. Новые общие файлы видны в Git как untracked; установщик не индексирует и не коммитит их. Runtime-исключения ставятся до генерации конфига. MCP-пути создаются заново для целевого checkout.

По умолчанию перенос запускает setup с `-ConfigOnly`; `-InstallDependencies` устанавливает закреплённые зависимости. После переноса выполни check и два MCP smoke из [TOOLS](TOOLS.md).

Для другого проекта сначала адаптируй контекст, инструкции, include/build и skill по реальным исходникам. Установщик намеренно требует `tgstation.dme` и `modular_bandastation/modular_bandastation.dme`.
