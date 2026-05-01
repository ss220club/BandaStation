// NSV13

import { Button, ProgressBar, Section } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type NtosStormdriveMonitorData = {
  control_rod_percent: number;
  heat: number;
  reactor_meltdown: number;
  reactor_hot: number;
  reactor_critical: number;
  rod_integrity: number;
  last_power_produced: number;
  theoretical_maximum_power: number;
  reaction_rate: number;
  total_moles: number;
  mole_threshold_high: number;
  mole_threshold_very_high: number;
};

export function NtosStormdriveMonitor(props: any, context: any) {
  const { act, data } = useBackend<NtosStormdriveMonitorData>(context);

  const {
    control_rod_percent,
    heat,
    reactor_meltdown,
    reactor_hot,
    reactor_critical,
    rod_integrity,
    last_power_produced,
    theoretical_maximum_power,
    reaction_rate,
    total_moles,
    mole_threshold_high,
    mole_threshold_very_high,
  } = data;

  return (
    <NtosWindow resizable width={440} height={650}>
      <NtosWindow.Content>
        <Section
          title="Legend:"
          buttons={
            <Button
              icon="search"
              onClick={() => act('swap_reactor')}
              content="Change Reactor"
            />
          }
        >
          Control Rod Insertion:
          <ProgressBar
            value={control_rod_percent}
            minValue={0}
            maxValue={100}
          />
          Temperature:
          <ProgressBar
            value={heat / reactor_meltdown}
            ranges={{
              good: [],
              average: [
                reactor_hot / reactor_meltdown,
                reactor_critical / reactor_meltdown,
              ],
              bad: [reactor_critical / reactor_meltdown, Infinity],
            }}
          >
            {`${toFixed(heat)} °C`}
          </ProgressBar>
          Rod Integrity:
          <ProgressBar
            value={rod_integrity / 100}
            ranges={{
              good: [],
              average: [0.15, 0.5],
              bad: [-Infinity, 0.15],
            }}
          />
          Power Output:
          <ProgressBar
            value={last_power_produced / theoretical_maximum_power}
            ranges={{
              good: [],
              average: [0.08, 0.2],
              bad: [-Infinity, 0.08],
            }}
          >
            {`${toFixed(last_power_produced / 1e6, 1)} MW`}
          </ProgressBar>
          Reaction Rate:
          <ProgressBar
            value={reaction_rate * 0.05}
            ranges={{
              good: [],
              average: [0.1, 0.2],
              bad: [-Infinity, 0.1],
            }}
          >
            {`${toFixed(reaction_rate, 1)} mol/s`}
          </ProgressBar>
          Fuel:
          <ProgressBar
            value={total_moles / mole_threshold_very_high}
            ranges={{
              good: [],
              average: [
                mole_threshold_high / mole_threshold_very_high,
                Infinity,
              ],
              bad: [-Infinity, reaction_rate / mole_threshold_very_high],
            }}
          >
            {`${toFixed(total_moles)} mol`}
          </ProgressBar>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
}
