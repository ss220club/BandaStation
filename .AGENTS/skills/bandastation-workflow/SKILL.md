---
name: bandastation-workflow
description: Work on BandaStation DM, tgui, maps and ports through real module extension points, task state and the build pipeline.
---

# Работа с BandaStation

Начни с [AGENTS.md](../../../AGENTS.md), [контекста](../../PROJECT_CONTEXT.md) и [правил модуляризации](../../WORKFLOW_RULES.md). Для нескольких этапов выбери явный TaskId по [TASK_STATE](../../TASK_STATE.md).

Проследи entrypoint → include → вызовы → состояние → потребитель. Новая логика — в `modular_bandastation/`; сначала используй существующий сигнал, override или собственное состояние. Проверки до `..()` и дополнение результата после `. = ..()` должны учитывать контракт результата и побочные эффекты. Не копируй штатный алгоритм и не оставляй upstream неисполняемым. Внутренняя инъекция минимальна, с `BANDASTATION EDIT`; для блока — START/END, без повторных inline-меток. Модульные файлы такими метками не обрамляй.

Код-стайл: [STYLE](../../../.github/guides/STYLE.md), [STANDARDS](../../../.github/guides/STANDARDS.md), [AUTODOC](../../../.github/guides/AUTODOC.md); [модуль-пример](../../../modular_bandastation/example/_example.dme). Проверяй реальные includes и потребителя, а не только наличие файла.

Сборка идёт через `tools/build/build.bat`. Для переводов редактируй TOML fragments, не generated `ru_names.toml`. Различай compile, targeted tests, DM runtime и веб-кадр. Весь diff к базе обязан сохранять рабочий штатный путь.

Общие инструкции и утилиты версионируются; task state и машинный MCP config локальны. Установка и реальные MCP-проверки — [TOOLS](../../TOOLS.md). Перед коммитом: `tools/agents/local-only.ps1 -Action check`, выбранные пути и `git diff --check`.
