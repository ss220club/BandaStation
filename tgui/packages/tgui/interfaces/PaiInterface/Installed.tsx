import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, NoticeBox, Section, Stack } from 'tgui-core/components';

import { DOOR_JACK, HOST_SCAN, PHOTO_MODE, SOFTWARE_DESC } from './constants';
import type { PaiData } from './types';

/**
 * Renders two sections: A section of buttons and
 * another section that displays the selected installed
 * software info.
 */
export function InstalledDisplay(props) {
  const { data } = useBackend<PaiData>();
  const { installed = [] } = data;

  const [currentSelection, setCurrentSelection] = useState('');

  const title = !currentSelection ? 'Выбрать программу' : currentSelection;

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section fill scrollable title={title}>
          {currentSelection && (
            <Stack fill vertical>
              <Stack.Item>{SOFTWARE_DESC[currentSelection]}</Stack.Item>
              <Stack.Item grow>
                <SoftwareButtons currentSelection={currentSelection} />
              </Stack.Item>
            </Stack>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item grow={2}>
        <Section fill scrollable title="Установленное ПО">
          {!installed.length ? (
            <NoticeBox>Ничего не установлено!</NoticeBox>
          ) : (
            installed.map((software, index) => {
              return (
                <Button
                  key={index}
                  onClick={() => setCurrentSelection(software)}
                >
                  {software}
                </Button>
              );
            })
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
}

type SoftwareButtonsProps = {
  currentSelection: string;
};

/**
 * Once a software is selected, generates custom buttons or a default
 * power toggle.
 */
function SoftwareButtons(props: SoftwareButtonsProps) {
  const { currentSelection } = props;

  const { act, data } = useBackend<PaiData>();
  const { door_jack, languages, master_name } = data;

  switch (currentSelection) {
    case 'Дверной взломщик':
      return (
        <>
          <Button
            disabled={!!door_jack}
            icon="plug"
            onClick={() => act(currentSelection, { mode: DOOR_JACK.Cable })}
            tooltip="Отсоедините кабель. Вставьте в совместимый шлюз."
          >
            Вытянуть провод
          </Button>
          <Button
            color="bad"
            disabled={!door_jack}
            icon="door-open"
            onClick={() => act(currentSelection, { mode: DOOR_JACK.Hack })}
            tooltip="Начинает переопределять протоколы безопасности шлюза."
          >
            Взлом двери
          </Button>
          <Button
            disabled={!door_jack}
            icon="unlink"
            onClick={() => act(currentSelection, { mode: DOOR_JACK.Cancel })}
          >
            Cancel
          </Button>
        </>
      );
    case 'Сканирование хоста':
      return (
        <>
          <Button
            icon="hand-holding-heart"
            onClick={() => act(currentSelection, { mode: HOST_SCAN.Target })}
            tooltip="Необходимо держать или взять для сканирования."
          >
            Сканирование
          </Button>
          <Button
            disabled={!master_name}
            icon="user-cog"
            onClick={() => act(currentSelection, { mode: HOST_SCAN.Master })}
            tooltip="Сканирует привязанного мастера."
          >
            Сканирование мастера
          </Button>
        </>
      );
    case 'Модуль фотографии':
      return (
        <>
          <Button
            icon="camera-retro"
            onClick={() => act(currentSelection, { mode: PHOTO_MODE.Camera })}
            tooltip="Включает камеру. Кликните по области, чтобы сделать снимок."
          >
            Камера
          </Button>
          <Button
            icon="print"
            onClick={() => act(currentSelection, { mode: PHOTO_MODE.Printer })}
            tooltip="Выводит список сохранённых фотографий."
          >
            Принтер
          </Button>
          <Button
            icon="search-plus"
            onClick={() => act(currentSelection, { mode: PHOTO_MODE.Zoom })}
            tooltip="Настраивает уровень масштабирования будущих фотографий."
          >
            Масштабирование
          </Button>
        </>
      );
    case 'Универсальный переводчик':
      return (
        <Button
          icon="download"
          onClick={() => act(currentSelection)}
          disabled={!!languages}
        >
          {!languages ? 'Установить' : 'Установлено'}
        </Button>
      );
    default:
      return (
        <Button
          icon="power-off"
          onClick={() => act(currentSelection)}
          tooltip="Попытка включения модуля."
        >
          Переключить
        </Button>
      );
  }
}
