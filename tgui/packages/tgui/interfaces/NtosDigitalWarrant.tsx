import { useState } from 'react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
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
    <Window width={500} height={400}>
      <Window.Content>
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
      </Window.Content>
    </Window>
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
        <LabeledList.Item label="Name">
          <Input
            value={warrant.namewarrant}
            onChange={(value: string) => act('edit_name', { name: value, job: warrant.jobwarrant })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Job">
          <Input
            value={warrant.jobwarrant}
            onChange={(value: string) => act('edit_name', { name: warrant.namewarrant, job: value })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="From Manifest">
          <Button onClick={onShowCrewManifest}>Select</Button>
        </LabeledList.Item>
        <LabeledList.Item label="Charges">
          <Input
            value={warrant.charges}
            onChange={(value: string) => act('edit_charges', { charges: value })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Authorized">
          {warrant.auth}
          <Button ml={1} onClick={() => act('authorize')}>
            Auth
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Access Auth">
          {warrant.idauth}
          <Button ml={1} onClick={() => act('authorize_access')}>
            Auth Access
          </Button>
        </LabeledList.Item>
      </LabeledList>
      <Stack mt={2} justify="space-between">
        <Button onClick={() => act('save')}>Save</Button>
        <Button onClick={() => act('delete', { id: warrant.id })}>Delete</Button>
        <Button onClick={() => act('back')}>Back</Button>
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
      title="Crew Manifest"
      buttons={<Button onClick={onClose}>Back</Button>}
    >
      <Input
        placeholder="Search by name or job"
        onChange={(value: string) => setSearch(value)}
        mb={1}
      />
      {filteredCrew.map((member) => (
        <Stack key={member.name} justify="space-between" mb={1}>
          <Stack.Item grow>
            {member.name} - {member.job}
          </Stack.Item>
          <Button onClick={() => onSelect(member.name, member.job)}>
            Select
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
      title="Warrants"
      buttons={
        <>
          <Button onClick={() => act('add_arrest')}>Add Arrest</Button>
          <Button onClick={() => act('add_search')}>Add Search</Button>
        </>
      }
    >
      {warrants.length ? (
        warrants.map((warrant) => (
          <Stack key={warrant.id} justify="space-between" mb={1}>
            <Stack.Item grow>
              {warrant.namewarrant}: {warrant.charges}
            </Stack.Item>
            <Button onClick={() => act('open', { id: warrant.id })}>View</Button>
            <Button onClick={() => act('delete', { id: warrant.id })}>Delete</Button>
          </Stack>
        ))
      ) : (
        'No warrants.'
      )}
    </Section>
  );
};
