import { useBackend } from 'tgui/backend';
import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import type { PaiData } from './types';

export function SystemDisplay(props) {
  return (
    <Stack fill vertical>
      <Stack.Item grow={3}>
        <SystemWallpaper />
      </Stack.Item>
      <Stack.Item grow>
        <SystemInfo />
      </Stack.Item>
    </Stack>
  );
}

/** Renders some ASCII art. Changes to red on emag. */
function SystemWallpaper(props) {
  const { data } = useBackend<PaiData>();
  const { emagged } = data;

  const owner = !emagged ? 'НАНОТРЕЙЗЕН' : ' СИНДИКАТА';
  const eyebrows = !emagged ? "/\\ ' /\\" : ' \\\\ // ';

  const paiAscii = [
    ' ________  ________  ___',
    ' |\\   __  \\|\\   __  \\|\\  \\',
    ' \\ \\  \\|\\  \\ \\  \\|\\  \\ \\  \\     Версия',
    '  \\ \\   ____\\ \\   __  \\ \\  \\     интерфейса 2.5',
    '   \\ \\  \\___|\\ \\  \\ \\  \\ \\  \\',
    '    \\ \\__\\    \\ \\__\\ \\__\\ \\__\\     Собственность',
    `     \\|__|     \\|__|\\|__|\\|__|      ${owner}`,
    '',
  ].join('\n');

  const floofAscii = [
    '                              .--.       .-.',
    "        ,;;``;;-;,,..___.,,.-/   `;_//,.'   )",
    "      .' ;;  `;  :; `;;  ;;  `.       '/   .'",
    `     ,;  ';   ;   '  ';  ';   ,'    ${eyebrows}';`, // lol
    "    /'     `      \\   `     ;','   ( d\\__b_),",
    "   /   /       .,;;)       ', (    .'     __\\",
    "  ;:.  \\     ,_   /         ', ' .'_      \\/;",
    " ,   ,;'      `;;/       /    ';,\\ `-..__._,'",
    " ;:.  /____  ..-'--.    /-'    ..---. ._._/ ---.",
    " |    ;' ;'|        \\--/;' ,' /      \\   ,      \\",
    " `.fL__;,__/-..__)_)/  `--'--'`-._)_)/ --\\.._)_)/",
  ].join('\n');

  return (
    <Section fill nowrap overflow="hidden">
      <pre>
        <Box color={!emagged ? 'blue' : 'crimson'}>{paiAscii}</Box>
        <Box color={!emagged ? 'gold' : 'limegreen'}>{floofAscii}</Box>
      </pre>
    </Section>
  );
}

/** Displays master info.
 * You can check their DNA and change your image here.
 */
function SystemInfo(props) {
  const { act, data } = useBackend<PaiData>();
  const { screen_image_interface_icon, master_dna, master_name } = data;

  return (
    <Section
      buttons={
        <>
          <Button
            disabled={!master_dna}
            icon="dna"
            onClick={() => act('check dna')}
            tooltip="Проверяет ДНК вашего хозяина. Необходимо носить в руке."
          >
            Проверка
          </Button>
          <Button
            icon={screen_image_interface_icon}
            onClick={() => act('change image')}
            tooltip="Сменить изображение на дисплее."
          >
            Дисплей
          </Button>
        </>
      }
      fill
      title="Системная информация"
    >
      <LabeledList>
        <LabeledList.Item label="Мастер">
          {master_name || 'Отсутствует.'}
        </LabeledList.Item>
        <LabeledList.Item color={master_dna ? 'red' : ''} label="ДНК">
          {master_dna || 'Отсутствует.'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
}
