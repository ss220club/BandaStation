import { useState } from 'react';
import { Box, Button, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  comments: string;
  description: string;
  name: string;
};

const PAI_DESCRIPTION = `Персональные ИИ - это продвинутые модели, способные к
тонко настроенному взаимодействию. Они созданы, чтобы помогать своим хозяевам в
работе. У них нет рук, поэтому они не могут взаимодействовать с оборудованием
или предметами. Находясь в форме голограммы, вы не можете быть убиты напрямую,
но можете быть выведены из строя.`;

const PAI_RULES = `От вас ожидается в определённой степени участие в ролевой
игре. Имейте в виду: если вы не укажете свои данные, вас могут не выбрать.
Нажмите «Отправить», чтобы уведомить ПИИ‑карты о вашей кандидатуре.`;

export const PaiSubmit = (props) => {
  const { data } = useBackend<Data>();
  const { comments, description, name } = data;
  const [input, setInput] = useState({
    comments,
    description,
    name,
  });

  return (
    <Window width={400} height={460} title="Меню кандидатов ПИИ">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <DetailsDisplay />
          </Stack.Item>
          <Stack.Item>
            <InputDisplay input={input} setInput={setInput} />
          </Stack.Item>
          <Stack.Item>
            <ButtonsDisplay input={input} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays basic info about playing pAI */
const DetailsDisplay = (props) => {
  return (
    <Section fill scrollable title="Подробности">
      <Box color="label">
        {PAI_DESCRIPTION}
        <br />
        <br />
        {PAI_RULES}
      </Box>
    </Section>
  );
};

/** Input boxes for submission details */
const InputDisplay = (props) => {
  const { input, setInput } = props;
  const { name, description, comments } = input;

  return (
    <Section fill title="Ввод">
      <Stack fill vertical>
        <Stack.Item>
          <Box bold color="label">
            Имя
          </Box>
          <Input
            fluid
            maxLength={41}
            value={name}
            onChange={(value) => setInput({ ...input, name: value })}
          />
        </Stack.Item>
        <Stack.Item>
          <Box bold color="label">
            Описание
          </Box>
          <Input
            fluid
            maxLength={100}
            value={description}
            onChange={(value) => setInput({ ...input, description: value })}
          />
        </Stack.Item>
        <Stack.Item>
          <Box bold color="label">
            OOC комментарии
          </Box>
          <Input
            fluid
            maxLength={100}
            value={comments}
            onChange={(value) => setInput({ ...input, comments: value })}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/** Gives the user a submit button */
const ButtonsDisplay = (props) => {
  const { act } = useBackend<Data>();
  const { input } = props;
  const { comments, description, name } = input;

  return (
    <Section fill>
      <Stack>
        <Stack.Item>
          <Button
            onClick={() => act('save', { comments, description, name })}
            tooltip="Saves your candidate data locally."
          >
            СОХРАНИТЬ
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() => act('load')}
            tooltip="Loads saved candidate data, if any."
          >
            ЗАГРУЗИТЬ
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() =>
              act('submit', {
                comments,
                description,
                name,
              })
            }
          >
            ОТПРАВИТЬ
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() => act('withdraw')}
            tooltip="Отзывает вашу кандидатуру ПИИ, при наличии."
          >
            ОТОЗВАТЬ
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
