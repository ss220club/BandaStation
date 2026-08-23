import { useState } from 'react';
import { Box, Button, Dropdown, Icon, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  credits_stored: number;
  tc_price: number;
  tc_purchase_limit: number;
  tc_purchased: number;
  active: boolean;
  attached: boolean;
  nearby_players: { name: string; ref: string }[];
};

export const CreditSiphon = () => {
  const { act, data } = useBackend<Data>();
  const {
    credits_stored,
    tc_price,
    tc_purchase_limit,
    tc_purchased,
    active,
    attached,
    nearby_players = [],
  } = data;
  const [target, setTarget] = useState('');
  const targetOptions = nearby_players.map((player) => ({
    displayText: player.name,
    value: player.ref,
  }));

  return (
    <Window
      width={380}
      height={450}
      title="Hacking Initialized.."
      theme="hackerman"
    >
      <Window.Content style={{ fontFamily: 'Verdana, sans-serif' }}>
        <Section title="Сохранённые кредиты">
          <Box textAlign="center" fontSize={2} mb={2}>
            {credits_stored} cr <Icon color="gold" name="coins" />
          </Box>
          <Button
            fluid
            icon={active ? 'power-off' : 'play'}
            color={active ? 'red' : 'green'}
            onClick={() => act('toggle')}
          >
            {active ? 'Выключить фишинг-бот' : 'Включить фишинг-бот'}
          </Button>
          <Button
            fluid
            icon="user-secret"
            disabled={attached || !target}
            onClick={() => act('attach', { target })}
          >
            {attached
              ? 'Прикреплён к жертве'
              : 'Прикрепить вирус к ближайшей жертве'}
          </Button>
          <Dropdown
            buttons
            fluid
            disabled={attached || !targetOptions.length}
            options={targetOptions}
            selected={target}
            displayText={
              targetOptions.find((option) => option.value === target)
                ?.displayText
            }
            placeholder="Выберите ближайшую жертву"
            onSelected={(value) => setTarget(String(value))}
          />
          <Button
            fluid
            icon="money-bill-wave"
            disabled={credits_stored <= 0}
            onClick={() => act('withdraw')}
          >
            Вывести
          </Button>
        </Section>
        <Section title="КОСМООБМЕННИК 'СИНДИБАНК'">
          <Box textAlign="center" mb={1}>
            {tc_price} кр. за 1 ТК <Icon color="gold" name="coins" />
          </Box>
          <Box textAlign="center" mb={1}>
            {tc_purchased} / {tc_purchase_limit} ТК куплено
          </Box>
          <Button
            fluid
            icon="gem"
            disabled={
              credits_stored < tc_price || tc_purchased >= tc_purchase_limit
            }
            onClick={() => act('buy_tc')}
          >
            Купить 1 ТК
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
