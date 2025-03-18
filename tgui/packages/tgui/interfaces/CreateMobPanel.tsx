import { LabeledList, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export function CreateMobPanel(props) {
  const { act, data } = useBackend<Data>();
  const { title, mobs } = data;
  const listItems = mobs.map((item) => '<Table.Row>{item}</Table.Row>');
  return (
    <Window height={240} title={title} width={280} theme="admin">
      <Window.Content>
        <Stack
          height="100%"
          vertical
          align="center"
          verticalAlign="center"
          textAlign="center"
          direction="column"
          justify="space-around"
          fillPositionedParent
        />
        <LabeledList>
          {mobs.map((mob: string, index: number) => (
            <LabeledList.Item key={index}>{mob}</LabeledList.Item>
          ))}
        </LabeledList>
      </Window.Content>
    </Window>
  );
}

export type Data = {
  title: string;
  mobs: string[];
};
