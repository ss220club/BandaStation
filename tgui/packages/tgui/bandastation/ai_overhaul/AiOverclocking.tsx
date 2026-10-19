import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import { formatPower } from 'tgui-core/format';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { NetworkHeader } from './Common';
import { NeuralShell } from './NeuralOS';

type Result = { speed: number; power: number; valid: BooleanLike };
type Data = {
  overclocking: BooleanLike;
  overclock_progress: number;
  has_cpu: BooleanLike;
  speed: number;
  max_speed: number;
  power_multiplier: number;
  max_power_multiplier: number;
  last_values: Result[];
  power_usage: number;
};
export function AiOverclocking() {
  const { act, data } = useBackend<Data>();
  const busy = !!data.overclocking;
  return (
    <Window title="Настройка нейропроцессора" width={510} height={580}>
      <Window.Content fitted className="AiOS">
        <NeuralShell application="Настройка процессора">
          <NetworkHeader
            title="Настройка нейропроцессора"
            signal={busy ? 'busy' : 'nominal'}
            status={
              busy
                ? 'ПРОВЕРКА СТАБИЛЬНОСТИ'
                : data.has_cpu
                  ? 'ПРОЦЕССОР УСТАНОВЛЕН'
                  : 'ОЖИДАНИЕ ПРОЦЕССОРА'
            }
            subtitle="Настройте частоту и питание, затем проверьте стабильность перед установкой процессора в сервер."
          />
          {!data.has_cpu ? (
            <NoticeBox info>
              {' '}
              Вставьте нейропроцессор. После успешной проверки CPU будет
              извлечён с подтверждёнными настройками.{' '}
            </NoticeBox>
          ) : (
            <>
              <Section
                title="Параметры настройки"
                buttons={
                  <Button
                    icon="eject"
                    disabled={busy}
                    onClick={() => act('eject_cpu')}
                  >
                    {' '}
                    Извлечь со сбросом{' '}
                  </Button>
                }
              >
                <LabeledList>
                  <LabeledList.Item label="Тактовая частота">
                    <NumberInput
                      value={data.speed}
                      unit="ТГц"
                      minValue={0.1}
                      maxValue={data.max_speed}
                      step={0.1}
                      disabled={busy}
                      onChange={(new_speed) => act('set_speed', { new_speed })}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Множитель питания">
                    <NumberInput
                      value={data.power_multiplier}
                      minValue={0.5}
                      maxValue={data.max_power_multiplier}
                      step={0.1}
                      disabled={busy}
                      onChange={(new_power) => act('set_power', { new_power })}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Потребляемая мощность">
                    {formatPower(data.power_usage)}
                  </LabeledList.Item>
                </LabeledList>
                <Box color="label" mt={1}>
                  {' '}
                  Неудачная проверка или отмена настройки восстанавливает
                  заводские параметры.{' '}
                </Box>
              </Section>
              <Section
                title={
                  busy ? 'Идёт проверка стабильности' : 'Проверка стабильности'
                }
              >
                {busy ? (
                  <>
                    <ProgressBar
                      value={1 - data.overclock_progress}
                      color="blue"
                    >
                      {Math.round((1 - data.overclock_progress) * 100)}%
                    </ProgressBar>
                    <Button
                      mt={1}
                      color="bad"
                      icon="stop"
                      onClick={() => act('stop_overclock')}
                    >
                      {' '}
                      Отменить проверку{' '}
                    </Button>
                  </>
                ) : (
                  <Button
                    fluid
                    icon="play"
                    onClick={() => act('test_overclock')}
                  >
                    {' '}
                    Проверить и применить{' '}
                  </Button>
                )}
              </Section>
              <Section title="Последние проверки">
                {!data.last_values?.length && (
                  <Box color="label">Этот процессор ещё не проверяли.</Box>
                )}
                {(data.last_values || []).map((result, index) => (
                  <Section
                    key={index}
                    title={`${result.speed.toFixed(2)} ТГц / ${result.power.toFixed(2)}× питание`}
                    buttons={
                      <Button
                        disabled={busy}
                        onClick={() => {
                          act('set_speed', { new_speed: result.speed });
                          act('set_power', { new_power: result.power });
                        }}
                      >
                        {' '}
                        Применить{' '}
                      </Button>
                    }
                  >
                    <Box color={result.valid ? 'good' : 'bad'}>
                      {result.valid ? 'Стабильно' : 'Нестабильно'}
                    </Box>
                  </Section>
                ))}
              </Section>
            </>
          )}
        </NeuralShell>
      </Window.Content>
    </Window>
  );
}
