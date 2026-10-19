import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { NetworkHeader, NetworkLogin } from './Common';
import { NeuralShell } from './NeuralOS';

type Ai = {
  name: string;
  ref: string;
  in_core: BooleanLike;
  active: BooleanLike;
  can_download: BooleanLike;
  health: number;
};
type Data = {
  authenticated: BooleanLike;
  has_access: BooleanLike;
  username: string;
  intellicard: BooleanLike;
  intellicard_ai: string | null;
  intellicard_ai_health: number;
  can_upload: BooleanLike;
  can_log_out: BooleanLike;
  downloading: string | null;
  download_progress: number;
  downloading_ref: string;
  current_ai_ref: string;
  ais: Ai[];
};

export function AiControlPanel() {
  const { act, data } = useBackend<Data>();
  const [code, setCode] = useState('');
  return (
    <Window title="Консоль управления ИИ" width={640} height={650}>
      <Window.Content fitted className="AiOS">
        <NeuralShell application="Управление ИИ">
          <NetworkHeader
            title="Управление ИИ"
            signal={data.downloading ? 'busy' : 'nominal'}
            status={
              !data.authenticated
                ? 'ТРЕБУЕТСЯ АВТОРИЗАЦИЯ'
                : data.downloading
                  ? 'ПЕРЕНОС ИИ'
                  : 'ОПЕРАТОР АВТОРИЗОВАН'
            }
            subtitle="Контроль ядер ИИ и перенос интеллекта с помощью intelliCard."
          />
          {!data.authenticated ? (
            <>
              <NetworkLogin
                username={data.username}
                hasAccess={data.has_access}
                onLogin={() => act('log_in')}
              />
              <Section title="Аварийный доступ">
                <Stack>
                  <Stack.Item grow>
                    <Input
                      fluid
                      value={code}
                      maxLength={6}
                      placeholder="Шестизначный код доступа"
                      onChange={setCode}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      disabled={!/^\d{6}$/.test(code)}
                      onClick={() =>
                        act('log_in_control_code', { control_code: code })
                      }
                    >
                      {' '}
                      Авторизоваться{' '}
                    </Button>
                  </Stack.Item>
                </Stack>
              </Section>
            </>
          ) : (
            <>
              <Section
                title="Перенос ИИ"
                buttons={
                  !!data.can_log_out && (
                    <Button icon="sign-out-alt" onClick={() => act('log_out')}>
                      {' '}
                      Выйти{' '}
                    </Button>
                  )
                }
              >
                {!data.intellicard ? (
                  <NoticeBox info>
                    {' '}
                    Вставьте intelliCard для загрузки или выгрузки ИИ. Для
                    создания ИИ можно вставить активный ММИ.{' '}
                  </NoticeBox>
                ) : (
                  <>
                    <Box mb={1}>
                      {data.intellicard_ai
                        ? `ИИ на карте: ${data.intellicard_ai}`
                        : 'Пустая intelliCard готова к работе'}
                    </Box>
                    <Button
                      icon="eject"
                      onClick={() => act('eject_intellicard')}
                    >
                      {' '}
                      Извлечь карту{' '}
                    </Button>
                    <Button.Confirm
                      icon="upload"
                      disabled={
                        !data.intellicard_ai ||
                        !data.can_upload ||
                        !!data.downloading
                      }
                      confirmContent="Загрузить ИИ в сеть?"
                      onClick={() => act('upload_intellicard')}
                    >
                      {' '}
                      Загрузить ИИ{' '}
                    </Button.Confirm>
                  </>
                )}
                {!data.can_upload && (
                  <NoticeBox>
                    {' '}
                    Нет рабочего ядра ИИ. Проверьте питание, атмосферу и
                    охлаждение.{' '}
                  </NoticeBox>
                )}
              </Section>
              {!!data.downloading && (
                <Section
                  title={`Выгрузка ${data.downloading}`}
                  buttons={
                    <Button
                      color="bad"
                      icon="stop"
                      onClick={() => act('stop_download')}
                    >
                      {' '}
                      Отменить{' '}
                    </Button>
                  }
                >
                  <ProgressBar
                    value={data.download_progress / 100}
                    color="blue"
                  >
                    {data.download_progress.toFixed(1)}%
                  </ProgressBar>
                  <Box mt={1} color="label">
                    {' '}
                    Не извлекайте карту и не отключайте питание консоли. ИИ
                    может отозвать разрешение на выгрузку.{' '}
                  </Box>
                  {data.current_ai_ref === data.downloading_ref && (
                    <Button
                      mt={1}
                      icon="check"
                      onClick={() => act('skip_download')}
                    >
                      {' '}
                      Подтвердить и завершить перенос{' '}
                    </Button>
                  )}
                </Section>
              )}
              {!data.ais?.length && (
                <NoticeBox info>Зарегистрированных ИИ нет.</NoticeBox>
              )}
              {(data.ais || []).map((ai) => {
                const reason = !ai.in_core
                  ? 'ИИ находится вне ядра'
                  : !ai.can_download
                    ? 'Выгрузка не разрешена'
                    : !data.intellicard
                      ? 'Вставьте intelliCard'
                      : data.intellicard_ai
                        ? 'Карта уже занята'
                        : data.downloading
                          ? 'Перенос уже выполняется'
                          : undefined;
                return (
                  <Section
                    key={ai.ref}
                    title={ai.name}
                    buttons={
                      <Box color={ai.in_core ? 'good' : 'average'}>
                        {ai.in_core ? 'В СЕТИ' : 'ВНЕ ЯДРА'}
                      </Box>
                    }
                  >
                    <ProgressBar
                      value={Math.max(0, Math.min(1, (ai.health + 100) / 200))}
                      color={ai.health > 0 ? 'good' : 'bad'}
                    >
                      {' '}
                      Целостность:{' '}
                      {Math.max(
                        0,
                        Math.min(100, (ai.health + 100) / 2),
                      ).toFixed(0)}
                      %
                    </ProgressBar>
                    <Stack mt={1} align="center">
                      <Stack.Item grow>
                        <Box color="label">{reason || 'Готов к выгрузке'}</Box>
                      </Stack.Item>
                      <Stack.Item>
                        <Button.Confirm
                          icon="download"
                          disabled={!!reason}
                          confirmContent="Начать выгрузку?"
                          onClick={() =>
                            act('start_download', { download_target: ai.ref })
                          }
                        >
                          {' '}
                          Выгрузить{' '}
                        </Button.Confirm>
                      </Stack.Item>
                    </Stack>
                  </Section>
                );
              })}
            </>
          )}
        </NeuralShell>
      </Window.Content>
    </Window>
  );
}
