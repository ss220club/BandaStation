import { useState } from 'react';
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Button, Input, LabeledList, Section, Stack } from 'tgui-core/components';

type Warrant = {
  id: string;
  namewarrant: string;
  jobwarrant: string;
  charges: string;
  auth: string;
  idauth: string;
  arrestsearch: string;
};

type CrewMember = {
  name: string;
  job: string;
};

type Data = {
  warrants?: Warrant[] | null;
  active?: Warrant | null;
  crew_manifest?: CrewMember[];
};

export const NtosDigitalWarrant = () => {
  const { act, data } = useBackend<Data>();
  const { active, crew_manifest = [] } = data;
  const warrants = data.warrants ?? [];
  const [showCrewManifest, setShowCrewManifest] = useState(false);

  return (
    <NtosWindow title="Цифровые ордера" width={500} height={400}>
      <NtosWindow.Content>
        {active ? (
          showCrewManifest ? (
            <CrewManifest
              crew={crew_manifest}
              onSelect={(name, job) => {
                act('edit_name', { name, job });
                setShowCrewManifest(false);
              }}
              onClose={() => setShowCrewManifest(false)}
            />
          ) : (
            <WarrantEditor
              warrant={active}
              act={act}
              onShowCrewManifest={() => setShowCrewManifest(true)}
            />
          )
        ) : (
          <WarrantList warrants={warrants} act={act} />
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

type WarrantEditorProps = {
  warrant: Warrant;
  act: (action: string, params?: any) => void;
  onShowCrewManifest: () => void;
};

const WarrantEditor = (props: WarrantEditorProps) => {
  const { warrant, act, onShowCrewManifest } = props;
  return (
    <Section title={warrant.namewarrant}>
      <LabeledList>
        <LabeledList.Item label="Имя">
          <Input
            value={warrant.namewarrant}
            onChange={(value: string) => act('edit_name', { name: value, job: warrant.jobwarrant })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Должность">
          <Input
            value={warrant.jobwarrant}
            onChange={(value: string) => act('edit_name', { name: warrant.namewarrant, job: value })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Из манифеста">
          <Button onClick={onShowCrewManifest}>Выбрать</Button>
        </LabeledList.Item>
        <LabeledList.Item label="Обвинения">
          <Input
            value={warrant.charges}
            onChange={(value: string) => act('edit_charges', { charges: value })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Авторизовал">
          {warrant.auth}
          <Button ml={1} onClick={() => act('authorize')}>
            Подпись
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Авторизация доступа">
          {warrant.idauth}
          <Button ml={1} onClick={() => act('authorize_access')}>
            Подп. доступ
          </Button>
        </LabeledList.Item>
      </LabeledList>
      <Stack mt={2} justify="space-between">
        <Button onClick={() => act('save')}>Сохранить</Button>
        <Button onClick={() => act('delete', { id: warrant.id })}>Удалить</Button>
        <Button onClick={() => act('back')}>Назад</Button>
      </Stack>
    </Section>
  );
};

type CrewManifestProps = {
  crew: CrewMember[];
  onSelect: (name: string, job: string) => void;
  onClose: () => void;
};

const CrewManifest = (props: CrewManifestProps) => {
  const { crew, onSelect, onClose } = props;
  const [search, setSearch] = useState('');

  const filteredCrew = crew.filter(
    (member) =>
      member.name.toLowerCase().includes(search.toLowerCase()) ||
      member.job.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <Section
      title="Манифест экипажа"
      buttons={<Button onClick={onClose}>Назад</Button>}
    >
      <Input
        placeholder="Поиск по имени или должности"
        onChange={(value: string) => setSearch(value)}
        mb={1}
      />
      {filteredCrew.map((member) => (
        <Stack key={member.name} justify="space-between" mb={1}>
          <Stack.Item grow>
            {member.name} - {member.job}
          </Stack.Item>
            <Button onClick={() => onSelect(member.name, member.job)}>
              Выбрать
            </Button>
        </Stack>
      ))}
    </Section>
  );
};

type WarrantListProps = {
  warrants: Warrant[];
  act: (action: string, params?: any) => void;
};

const WarrantList = (props: WarrantListProps) => {
  const { warrants, act } = props;
  return (
    <Section
      title="Ордеры"
      buttons={
        <>
          <Button onClick={() => act('add_arrest')}>Ордер на арест</Button>
          <Button onClick={() => act('add_search')}>Ордер на обыск</Button>
        </>
      }
    >
      {warrants.length ? (
        warrants.map((warrant) => (
          <Stack key={warrant.id} justify="space-between" mb={1}>
            <Stack.Item grow>
              {warrant.namewarrant}: {warrant.charges}
            </Stack.Item>
            <Button onClick={() => act('open', { id: warrant.id })}>Открыть</Button>
            <Button onClick={() => act('delete', { id: warrant.id })}>Удалить</Button>
          </Stack>
        ))
      ) : (
        'Ордеров нет.'
      )}
    </Section>
  );
};
