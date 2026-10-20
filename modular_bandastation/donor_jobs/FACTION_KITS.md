# Комплекты, ID и PDA

Источник: Paradise SS220 `71c8bb1b88e29c352875865b362a1f8a99a205cc`, [T3](https://github.com/ss220club/Paradise-SS220/blob/71c8bb1b88e29c352875865b362a1f8a99a205cc/modular_ss220/jobs/code/donor/job/3_tier_jobs.dm), [T4](https://github.com/ss220club/Paradise-SS220/blob/71c8bb1b88e29c352875865b362a1f8a99a205cc/modular_ss220/jobs/code/donor/job/4_tier_jobs.dm), [ID](https://github.com/ss220club/Paradise-SS220/blob/71c8bb1b88e29c352875865b362a1f8a99a205cc/modular_ss220/jobs/code/card_id.dm). Одежда и её изображения перечислены отдельно в [FACTION_CLOTHING](FACTION_CLOTHING.md).

ТСФ и СССП имеют по две исходные донатные профессии. «Посетитель» — название туриста; «Дипломат», «Публицист ТСФ» и «Пресс-Секретарь СССП» — названия представителя. Все десять названий сохранены; отдельные вакансии и дополнительные комплекты для этих aliases исходник не задаёт.

| Комплект | Обязательные вещи сверх фракционной формы |
| --- | --- |
| Турист ТСФ | Синяя худи, combat boots, чёрная поясная сумка, fingerless gloves, запасные синие шорты |
| Турист СССП | Combat boots, красная поясная сумка, широкие sunglasses, fingerless gloves, запасные красные шорты и ушанка |
| Представитель ТСФ | Laceup shoes, чёрная поясная сумка, sunglasses, белые перчатки, telescopic baton, mining survival box, запасные синие шорты, death-alarm implanter, Zippo и Robust Gold |
| Представитель СССП | Combat boots, красная поясная сумка, sunglasses, чёрные перчатки, telescopic baton, mining survival box, запасные красные шорты и ушанка, death-alarm implanter, Zippo и Robust Gold |

У всех четырёх outfits обычный headset. Представители отдельно получают штатные mindshield/death-alarm implants: запасной implanter в сумке не заменяет установленный имплант. Backpack и его разновидности выбираются штатными preferences. PDA занимает правый карман, освобождая belt под сумку; `pda_slot` направляет штатный imprint и модульное отображение выбранного названия в тот же предмет.

Это адаптация к TG/BS, а не перенос чужого баланса и всех растровых изображений. Турист/представитель ТСФ переиспользуют существующие BS marine/commander uniforms. Combat boots, mining box, бельё, очки, поясные сумки, ушанка, implants/implanter и cigarettes используют существующие местные типы со своими свойствами. Худи использует native zipup/GAGS с цветом `#02519a` из исходной палитры; капюшон и застёжка остаются native, map preview хранится в модуле. Синий и гравированный source Zippo заменены уже существующим native fancy Zippo с engraving overlays. Отдельные blue/engraved sprites не импортируются. Представитель ТСФ использует обычные laceups: местный CentCom subtype добавил бы отсутствующую в исходном комплекте защиту от скольжения.

Языки следуют уже существующим фракционным outfits BS: `/datum/language/uncommon` для ТСФ, `/datum/language/spinwarder` (Неорусский) для СССП. Uncommon не называется исходным Tradeband. Новая language system не добавляется. Preview не выдаёт языки, содержимое сумок и импланты.

## ID-карты

Native advanced ID, job trim, wildcard limit, регистрация владельца, банковский account и доступы остаются штатными. Из BetterIDs используются только лицевые эмблемы на прозрачных trims, совмещённые с геометрией TG. Целые плоские Paradise карты и их backend не подменяют native renderer. Ordinary Prisoner сохраняет свою native карту и trim.

В исходнике Courier ссылается на отсутствующий `deliverer`, а Cleaning Manager — на отсутствующий `cleaningmanager`. Для эмблем явно используются существующие source states `courier` и `managerjanitor`. Варианты художника, подмастерья, дворецкого, горничной и Deliverer сохраняют доступы своей канонической роли. Гражданские фракционные карты не наследуют military TSF/USSP карту с CentCom authority.

## PDA

У исходных фракционных ролей обычный PDA; отдельных ТСФ/СССП PDA там нет. Native modular computers заменяют Paradise PDA и его cartridges/apps. У остальных outfits используются местные themed subtypes: casino/guard/butler/maid → bar, waiter → cook, acolyte → chaplain, wrestler/uncertain/administrator/dealer → curator, adjutant → lawyer, cleaning manager → janitor, seclown → clown, Deliverer → cargo. Подмастерье получает обычный crew PDA; остальные — crew. Prisoner PDA не получает.

Все девять используемых PDA presets — существующие типы BS. Их inventory, worn/inhand sprites, GAGS palettes и overlays не переопределяются; новые PDA типы, icon files или foreign colours не добавляются. После спавна меняются только данные владельца и отображаемое название выбранной роли. `donor_role_pdas` проверяет четыре исправленных комплекта через настоящую экипировку; `donor_faction_outfits` — обычный crew PDA и его регистрацию у каждой из четырёх фракционных ролей.

## Игровые карты и другие фракционные роли

Этот PR не переносит целые Paradise станции или USSP space ruins. 22 обычных и 22 постоянных override landmarks определены в модуле и используют native регистрацию/поиск. На существующих игровых картах новые donor landmarks пока не расставлены: обычные новые роли используют native arrivals, Cargo/Deliverer — существующие cargo starts, Prisoner — существующие prison starts и проверяемые безопасные prison клетки. Определение типа не подтверждает расстановку на DMM.

Проверенные production DMM, число существующих prison/cargo starts: Delta 8/8, IceBox 10/3, Meta 4/7, Tram 10/4, Nebula 10/9, Cyberiad 11/6, Kilo 5/9, Wawa 23/8. Все 81 prison starts находятся в prison areas. Это проверка файлов карт и маршрутов поиска; она не является клиентским проходом всех точек.

Source admin/military outfits ТСФ и СССП не являются дополнительными донатными профессиями этих tier-файлов. Их одежда сопоставлена в FACTION_CLOTHING; BS уже имеет собственные военные outfits. Импорт foreign guns, ammo, implants, military duties и случайных торговых комплектов из admin menu не является завершённой частью donor-feature.

`donor_faction_outfits` независимо проверяет перечисленные обязательные вещи, native ID/PDA, язык и preview. Общая `donor_job_outfits` проверяет выдачу объявленных вещей, переполнение и отсутствие повторных наград; она отдельно не доказывает полноту исходного комплекта. Проверки landmarks на тестовой клетке не доказывают расстановку на настоящей карте.
