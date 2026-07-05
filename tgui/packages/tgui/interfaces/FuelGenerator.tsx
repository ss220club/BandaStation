import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';
export const FuelGenerator = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={420} height={370}>
      <Window.Content scrollable>
        <Section title="Топливный генератор">
          <LabeledList>
            <LabeledList.Item label="Питание">
              <Button
                disabled={data.broken}
                icon={data.active ? 'power-off' : 'power-off'}
                selected={data.active}
                onClick={() => act('toggle_power')}>
                {data.active ? 'Включено' : 'Выключено'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Водяное охлаждение">
              <Button
                selected={data.cooling_enabled}
                onClick={() => act("toggle_cooling")}>
                {data.cooling_enabled ? "Включено" : "Выключено"}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Выработка">
              <Box>
                {data.power_output}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Топливо">
          <LabeledList>
            <LabeledList.Item label="Запас">
              {data.fuel}/{data.max_fuel}
            </LabeledList.Item>
            <LabeledList.Item label="Уровень">
              <ProgressBar
                value={data.fuel_percent}
                ranges={{
                  good: [0.6, Infinity],
                  average: [0.3, 0.6],
                  bad: [-Infinity, 0.3],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Топливный картридж">
              <Box color={data.fuel_pellet ? 'good' : 'bad'}>
                {data.fuel_pellet ? "Установлен" : "Отсутствует"}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Водяной буфер">
          <LabeledList>
            <LabeledList.Item label="Вода">
              {data.water}/{data.max_coolant}
            </LabeledList.Item>
            <LabeledList.Item label="Заполнение">
              <ProgressBar
                value={data.water_percent}
                ranges={{
                  good: [0.5, Infinity],
                  average: [0.2, 0.5],
                  bad: [-Infinity, 0.2],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Рециркулятор воды">
              <Box color={data.water_recycler ? 'good' : 'bad'}>
                {data.water_recycler ? 'Установлен' : 'Отсутствует'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Температура">
          <LabeledList>
            <LabeledList.Item label="Нагрев">
              <Box
                color={
                  data.heat_percent < 0.5
                    ? 'good'
                    : data.heat_percent < 0.8
                      ? 'average'
                      : 'bad'
                }
              >
                {data.heat}K
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Степень перегрева">
              <ProgressBar
                value={data.heat_percent}
                ranges={{
                  good: [-Infinity, 0.5],
                  average: [0.5, 0.8],
                  bad: [0.8, Infinity],
                }}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
