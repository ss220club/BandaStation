import { BlockQuote, LabeledList, Section, Stack } from 'tgui-core/components';

import { Window } from '../layouts';

const tipstyle = {
  color: 'white',
};

const noticestyle = {
  color: 'lightblue',
};

export const AntagInfoVoidwalker = (props) => {
  return (
    <Window width={620} height={470}>
      <Window.Content backgroundColor="#0d0d0d">
        <Stack fill>
          <Stack.Item width="46.2%">
            <Section fill>
              <Stack vertical fill>
                <Stack.Item fontSize="25px">Вы - Войдволкер.</Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    Вы - существо из пустоты между звездами. Вас привлекли
                    радиосигналы, передаваемые этой станцией.
                  </BlockQuote>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item textColor="label">
                  <span style={tipstyle}>Выживайте:&ensp;</span>
                  Вы безудержно свободны. Оставаясь в космосе - никто не сможет
                  вас остановить. Вы можете перемещаться через окна, поэтому
                  держитесь возле них, чтобы чтобы всегда иметь путь к спасению.
                  <br />
                  <span style={tipstyle}>Охотьтесь:&ensp;</span>
                  Выбирайте нечестные бои. Ищите невнимательных жертв и наносите
                  удары когда они вас не ожидают.
                  <br />
                  <span style={tipstyle}>Abduct:&ensp;</span>
                  Ваша способность Unsettle оглушает и истощает цели. Прикончите
                  их с помощью своего острия пустоты и используйте его, чтобы
                  открыть окно, перетащите их в космос и используйте пустую
                  руку, чтобы похитить их.
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="53%">
            <Section fill title="Ваши способности">
              <LabeledList>
                <LabeledList.Item label="Space Dive">
                  Вы можете перемещаться под станцией по космосу, используйте
                  это для охоты и проникновения в изолированные участки космоса.
                </LabeledList.Item>
                <LabeledList.Item label="Void Eater">
                  Ваш божественный отросток, он позволяет обездвиживать слишком
                  шумных и мгновенно разбивать окна. Позволяет превращать слабые
                  стены в окна, через которые вы сможете проходить.
                </LabeledList.Item>
                <LabeledList.Item label="Cosmic Physiology">
                  Ваш природный камуфляж делает вас почти невидимым в космосе, а
                  также залечивает любые раны, полученные вашим телом. Вы можете
                  свободно проникать сквозь стекло, но замедляетесь под
                  действием гравитации.
                </LabeledList.Item>
                <LabeledList.Item label="Unsettle">
                  Нацельтесь на жертву, частично оставаясь в поле ее зрения,
                  чтобы оглушить и ослабить их, но при этом объявить им о своем
                  присутствии.
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
