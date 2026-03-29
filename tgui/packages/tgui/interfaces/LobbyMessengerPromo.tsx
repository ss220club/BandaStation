import type { CSSProperties } from 'react';
import { Box, Button, Image, Stack } from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  step: number;
  asset_gosuslugi?: string;
  asset_flag_ru?: string;
  asset_max_logo?: string;
};

const bgPage = '#e8f4fc';
const bluePrimary = '#0055d4';
const blueText = '#0055d4';
const textMuted = 'rgba(0,0,0,0.62)';

const maxWordmarkStyle: CSSProperties = {
  textTransform: 'uppercase',
  fontFamily:
    '"Bahnschrift", "Segoe UI Variable", "Segoe UI Semibold", "Segoe UI", system-ui, sans-serif',
  fontWeight: 700,
  letterSpacing: '0.1em',
  fontSize: '26px',
  color: '#111',
  WebkitFontSmoothing: 'antialiased',
  MozOsxFontSmoothing: 'grayscale',
  textShadow: '0 1px 0 rgba(255, 255, 255, 0.35)',
};

// uhm seems to be broken
const imgSmoothRaster = (extra: CSSProperties = {}): CSSProperties => ({
  display: 'block',
  imageRendering: 'auto',
  ...extra,
});

const flagCircleOutline: CSSProperties = imgSmoothRaster({
  width: '18px',
  height: '18px',
  borderRadius: '50%',
  objectFit: 'cover',
  objectPosition: 'center',
  flexShrink: 0,
  boxShadow:
    '0 0 0 1px rgba(0, 0, 0, 0.14), 0 0 0 2px rgba(255, 255, 255, 0.95), 0 1px 3px rgba(0, 0, 0, 0.12)',
});

const gosuslugiLogoStyle: CSSProperties = imgSmoothRaster({
  margin: '0 auto',
  width: 'auto',
  height: 'auto',
  maxWidth: '100%',
  maxHeight: '52px',
  objectFit: 'contain',
  objectPosition: 'center center',
});

const maxCircleLogoStyle: CSSProperties = imgSmoothRaster({
  width: '52px',
  height: '52px',
  borderRadius: '50%',
  objectFit: 'contain',
  objectPosition: 'center',
  flexShrink: 0,
  boxSizing: 'border-box',
});

const card = {
  backgroundColor: '#ffffff',
  borderRadius: '14px',
  padding: '22px 20px 20px',
  boxShadow: '0 2px 12px rgba(0, 80, 160, 0.08)',
  maxWidth: '400px',
  margin: '0 auto',
};

const btnFluidCentered = {
  display: 'flex',
  justifyContent: 'center',
  alignItems: 'center',
  width: '100%',
  textAlign: 'center' as const,
};

const primaryBtn = {
  ...btnFluidCentered,
  backgroundColor: bluePrimary,
  color: '#ffffff',
  border: 'none',
  fontWeight: 'bold' as const,
  borderRadius: '10px',
  padding: '12px',
};

const ghostBtn = {
  ...btnFluidCentered,
  backgroundColor: 'transparent',
  color: blueText,
  border: 'none',
  fontWeight: 'normal' as const,
};

export function LobbyMessengerPromo() {
  const { act, data } = useBackend<Data>();
  const step = data.step ?? 1;
  const isStep1 = step === 1;

  const gos = data.asset_gosuslugi && resolveAsset(data.asset_gosuslugi);
  const flag = data.asset_flag_ru && resolveAsset(data.asset_flag_ru);
  const maxLogo = data.asset_max_logo && resolveAsset(data.asset_max_logo);

  return (
    <Window
      theme="paper"
      width={440}
      height={620}
      title=" "
      canClose={false}
      showStatusIcon={false}
    >
      <Window.Content fitted backgroundColor={bgPage}>
        <Box style={{ padding: '12px 10px 14px' }}>
          <Stack vertical>
            <Stack.Item>
              <Box style={card}>
                <Stack vertical>
                  {gos && (
                    <Stack.Item>
                      <Box textAlign="center" mb={1} style={{ lineHeight: 0 }}>
                        <Image src={gos} style={gosuslugiLogoStyle} />
                      </Box>
                    </Stack.Item>
                  )}

                  <Stack.Item>
                    <Box
                      style={{
                        display: 'flex',
                        width: '100%',
                        justifyContent: 'center',
                        alignItems: 'center',
                        gap: '6px',
                        color: '#5a6d8c',
                        fontSize: '12px',
                      }}
                    >
                      <Box inline>Русский</Box>
                      {flag && <Image src={flag} style={flagCircleOutline} />}
                    </Box>
                  </Stack.Item>

                  <Stack.Item mt={2}>
                    {isStep1 ? <Step1 maxLogoSrc={maxLogo} /> : <Step2 />}
                  </Stack.Item>

                  <Stack.Item mt={2}>
                    {isStep1 ? (
                      <Stack vertical>
                        <Stack.Item mb={2}>
                          <Button
                            fluid
                            onClick={() => act('download')}
                            style={primaryBtn}
                          >
                            Скачать MAX
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            fluid
                            content="Пропустить"
                            onClick={() => act('skip_step1')}
                            style={ghostBtn}
                          />
                        </Stack.Item>
                      </Stack>
                    ) : (
                      <Stack vertical>
                        <Stack.Item mb={2}>
                          <Button
                            fluid
                            content="Подключить"
                            onClick={() => act('connect')}
                            style={primaryBtn}
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            fluid
                            content="Пропустить"
                            onClick={() => act('dismiss')}
                            style={ghostBtn}
                          />
                        </Stack.Item>
                      </Stack>
                    )}
                  </Stack.Item>
                </Stack>
              </Box>
            </Stack.Item>
          </Stack>
        </Box>
      </Window.Content>
    </Window>
  );
}

function Step1(props: { maxLogoSrc: string | undefined }) {
  const { maxLogoSrc } = props;
  return (
    <Stack vertical>
      <Stack.Item mb={2}>
        <Box
          fontSize="14px"
          fontWeight="bold"
          lineHeight={1.45}
          color="#1a1a1a"
          textAlign="center"
        >
          Установите национальный мессенджер и подтверждайте вход через
        </Box>
      </Stack.Item>

      <Stack.Item mb={2}>
        <Stack align="center" justify="center">
          {maxLogoSrc && <Image src={maxLogoSrc} style={maxCircleLogoStyle} />}
          <Box inline ml={maxLogoSrc ? 2 : 0} style={maxWordmarkStyle}>
            MAX
          </Box>
        </Stack>
      </Stack.Item>

      <Stack.Item>
        <Box
          fontSize="12px"
          lineHeight={1.55}
          color={textMuted}
          textAlign="center"
        >
          Получайте коды подтверждения в чат мессенджера. Для этого скачайте
          приложение и зарегистрируйтесь по номеру.
        </Box>
      </Stack.Item>
    </Stack>
  );
}

function Step2() {
  return (
    <Stack vertical>
      <Stack.Item mb={2}>
        <Box
          fontSize="14px"
          fontWeight="bold"
          lineHeight={1.45}
          color="#1a1a1a"
          textAlign="center"
        >
          Подтверждайте вход через мессенджер МАХ
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Box
          fontSize="12px"
          lineHeight={1.55}
          color={textMuted}
          textAlign="center"
        >
          Код для входа будет приходить в мессенджер МАХ на номер телефона.
        </Box>
      </Stack.Item>
    </Stack>
  );
}
