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
    <Window width={660} height={660}>
      <Window.Content backgroundColor="#0d0d0d">
        <Stack fill>
          <Stack.Item width="50%">
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
                  <br />
                  <span style={tipstyle}>Похищение:&ensp;</span>
                  Твоя способность «Unsettle» оглушает и истощает цели. Выруби
                  их истощающим ударом, утащи в космос (или блевотину
                  туманности) и просвети.
                  <br />
                  <br />
                  <span style={tipstyle}>Жатва:&ensp;</span>
                  Наши ученики регулярно извергают нашу сущность. Мы можем
                  использовать это, чтобы попасть туда, куда обычно не можем, но
                  при уходе вновь её поглощаем. (Ты можешь нырять в космическую
                  блевотину.)
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="50%">
            <Section fill title="Способности">
              <LabeledList>
                <LabeledList.Item label="Space Dive">
                  Вы можете перемещаться под станцией по космосу, используйте
                  это для охоты и проникновения в изолированные участки космоса.
                </LabeledList.Item>
                <LabeledList.Item label="Draining Slash">
                  Ты вырываешь дыхание прямо из их легких и быстро сносишь даже
                  самых сильных противников. Если они окажут сопротивление, клик
                  правой кнопкой позволяет нанести сырой урон. Твои руки в
                  остальном не особенно утончены, и не годятся для чего-то
                  большего, чем просто хватать вещи.
                </LabeledList.Item>
                <LabeledList.Item label="Cosmic Physiology">
                  Твоя природная маскировка делает тебя невидимым в космосе, а
                  также залечивает любые полученные ранения. Ты свободно
                  проходишь сквозь стекло, но замедляешься при гравитации.
                </LabeledList.Item>
                <LabeledList.Item label="Unsettle">
                  Нацельтесь на жертву, частично оставаясь в поле ее зрения,
                  чтобы оглушить и ослабить их, но при этом объявить им о своем
                  присутствии.
                </LabeledList.Item>
                <LabeledList.Item label="Cosmic Dash">
                  С короткой дальностью и незначительным уроном это плохое
                  оружие для атаки, но отличное — для быстрого отхода и смены
                  позиции.
                </LabeledList.Item>
                <LabeledList.Item label="Expand">
                  С каждым уроком, что мы преподаём, мы становимся сильнее. Мы
                  можем превращать стены в стекло, чтобы добираться ещё дальше.
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
