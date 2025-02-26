import { useState } from 'react';
import {
  Button,
  Icon,
  Section,
  Stack,
  Table,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { SearchBar } from '../common/SearchBar';
import { getConditionColor } from './helpers';
import { ShowPing } from './Ping';
import { WhoData } from './types';
import { NEW_ACCOUNT_AGE, NEW_ACCOUNT_NOTICE } from './constants';

export function UserInfo(props) {
  const { act, data } = useBackend<WhoData>();
  const { user } = data;

  return (
    <Section>
      <Stack fill ml={0.5} mr={0.5}>
        <Stack.Item grow bold fontSize={1.2}>
          {user.ckey}{' '}
          {!!user.admin && (
            <Tooltip content={'Администратор'}>
              <Icon name="crown" color="gold" />
            </Tooltip>
          )}
        </Stack.Item>
        <Stack.Item mr={1} align="center">
          <ShowPing user={user} />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={'arrows-rotate'}
            tooltip={'Обновить'}
            tooltipPosition={'top-end'}
            onClick={() => act('update')}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}

export function Clients(props) {
  const { act, data } = useBackend<WhoData>();
  const { user, clients } = data;
  const { setSubjectRef } = props;

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
        </Stack>
      }
    >
      {moreInfo && !!user.admin ? (
        <ClientsTable clients={sortedClients} setSubjectRef={setSubjectRef} />
      ) : (
        <ClientsCompact clients={sortedClients} setSubjectRef={setSubjectRef} />
      )}
    </Section>
  );
}

function ClientsTable(props) {
  const { act } = useBackend();
  const { clients, setSubjectRef } = props;
  return (
    <Table className="Who_Table">
      <Table.Row header>
        <Table.Cell>CKEY</Table.Cell>
        <Table.Cell>Персонаж</Table.Cell>
        <Table.Cell>Состояние</Table.Cell>
        <Table.Cell>Пинг</Table.Cell>
        <Table.Cell />
      </Table.Row>
      {clients.map((client) => {
        const status = client?.status;
        return (
          <Table.Row
            key={client.ckey}
            backgroundColor={
              client.accountAge < NEW_ACCOUNT_AGE && 'hsla(60, 100%, 25%, 0.25)'
            }
          >
            <Tooltip
              content={
                client.accountAge < NEW_ACCOUNT_AGE && NEW_ACCOUNT_NOTICE
              }
            >
              <Table.Cell bold>
                {client.accountAge < NEW_ACCOUNT_AGE && (
                  <Icon name="baby" color="green" size={1.25} />
                )}{' '}
                {client.ckey}
              </Table.Cell>
            </Tooltip>
            <Table.Cell>{status?.where}</Table.Cell>
            <Table.Cell color={getConditionColor(client.status?.state)}>
              {status?.state}
            </Table.Cell>
            <Table.Cell>{Math.round(client.ping.avgPing)}ms</Table.Cell>
            <Table.Cell collapsing>
              <Button
                icon="question"
                tooltip="Подробнее"
                tooltipPosition={'bottom-end'}
                onClick={() => {
                  setSubjectRef(client.mobRef);
                  act('show_more_info', { ref: client.mobRef });
                }}
              />
            </Table.Cell>
          </Table.Row>
        );
      })}
    </Table>
  );
}

function ClientsCompact(props) {
  const { act, data } = useBackend<WhoData>();
  const { clients, setSubjectRef } = props;
  return clients.map((client) => (
    <Button
      key={client.ckey}
      icon={client.accountAge < NEW_ACCOUNT_AGE && 'baby'}
      color={getConditionColor(client.status?.state)}
      tooltip={
        <Stack vertical align="center">
          <Stack.Item>
            {client.accountAge < NEW_ACCOUNT_AGE && NEW_ACCOUNT_NOTICE}
          </Stack.Item>
          <Stack.Item>
            <ShowPing user={client} />
          </Stack.Item>
        </Stack>
      }
      tooltipPosition={'bottom-start'}
      onClick={() => {
        if (!data.user.admin) {
          return;
        }
        setSubjectRef(client.mobRef);
        act('show_more_info', { ref: client.mobRef });
      }}
      onContextMenu={(e) => {
        e.preventDefault();
        act('follow', { ref: client.mobRef });
      }}
    >
      {client.ckey}
    </Button>
  ));
}
