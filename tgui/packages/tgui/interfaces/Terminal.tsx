import { Box, NoticeBox } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  uppertext: string;
  messages: { key: string }[];
  tguitheme: string;
};

export const Terminal = (props) => {
  const { data } = useBackend<Data>();
  const { messages = [], uppertext } = data;

  return (
    <Window theme={data.tguitheme} title="Terminal" width={480} height={520}>
      <Window.Content scrollable>
        <NoticeBox textAlign="left">{uppertext}</NoticeBox>
        {messages.map((message) => (
          <Box key={message.key} style={{ whiteSpace: 'pre-wrap' }}>
            {/* BANDASTATION EDIT: as text*/}
            {message.key}
          </Box>
        ))}
      </Window.Content>
    </Window>
  );
};
