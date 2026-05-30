import { useBackend } from '../backend';
import { Button, Section, Stack, LabeledList, ProgressBar, NoticeBox, Divider } from 'tgui-core/components';
import { Window } from '../layouts';

type ThrallData = {
  name: string;
  ref: string;
  status: string;
  health: number;
  location: string;
  objective: string;
  has_mob: boolean;
};

type HivemindData = {
  infector_name: string;
  infector_status: string;
  thralls: ThrallData[];
  thrall_count: number;
};

const STATUS_COLORS: Record<string, string> = {
  'Активен': 'green',
  'Критическое': 'orange',
  'Без сознания': 'yellow',
  'Мёртв': 'red',
};

export const KhaaraHivemind = (props) => {
  const { act, data } = useBackend<HivemindData>();
  const { infector_name, infector_status, thralls = [], thrall_count } = data;

  return (
    <Window width={620} height={500} title="Улей Кхара">
      <Window.Content>
        <Section scrollable fill>
          <Stack vertical>
            <Stack.Item textAlign="center" fontSize="18px" bold color="#ff5500">
              Улей Кхара
            </Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Источник">
                  {infector_name} ({infector_status})
                </LabeledList.Item>
                <LabeledList.Item label="Заражённых">
                  {thrall_count}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Divider />
            <Stack.Item>
              <Button icon="sync" onClick={() => act('refresh')}>
                Обновить
              </Button>
            </Stack.Item>
            <Stack.Item>
              {thralls.length === 0 ? (
                <NoticeBox>Нет заражённых в улье.</NoticeBox>
              ) : (
                <Stack vertical>
                  {thralls.map((thrall) => (
                    <Section
                      key={thrall.ref}
                      title={thrall.name}
                      buttons={
                        <Stack>
                          <Stack.Item>
                            <Button
                              icon="comment"
                              color="blue"
                              onClick={() =>
                                act('send_command', { ref: thrall.ref })
                              }>
                              Команда
                            </Button>
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              icon="bullseye"
                              color="yellow"
                              onClick={() =>
                                act('set_objective', { ref: thrall.ref })
                              }>
                              Цель
                            </Button>
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              icon="skull"
                              color="red"
                              onClick={() =>
                                act('kill_thrall', { ref: thrall.ref })
                              }>
                              Умертвить
                            </Button>
                          </Stack.Item>
                        </Stack>
                      }>
                      <LabeledList>
                        <LabeledList.Item label="Статус">
                          <span
                            style={{ color: STATUS_COLORS[thrall.status] || 'white' }}>
                            {thrall.status}
                          </span>
                        </LabeledList.Item>
                        <LabeledList.Item label="Здоровье">
                          <ProgressBar
                            value={thrall.health / 100}
                            ranges={{
                              good: [0.7, 1],
                              average: [0.4, 0.7],
                              bad: [0, 0.4],
                            }}>
                            {thrall.health}%
                          </ProgressBar>
                        </LabeledList.Item>
                        <LabeledList.Item label="Локация">
                          {thrall.location}
                        </LabeledList.Item>
                        <LabeledList.Item label="Цель">
                          {thrall.objective}
                        </LabeledList.Item>
                      </LabeledList>
                    </Section>
                  ))}
                </Stack>
              )}
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
