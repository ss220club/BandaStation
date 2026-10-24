# Инструменты и MCP

Команды выполняются из корня checkout. Требуются Windows, PowerShell 5.1 или 7, Python 3.11+, Node.js 20+ с npm, Git, `rg` и установленный Microsoft Edge. Игровые версии и сборка определяются отдельно через `dependencies.sh` и штатный bootstrap.

| Задача | Команда |
| --- | --- |
| Git-аудит | `py -3 -B tools/agents/inspect-repo.py status` |
| Includes | `py -3 -B tools/agents/inspect-repo.py includes --path modular_bandastation/modular_bandastation.dme --depth 1 --limit 30` |
| Чтение UTF-8 | `py -3 -B tools/agents/inspect-repo.py read --path tgstation.dme --start 1 --count 40` |
| Поиск | Узкий `rg` или MCP `bandastation-ripgrep` |
| Веб-страница | MCP `bandastation-browser` |
| Задачи | [TASK_STATE](TASK_STATE.md) |

## Установка

```powershell
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File tools/agents/setup-tools.ps1
# После перемещения checkout: только локальная защита и новый конфиг.
tools/agents/setup-tools.ps1 -ConfigOnly
```

Установка использует закреплённые package locks, стандартный npm ci с integrity и отключёнными lifecycle scripts. Playwright MCP — `0.0.80`; адаптация mcp-ripgrep — `0.4.0`, SDK — `1.29.0`; [MIT LICENSE](../tools/agents/ripgrep/LICENSE) сохранена. Зависимости находятся в `%LOCALAPPDATA%/BandaStation/agent-tools/`, вне Git.

Setup генерирует локальный `.codex/config.toml` из [шаблона](templates/codex.toml), подставляя пути текущего checkout и Node. Глобальный config, модели, approvals, sandbox и авторизация не меняются. Custom config/hook/cache не перезаписываются. Runtime проверяется по SHA256; `-Repair` переустанавливает только принадлежащий набору cache. `-BrowserSeed` и `-RipgrepSeed` позволяют использовать уже установленный runtime с совпадающими версиями lock.

Формат конфигурации — в [официальном руководстве MCP](https://learn.chatgpt.com/docs/extend/mcp). Проектная `.codex/config.toml` загружается для доверенного проекта; после установки может потребоваться переоткрыть проект/подключение. Доступные tools проверь в клиенте (`codex mcp list`, `/mcp`, если эти команды доступны в установленной версии).

## Использование

`bandastation-ripgrep`: указывай узкий путь внутри checkout, literal pattern по умолчанию; regex включается явно. Tools: `search`, `list-files`, `count-matches`, `list-file-types`. Вывод ограничен; `.git`, выход наружу и перенаправленные пути запрещены. Git ignores соблюдаются; локальные документы можно читать через inspect-repo. Сервер не запускает shell.

`bandastation-browser`: изолированный headless Edge 1920×1080, без пользовательских cookies. Для локального интерфейса запусти свой HTTP-сервер и открой его URL. Снимок/DOM и события подтверждают только веб-сценарий, не игровой BYOND runtime. Кадры сохраняй в выделенный TEMP, указанный launcher; штатный shutdown очищает его. Не закрывай пользовательский браузер и чужие серверы.

## Проверка

```powershell
tools/agents/check.ps1
node tools/agents/ripgrep-mcp.cjs --check
node tools/agents/playwright-mcp.cjs --check
node tools/agents/test-ripgrep-mcp.cjs
node tools/agents/test-mcp.cjs
```

`--check` проверяет наличие runtime, но ещё не MCP-вызов. Два smoke-скрипта выполняют initialize → tools/list → tools/call → shutdown: поиск с пограничными входами и браузер с локальной страницей, событием и PNG. `check.ps1` проверяет документацию, синтаксис, task state, перенос и Git-защиту в одноразовых fixtures.

Успешный standalone smoke и подключение MCP именно в вашем чате — разные факты. Не добавляй другие MCP без конкретной задачи. [Ограничения](KNOWN_ISSUES.md), [перенос](PORTING.md).
