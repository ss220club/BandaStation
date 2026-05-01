// NSV13

import { Fragment } from 'react';
import {
  Button,
  Chart,
  Flex,
  LabeledList,
  ProgressBar,
  Section,
  Slider,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

type GasRecord = number[];

type StormdriveData = {
  gas_records: {
    plasma: GasRecord;
    tritium: GasRecord;
    o2: GasRecord;
    n2: GasRecord;
    co2: GasRecord;
    water_vapour: GasRecord;
    nob: GasRecord;
    n2o: GasRecord;
    no2: GasRecord;
    bz: GasRecord;
    stim: GasRecord;
    pluoxium: GasRecord;
    nucleium: GasRecord;
  };
  control_rod_percent: number;
  heat: number;
  reactor_meltdown: number;
  reactor_hot: number;
  reactor_critical: number;
  rod_integrity: number;
  last_power_produced: number;
  theoretical_maximum_power: number;
  reaction_rate: number;
  fuel_mix: number;
  total_moles: number;
  mole_threshold_high: number;
  mole_threshold_very_high: number;
  plasma: number;
  tritium: number;
  o2: number;
  n2: number;
  co2: number;
  water_vapour: number;
  nob: number;
  n2o: number;
  no2: number;
  bz: number;
  stim: number;
  pluoxium: number;
  nucleium: number;
  reactor_maintenance: boolean;
  pipe_open: boolean;
};

export function StormdriveConsole(props: any, context: any) {
  const { act, data } = useBackend<StormdriveData>(context);

  const {
    gas_records,
    control_rod_percent,
    heat,
    reactor_meltdown,
    reactor_hot,
    reactor_critical,
    rod_integrity,
    last_power_produced,
    theoretical_maximum_power,
    reaction_rate,
    fuel_mix,
    total_moles,
    mole_threshold_high,
    mole_threshold_very_high,
    plasma,
    tritium,
    o2,
    n2,
    co2,
    water_vapour,
    nob,
    n2o,
    no2,
    bz,
    stim,
    pluoxium,
    nucleium,
    reactor_maintenance,
    pipe_open,
  } = data;

  const plasmaData = gas_records.plasma.map(
    (value, i) => [i, value] as [number, number],
  );
  const tritiumData = gas_records.tritium.map(
    (value, i) => [i, value] as [number, number],
  );
  const o2Data = gas_records.o2.map(
    (value, i) => [i, value] as [number, number],
  );
  const n2Data = gas_records.n2.map(
    (value, i) => [i, value] as [number, number],
  );
  const co2Data = gas_records.co2.map(
    (value, i) => [i, value] as [number, number],
  );
  const water_vapourData = gas_records.water_vapour.map(
    (value, i) => [i, value] as [number, number],
  );
  const nobData = gas_records.nob.map(
    (value, i) => [i, value] as [number, number],
  );
  const n2oData = gas_records.n2o.map(
    (value, i) => [i, value] as [number, number],
  );
  const no2Data = gas_records.no2.map(
    (value, i) => [i, value] as [number, number],
  );
  const bzData = gas_records.bz.map(
    (value, i) => [i, value] as [number, number],
  );
  const stimData = gas_records.stim.map(
    (value, i) => [i, value] as [number, number],
  );
  const pluoxiumData = gas_records.pluoxium.map(
    (value, i) => [i, value] as [number, number],
  );
  const nucleiumData = gas_records.nucleium.map(
    (value, i) => [i, value] as [number, number],
  );

  return (
    <Window resizable theme="ntos" width={560} height={600}>
      <Window.Content scrollable>
        <Section>
          {/* Control presets */}
          <Section title="Control presets:">
            <Fragment>
              <Button
                fluid
                content="AZ-1 - FULLY RAISE CONTROL RODS"
                icon="exclamation-triangle"
                color="bad"
                onClick={() => act('rods_1')}
              />
              <Button
                fluid
                content="AZ-2 - HIGH TEMPERATURE OPERATION"
                icon="temperature-high"
                color="average"
                onClick={() => act('rods_2')}
              />
              <Button
                fluid
                content="AZ-3 - NOMINAL OPERATION"
                icon="temperature-low"
                color="yellow"
                onClick={() => act('rods_3')}
              />
              <Button
                fluid
                content="AZ-4 - COLD START"
                icon="snowflake"
                color="blue"
                onClick={() => act('rods_4')}
              />
              <Button
                fluid
                content="AZ-5 - SCRAM"
                icon="radiation-alt"
                color="bad"
                onClick={() => act('rods_5')}
              />
              <Button
                fluid
                content="AZ-6 - MAINTENANCE MODE"
                icon="cog"
                color={reactor_maintenance ? 'white' : undefined}
                onClick={() => act('maintenance')}
              />
              <Button
                fluid
                content="AZ-7 - FUEL DUMP"
                icon="gas-pump"
                color={pipe_open ? 'white' : undefined}
                onClick={() => act('pipe')}
              />
            </Fragment>
          </Section>

          {/* Control Rod Insertion */}
          <Section title="Control Rod Insertion:">
            <Slider
              value={control_rod_percent}
              minValue={0}
              maxValue={100}
              step={1}
              stepPixelSize={5}
              onDrag={(e, value) =>
                act('control_rod_percent', { adjust: value })
              }
            />
          </Section>

          {/* Statistics */}
          <Section title="Statistics:">
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
              value={rod_integrity}
              ranges={{
                good: [],
                average: [15, 50],
                bad: [-Infinity, 15],
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
            Fuel Ratio:
            <ProgressBar
              value={fuel_mix / total_moles}
              ranges={{
                good: [],
                average: [0.125, 0.25],
                bad: [-Infinity, 0.125],
              }}
            >
              {`${toFixed((fuel_mix / total_moles) * 100)} %`}
            </ProgressBar>
            Fuel Moles:
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

          {/* Fuel Line Composition */}
          <Section title="Fuel Line Composition:">
            <Flex spacing={1}>
              <Flex.Item width="200px">
                <Section>
                  <LabeledList>
                    <LabeledList.Item label="Plasma">
                      <ProgressBar
                        value={(plasma / total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="purple"
                      >
                        {`${toFixed((plasma / total_moles) * 100)} %`}
                      </ProgressBar>
                    </LabeledList.Item>

                    <LabeledList.Item label="Tritium">
                      <ProgressBar
                        value={(tritium / total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="pink"
                      >
                        {`${toFixed((tritium / total_moles) * 100)} %`}
                      </ProgressBar>
                    </LabeledList.Item>

                    <LabeledList.Item label="Oxygen">
                      <ProgressBar
                        value={(o2 / total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="blue"
                      >
                        {`${toFixed((o2 / total_moles) * 100)} %`}
                      </ProgressBar>
                    </LabeledList.Item>

                    <LabeledList.Item label="Nitrogen">
                      <ProgressBar
                        value={(n2 / total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="red"
                      >
                        {`${toFixed((n2 / total_moles) * 100)} %`}
                      </ProgressBar>
                    </LabeledList.Item>

                    <LabeledList.Item label="Carbon Dioxide">
                      <ProgressBar
                        value={(co2 / total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="grey"
                      >
                        {`${toFixed((co2 / total_moles) * 100)} %`}
                      </ProgressBar>
                    </LabeledList.Item>

                    <LabeledList.Item label="Water Vapour">
                      <ProgressBar
                        value={(water_vapour / total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="white"
                      >
                        {`${toFixed((water_vapour / total_moles) * 100)} %`}
                      </ProgressBar>
                    </LabeledList.Item>

                    <LabeledList.Item label="Hypernoblium">
                      <ProgressBar
                        value={(nob / total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="teal"
                      >
                        {`${toFixed((nob / total_moles) * 100)} %`}
                      </ProgressBar>
                    </LabeledList.Item>

                    <LabeledList.Item label="Nitrous Oxide">
                      <ProgressBar
                        value={(n2o / total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="label"
                      >
                        {`${toFixed((n2o / total_moles) * 100)} %`}
                      </ProgressBar>
                    </LabeledList.Item>

                    <LabeledList.Item label="Nitryl">
                      <ProgressBar
                        value={(no2 / total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                      >
                        {`${toFixed((no2 / total_moles) * 100)} %`}
                      </ProgressBar>
                    </LabeledList.Item>

                    <LabeledList.Item label="BZ">
                      <ProgressBar
                        value={(bz / total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="orange"
                      >
                        {`${toFixed((bz / total_moles) * 100)} %`}
                      </ProgressBar>
                    </LabeledList.Item>

                    <LabeledList.Item label="Stimulum">
                      <ProgressBar
                        value={(stim / total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="yellow"
                      >
                        {`${toFixed((stim / total_moles) * 100)} %`}
                      </ProgressBar>
                    </LabeledList.Item>

                    <LabeledList.Item label="Pluoxium">
                      <ProgressBar
                        value={(pluoxium / total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="olive"
                      >
                        {`${toFixed((pluoxium / total_moles) * 100)} %`}
                      </ProgressBar>
                    </LabeledList.Item>

                    <LabeledList.Item label="Nucleium">
                      <ProgressBar
                        value={(nucleium / total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="brown"
                      >
                        {`${toFixed((nucleium / total_moles) * 100)} %`}
                      </ProgressBar>
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Flex.Item>

              {/* Графики */}
              <Flex.Item grow={1}>
                <Section fill position="relative" height="100%">
                  <Chart.Line
                    fillPositionedParent
                    data={plasmaData}
                    rangeX={[0, plasmaData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(163, 51, 200, 1)"
                    fillColor="rgba(163, 51, 200, 0.1)"
                  />
                  <Chart.Line
                    fillPositionedParent
                    data={tritiumData}
                    rangeX={[0, tritiumData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(224, 57, 151, 1)"
                    fillColor="rgba(224, 57, 151, 0.1)"
                  />
                  <Chart.Line
                    fillPositionedParent
                    data={o2Data}
                    rangeX={[0, o2Data.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(33, 133, 208, 1)"
                    fillColor="rgba(33, 133, 208, 0)"
                  />
                  <Chart.Line
                    fillPositionedParent
                    data={n2Data}
                    rangeX={[0, n2Data.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(255, 0, 0, 1)"
                    fillColor="rgba(255, 0, 0, 0)"
                  />
                  <Chart.Line
                    fillPositionedParent
                    data={co2Data}
                    rangeX={[0, co2Data.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(118, 118, 118, 1)"
                    fillColor="rgba(118, 118, 118, 0)"
                  />
                  <Chart.Line
                    fillPositionedParent
                    data={water_vapourData}
                    rangeX={[0, water_vapourData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(255, 255, 255, 1)"
                    fillColor="rgba(255, 255, 255, 0)"
                  />
                  <Chart.Line
                    fillPositionedParent
                    data={nobData}
                    rangeX={[0, nobData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(0, 181, 173, 1)"
                    fillColor="rgba(0, 181, 173, 0)"
                  />
                  <Chart.Line
                    fillPositionedParent
                    data={n2oData}
                    rangeX={[0, n2oData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(126, 144, 167, 1)"
                    fillColor="rgba(126, 144, 167, 0)"
                  />
                  <Chart.Line
                    fillPositionedParent
                    data={no2Data}
                    rangeX={[0, no2Data.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(66, 87, 112, 1)"
                    fillColor="rgba(66, 87, 112, 0)"
                  />
                  <Chart.Line
                    fillPositionedParent
                    data={bzData}
                    rangeX={[0, bzData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(242, 113, 28, 1)"
                    fillColor="rgba(242, 113, 28, 0)"
                  />
                  <Chart.Line
                    fillPositionedParent
                    data={stimData}
                    rangeX={[0, stimData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(251, 214, 8, 1)"
                    fillColor="rgba(251, 214, 8, 0)"
                  />
                  <Chart.Line
                    fillPositionedParent
                    data={pluoxiumData}
                    rangeX={[0, pluoxiumData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(181, 204, 24, 1)"
                    fillColor="rgba(181, 204, 24, 0)"
                  />
                  <Chart.Line
                    fillPositionedParent
                    data={nucleiumData}
                    rangeX={[0, nucleiumData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(165, 103, 63, 1)"
                    fillColor="rgba(165, 103, 63, 0)"
                  />
                </Section>
              </Flex.Item>
            </Flex>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
}
