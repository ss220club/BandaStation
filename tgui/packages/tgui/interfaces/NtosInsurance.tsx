import { Box, Button, LabeledList, NoticeBox, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  name: string | null;
  insurance_current: string;
  insurance_desired: string;
  payer_account_id: number;
  is_dept: boolean;
};

export const NtosInsurance = (props) => {
  const { data } = useBackend<Data>();
  const { name } = data;

  return (
    <NtosWindow width={420} height={300}>
      <NtosWindow.Content>
        {!name ? <NoAccount /> : <InsuranceContent />}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const NoAccount = () => (
  <NoticeBox danger>Insert an ID card with a personal bank account.</NoticeBox>
);

const InsuranceContent = () => {
  const { act, data } = useBackend<Data>();
  const { name, insurance_current, insurance_desired, payer_account_id, is_dept } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        {is_dept && (
          <NoticeBox danger>
            Departmental accounts cannot manage personal insurance.
          </NoticeBox>
        )}
        <Section title="Insurance Status">
          <LabeledList>
            <LabeledList.Item label="Name">{name}</LabeledList.Item>
            <LabeledList.Item label="Current">{insurance_current}</LabeledList.Item>
            <LabeledList.Item label="Desired">{insurance_desired}</LabeledList.Item>
            <LabeledList.Item label="Payer Account">
              {payer_account_id ?? '—'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Set Desired Tier">
          <Box>
            <Button disabled={is_dept} onClick={() => act('set_tier', { tier: 0 })}>
              None
            </Button>
            <Button disabled={is_dept} onClick={() => act('set_tier', { tier: 1 })} ml={1}>
              Standard
            </Button>
            <Button disabled={is_dept} onClick={() => act('set_tier', { tier: 2 })} ml={1}>
              Premium
            </Button>
          </Box>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

