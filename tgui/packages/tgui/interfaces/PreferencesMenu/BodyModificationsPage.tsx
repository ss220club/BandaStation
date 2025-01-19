import { useBackend } from '../../backend';
import { Button, NoticeBox, Stack } from '../../components';
import { BodyModification, PreferencesMenuData, ServerData } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

export const BodyModificationsPage = () => {
  return (
    <ServerPreferencesFetcher
      render={(serverData: ServerData) => {
        if (!serverData) {
          return <NoticeBox>Loading...</NoticeBox>;
        }
        return (
          <BodyModificationsPageInner
            bodyModification={serverData.body_modifications}
          />
        );
      }}
    />
  );
};

const BodyModificationsPageInner = (props: {
  bodyModification: BodyModification[];
}) => {
  return (
    <Stack height={'100%'} vertical>
      {props.bodyModification.map((bodyModification) => (
        <Stack.Item key={bodyModification.key}>
          <BodyModificationRow bodyModification={bodyModification} />
        </Stack.Item>
      ))}
    </Stack>
  );
};

const BodyModificationRow = (props: { bodyModification: BodyModification }) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { applied_body_modifications } = data;
  return (
    <Stack>
      <Stack.Item>{props.bodyModification.name}</Stack.Item>
      <Stack.Item>
        {props.bodyModification.key in applied_body_modifications ? (
          <Button
            onClick={() =>
              act('remove_body_modification', {
                body_modification_key: props.bodyModification.key,
              })
            }
          >
            Remove
          </Button>
        ) : (
          <Button
            onClick={() =>
              act('apply_body_modification', {
                body_modification_key: props.bodyModification.key,
              })
            }
          >
            Apply
          </Button>
        )}
      </Stack.Item>
    </Stack>
  );
};
