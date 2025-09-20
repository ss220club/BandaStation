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

type Data = {
  warrants?: Warrant[];
  active?: Warrant;
};

export const NtosDigitalWarrant = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { warrants = [], active } = data;

  return (
    <Window width={500} height={400}>
      <Window.Content>
        {active ? (
          <WarrantEditor warrant={active} act={act} />
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
};

const WarrantEditor = (props: WarrantEditorProps) => {
  const { warrant, act } = props;
  return (
    <Section title={warrant.namewarrant}>
      <LabeledList>
        <LabeledList.Item label="Name">
          <Input
            value={warrant.namewarrant}
            onChange={(name) => act('edit_name', { name, job: warrant.jobwarrant })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Job">
          <Input
            value={warrant.jobwarrant}
            onChange={(job) => act('edit_name', { name: warrant.namewarrant, job })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Charges">
          <Input
            value={warrant.charges}
            onChange={(charges) => act('edit_charges', { charges })}
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

