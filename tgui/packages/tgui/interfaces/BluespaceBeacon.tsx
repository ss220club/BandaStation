import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import { formatPower } from 'tgui-core/format';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  maximumCharge: number;
  inputLevelMax: number;
  charge: number;
  powerUsage: number;
  inputLevel: number;
  inputting: number;
  inputAvailable: number;
};

const POWER_MUL = 1e3;

export const BluespaceBeacon = () => {
  const { act, data } = useBackend<Data>();
  const {
    inputLevelMax,
    charge,
    powerUsage,
    inputLevel,
    inputting,
    inputAvailable,
  } = data;

  const inputState =
    (charge >= 100 && 'good') || (inputting && 'average') || 'bad';

  return (
    <Window width={340} height={280}>
      <Window.Content>
        <Section title="Статус зарядки">
          <ProgressBar
            value={charge}
            ranges={{
              good: [50, Infinity],
              average: [15, 50],
              bad: [-Infinity, 15],
            }}
          >
            {Math.round(charge)}%
          </ProgressBar>
        </Section>

        <LabeledList>
          <LabeledList.Item label="Режим зарядки">
            <Box color={inputState}>
              {(charge >= 100 && 'Заряжно') ||
                (inputting && 'Заряжется') ||
                'Не заряжается'}
            </Box>
          </LabeledList.Item>

          <LabeledList.Item label="Входная мощность">
            <Stack fill>
              <Stack.Item>
                <Button
                  icon="fast-backward"
                  disabled={inputLevel === 0}
                  onClick={() =>
                    act('input', {
                      target: 'min',
                    })
                  }
                />
                <Button
                  icon="backward"
                  disabled={inputLevel === 0}
                  onClick={() =>
                    act('input', {
                      adjust: -1000000,
                    })
                  }
                />
              </Stack.Item>

              <Stack.Item grow={1} mx={1}>
                <Slider
                  value={inputLevel / POWER_MUL}
                  fillValue={inputAvailable / POWER_MUL}
                  minValue={0}
                  maxValue={inputLevelMax / POWER_MUL}
                  step={1000}
                  stepPixelSize={4}
                  format={(value) => formatPower(value * POWER_MUL, 1)}
                  onChange={(e, value) =>
                    act('input', {
                      target: value * POWER_MUL,
                    })
                  }
                />
              </Stack.Item>

              <Stack.Item>
                <Button
                  icon="forward"
                  disabled={inputLevel === inputLevelMax}
                  onClick={() =>
                    act('input', {
                      adjust: 1000000,
                    })
                  }
                />
                <Button
                  icon="fast-forward"
                  disabled={inputLevel === inputLevelMax}
                  onClick={() =>
                    act('input', {
                      target: 'max',
                    })
                  }
                />
              </Stack.Item>
            </Stack>
          </LabeledList.Item>

          <LabeledList.Item label="Текущее потребление">
            {formatPower(powerUsage)}
          </LabeledList.Item>

          <LabeledList.Item label="Допустно">
            {formatPower(inputAvailable)}
          </LabeledList.Item>
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
