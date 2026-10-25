# Источники тенедемона

Порт из [ss220club/Paradise-SS220](https://github.com/ss220club/Paradise-SS220/tree/0fffca1f1f29a63aff49d9b56524813eedf82c6d),
зафиксированный коммит `0fffca1f1f29a63aff49d9b56524813eedf82c6d`.
Перенесённые механики и адаптации этого модуля распространяются под AGPL-3.0;
полный текст находится в `LICENSE-AGPLv3.txt` рядом с этим файлом.

Спрайты и звуки — CC BY-SA 3.0 по лицензии ресурсов донора:
[README](https://github.com/ss220club/Paradise-SS220/blob/0fffca1f1f29a63aff49d9b56524813eedf82c6d/README.md),
[текст лицензии](https://github.com/ss220club/Paradise-SS220/blob/0fffca1f1f29a63aff49d9b56524813eedf82c6d/LICENSE-CC-BY-SA-3.0.txt).

| Ресурс | Автор / исходный PR |
| --- | --- |
| Тенедемон, теневые переходы, кнопки, рука, луч захвата и флакон тьмы | hal9000PR, [Paradise #19732](https://github.com/ParadiseSS13/Paradise/pull/19732) |
| Текущий спрайт кокона | McRamon, [Paradise #21012](https://github.com/ParadiseSS13/Paradise/pull/21012) |
| Все десять звуков `sound/shadowdemon/*.ogg` | Stoniest, [Paradise #23052](https://github.com/ParadiseSS13/Paradise/pull/23052) |
| Перевод донора на basic mobs | PollardTheDragon, Burzah, [Paradise #30660](https://github.com/ParadiseSS13/Paradise/pull/30660) |

Исходные состояния извлечены в небольшие DMI без изменения пикселей, направлений,
кадров или задержек анимации. Звуки скопированы побайтово. `assets.json` содержит
входные и выходные хэши. Воспроизведение и проверка: `tools/shadow_demon/extract_assets.py`.
Существующие звуки и спрайт сердца из основной кодовой базы используются по их
существующей лицензии.

`images/preview.png` — обзорный лист из этих спрайтов для ревью; это не игровой скриншот.
