import { ReactNode } from 'react';
import {
  Box,
  Button,
  Dimmer,
  Divider,
  Icon,
  Input,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

enum SpellCategory {
  Offensive = 'Наступление',
  Defensive = 'Защита',
  Mobility = 'Мобильность',
  Assistance = 'Поддержка',
  Rituals = 'Ритуалы',
  Perks = 'Перки',
}

type byondRef = string;

type SpellEntry = {
  // Name of the spell
  name: string;
  // Description of what the spell does
  desc: string;
  // Byond REF of the spell entry datum
  ref: byondRef;
  // Whether the spell requires wizard clothing to cast
  requires_wizard_garb: BooleanLike;
  // Spell points required to buy the spell
  cost: number;
  // How many times the spell has been bought
  times: number;
  // Cooldown length of the spell once cast once
  cooldown: number;
  // Category of the spell
  cat: SpellCategory;
  // Whether the spell is refundable
  refundable: BooleanLike;
  // The verb displayed when buying
  buyword: Buywords;
};

type Data = {
  owner: string;
  points: number;
  semi_random_bonus: number;
  full_random_bonus: number;
  entries: SpellEntry[];
};

type TabType = {
  title: string;
  blurb?: string;
  component?: () => ReactNode;
  locked?: boolean;
  scrollable?: boolean;
};

const TAB2NAME: TabType[] = [
  {
    title: 'Вписанное имя',
    blurb:
      'Эта книга подчиняется только своему владельцу и, конечно, обязана иметь его. Постоянство договора между книгой заклинаний и ее владельцем гарантирует, что такой могущественный артефакт не может попасть в руки врага или быть использован в нарушение правил Федерации, например, для обмена заклинаний.',
    component: () => <EnscribedName />,
  },
  {
    title: 'Содержание',
    component: () => <TableOfContents />,
  },
  {
    title: 'Наступление',
    blurb: 'Заклинания и предметы, направленные на ослабление и разрушение.',
    scrollable: true,
  },
  {
    title: 'Защита',
    blurb:
      'Заклинания и предметы, направленные на повышение вашей живучести или снижение способности противников к атаке.',
    scrollable: true,
  },
  {
    title: 'Мобильность',
    blurb:
      'Заклинания и предметы, направленные на улучшение способности к передвижению. Хорошо бы взять хотя бы одно.',
    scrollable: true,
  },
  {
    title: 'Поддержка',
    blurb:
      'Заклинания и предметы, направленные на привлечение внешних сил для помощи вам или улучшение других предметов и способностей.',
    scrollable: true,
  },
  {
    title: 'Испытания',
    blurb:
      'Федерация волшебников ищет демонстрации силы. Вооружая станцию против вас, вы увеличиваете опасность, но получаете больше зарядов для книги заклинаний.',
    locked: true,
    scrollable: true,
  },
  {
    title: 'Ритуалы',
    blurb:
      'Эти мощные заклинания изменяют саму ткань реальности. Не всегда в вашу пользу.',
    scrollable: true,
  },
  {
    title: 'Наборы',
    blurb:
      'Федерация волшебников признает, что иногда выбор бывает нелегким. Здесь вы можете выбрать один из одобренных вариантов снаряжения волшебника.',
    component: () => <Loadouts />,
  },
  {
    title: 'Случайный выбор',
    blurb:
      'Если вам не понравились предложенные варианты снаряжения, вы можете принять хаос. Не рекомендуется для начинающих волшебников.',
    component: () => <Randomize />,
  },
  {
    title: 'Перки',
    blurb:
      'Perks are useful (and not so useful) improvements to the soul and body collected from all corners of the universe.',
    scrollable: true,
  },
  {
    title: 'Table of Contents',
    component: () => <TableOfContents />,
  },
];

enum Buywords {
  Learn = 'Выучить',
  Summon = 'Призвать',
  Cast = 'Провести',
}

const BUYWORD2ICON = {
  Learn: 'plus',
  Summon: 'hat-wizard',
  Cast: 'meteor',
};

const EnscribedName = (props) => {
  const { data } = useBackend<Data>();
  const { owner } = data;
  return (
    <>
      <Box
        mt={25}
        mb={-3}
        fontSize="50px"
        color="bad"
        textAlign="center"
        fontFamily="Ink Free"
      >
        {owner}
      </Box>
      <Divider />
    </>
  );
};

const lineHeightToc = '30.6px';

const TableOfContents = (props) => {
  const [tabIndex, setTabIndex] = useLocalState('tab-index', 1);
  return (
    <Box textAlign="center">
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="pen"
        disabled
        content="Именная пропись"
      />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="clipboard"
        disabled
        content="Содержание"
      />
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="fire"
        content="Смертоносные заклинания"
        onClick={() => setTabIndex(3)}
      />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="shield-alt"
        content="Защитные заклинания"
        onClick={() => setTabIndex(3)}
      />
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="globe-americas"
        content="Магическое перемещение"
        onClick={() => setTabIndex(5)}
      />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="users"
        content="Поддержка и призывы"
        onClick={() => setTabIndex(5)}
      />
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="crown"
        content="Испытания"
        onClick={() => setTabIndex(7)}
      />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="magic"
        content="Ритуалы"
        onClick={() => setTabIndex(7)}
      />
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="thumbs-up"
        content="Наборы снаряжения, одобренные волшебниками"
        onClick={() => setTabIndex(9)}
      />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="dice"
        content="Магический рандомайзер"
        onClick={() => setTabIndex(9)}
      />
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="cog"
        content="Перки"
        onClick={() => setTabIndex(11)}
      />
    </Box>
  );
};

const LockedPage = (props) => {
  const { act, data } = useBackend<Data>();
  const { owner } = data;
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item>
          <Icon color="purple" name="lock" size={10} />
        </Stack.Item>
        <Stack.Item fontSize="18px" color="purple">
          Федерация волшебников закрыла эту страницу.
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const PointLocked = (props) => {
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item>
          <Icon color="purple" name="dollar-sign" size={10} />
          <div
            style={{
              background: 'purple',
              bottom: '60%',
              left: '33%',
              height: '10px',
              position: 'relative',
              transform: 'rotate(45deg)',
              width: '150px',
            }}
          />
        </Stack.Item>
        <Stack.Item fontSize="14px" color="purple">
          У вас недостаточно очков для использования этой страницы.
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

type WizardLoadout = {
  loadoutId: string;
  loadoutColor: string;
  name: string;
  blurb: string;
  icon: string;
  author: string;
};

const SingleLoadout = (props: WizardLoadout) => {
  const { act } = useBackend<WizardLoadout>();
  const { author, name, blurb, icon, loadoutId, loadoutColor } = props;
  return (
    <Stack.Item fontSize="10px" grow>
      <Section width={LoadoutWidth} title={name}>
        {blurb}
        <Divider />
        <Button.Confirm
          confirmContent="Подтвердить покупку?"
          confirmIcon="dollar-sign"
          confirmColor="good"
          fluid
          icon={icon}
          content="Приобрести набор"
          onClick={() =>
            act('purchase_loadout', {
              id: loadoutId,
            })
          }
        />
        <Divider />
        <Box color={loadoutColor}>Добавлен {author}.</Box>
      </Section>
    </Stack.Item>
  );
};

const LoadoutWidth = 19.17;

const Loadouts = (props) => {
  const { data } = useBackend<Data>();
  const { points } = data;
  // Future todo : Make these datums on the DM side
  return (
    <Stack ml={0.5} mt={-0.5} vertical fill>
      {points < 10 && <PointLocked />}
      <Stack.Item>
        <Stack fill>
          <SingleLoadout
            loadoutId="loadout_classic"
            loadoutColor="purple"
            name="Классический маг"
            icon="fire"
            author="Архиканцлер Грей"
            blurb={`
                Это классический маг, был безумно популярным в
                2550-е годы. Поставляется с Fireball, Magic Missile,
                Ei Nath, и Ethereal Jaunt. Ключевой момент тут в том, что
                каждый элемент этого набора очень легко освоить и использовать.
              `}
          />
          <SingleLoadout
            name="Сила Мьёльнира"
            icon="hammer"
            loadoutId="loadout_hammer"
            loadoutColor="green"
            author="Джегудиэль Ворлдшейкер"
            blurb={`
                Сила могучего Мьёльнира! Лучше не терять его.
                Этот набор содержит Summon Item, Mutate, Blink, Force Wall,
                Tesla Blast, и Мьёлнир. Mutate это ваша поддержка в данном случае:
                Используйте его для стрельбы с ограниченным радиусом действия и выхода из плохих блинков.
              `}
          />
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <SingleLoadout
            name="Фантастическая армия"
            icon="pastafarianism"
            loadoutId="loadout_army"
            loadoutColor="yellow"
            author="Просперо Спеллстоун"
            blurb={`
                Зачем убивать, если другие с радостью сделают это за вас?
                Устройте хаос с помощью своего набора: Soulshards, Staff of Change,
                Necro Stone, Teleport, and Jaunt! Помните, у вас нет атакующих заклинаний!
              `}
          />
          <SingleLoadout
            name="Ловец душ"
            icon="skull"
            loadoutId="loadout_tap"
            loadoutColor="white"
            author="Том Пустотный"
            blurb={`
                Примите темноту и откройте свою душу.
                Вы можете перезаряжать очень длинные заклинания
                как Ei Nath перемещаясь в новые тела с помощью
                Mind Swap и начинать ловить души заного.
              `}
          />
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const lineHeightRandomize = 3;

const Randomize = (props) => {
  const { act, data } = useBackend<Data>();
  const { points, semi_random_bonus, full_random_bonus } = data;
  return (
    <Stack fill vertical>
      {points < 10 && <PointLocked />}
      <Stack.Item>
        С полурандомизацией вы гарантированно получите хотя бы некоторую
        мобильность и смертоносность. Гарантированно имеет заклинания стоймостью{' '}
        {semi_random_bonus} очков.
      </Stack.Item>
      <Stack.Item>
        <Button.Confirm
          confirmContent="Ковабунга?"
          confirmIcon="dice-three"
          lineHeight={lineHeightRandomize}
          fluid
          icon="dice-three"
          content="Полу-рандомизация!"
          onClick={() => act('semirandomize')}
        />
        <Divider />
      </Stack.Item>
      <Stack.Item>
        Полный рандом даст вам все, что угодно. Тут также нет пути назад!
        Гарантированно имеет заклинания стоймостью {full_random_bonus} очков.
      </Stack.Item>
      <Stack.Item>
        <NoticeBox danger>
          <Button.Confirm
            confirmContent="Ковабунга?"
            confirmIcon="dice"
            lineHeight={lineHeightRandomize}
            fluid
            color="black"
            icon="dice"
            content="Полный рандом!"
            onClick={() => act('randomize')}
          />
        </NoticeBox>
      </Stack.Item>
    </Stack>
  );
};

const SearchSpells = (props) => {
  const { data } = useBackend<Data>();
  const [spellSearch] = useLocalState('spell-search', '');
  const { entries } = data;

  const filterEntryList = (entries: SpellEntry[]) => {
    const searchStatement = spellSearch.toLowerCase();
    if (searchStatement === 'robeless') {
      // Lets you just search for robeless spells, you're welcome mindswap-bros
      return entries.filter((entry) => !entry.requires_wizard_garb);
    }

    return entries.filter(
      (entry) =>
        entry.name.toLowerCase().includes(searchStatement) ||
        // Unsure about including description. Wizard spell descriptions
        // are painfully original and use the same verbiage often,
        // which may both be a benefit and a curse
        entry.desc.toLowerCase().includes(searchStatement) ||
        // Also opting to include category
        // so you can search "rituals" to see them all at once
        entry.cat.toLowerCase().includes(searchStatement),
    );
  };

  const filteredEntries = filterEntryList(entries);

  if (filteredEntries.length === 0) {
    return (
      <Stack width="100%" vertical>
        <Stack.Item>
          <NoticeBox>{`Заклинаний не найдено!`}</NoticeBox>
        </Stack.Item>
        <Stack.Item>
          <Box italic align="center" color="lightgrey">
            {`Совет по поиску: При поиске «Robeless» вы увидите только
            заклинания, не требующие облачения волшебника!`}
          </Box>
        </Stack.Item>
      </Stack>
    );
  }
  return (
    <SpellTabDisplay
      TabSpells={filteredEntries}
      CooldownOffset={32}
      PointOffset={84}
    />
  );
};

const SpellTabDisplay = (props: {
  TabSpells: SpellEntry[];
  CooldownOffset?: number;
  PointOffset?: number;
}) => {
  const { act, data } = useBackend<Data>();
  const { points } = data;
  const { TabSpells, CooldownOffset, PointOffset } = props;

  const getTimeOrCat = (entry: SpellEntry) => {
    if (entry.cat === SpellCategory.Rituals) {
      if (entry.times) {
        return `Проведено ${entry.times} раз.`;
      } else {
        return 'Еще не проведено.';
      }
    } else {
      if (entry.cooldown) {
        return `Перезарядка: ${entry.cooldown} сек.`;
      } else {
        return '';
      }
    }
  };

  return (
    <Stack vertical>
      {TabSpells.sort((a, b) => a.name.localeCompare(b.name)).map((entry) => (
        <Stack.Item key={entry.name}>
          <Divider />
          <Stack mt={1.3} width="100%" position="absolute" textAlign="left">
            <Stack.Item width="150px" ml={CooldownOffset}>
              {getTimeOrCat(entry)}
            </Stack.Item>
            <Stack.Item width="60px" ml={PointOffset}>
              {entry.cost} очков
            </Stack.Item>
            {entry.buyword === Buywords.Learn && (
              <Stack.Item>
                <Button
                  mt={-0.8}
                  icon="tshirt"
                  color={entry.requires_wizard_garb ? 'bad' : 'green'}
                  tooltipPosition="bottom-start"
                  tooltip={
                    entry.requires_wizard_garb
                      ? 'Требуется одежда волшебника.'
                      : 'Может применяться без одежды волшебника.'
                  }
                />
              </Stack.Item>
            )}
          </Stack>
          <Section title={entry.name}>
            <Stack>
              <Stack.Item grow>{entry.desc}</Stack.Item>
              <Stack.Item>
                <Divider vertical />
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  textAlign="center"
                  color={points >= entry.cost ? 'green' : 'bad'}
                  disabled={points < entry.cost}
                  width={7}
                  icon={BUYWORD2ICON[entry.buyword]}
                  content={entry.buyword}
                  onClick={() =>
                    act('purchase', {
                      spellref: entry.ref,
                    })
                  }
                />
                <br />
                {(!entry.refundable && (
                  <NoticeBox>Без возврата.</NoticeBox>
                )) || (
                  <Button
                    textAlign="center"
                    width={7}
                    icon="arrow-left"
                    content="Возврат"
                    onClick={() =>
                      act('refund', {
                        spellref: entry.ref,
                      })
                    }
                  />
                )}
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      ))}
    </Stack>
  );
};

const CategoryDisplay = (props: { ActiveCat: TabType }) => {
  const { data } = useBackend<Data>();
  const { entries } = data;
  const { ActiveCat } = props;

  const TabSpells = entries.filter((entry) => entry.cat === ActiveCat.title);

  return (
    <>
      {!!ActiveCat.locked && <LockedPage />}
      <Stack vertical>
        {ActiveCat.blurb && (
          <Stack.Item>
            <Box textAlign="center" bold height="50px">
              {ActiveCat.blurb}
            </Box>
          </Stack.Item>
        )}
        <Stack.Item>
          {(ActiveCat.component && ActiveCat.component()) || (
            <SpellTabDisplay TabSpells={TabSpells} PointOffset={38} />
          )}
        </Stack.Item>
      </Stack>
    </>
  );
};

const widthSection = '466px';
const heightSection = '456px';

export const Spellbook = (props) => {
  const { data } = useBackend<Data>();
  const { points } = data;
  const [tabIndex, setTabIndex] = useLocalState('tab-index', 1);
  const [spellSearch, setSpellSearch] = useLocalState('spell-search', '');
  const ActiveCat = TAB2NAME[tabIndex - 1];
  const ActiveNextCat = TAB2NAME[tabIndex];

  // Has a chance of selecting a random funny verb instead of "Searching"
  const SelectSearchVerb = () => {
    let found = Math.random();
    if (found <= 0.03) {
      return 'Просматривание';
    }
    if (found <= 0.06) {
      return 'Размышление';
    }
    if (found <= 0.09) {
      return 'Гадание';
    }
    if (found <= 0.12) {
      return 'Прорицание';
    }
    if (found <= 0.15) {
      return 'Подсматривание';
    }
    if (found <= 0.18) {
      return 'Обдумывание';
    }
    if (found <= 0.21) {
      return 'Разгадывание';
    }
    if (found <= 0.24) {
      return 'Вглядывание';
    }
    if (found <= 0.27) {
      return 'Изучение';
    }
    if (found <= 0.3) {
      return 'Рассмотрение';
    }

    return 'Поиск';
  };

  const SelectedVerb = SelectSearchVerb();

  return (
    <Window title="Книга заклинаний" theme="wizard" width={950} height={540}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack fill>
              {spellSearch.length > 1 ? (
                <Stack.Item grow>
                  <Section
                    title={`${SelectedVerb}...`}
                    scrollable
                    height={heightSection}
                    fill
                    buttons={
                      <Button
                        content={`Отмена ${SelectedVerb}`}
                        icon="arrow-rotate-left"
                        onClick={() => setSpellSearch('')}
                      />
                    }
                  >
                    <SearchSpells />
                  </Section>
                </Stack.Item>
              ) : (
                <>
                  <Stack.Item grow>
                    <Section
                      scrollable={ActiveCat.scrollable}
                      textAlign="center"
                      width={widthSection}
                      height={heightSection}
                      fill
                      title={ActiveCat.title}
                      buttons={
                        <>
                          <Button
                            mr={48.55}
                            disabled={tabIndex === 1}
                            icon="arrow-left"
                            content="Предыдущая страница"
                            onClick={() => setTabIndex(tabIndex - 2)}
                          />
                          <Box textAlign="right" bold mt={-3.3} mr={1}>
                            {tabIndex}
                          </Box>
                        </>
                      }
                    >
                      <CategoryDisplay ActiveCat={ActiveCat} />
                    </Section>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Section
                      scrollable={ActiveNextCat.scrollable}
                      textAlign="center"
                      width={widthSection}
                      height={heightSection}
                      fill
                      title={ActiveNextCat.title}
                      buttons={
                        <>
                          <Button
                            mr={0}
                            icon="arrow-right"
                            disabled={tabIndex === 11}
                            content="Далее"
                            onClick={() => setTabIndex(tabIndex + 2)}
                          />
                          <Box textAlign="left" bold mt={-3.3} ml={-59.8}>
                            {tabIndex + 1}
                          </Box>
                        </>
                      }
                    >
                      <CategoryDisplay ActiveCat={ActiveNextCat} />
                    </Section>
                  </Stack.Item>
                </>
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item grow>
                  <ProgressBar value={points / 10}>
                    {points + ' оставшихся очков.'}
                  </ProgressBar>
                </Stack.Item>
                <Stack.Item>
                  <Input
                    width={15}
                    placeholder="Поиск заклинания..."
                    onChange={setSpellSearch}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
