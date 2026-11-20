import {
  Box,
  Button,
  Collapsible,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { NetworkHeader } from './Common';
import { NeuralShell } from './NeuralOS';

type Data = {
  AI_present: BooleanLike;
  name?: string;
  isDead?: BooleanLike;
  isBraindead?: BooleanLike;
  health?: number;
  wireless?: BooleanLike;
  radio?: BooleanLike;
  wiping: BooleanLike;
  laws?: string[];
};

export function Intellicard() {
  const { act, data } = useBackend<Data>();
  const present = !!data.AI_present;
  const wiping = present && !!data.wiping;
  const dead = present && !!data.isDead;
  const health =
    typeof data.health === 'number' && Number.isFinite(data.health)
      ? Math.max(0, Math.min(100, data.health))
      : undefined;
  const laws = data.laws || [];
  const status = !present
    ? 'НОСИТЕЛЬ ПУСТ'
    : wiping
      ? 'ОЧИСТКА НЕЙРОСТРУКТУРЫ'
      : dead
        ? 'ИИ НЕ ФУНКЦИОНИРУЕТ'
        : data.isBraindead
          ? 'ИГРОК НЕ ПОДКЛЮЧЁН'
          : 'НЕЙРОСТРУКТУРА АКТИВНА';
  return (
    <Window title="intelliCard / Сервисный терминал" width={540} height={680}>
      <Window.Content fitted className="AiOS">
        <NeuralShell
          application="intelliCard / Переносной носитель ИИ"
          telemetry={
            present ? { integrityPercent: dead ? 0 : health } : undefined
          }
        >
          <NetworkHeader
            compact
            title={present ? data.name || 'ИИ на карте' : 'intelliCard'}
            subtitle="Переносной носитель / локальное обслуживание"
            status={status}
            signal={
              wiping || dead
                ? 'alert'
                : present && (data.isBraindead || (health ?? 100) < 70)
                  ? 'degraded'
                  : 'nominal'
            }
          />
          {!present ? (
            <Section title="Носитель готов к загрузке">
              <NoticeBox info>
                На карте нет ИИ. Подключите её к оборудованию переноса или
                используйте на доступном ядре. Для выгрузки требуется согласие
                ИИ.
              </NoticeBox>
              <Box color="label">
                После загрузки здесь появятся состояние нейроструктуры,
                управление связью и список законов.
              </Box>
            </Section>
          ) : (
            <>
              <Section title="Состояние нейроструктуры">
                <div className="AiOS__cardReadout">
                  <div>
                    <div className="AiOS__eyebrow">ЦЕЛОСТНОСТЬ</div>
                    <div className="AiOS__cardIntegrity">
                      {health === undefined ? '—' : `${Math.round(health)}%`}
                    </div>
                  </div>
                  <div className="AiOS__cardState" role="status">
                    {wiping
                      ? 'Удаление системных файлов'
                      : dead
                        ? 'Требуется восстановление на специальном оборудовании'
                        : data.isBraindead
                          ? 'Содержимое сохранено; подключённого игрока нет'
                          : 'ИИ находится на переносном носителе'}
                  </div>
                </div>
                {health !== undefined && (
                  <ProgressBar
                    value={health}
                    minValue={0}
                    maxValue={100}
                    ranges={{
                      good: [70, Infinity],
                      average: [50, 70],
                      bad: [-Infinity, 50],
                    }}
                  >
                    {Math.round(health)} / 100
                  </ProgressBar>
                )}
              </Section>
              <Section title="Каналы связи">
                <div className="AiOS__cardChannels">
                  <div>
                    <Button
                      fluid
                      icon="signal"
                      selected={!!data.wireless}
                      onClick={() => act('wireless')}
                    >
                      Беспроводное управление:{' '}
                      {data.wireless ? 'вкл.' : 'выкл.'}
                    </Button>
                    <Box color="label">
                      Разрешение на удалённое управление устройствами.
                    </Box>
                  </div>
                  <div>
                    <Button
                      fluid
                      icon="microphone"
                      selected={!!data.radio}
                      onClick={() => act('radio')}
                    >
                      Подпространственная связь: {data.radio ? 'вкл.' : 'выкл.'}
                    </Button>
                    <Box color="label">Включение и отключение радио ИИ.</Box>
                  </div>
                </div>
              </Section>
              <Collapsible title={`Законы на носителе · ${laws.length}`}>
                <Section title="Сохранённые директивы">
                  {laws.length ? (
                    <ul className="AiOS__cardLaws">
                      {laws.map((law, index) => (
                        <li key={index}>{law}</li>
                      ))}
                    </ul>
                  ) : (
                    <NoticeBox>В сохранённом наборе нет законов.</NoticeBox>
                  )}
                </Section>
              </Collapsible>
              <Section title="Очистка памяти" className="AiOS__cardDanger">
                {wiping ? (
                  <NoticeBox danger>
                    Очистка выполняется. Её можно остановить; уже нанесённый
                    ущерб при остановке сохраняется.
                  </NoticeBox>
                ) : (
                  <Box mb={1}>
                    Очистка повреждает нейроструктуру и приводит к гибели ИИ.
                    Для запуска потребуется подтверждение.
                  </Box>
                )}
                <Button
                  fluid
                  color="bad"
                  icon={wiping ? 'stop' : 'trash'}
                  disabled={dead && !wiping}
                  onClick={() => act('wipe')}
                >
                  {wiping ? 'Остановить очистку' : 'Начать очистку памяти'}
                </Button>
              </Section>
            </>
          )}
        </NeuralShell>
      </Window.Content>
    </Window>
  );
}
