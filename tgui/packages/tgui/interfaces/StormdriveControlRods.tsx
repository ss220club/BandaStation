// NSV13
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

type ControlRod = {
  id: string | number;
  name: string;
  health: number;
  max_health: number;
};

type StormdriveControlRodsData = {
  mounted_control_rods?: Record<string, ControlRod>;
};

export function StormdriveControlRods(props: any, context: any) {
  const { act, data } = useBackend<StormdriveControlRodsData>(context);

  const { mounted_control_rods } = data;

  return (
    <Window resizable theme="hackerman" width={560} height={600}>
      <Window.Content scrollable>
        <Section>
          <Section title="Installed Control Rods:">
            {!!mounted_control_rods && Object.keys(mounted_control_rods).length > 0 ? (
              <Section>
                {Object.keys(mounted_control_rods).map((key) => {
                  const rod = mounted_control_rods[key];

                  return (
                    <Fragment key={key}>
                      <Section title={rod.name}>
                        <Button
                          fluid
                          content={`Eject ${rod.name}`}
                          icon="eject"
                          onClick={() => act('remove_rod', { target: rod.id })}
                        />

                        <ProgressBar
                          value={rod.health / rod.max_health}
                          ranges={{
                            good: [0.66, Infinity],
                            average: [0.33, 0.66],
                            bad: [-Infinity, 0.33],
                          }}
                        >
                          {Math.round((rod.health / rod.max_health) * 100)}%
                        </ProgressBar>
                      </Section>
                    </Fragment>
                  );
                })}
              </Section>
            ) : (
              <Section>
                <Box color="average">No control rods installed.</Box>
              </Section>
            )}
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
