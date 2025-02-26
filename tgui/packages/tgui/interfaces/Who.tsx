import { useState } from 'react';
import {
  Button,
  Section,
  Stack,
  Icon,
  Tooltip,
  Table,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { SearchBar } from './common/SearchBar';

type Data = {
  user: User;
  clients: Record<string, Client[]>;
};

type User = {
  ckey: string;
  admin: BooleanLike;
  ping: Ping;
};

type Client = {
  ckey: string;
  ping: Ping;
  status: Status | null;
  account: AccountInfo | null;
  adminRank: BooleanLike | null;
  mobRef: string | null;
};

type Ping = {
  lastPing: number;
  avgPing: number;
};

type Status = {
  where: string;
  state: string;
  antag: BooleanLike;
};

type AccountInfo = {
  age: number;
  donorTier: number;
  byondVersion: number;
  byondBuild: number;
};

const getStateColor = (client) => {
  switch (client.status.state) {
    case 'Живой':
      return 'green';
    case 'Без сознания':
      return 'yellow';
    case 'В крите':
      return 'orange';
    case 'Мёртв':
      return 'red';
    case 'Наблюдает':
      return 'grey';
    default:
      return '';
  }
};

export function Who(props) {
  return (
    <Window title="Who's there?" width={550} height={650}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Clients />
          </Stack.Item>
          <Stack.Item>
            <UserInfo />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

function UserInfo(props) {
  const { act, data } = useBackend<Data>();
  const { user } = data;

  return (
    <Section>
      <Stack fill ml={0.5} mr={0.5} justify="space-between">
        <Stack.Item bold fontSize={1.2}>
          {user.ckey}{' '}
          {user.admin && (
            <Tooltip content={'Администратор'}>
              <Icon name="crown" color="gold" />
            </Tooltip>
          )}
        </Stack.Item>
        <Stack.Item align="center">
          <ShowPing user={user} />
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function Clients(props) {
  const { act, data } = useBackend<Data>();
  const { user, clients } = data;

  const [searchText, setSearchText] = useState('');
  const [moreInfo, setMoreInfo] = useState(false);

  const clientsList = Object.values(clients).flat();
  const sortedClients = clientsList
    .filter((client) =>
      client.ckey.toLowerCase().includes(searchText.toLowerCase()),
    )
    .sort((a, b) => a.ckey.localeCompare(b.ckey));

  return (
    <Section
      fill
      scrollable
      title={`Онлайн: ${clientsList.length}`}
      buttons={
        <Stack>
          <Stack.Item>
            <SearchBar
              style={{ width: '15em' }}
              query={searchText}
              onSearch={(value) => setSearchText(value)}
            />
          </Stack.Item>
          {!!user.admin && (
            <Stack.Item>
              <Button
                icon={moreInfo ? 'compress' : 'expand'}
                tooltip={moreInfo ? 'Меньше информации' : 'Больше информации'}
                tooltipPosition={'bottom-end'}
                onClick={() => setMoreInfo(!moreInfo)}
              />
            </Stack.Item>
          )}
          <Stack.Item>
            <Button
              icon={'arrows-rotate'}
              tooltip={'Обновить'}
              tooltipPosition={'bottom-end'}
              onClick={() => act('update')}
            />
          </Stack.Item>
        </Stack>
      }
    >
      {moreInfo && !!user.admin ? (
        <ClientsTable clients={sortedClients} />
      ) : (
        <ClientsCompact clients={sortedClients} />
      )}
    </Section>
  );
}

function ClientsTable(props) {
  const { clients } = props;
  return (
    <Table>
      <Table.Row header>
        <Table.Cell bold>CKEY</Table.Cell>
        <Table.Cell bold>Статус</Table.Cell>
        <Table.Cell bold>Состояние</Table.Cell>
        <Table.Cell bold>Пинг</Table.Cell>
      </Table.Row>
      {clients.map((client) => {
        const status = client?.status;
        return (
          <Table.Row key={client.ckey} className="candystripe">
            <Table.Cell bold>{client.ckey}</Table.Cell>
            <Table.Cell>{status?.where}</Table.Cell>
            <Table.Cell color={getStateColor(client)}>
              {status?.state}
            </Table.Cell>
            <Table.Cell>{Math.round(client.ping.avgPing)}ms</Table.Cell>
            <Table.Cell collapsing>
              <Button icon="question" />
            </Table.Cell>
          </Table.Row>
        );
      })}
    </Table>
  );
}

function ClientsCompact(props) {
  const { act } = useBackend();
  const { clients } = props;
  return clients.map((client) => (
    <Button
      key={client.ckey}
      color={getStateColor(client)}
      tooltip={<ShowPing user={client} />}
      tooltipPosition={'bottom-start'}
      onClick={() => client.mobRef && act('follow', { ref: client.mobRef })}
    >
      {client.ckey}
    </Button>
  ));
}

function ShowPing(props) {
  const { user } = props;

  return (
    <Stack wrap color="label">
      <Tooltip content="Текущий пинг" position={'bottom-end'}>
        <Stack.Item color="green">
          <Icon name="clock-rotate-left" /> {Math.round(user.ping.lastPing)}ms
        </Stack.Item>
      </Tooltip>
      <Stack.Divider />
      <Tooltip content="Средний пинг" position={'bottom-end'}>
        <Stack.Item color="orange">
          <Icon name="chart-simple" /> {Math.round(user.ping.avgPing)}ms
        </Stack.Item>
      </Tooltip>
    </Stack>
  );
}
