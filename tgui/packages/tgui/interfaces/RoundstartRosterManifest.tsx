import { Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  jobs: { title: string; count: number }[];
  total: number;
};

export function RoundstartRosterManifest() {
  const { data } = useBackend<Data>();
  const { jobs, total } = data;

  return (
    <Window width={400} height={360}>
      <Window.Content style={{ overflowY: 'auto' }}>
        <Section title={`Занято мест: ${total}`}>
          <Table>
            {jobs.map((job) => (
              <Table.Row key={job.title} className="candystripe">
                <Table.Cell bold>{job.title}</Table.Cell>
                <Table.Cell collapsing textAlign="right">
                  {job.count}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
}
