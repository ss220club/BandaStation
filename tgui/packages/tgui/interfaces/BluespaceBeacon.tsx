import { ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  maximum_charge: number;
  inputLevelMax: number;
  charge: number;
  power_usage: number;
  input_level: number;
};

// Common power multiplier
const POWER_MUL = 1e3;

export const BluespaceBeacon = () => {
  const { act, data } = useBackend<Data>();
  const { maximum_charge, inputLevelMax, charge, power_usage, input_level } =
    data;
  return (
    <Window width={340} height={350}>
      <Window.Content>
        <Section title="Charge status">
          <ProgressBar
            value={charge}
            ranges={{
              good: [0.5, Infinity],
              average: [0.15, 0.5],
              bad: [-Infinity, 0.15],
            }}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
