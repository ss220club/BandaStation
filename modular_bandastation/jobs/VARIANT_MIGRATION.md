# Job variant ID compatibility

Canonical job titles, displayed variant names, outfits and the `job_outfit_variants` save key are unchanged.
Character preference deserialization converts the following legacy PR11 IDs to semantic IDs.
Unknown jobs and IDs are preserved; the runtime resolver accepts current declarations and falls back to `default`.
The conversion is scoped to the canonical job title, idempotent, and does not require initialized jobs.

| Canonical job | Previous ID | Current ID | Displayed title |
| --- | --- | --- | --- |
| Acolyte | `title_fa2ad154cb` | `monk` | Монах |
| Acolyte | `title_1678dcfc2b` | `disciple` | Приспешник |
| Acolyte | `title_5bf3063650` | `follower` | Последователь |
| Acolyte | `title_ad3bbe9dea` | `ritualist` | Обрядчик |
| Actor | `title_980bd5882d` | `actor` | Актер |
| Actor | `title_e639ea25de` | `artist` | Артист |
| Actor | `title_666e779ffe` | `standup_comedian` | Стендапер |
| Actor | `title_402e7e66c9` | `comedian` | Комедиант |
| Actor | `title_b7d6ec5648` | `variety_artist` | Эстрадный Артист |
| Actor | `title_6f18f1d35f` | `painter` | Художник |
| Actor | `title_3e555ea0d3` | `creator` | Творец |
| Actor | `title_2e5c5324c9` | `art_critic` | Искусствовед |
| Actor | `title_461c5e40dd` | `landscape_painter` | Пейзажист |
| Actor | `title_404e8c6af6` | `photorealist` | Фотореалист |
| Actor | `title_ca1e1a3fe6` | `performance_artist` | Перфоманс-Артист |
| Adjutant | `title_676e2d10c4` | `butler` | Butler |
| Adjutant | `title_194cb4f395` | `butler_ru` | Дворецкий |
| Adjutant | `title_7076a8eeb7` | `maid` | Maid |
| Adjutant | `title_45cfde778e` | `maid_ru` | Горничная |
| Administrator | `title_d20908b6e6` | `service_administrator` | Сервис-Администратор |
| Administrator | `title_1e7d8aded0` | `steward` | Сервис-Управитель |
| Administrator | `title_b4112b1abe` | `pompadour` | Помпадур |
| Administrator | `title_e3c0153ea3` | `service_manager` | Сервис-Менеджер |
| Banker | `title_a9bad37f6c` | `independent_banker` | Независимый Банкир |
| Banker | `title_be26aa1f6c` | `corporate` | Корпорат |
| Banker | `title_8186c90396` | `businessman` | Бизнесмен |
| Banker | `title_dfd2a4023a` | `nt_banker` | Банкир NT |
| Banker | `title_9b812edd4a` | `nt_corporate` | Корпорат NT |
| Banker | `title_cffc8f2bc5` | `nt_businessman` | Бизнесмен NT |
| Barber | `title_6f6165b91f` | `stylist` | Стилист |
| Barber | `title_2c81d24615` | `salon_owner` | Хозяин Студии Красоты |
| Barber | `title_9c317438ff` | `makeup_artist` | Визажист |
| Barber | `title_23113d9e46` | `coiffeur` | Куафёр |
| Barber | `title_ccd298be8c` | `hairdresser` | Цирюльник |
| Barber | `title_fd889e9fdb` | `barber` | Брадобрей |
| Bath | `title_59b875790f` | `bath_owner` | Хозяин Бани |
| Bath | `title_4bed95ffa5` | `bath_steamer` | Парильщик |
| Bath | `title_298399a251` | `bath_master` | Пармейстер |
| JOB_CARGO_TECHNICIAN | `title_c3e626e8a5` | `deliverer` | Deliverer |
| JOB_CARGO_TECHNICIAN | `title_9bc06590d6` | `deliverer_ru` | Доставщик |
| JOB_CARGO_TECHNICIAN | `title_1044de84e6` | `porter` | Переносчик |
| Casino | `title_decf6968b3` | `dealer` | Дилер |
| Casino | `title_6412089ad5` | `slot_assistant` | Слот-Ассистент |
| Casino | `title_2c5efdcd59` | `pit_boss` | Пит-Босс |
| Cleaning Manager | `title_af28e87894` | `cleaning_manager` | Менеджер по Клинингу |
| Cleaning Manager | `title_699f9246d9` | `rat_catcher` | Ловец Крыс |
| Cleaning Manager | `title_2182b9664c` | `cleaner_1` | Уборщик I-разряда |
| Cleaning Manager | `title_b00e6b3ad8` | `cleaner_2` | Уборщик II-разряда |
| Cleaning Manager | `title_e84a0954fc` | `cleaner_3` | Уборщик III-разряда |
| Cleaning Manager | `title_e0b933da94` | `cleaner_4` | Уборщик IV-разряда |
| Cleaning Manager | `title_a3e33fb604` | `cleaner_5` | Уборщик V-разряда |
| Cleaning Manager | `title_fb98757975` | `apprentice` | Подмастерье |
| Cleaning Manager | `title_35f098909c` | `maintenance_assistant` | Ассистент-Механик |
| Cleaning Manager | `title_5e938821f0` | `assistant_1` | Ассистент I-го разряда |
| Cleaning Manager | `title_d28fdcea7d` | `assistant_2` | Ассистент II-го разряда |
| Cleaning Manager | `title_aebaad8051` | `assistant_3` | Ассистент III-го разряда |
| Cleaning Manager | `title_f9f1c4fee5` | `assistant_4` | Ассистент IV-го разряда |
| Cleaning Manager | `title_8a2af0d4de` | `assistant_5` | Ассистент V-го разряда |
| Dealer | `title_5b94e95f0b` | `security_seller` | Независимый Торговец |
| Dealer | `title_1c1fc9e1f6` | `merchant` | Сдельщик |
| Dealer | `title_548b9257d9` | `philanthropist` | Барахольщик |
| Dealer | `title_2fe62dd819` | `trader` | Меценат |
| Dealer | `title_e4a058f1e6` | `junk_dealer` | Коммерсант |
| Guard | `title_80a6d55193` | `bodyguard` | Охранник |
| Guard | `title_d56e622369` | `external_guard` | Сторож Сервиса |
| Guard | `title_02173d4901` | `technical_guard` | Охранник Сервиса |
| Guard | `title_82bdb3534d` | `personal_guard` | Вышибала Сервиса |
| Musician | `title_1d6c0e0483` | `maestro` | Маэстро |
| Musician | `title_89d350c8f3` | `guitarist` | Гитарист |
| Musician | `title_5369d65484` | `drummer` | Барабанщик |
| Musician | `title_8e41d8e8c6` | `pianist` | Пианист |
| Musician | `title_01a03ad63b` | `piper` | Волынщик |
| Musician | `title_77f89f1bf1` | `violinist` | Скрипач |
| Musician | `title_0a2f7ed94c` | `jester` | Скоморох |
| Musician | `title_80547d2c80` | `saxophonist` | Саксофонист |
| Musician | `title_524b7f6098` | `soloist` | Солист |
| Musician | `title_686160ec02` | `singer` | Певец |
| Musician | `title_32be51e83f` | `touring_musician` | Гастролер |
| JOB_PRISONER | `title_f095933019` | `prisoner` | Заключенный |
| JOB_PRISONER | `title_b4b118ef86` | `felon` | Уголовник |
| JOB_PRISONER | `title_d49f7780c4` | `lawbreaker` | Законопреступник |
| JOB_PRISONER | `title_3f92b3561f` | `permanent_prisoner` | Пермазаключенный |
| JOB_PRISONER | `title_ccb8d414fd` | `illegal_migrant` | Нелегальный Мигрант |
| JOB_PRISONER | `title_fb54083629` | `illegal_worker` | Нелегальный Работник |
| JOB_PRISONER | `title_5aaf5a10d4` | `lifer` | Пожизненно-Заключенный |
| JOB_PRISONER | `title_efc5efc07d` | `political_prisoner` | Политический Заключенный |
| JOB_PRISONER | `title_12ea21d982` | `criminal` | Заключенный Преступник |
| JOB_PRISONER | `title_51658087b8` | `bandit` | Заключенный Бандит |
| JOB_PRISONER | `title_7fd85bb83b` | `conman` | Заключенный Мошенник |
| JOB_PRISONER | `title_29e731561e` | `thief` | Заключенный Вор |
| JOB_PRISONER | `title_2c9f46ef15` | `murderer` | Заключенный Убийца |
| JOB_PRISONER | `title_80cc8cd7d4` | `drug_dealer` | Заключенный Наркоторговец |
| JOB_PRISONER | `title_a8be352fd0` | `recidivist` | Заключенный Рецидивист |
| JOB_PRISONER | `title_3c5e9af02c` | `saboteur` | Заключенный Саботер |
| JOB_PRISONER | `title_f3e52e13db` | `torturer` | Заключенный Мучитель |
| JOB_PRISONER | `title_224ed57414` | `swindler` | Заключенный Жулик |
| JOB_PRISONER | `title_fa2a83402f` | `scoundrel` | Заключенный Негодяй |
| JOB_PRISONER | `title_68303ec240` | `hooligan` | Заключенный Хулиган |
| JOB_PRISONER | `title_c298f2d33f` | `nt_enemy` | Заключенный Враг-NT |
| JOB_PRISONER | `title_17b4c084eb` | `mafioso` | Заключенный Мафиози |
| JOB_PRISONER | `title_52e5e8a719` | `corrupt_official` | Заключенный Коррупционер |
| JOB_PRISONER | `title_af200c4bc2` | `psychopath` | Заключенный Психопат |
| JOB_PRISONER | `title_3c00350498` | `counterfeiter` | Заключенный Фальшивокредитчик |
| JOB_PRISONER | `title_1aca9d1c4c` | `slaver` | Заключенный Работорговец |
| Representative TSF | `title_ca11487592` | `diplomat` | Дипломат ТСФ |
| Representative TSF | `title_7f78932f04` | `publicist` | Публицист ТСФ |
| Representative USSP | `title_30ed7adb53` | `diplomat` | Дипломат СССП |
| Representative USSP | `title_8e7b375145` | `press_secretary` | Пресс-Секретарь СССП |
| Security Clown | `title_8cd08702d6` | `security_clown` | Клоун Службы Безопасности |
| Security Clown | `title_190bf220ef` | `detective` | Клоун-Детектив |
| Security Clown | `title_a22b40d7a4` | `warden` | Клоун-Смотритель |
| Security Clown | `title_2384147c33` | `honkective` | Хонкектив |
| Security Clown | `title_410a1ecab5` | `cadet` | Клоун Кадет |
| Tourist TSF | `title_60a05c3bd2` | `visitor` | Посетитель ТСФ |
| Tourist USSP | `title_7edf192313` | `visitor` | Посетитель СССП |
| Uncertain | `title_56a54c66c1` | `unemployed_assistant` | Безработный Ассистент |
| Uncertain | `title_991a8712f0` | `free_assistant` | Свободный Ассистент |
| Uncertain | `title_243891c037` | `working_off_debt_assistant` | Отрабатыващий Ассистент |
| Uncertain | `title_72948e94fd` | `maintenance_assistant` | Ассистент Технических Тоннелей |
| VIP Corporate Guest | `title_d99248469b` | `vip_guest` | VIP Гость |
| VIP Corporate Guest | `title_b8153714bb` | `vip_person` | VIP Персона |
| VIP Corporate Guest | `title_d0f83cbdf0` | `nt_vip_guest` | VIP Гость NT |
| VIP Corporate Guest | `title_cc3777df37` | `nt_vip_person` | VIP Персона NT |
| VIP Corporate Guest | `title_2a652650f5` | `nt_corporate_guest` | Гость Корпорации NT |
| Waiter | `title_c86b39312d` | `service_host` | Хост Сервиса |
| Wrestler | `title_fa0e90435e` | `referee` | Рефери |
| Wrestler | `title_894d7eccc6` | `trainer` | Тренер |
| Wrestler | `title_1fac104508` | `boxer` | Боксёр |
| Wrestler | `title_0b7ca27e25` | `athlete` | Спортсмен |

`DONOR_MUSICAN` remains the existing jobconfig tag for deployment compatibility. The internal DM path is `musician`.
DM item/job/outfit paths introduced by PR11 were renamed before merge; references in the source/include graph are updated together.
DMI icon states remain unchanged, including the hoodie state whose literal contains the previous typepath.
