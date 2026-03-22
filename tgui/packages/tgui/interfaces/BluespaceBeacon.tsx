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
  inputAttempt: number;
  inputting: number;
  inputAvailable: number;
};

// Common power multiplier
const POWER_MUL = 1e3;

export const BluespaceBeacon = () => {
  const { act, data } = useBackend<Data>();
  const {
    maximumCharge,
    inputLevelMax,
    charge,
    powerUsage,
    inputLevel,
    inputAttempt,
    inputting,
    inputAvailable,
  } = data;

  const inputState =
    (charge >= 100 && 'good') || (inputting && 'average') || 'bad';

  return (
    <Window width={340} height={350}>
      <Window.Content>
        <Section title="Charge status">
          <ProgressBar
            value={charge / 100}
            ranges={{
              good: [50, Infinity],
              average: [15, 50],
              bad: [-Infinity, 15],
            }}
          />
        </Section>
        <Section
          title="Input"
          buttons={
            <Button
              icon={inputAttempt ? 'sync-alt' : 'times'}
              selected={inputAttempt}
              onClick={() => act('tryinput')}
            >
              {inputAttempt ? 'On' : 'Off'}
            </Button>
          }
        />
        <LabeledList>
          <LabeledList.Item label="Charge Mode">
            <Box color={inputState}>
              {(charge >= 100 && 'Fully Charged') ||
                (inputting && 'Charging') ||
                'Not Charging'}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Target Input">
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
                      adjust: -10000,
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
                  step={5}
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
                      adjust: 10000,
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
          <LabeledList.Item label="Available">
            {formatPower(inputAvailable)}
          </LabeledList.Item>
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
