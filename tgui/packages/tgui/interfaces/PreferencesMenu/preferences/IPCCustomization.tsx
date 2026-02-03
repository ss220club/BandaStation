import { useState } from 'react';
import { Box, Button, Icon, Modal, Stack } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { CharacterPreview } from '../../common/CharacterPreview';
import type {
  IPCBrainType,
  IPCChassisBrand,
  IPCCustomization,
  IPCHEFManufacturer,
  PreferencesMenuData,
} from '../types';
import { useServerPrefs } from '../useServerPrefs';

type IPCCustomizationProps = {
  handleClose: () => void;
};

// Маппинг брендов на иконки
const BRAND_ICONS: Record<string, string> = {
  unbranded: 'robot',
  morpheus: 'brain',
  etamin: 'temperature-low',
  bishop: 'plus-square',
  hesphiastos: 'shield-alt',
  ward_takahashi: 'running',
  xion: 'microchip',
  zeng_hu: 'flask',
  shellguard: 'shield-alt',
  cybersun: 'sun',
  hef: 'puzzle-piece',
};

const BRAIN_ICONS: Record<string, string> = {
  positronic: 'brain',
  mmi: 'head-side-virus',
  borg: 'server',
};

// Части тела для HEF режима
const HEF_BODY_PARTS = [
  { key: 'hef_head', label: 'Голова', icon: 'head-side-virus' },
  { key: 'hef_chest', label: 'Торс', icon: 'heart' },
  { key: 'hef_l_arm', label: 'Л. Рука', icon: 'hand-paper' },
  { key: 'hef_r_arm', label: 'П. Рука', icon: 'hand-paper' },
  { key: 'hef_l_leg', label: 'Л. Нога', icon: 'shoe-prints' },
  { key: 'hef_r_leg', label: 'П. Нога', icon: 'shoe-prints' },
] as const;

export const IPCCustomizationPage = (props: IPCCustomizationProps) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const serverData = useServerPrefs();

  // Какой выбор сейчас открыт
  const [activeSelection, setActiveSelection] = useState<
    'chassis' | 'brain' | string | null
  >(null);

  // Получаем данные IPC из middleware (ui_data)
  const customization: IPCCustomization = data.ipc_customization || {
    chassis_brand: 'unbranded',
    brain_type: 'positronic',
    hef_head: 'unbranded',
    hef_chest: 'unbranded',
    hef_l_arm: 'unbranded',
    hef_r_arm: 'unbranded',
    hef_l_leg: 'unbranded',
    hef_r_leg: 'unbranded',
  };

  const isIPC = data.is_ipc ?? false;

  // Получаем статические данные из serverData (preferences.json)
  const ipcData = serverData?.ipc_customization;
  const chassisBrands: IPCChassisBrand[] = ipcData?.chassis_brands || [];
  const brainTypes: IPCBrainType[] = ipcData?.brain_types || [];
  const hefManufacturers: IPCHEFManufacturer[] = ipcData?.hef_manufacturers || [];

  const isHEF = customization.chassis_brand === 'hef';

  // Находим текущие значения
  const currentChassis = chassisBrands.find(
    (b) => b.key === customization.chassis_brand,
  );
  const currentBrain = brainTypes.find(
    (b) => b.key === customization.brain_type,
  );

  // Функция получения имени производителя для HEF части
  const getPartManufacturerName = (partKey: string) => {
    const manufacturerKey =
      customization[partKey as keyof IPCCustomization] || 'unbranded';
    const manufacturer = hefManufacturers.find(
      (m) => m.key === manufacturerKey,
    );
    return manufacturer?.name || 'Unbranded';
  };

  // Если не IPC - показываем сообщение
  if (!isIPC) {
    return (
      <Modal className="IPCPanel">
        <div className="IPCPanel__Header">
          <div className="IPCPanel__Title">
            <Icon name="robot" />
            <span>КОНФИГУРАЦИЯ КПБ</span>
          </div>
          <Button
            className="IPCPanel__CloseBtn"
            icon="times"
            onClick={props.handleClose}
          />
        </div>
        <Stack fill vertical align="center" justify="center" p={2}>
          <Icon name="exclamation-triangle" size={3} color="#ff3333" />
          <Box mt={1} fontSize={1} color="label" bold textAlign="center">
            ДОСТУП ЗАПРЕЩЁН
          </Box>
          <Box mt={0.5} color="label" textAlign="center" fontSize={0.9}>
            Данная конфигурация доступна только для КПБ
          </Box>
        </Stack>
      </Modal>
    );
  }

  return (
    <Modal className="IPCPanel">
      {/* Заголовок */}
      <div className="IPCPanel__Header">
        <div className="IPCPanel__Title">
          <Icon name="robot" />
          <span>КОНФИГУРАЦИЯ КПБ</span>
          {isHEF && (
            <span className="IPCPanel__HEFBadge">
              <Icon name="puzzle-piece" /> HEF
            </span>
          )}
        </div>
        <Button
          className="IPCPanel__CloseBtn"
          icon="times"
          onClick={props.handleClose}
        />
      </div>

      {/* Основной контент */}
      <div className="IPCPanel__Body">
        {/* Левая часть - слоты */}
        <div className="IPCPanel__Slots">
          {/* Шасси - всегда видно */}
          <SlotButton
            label="Шасси"
            value={currentChassis?.name || 'Unbranded'}
            icon={BRAND_ICONS[customization.chassis_brand] || 'robot'}
            isActive={activeSelection === 'chassis'}
            color="blue"
            onClick={() =>
              setActiveSelection(activeSelection === 'chassis' ? null : 'chassis')
            }
          />

          {/* Мозг - всегда видно */}
          <SlotButton
            label="Ядро"
            value={currentBrain?.name || 'Positronic'}
            icon={BRAIN_ICONS[customization.brain_type] || 'brain'}
            isActive={activeSelection === 'brain'}
            color="purple"
            onClick={() =>
              setActiveSelection(activeSelection === 'brain' ? null : 'brain')
            }
          />

          {/* HEF части - только если HEF режим */}
          {isHEF && (
            <>
              <div className="IPCPanel__Divider">
                <span>HEF ЧАСТИ</span>
              </div>
              {HEF_BODY_PARTS.map((part) => (
                <SlotButton
                  key={part.key}
                  label={part.label}
                  value={getPartManufacturerName(part.key)}
                  icon={part.icon}
                  isActive={activeSelection === part.key}
                  color="yellow"
                  onClick={() =>
                    setActiveSelection(
                      activeSelection === part.key ? null : part.key,
                    )
                  }
                />
              ))}
            </>
          )}
        </div>

        {/* Правая часть - персонаж + выбор */}
        <div className="IPCPanel__Right">
          {/* Превью персонажа */}
          <div className="IPCPanel__Preview">
            <CharacterPreview height="180px" id={data.character_preview_view} />
            <div className="IPCPanel__PreviewInfo">
              <div className="IPCPanel__PreviewName">
                {currentChassis?.name || 'UNBRANDED'}
              </div>
              <div className="IPCPanel__PreviewBrain">
                {currentBrain?.name || 'Positronic Core'}
              </div>
            </div>
          </div>

          {/* Панель выбора - показывается когда activeSelection не null */}
          {activeSelection && (
            <div className="IPCPanel__Selection">
              {activeSelection === 'chassis' && (
                <SelectionList
                  title="ВЫБОР ШАССИ"
                  items={chassisBrands.map((b) => ({
                    key: b.key,
                    name: b.name,
                    description: b.description,
                    icon: BRAND_ICONS[b.key] || 'robot',
                    selected: b.key === customization.chassis_brand,
                  }))}
                  onSelect={(key) => {
                    act('set_chassis_brand', { brand: key });
                    setActiveSelection(null);
                  }}
                />
              )}

              {activeSelection === 'brain' && (
                <SelectionList
                  title="ТИП ЯДРА"
                  items={brainTypes.map((b) => ({
                    key: b.key,
                    name: b.name,
                    description: b.description,
                    icon: BRAIN_ICONS[b.key] || 'brain',
                    selected: b.key === customization.brain_type,
                  }))}
                  onSelect={(key) => {
                    act('set_brain_type', { brain_type: key });
                    setActiveSelection(null);
                  }}
                />
              )}

              {/* HEF части */}
              {activeSelection.startsWith('hef_') && (
                <SelectionList
                  title={
                    HEF_BODY_PARTS.find((p) => p.key === activeSelection)
                      ?.label.toUpperCase() || activeSelection.toUpperCase()
                  }
                  items={hefManufacturers.map((m) => ({
                    key: m.key,
                    name: m.name,
                    icon: BRAND_ICONS[m.key] || 'cog',
                    selected:
                      m.key ===
                      customization[activeSelection as keyof IPCCustomization],
                  }))}
                  onSelect={(key) => {
                    act('set_hef_part', { part: activeSelection, manufacturer: key });
                    setActiveSelection(null);
                  }}
                />
              )}
            </div>
          )}
        </div>
      </div>

      {/* Подсказка внизу */}
      <div className="IPCPanel__Footer">
        {isHEF
          ? 'HEF режим: выберите производителя для каждой части'
          : 'Выберите шасси "HEF" для настройки каждой части тела отдельно'}
      </div>
    </Modal>
  );
};

// ============================================
// Компонент кнопки слота
// ============================================
type SlotButtonProps = {
  label: string;
  value: string;
  icon: string;
  isActive: boolean;
  color: 'blue' | 'purple' | 'yellow' | 'red' | 'green';
  onClick: () => void;
};

function SlotButton(props: SlotButtonProps) {
  const { label, value, icon, isActive, color, onClick } = props;

  return (
    <div
      className={`IPCPanel__Slot IPCPanel__Slot--${color} ${isActive ? 'IPCPanel__Slot--active' : ''}`}
      onClick={onClick}
    >
      <div className="IPCPanel__SlotIcon">
        <Icon name={icon} />
      </div>
      <div className="IPCPanel__SlotInfo">
        <div className="IPCPanel__SlotLabel">{label}</div>
        <div className="IPCPanel__SlotValue">{value}</div>
      </div>
      <Icon
        name={isActive ? 'chevron-down' : 'chevron-right'}
        className="IPCPanel__SlotArrow"
      />
    </div>
  );
}

// ============================================
// Компонент списка выбора
// ============================================
type SelectionItem = {
  key: string;
  name: string;
  description?: string;
  icon: string;
  selected: boolean;
};

type SelectionListProps = {
  title: string;
  items: SelectionItem[];
  onSelect: (key: string) => void;
};

function SelectionList(props: SelectionListProps) {
  const { title, items, onSelect } = props;

  return (
    <div className="IPCPanel__SelectionList">
      <div className="IPCPanel__SelectionHeader">{title}</div>
      <div className="IPCPanel__SelectionItems">
        {items.map((item) => (
          <div
            key={item.key}
            className={`IPCPanel__SelectionItem ${item.selected ? 'IPCPanel__SelectionItem--selected' : ''}`}
            onClick={() => onSelect(item.key)}
          >
            <div className="IPCPanel__SelectionItemIcon">
              <Icon name={item.icon} />
            </div>
            <div className="IPCPanel__SelectionItemInfo">
              <div className="IPCPanel__SelectionItemName">{item.name}</div>
              {item.description && (
                <div className="IPCPanel__SelectionItemDesc">
                  {item.description}
                </div>
              )}
            </div>
            {item.selected && (
              <Icon name="check" className="IPCPanel__SelectionItemCheck" />
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
