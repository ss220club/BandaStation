# Контекст BandaStation

Карта проверена на базе `820de7f6ef9235d8417250cb01eec15da6735b18`, 2026-10-24. При продолжении сверяй текущие исходники и конфиги; номера версий не бери из старых отчётов.

| Область | Источник фактов |
| --- | --- |
| DM include graph | `tgstation.dme` → `code/` и `modular_bandastation/modular_bandastation.dme` |
| Модули | `modular_bandastation/<module>/_*.dme`, `_*.dm`, `code/`; [пример](../modular_bandastation/example/_example.dme) |
| Штатный код | `code/`; добавочные изменения отмечаются `BANDASTATION EDIT` |
| Карты | `_maps/`, их конфиги/includes, [maplint](../tools/maplint/README.md), `tools/mapmerge2/` |
| Ресурсы | `icons/`, `sound/`, модульные каталоги; проверяй DM binding и runtime |
| TGUI | `tgui/packages/`, `tgui/package.json`, lock/config; [руководство](../tgui/README.md) |
| Переводы имён | `modular_bandastation/translations/public/ru_names/*.toml` → `tools/translations/merge_ru_names.py` → generated `ru_names.toml` |
| Сборка | `BUILD.cmd` → `tools/build/build.bat` → `tools/bootstrap/javascript.bat` → `tools/build/build.ts` |
| Версии | `dependencies.sh`, `.tgs.yml`, package locks; для pipeline используй его bootstrap |
| Проверки | `.github/workflows/run_linters.yml`, `ci_suite.yml`, [DM unit tests](../code/modules/unit_tests/README.md) |

Не редактируй generated `ru_names.toml` вручную. Include-инспектор читает текстовые ссылки, а не выполняет препроцессор DM. Проверь условия подключения и реального потребителя нового файла.

Код-стайл и правила — [STYLE](../.github/guides/STYLE.md), [STANDARDS](../.github/guides/STANDARDS.md), [AUTODOC](../.github/guides/AUTODOC.md), [CONTRIBUTING](../.github/CONTRIBUTING.md). Для собственной логики сначала прочитай [правила расширения](WORKFLOW_RULES.md).

Имена Git remotes не гарантируют их назначение: перед синхронизацией проверь адреса, точные refs и локальные коммиты. Не переноси структуру каталогов, API и соглашения другого SS13-билда без проверки по этой базе.
