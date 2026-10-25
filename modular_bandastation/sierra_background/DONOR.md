# Источники и атрибуция

## Механика SierraBay12

Источником механики четырёх категорий Background является [SierraBay12](https://github.com/SierraBay/SierraBay12/tree/40edecd4203679a060f826f00ff773964582a4c2), commit `40edecd4203679a060f826f00ff773964582a4c2`. Авторы исходного кода — участники SierraBay12/Baystation12; лицензия исходного репозитория — AGPL-3.0.

Исследованные компоненты:

- `code/modules/client/preference_setup/preference_setup.dm` и `background/01_culture.dm`: четыре категории, выбор, описания и сохранение.
- `code/controllers/subsystems/initialization/culture.dm` и `code/modules/culture_descriptor`: реестр культурных определений.
- `mods/expanded_culture_descriptor`, `mods/faction_background_grouping`, `mods/starmap_background` и `mods/_master_files/code/modules/culture_descriptor`: расширения каталога, доступность и окончательные описания.
- Объявления видов и startup hooks: значения по умолчанию и формирование списков.
- `background/02_language.dm`, `general/01_basic.dm` и `culture_descriptor/_culture.dm`: культурные языки и генерация имён.

Интеграция адаптирована к TGUI, preferences, language holders и именословам BandaStation. Донорские виды, каталоги лора, языки, коэффициенты экономики и автоматические связи места жительства с культурой или фракцией в игровой каталог не включены. Техническое имя `sierra_background` и ключи сохранения оставлены для совместимости.

## Лор BandaStation

Культуры, миры, принадлежности и верования основаны на согласованных автором документах, политической карте и отдельно разрешённых статьях wiki. Их адреса, версии, исходные абзацы и происхождение текста сохранены в метаданных соответствующих JSON.

Политическая карта: [SpaceStation220/SS220-Political-Map](https://github.com/SpaceStation220/SS220-Political-Map/tree/d6eebf606c4145b4e263e7f56093f811fcb2c684), ревизия `d6eebf606c4145b4e263e7f56093f811fcb2c684`. Авторские Google Docs описывают ТСФ, КССП, Элизиум, Вольные секторы, NanoTrasen, организации и скреллов. Пять полных описаний скреллианских генетических каст находятся в `data/skrell.json` со ссылкой на документ.

Дополнение [BandaStation wiki](https://bs.ss220.club/index.php/Заглавная_страница) разрешено для фелинидов, плазмаменов, ниан, эфириалов и церулеанцев. Конкретные страницы и ревизии перечислены в `data/wiki_species.json`. Статья церулеанцев не найдена; для них используются общие варианты. Google Doc скреллов имеет отдельно утверждённый приоритет; остальные разногласия решаются автором по каждому пункту. Подтверждённые уточнения перечислены в [README.md](README.md).

## Гаттер Элизиума

По решению автора элизианский Гаттер использует латинские речевые слоги Tradeband из Paradise-SS220. Источник — участники Paradise/SS220, AGPL-3.0, commit `0fffca1f1f29a63aff49d9b56524813eedf82c6d`: [`code/modules/mob/language.dm`, строки 455–469](https://github.com/ss220club/Paradise-SS220/blob/0fffca1f1f29a63aff49d9b56524813eedf82c6d/code/modules/mob/language.dm#L455). Список слогов, его порядок и повторы сохранены; поля адаптированы к language API BandaStation в `code/gutter.dm`.

Описание торговых картелей Tradeband и криминальный пиджин Paradise Gutter не перенесены. Лор языка взят из документа Элизиума, указанного в данных. Ввод использует штатный префикс BandaStation `,3`.

Именослов Элизиума — отдельный авторский набор с римской и неолатинской стилизацией, согласованной автором. Речевые слоги Tradeband не служат именами персонажей. Происхождение и авторское уточнение находятся в `data/name_profiles.json`; персонажи, титулы и организации других вселенных в именослов не заимствованы.
