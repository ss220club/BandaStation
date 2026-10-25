# Проверка предыстории

`run_tests.ps1` запускает регрессии интеграции Background. Описание функций и данных — в [README модуля](../../modular_bandastation/sierra_background/README.md), источники и атрибуция — в [DONOR.md](../../modular_bandastation/sierra_background/DONOR.md).

Из корня BandaStation в PowerShell 7, с установленными BYOND и native-библиотеками проекта:

```powershell
pwsh -File ./tools/sierra_background/run_tests.ps1
```

Если BYOND установлен в другой каталог:

```powershell
pwsh -File ./tools/sierra_background/run_tests.ps1 -ByondBin 'C:\BYOND\bin'
```

Скрипт находит группы `sierra_background_*` в `tests/*.dm` модуля, создаёт игнорируемую Git тестовую обёртку, компилирует и запускает отдельный тестовый мир. Используются изолированные тестовые сохранения; реальные файлы персонажей не используются. Дополнительно выполняются пять штатных проверок preferences и шесть проверок языков: смена вида, перенос и обмен сознаниями, сохранение независимых источников и конфликты префиксов.

Прогон успешен при завершении компиляции и сервера без ошибок, отсутствии runtime errors, наличии `clean_run.lk` и успешном результате каждой ожидаемой группы в `data/unit_tests.json`. Скрипт выводит путь к журналам конкретного запуска. Это серверные проверки; визуальную работу меню в настоящем BYOND-клиенте проверяют отдельно. Результаты и ограничения проверок описаны в [VALIDATION.md](../../modular_bandastation/sierra_background/VALIDATION.md).
