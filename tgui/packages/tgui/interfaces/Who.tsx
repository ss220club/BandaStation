import { useState } from 'react';
import {
  Button,
  Section,
  Stack,
  Icon,
  Tooltip,
  Table,
  Modal,
  LabeledList,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { SearchBar } from './common/SearchBar';

type Data = {
  user: User;
  subject: Subject;
  clients: Record<string, Client[]>;
  modalOpen: BooleanLike;
};

type User = {
  ckey: string;
  admin: BooleanLike;
  ping: Ping;
};

type Subject = {
  key: string | null;
  type: string | null;
  gender: string | null;
  state: string | null;
  ping: Ping | null;
  name: SubjectName | null;
  role: SubjectRole | null;
  health: SubjectHealth | null;
  location: SubjectLocation | null;
  byondVersion: number | null;
  byondBuild: number | null;
};

type SubjectName = {
  real: string;
  mind: string;
};

type SubjectRole = {
  assigned: string;
  antagonist: string[];
};

type SubjectHealth = {
  brute: number;
  burn: number;
  toxin: number;
  oxygen: number;
  brain: number;
  stamina: number;
};

type SubjectLocation = {
  area: string;
  x: number;
  y: number;
  z: number;
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

const getStateColor = (state) => {
  switch (state) {
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
  const { act, data } = useBackend<Data>();
  const [subjectRef, setSubjectRef] = useState();

  return (
    <Window title="Who's there?" width={550} height={650}>
      <Window.Content>
        {!!data.modalOpen && (
          <SubjectInfo subjectRef={subjectRef} setSubjectRef={setSubjectRef} />
        )}
        <Stack fill vertical>
          <Stack.Item grow>
            <Clients setSubjectRef={setSubjectRef} />
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
          {!!user.admin && (
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
  const { setSubjectRef } = props;

  const [searchText, setSearchText] = useState('');
  const [moreInfo, setMoreInfo] = useState(true);

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
        <ClientsTable clients={sortedClients} setSubjectRef={setSubjectRef} />
      ) : (
        <ClientsCompact clients={sortedClients} setSubjectRef={setSubjectRef} />
      )}
    </Section>
  );
}

function ClientsTable(props) {
  const { act, data } = useBackend<Data>();
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
          <Table.Row key={client.ckey} className="candystripe">
            <Table.Cell bold>{client.ckey}</Table.Cell>
            <Table.Cell>{status?.where}</Table.Cell>
            <Table.Cell color={getStateColor(client.status?.state)}>
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
  const { act, data } = useBackend<Data>();
  const { clients, setSubjectRef } = props;
  return clients.map((client) => (
    <Button
      key={client.ckey}
      color={getStateColor(client.status?.state)}
      tooltip={<ShowPing user={client} />}
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

function SubjectInfo(props) {
  const { act, data } = useBackend<Data>();
  const { subject } = data;
  const { subjectRef, setSubjectRef } = props;

  return (
    <Modal p={1} style={{ width: '80vw' }}>
      <Section
        title={subject.key}
        buttons={
          <Stack align="center">
            <Stack.Item mr={1}>
              <ShowPing user={subject} />
            </Stack.Item>
            <Stack.Item>
              <Button
                color="red"
                icon="times"
                onClick={() => {
                  act('hide_more_info');
                  setSubjectRef(null);
                }}
              />
            </Stack.Item>
          </Stack>
        }
      >
        <SubjectInfoList subject={subject} />
      </Section>
      <Section>
        <SubjectInfoActions subjectRef={subjectRef} />
      </Section>
    </Modal>
  );
}

function SubjectInfoList(props) {
  const { subject } = props;
  return (
    <LabeledList>
      <LabeledList.Item label="Имя (Настоящее)">
        {subject.name?.real || 'N/A'}
      </LabeledList.Item>
      <LabeledList.Item label="Имя (Разум)">
        {subject.name?.mind || 'N/A'}
      </LabeledList.Item>
      <LabeledList.Item label="Роль">
        {subject.role?.assigned || 'N/A'}
      </LabeledList.Item>
      <LabeledList.Item label="Антагонист">
        {subject.role?.antagonist?.join(', ') || 'Нет'}
      </LabeledList.Item>
      <LabeledList.Item label="Тип моба">{subject.type}</LabeledList.Item>
      <LabeledList.Item label="Пол">{subject.gender}</LabeledList.Item>
      <LabeledList.Item label="Состояние" color={getStateColor(subject.state)}>
        {subject.state}
      </LabeledList.Item>
      <LabeledList.Item label="Повреждения">
        <Stack>
          <Tooltip content="Механические">
            <Stack.Item color="red">{subject.health?.brute}</Stack.Item>
          </Tooltip>
          <Stack.Divider />
          <Tooltip content="Ожоги">
            <Stack.Item color="orange">{subject.health?.burn}</Stack.Item>
          </Tooltip>
          <Stack.Divider />
          <Tooltip content="Отравление">
            <Stack.Item color="green">{subject.health?.toxin}</Stack.Item>
          </Tooltip>
          <Stack.Divider />
          <Tooltip content="Кислород">
            <Stack.Item color="blue">{subject.health?.oxygen}</Stack.Item>
          </Tooltip>
          <Stack.Divider />
          <Tooltip content="Мозг">
            <Stack.Item color="pink">{subject.health?.brain}</Stack.Item>
          </Tooltip>
          <Stack.Divider />
          <Tooltip content="Стамина">
            <Stack.Item color="yellow">{subject.health?.stamina}</Stack.Item>
          </Tooltip>
        </Stack>
      </LabeledList.Item>
      <LabeledList.Item label="Локация">
        {subject.location?.area || 'Неизвестно'}
      </LabeledList.Item>
      <LabeledList.Item label="Местоположение">
        <Stack>
          <Stack.Item>X: {subject.location?.x || 'N/A'}</Stack.Item>
          <Stack.Divider />
          <Stack.Item>Y: {subject.location?.y || 'N/A'}</Stack.Item>
          <Stack.Divider />
          <Stack.Item>Z: {subject.location?.z || 'N/A'}</Stack.Item>
        </Stack>
      </LabeledList.Item>
      <LabeledList.Item label="Версия Byond">
        {subject.byondVersion}.{subject.byondBuild}
      </LabeledList.Item>
    </LabeledList>
  );
}

function SubjectInfoActions(props) {
  const { act } = useBackend();
  const { subjectRef } = props;

  return (
    <Stack fill textAlign="center">
      <Stack.Item grow>
        <Button fluid>Player Panel</Button>
      </Stack.Item>
      <Stack.Item grow>
        <Button fluid>Traitor Panel</Button>
      </Stack.Item>
      <Stack.Item grow>
        <Button fluid>Variables</Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          color="purple"
          icon="phone"
          tooltip="Голос в голове"
          onClick={() => act('subtlepm', { ref: subjectRef })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="red"
          icon="skull-crossbones"
          tooltip="Наказать"
          onClick={() => act('smite', { ref: subjectRef })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="blue"
          icon="scroll"
          tooltip="Логи"
          onClick={() => act('logs', { ref: subjectRef })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="grey"
          icon="ghost"
          tooltip="Наблюдать"
          onClick={() => act('follow', { ref: subjectRef })}
        />
      </Stack.Item>
    </Stack>
  );
}
