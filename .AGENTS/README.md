# Агентский набор BandaStation

Вход — [AGENTS.md](../AGENTS.md). Общие исходники набора хранятся в Git; машинная конфигурация и текущие задачи — локально.

| Документ | Назначение |
| --- | --- |
| [PROJECT_CONTEXT](PROJECT_CONTEXT.md) | Карта исходников, include graph и сборка |
| [WORKFLOW_RULES](WORKFLOW_RULES.md) | Модуляризация, `..()`, инъекции, код-стайл и приёмка |
| [TASK_STATE](TASK_STATE.md) | Продолжение задач и работа нескольких исполнителей |
| [TOOLS](TOOLS.md) | Установка, использование и проверка двух MCP |
| [PORTING](PORTING.md) | Git-защита и перенос общих исходников |
| [KNOWN_ISSUES](KNOWN_ISSUES.md) | Границы инструментов |
| [bandastation-workflow](skills/bandastation-workflow/SKILL.md) | Краткий проектный skill |

Начало: `tools/agents/setup-tools.ps1`, затем `tools/agents/check.ps1`. Предпосылки и реальные MCP smoke-команды перечислены в TOOLS.

На Windows `.AGENTS` и `.agents` обозначают один каталог. Рабочие записи задач находятся отдельно в `task_state/`; в переносимый набор они не входят.
