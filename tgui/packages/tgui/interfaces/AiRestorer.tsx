// BANDASTATION ADD START - Перенос ИИ: оформление и состояния восстановления ИИ.
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { NetworkHeader } from '../bandastation/ai_overhaul/Common';
import { NeuralShell } from '../bandastation/ai_overhaul/NeuralOS';
import { Window } from '../layouts';

type Data = {
  AI_present: BooleanLike;
  error: string | null;
  name: string;
  laws: string[];
  isDead: BooleanLike;
  restoring: BooleanLike;
  health: number;
  ejectable: BooleanLike;
};

export const AiRestorer = () => {
  return (
    <Window title="Терминал восстановления ИИ" width={450} height={550}>
      <Window.Content fitted className="AiOS">
        <AiRestorerWorkspace />
      </Window.Content>
    </Window>
  );
};

export const AiRestorerWorkspace = () => {
  const { data } = useBackend<Data>();
  return (
    <NeuralShell
      application="Восстановление ИИ"
      telemetry={
        data.AI_present && !data.error
          ? {
              integrityPercent: data.isDead ? 0 : data.health,
            }
          : undefined
      }
    >
      <AiRestorerContent />
    </NeuralShell>
  );
};

export const AiRestorerContent = () => {
  const { act, data } = useBackend<Data>();
  const {
    AI_present,
    error,
    name,
    laws = [],
    isDead,
    restoring,
    health,
    ejectable,
  } = data;

  return (
    <>
      <NetworkHeader
        compact
        title={AI_present ? name || 'ИИ на карте' : 'Восстановление ИИ'}
        subtitle="intelliCard / восстановление нейроструктуры"
        signal={
          AI_present && isDead
            ? 'alert'
            : restoring || (AI_present && error)
              ? 'busy'
              : AI_present && health < 70
                ? 'degraded'
                : 'nominal'
        }
        status={
          !AI_present
            ? 'ОЖИДАНИЕ ИИ'
            : error
              ? 'РАБОТА С КАРТОЙ ЗАБЛОКИРОВАНА'
              : restoring
                ? 'ВОССТАНОВЛЕНИЕ'
                : isDead
                  ? 'ИИ НЕ ФУНКЦИОНИРУЕТ'
                  : 'ИИ ОТВЕЧАЕТ'
        }
      />
      {!AI_present && !error && (
        <NoticeBox info>
          {' '}
          Вставьте intelliCard с ИИ для проверки и восстановления.{' '}
        </NoticeBox>
      )}
      {error && <NoticeBox textAlign="center">{error}</NoticeBox>}
      {!!ejectable && (
        <Button
          fluid
          icon="eject"
          content={AI_present ? name || 'Извлечь intelliCard' : '----------'}
          disabled={!AI_present || !!restoring}
          onClick={() => act('PRG_eject')}
        />
      )}
      {!!AI_present && !error && (
        <Section
          title={ejectable ? 'Состояние системы' : name}
          buttons={
            <Box inline bold color={isDead ? 'bad' : 'good'}>
              {isDead ? 'Не функционирует' : 'Функционирует'}
            </Box>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Целостность">
              <ProgressBar
                value={health}
                minValue={0}
                maxValue={100}
                ranges={{
                  good: [70, Infinity],
                  average: [50, 70],
                  bad: [-Infinity, 50],
                }}
              />
            </LabeledList.Item>
          </LabeledList>
          {!!restoring && (
            <Box bold textAlign="center" fontSize="20px" color="good" mt={1}>
              {' '}
              ВОССТАНОВЛЕНИЕ В ПРОЦЕССЕ{' '}
            </Box>
          )}
          <Button
            fluid
            icon="plus"
            content="Начать восстановление"
            disabled={!!restoring || health >= 100}
            mt={1}
            onClick={() => act('PRG_beginReconstruction')}
          />
          <Section title="Законы">
            {laws.map((law) => (
              <Box key={law} className="candystripe">
                {law}
              </Box>
            ))}
          </Section>
        </Section>
      )}
    </>
  );
};
// BANDASTATION ADD END - Перенос ИИ
