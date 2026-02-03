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

// Части тела для HEF
const BODY_PARTS = [
  { key: 'hef_head', label: 'Голова', icon: 'head-side-virus', slot: 'head' },
  { key: 'hef_chest', label: 'Грудь', icon: 'heart', slot: 'chest' },
  { key: 'hef_l_arm', label: 'Левая рука', icon: 'hand-paper', slot: 'arm' },
  { key: 'hef_r_arm', label: 'Правая рука', icon: 'hand-paper', slot: 'arm' },
  { key: 'hef_l_leg', label: 'Левая нога', icon: 'shoe-prints', slot: 'leg' },
  { key: 'hef_r_leg', label: 'Правая нога', icon: 'shoe-prints', slot: 'leg' },
] as const;

export const IPCCustomizationPage = (props: IPCCustomizationProps) => {
  const { act, data } = useBackend<PreferencesMenuData>();

  // Модальное окно для выбора
  const [activeModal, setActiveModal] = useState<
    'chassis' | 'brain' | 'hef_part' | null
  >(null);
  const [selectedPartKey, setSelectedPartKey] = useState<string | null>(null);

  // Получаем данные IPC из middleware
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
  const chassisBrands: IPCChassisBrand[] = data.chassis_brands || [];
  const brainTypes: IPCBrainType[] = data.brain_types || [];
  const hefManufacturers: IPCHEFManufacturer[] = data.hef_manufacturers || [];

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
      <Modal className="RipperdocLayout RipperdocLayout--ipc">
        <div className="RipperdocLayout__Scanline" />
        <div className="RipperdocLayout__Header">
          <div className="RipperdocLayout__HeaderTitle">
            <Icon
              name="robot"
              className="RipperdocLayout__HeaderTitleIcon"
            />
            <span>КОНФИГУРАЦИЯ КПБ</span>
          </div>
          <Button
            className="RipperdocLayout__HeaderBtn RipperdocLayout__HeaderBtn--close"
            icon="times"
            onClick={props.handleClose}
          >
            ЗАКРЫТЬ
          </Button>
        </div>
        <Stack fill vertical align="center" justify="center" p={3}>
          <Stack.Item>
            <Icon name="exclamation-triangle" size={4} color="#ff3333" />
          </Stack.Item>
          <Stack.Item mt={2}>
            <Box fontSize={1.2} color="label" bold textAlign="center">
              ДОСТУП ЗАПРЕЩЁН
            </Box>
          </Stack.Item>
          <Stack.Item mt={1}>
            <Box color="label" textAlign="center">
              Данная конфигурация доступна только для
              <br />
              Кибернетических Позитронных Болванов (КПБ)
            </Box>
          </Stack.Item>
        </Stack>
      </Modal>
    );
  }

  // Левые слоты (голова, левая рука, левая нога)
  const leftSlots = [
    {
      key: 'brain',
      label: 'Позитронное ядро',
      icon: BRAIN_ICONS[customization.brain_type] || 'brain',
      value: currentBrain?.name || 'Позитронное',
      slot: 'brain',
      onClick: () => setActiveModal('brain'),
    },
    {
      key: 'hef_l_arm',
      label: 'Левая рука',
      icon: 'hand-paper',
      value: isHEF ? getPartManufacturerName('hef_l_arm') : currentChassis?.name,
      slot: 'arm',
      onClick: isHEF
        ? () => {
            setSelectedPartKey('hef_l_arm');
            setActiveModal('hef_part');
          }
        : undefined,
      disabled: !isHEF,
    },
    {
      key: 'hef_l_leg',
      label: 'Левая нога',
      icon: 'shoe-prints',
      value: isHEF ? getPartManufacturerName('hef_l_leg') : currentChassis?.name,
      slot: 'leg',
      onClick: isHEF
        ? () => {
            setSelectedPartKey('hef_l_leg');
            setActiveModal('hef_part');
          }
        : undefined,
      disabled: !isHEF,
    },
  ];

  // Правые слоты (шасси, правая рука, правая нога)
  const rightSlots = [
    {
      key: 'chassis',
      label: 'Бренд шасси',
      icon: BRAND_ICONS[customization.chassis_brand] || 'robot',
      value: currentChassis?.name || 'Unbranded',
      slot: 'chassis',
      onClick: () => setActiveModal('chassis'),
    },
    {
      key: 'hef_r_arm',
      label: 'Правая рука',
      icon: 'hand-paper',
      value: isHEF ? getPartManufacturerName('hef_r_arm') : currentChassis?.name,
      slot: 'arm',
      onClick: isHEF
        ? () => {
            setSelectedPartKey('hef_r_arm');
            setActiveModal('hef_part');
          }
        : undefined,
      disabled: !isHEF,
    },
    {
      key: 'hef_r_leg',
      label: 'Правая нога',
      icon: 'shoe-prints',
      value: isHEF ? getPartManufacturerName('hef_r_leg') : currentChassis?.name,
      slot: 'leg',
      onClick: isHEF
        ? () => {
            setSelectedPartKey('hef_r_leg');
            setActiveModal('hef_part');
          }
        : undefined,
      disabled: !isHEF,
    },
  ];

  return (
    <Modal className="RipperdocLayout RipperdocLayout--ipc">
      {/* Scanline эффект */}
      <div className="RipperdocLayout__Scanline" />

      {/* Заголовок */}
      <div className="RipperdocLayout__Header">
        <div className="RipperdocLayout__HeaderTitle">
          <Icon name="robot" className="RipperdocLayout__HeaderTitleIcon" />
          <span>КОНФИГУРАЦИЯ КПБ</span>
          <span className="RipperdocLayout__HeaderTitleSubtitle">
            SYNTHETIC INTERFACE v3.14
          </span>
        </div>
        <div className="RipperdocLayout__HeaderControls">
          {isHEF && (
            <Button
              className="RipperdocLayout__HeaderBtn"
              icon="puzzle-piece"
              tooltip="HEF режим: можно настроить каждую часть тела отдельно"
            >
              HEF
            </Button>
          )}
          <Button
            className="RipperdocLayout__HeaderBtn RipperdocLayout__HeaderBtn--close"
            icon="times"
            onClick={props.handleClose}
          >
            ЗАКРЫТЬ
          </Button>
        </div>
      </div>

      {/* Основное тело - персонаж в центре, слоты по бокам */}
      <div className="RipperdocLayout__Body">
        {/* Левые слоты */}
        <div className="RipperdocLayout__LeftSlots">
          {leftSlots.map((slot) => (
            <div
              key={slot.key}
              className={`RipperdocLayout__Slot RipperdocLayout__Slot--left RipperdocLayout__Slot--${slot.slot} ${slot.disabled ? '' : ''}`}
              onClick={slot.onClick}
              style={{ cursor: slot.onClick ? 'pointer' : 'default' }}
            >
              <div className="RipperdocLayout__SlotHeader">
                <div className="RipperdocLayout__SlotIcon">
                  <Icon name={slot.icon} />
                </div>
                <span className="RipperdocLayout__SlotLabel">{slot.label}</span>
              </div>
              <div
                className={`RipperdocLayout__SlotValue ${!slot.value ? 'RipperdocLayout__SlotValue--empty' : ''}`}
              >
                {slot.value || 'Не выбрано'}
              </div>
            </div>
          ))}
        </div>

        {/* Центр - персонаж */}
        <div className="RipperdocLayout__Center">
          <div className="RipperdocLayout__CenterSilhouette" />
          <div className="RipperdocLayout__CenterCharacter">
            <CharacterPreview height="350px" id={data.character_preview_view} />
          </div>
          <div className="RipperdocLayout__CenterInfo">
            <div className="RipperdocLayout__CenterInfoName">
              {currentChassis?.name || 'UNBRANDED'}
            </div>
            <div className="RipperdocLayout__CenterInfoChassis">
              {currentChassis?.description
                ? currentChassis.description.substring(0, 50) + '...'
                : 'Стандартное шасси'}
            </div>
            <div className="RipperdocLayout__CenterInfoBrain">
              {currentBrain?.name || 'Positronic Core'}
            </div>
          </div>

          {/* Центральные слоты (голова и грудь) - в виде полосы под персонажем */}
          {isHEF && (
            <Stack mt={2} gap={1}>
              <Button
                className="RipperdocLayout__HeaderBtn"
                icon="head-side-virus"
                onClick={() => {
                  setSelectedPartKey('hef_head');
                  setActiveModal('hef_part');
                }}
              >
                Голова: {getPartManufacturerName('hef_head')}
              </Button>
              <Button
                className="RipperdocLayout__HeaderBtn"
                icon="heart"
                onClick={() => {
                  setSelectedPartKey('hef_chest');
                  setActiveModal('hef_part');
                }}
              >
                Грудь: {getPartManufacturerName('hef_chest')}
              </Button>
            </Stack>
          )}
        </div>

        {/* Правые слоты */}
        <div className="RipperdocLayout__RightSlots">
          {rightSlots.map((slot) => (
            <div
              key={slot.key}
              className={`RipperdocLayout__Slot RipperdocLayout__Slot--right RipperdocLayout__Slot--${slot.slot}`}
              onClick={slot.onClick}
              style={{ cursor: slot.onClick ? 'pointer' : 'default' }}
            >
              <div className="RipperdocLayout__SlotHeader">
                <div className="RipperdocLayout__SlotIcon">
                  <Icon name={slot.icon} />
                </div>
                <span className="RipperdocLayout__SlotLabel">{slot.label}</span>
              </div>
              <div
                className={`RipperdocLayout__SlotValue ${!slot.value ? 'RipperdocLayout__SlotValue--empty' : ''}`}
              >
                {slot.value || 'Не выбрано'}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Нижняя панель */}
      <div className="RipperdocLayout__Footer">
        <div className="RipperdocLayout__FooterStats">
          <div className="RipperdocLayout__FooterStat">
            <Icon name="cog" className="RipperdocLayout__FooterStatIcon" />
            <span className="RipperdocLayout__FooterStatLabel">Шасси:</span>
            <span className="RipperdocLayout__FooterStatValue">
              {currentChassis?.name || 'Unbranded'}
            </span>
          </div>
          <div className="RipperdocLayout__FooterStat">
            <Icon name="brain" className="RipperdocLayout__FooterStatIcon" />
            <span className="RipperdocLayout__FooterStatLabel">Ядро:</span>
            <span className="RipperdocLayout__FooterStatValue">
              {currentBrain?.name || 'Positronic'}
            </span>
          </div>
        </div>
        <div className="RipperdocLayout__FooterHint">
          {isHEF
            ? 'HEF режим: нажмите на слот чтобы выбрать производителя для каждой части'
            : 'Нажмите на слот чтобы изменить настройки'}
        </div>
      </div>

      {/* Модальные окна */}
      {activeModal && (
        <>
          <div
            className="RipperdocBackdrop"
            onClick={() => setActiveModal(null)}
          />

          {activeModal === 'chassis' && (
            <ChassisModal
              brands={chassisBrands}
              currentBrand={customization.chassis_brand}
              onSelect={(brand) => {
                act('set_chassis_brand', { brand });
                setActiveModal(null);
              }}
              onClose={() => setActiveModal(null)}
            />
          )}

          {activeModal === 'brain' && (
            <BrainModal
              brainTypes={brainTypes}
              currentBrain={customization.brain_type}
              onSelect={(brain_type) => {
                act('set_brain_type', { brain_type });
                setActiveModal(null);
              }}
              onClose={() => setActiveModal(null)}
            />
          )}

          {activeModal === 'hef_part' && selectedPartKey && (
            <HEFPartModal
              partKey={selectedPartKey}
              partLabel={
                BODY_PARTS.find((p) => p.key === selectedPartKey)?.label ||
                selectedPartKey
              }
              manufacturers={hefManufacturers}
              currentManufacturer={
                customization[selectedPartKey as keyof IPCCustomization] ||
                'unbranded'
              }
              onSelect={(manufacturer) => {
                act('set_hef_part', { part: selectedPartKey, manufacturer });
                setActiveModal(null);
              }}
              onClose={() => setActiveModal(null)}
            />
          )}
        </>
      )}
    </Modal>
  );
};

// ============================================
// МОДАЛЬНОЕ ОКНО ВЫБОРА ШАССИ
// ============================================
type ChassisModalProps = {
  brands: IPCChassisBrand[];
  currentBrand: string;
  onSelect: (brand: string) => void;
  onClose: () => void;
};

function ChassisModal(props: ChassisModalProps) {
  const { brands, currentBrand, onSelect, onClose } = props;

  return (
    <div className="RipperdocModal">
      <div className="RipperdocModal__Header">
        <span className="RipperdocModal__HeaderTitle">ВЫБОР ШАССИ</span>
        <Button
          className="RipperdocModal__HeaderClose"
          icon="times"
          onClick={onClose}
        />
      </div>
      <div className="RipperdocModal__Content">
        {brands.map((brand) => {
          const isSelected = brand.key === currentBrand;
          const icon = BRAND_ICONS[brand.key] || 'robot';

          return (
            <div
              key={brand.key}
              className={`RipperdocModal__Option ${isSelected ? 'RipperdocModal__Option--selected' : ''}`}
              onClick={() => onSelect(brand.key)}
            >
              <div className="RipperdocModal__OptionIcon">
                <Icon name={icon} />
              </div>
              <div className="RipperdocModal__OptionInfo">
                <div className="RipperdocModal__OptionName">{brand.name}</div>
                <div className="RipperdocModal__OptionDesc">
                  {brand.description}
                </div>
              </div>
              {isSelected && (
                <Icon name="check" className="RipperdocModal__OptionCheck" />
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ============================================
// МОДАЛЬНОЕ ОКНО ВЫБОРА ТИПА МОЗГА
// ============================================
type BrainModalProps = {
  brainTypes: IPCBrainType[];
  currentBrain: string;
  onSelect: (brainType: string) => void;
  onClose: () => void;
};

function BrainModal(props: BrainModalProps) {
  const { brainTypes, currentBrain, onSelect, onClose } = props;

  return (
    <div className="RipperdocModal">
      <div className="RipperdocModal__Header">
        <span className="RipperdocModal__HeaderTitle">ТИП ПОЗИТРОННОГО ЯДРА</span>
        <Button
          className="RipperdocModal__HeaderClose"
          icon="times"
          onClick={onClose}
        />
      </div>
      <div className="RipperdocModal__Content">
        {brainTypes.map((brain) => {
          const isSelected = brain.key === currentBrain;
          const icon = BRAIN_ICONS[brain.key] || 'brain';

          return (
            <div
              key={brain.key}
              className={`RipperdocModal__Option ${isSelected ? 'RipperdocModal__Option--selected' : ''}`}
              onClick={() => onSelect(brain.key)}
            >
              <div className="RipperdocModal__OptionIcon">
                <Icon name={icon} />
              </div>
              <div className="RipperdocModal__OptionInfo">
                <div className="RipperdocModal__OptionName">{brain.name}</div>
                <div className="RipperdocModal__OptionDesc">
                  {brain.description}
                </div>
              </div>
              {isSelected && (
                <Icon name="check" className="RipperdocModal__OptionCheck" />
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}

// ============================================
// МОДАЛЬНОЕ ОКНО ВЫБОРА HEF ЧАСТИ
// ============================================
type HEFPartModalProps = {
  partKey: string;
  partLabel: string;
  manufacturers: IPCHEFManufacturer[];
  currentManufacturer: string;
  onSelect: (manufacturer: string) => void;
  onClose: () => void;
};

function HEFPartModal(props: HEFPartModalProps) {
  const {
    partLabel,
    manufacturers,
    currentManufacturer,
    onSelect,
    onClose,
  } = props;

  return (
    <div className="RipperdocModal">
      <div className="RipperdocModal__Header">
        <span className="RipperdocModal__HeaderTitle">
          {partLabel.toUpperCase()} - ПРОИЗВОДИТЕЛЬ
        </span>
        <Button
          className="RipperdocModal__HeaderClose"
          icon="times"
          onClick={onClose}
        />
      </div>
      <div className="RipperdocModal__Content">
        {manufacturers.map((mfr) => {
          const isSelected = mfr.key === currentManufacturer;
          const icon = BRAND_ICONS[mfr.key] || 'cog';

          return (
            <div
              key={mfr.key}
              className={`RipperdocModal__Option ${isSelected ? 'RipperdocModal__Option--selected' : ''}`}
              onClick={() => onSelect(mfr.key)}
            >
              <div className="RipperdocModal__OptionIcon">
                <Icon name={icon} />
              </div>
              <div className="RipperdocModal__OptionInfo">
                <div className="RipperdocModal__OptionName">{mfr.name}</div>
              </div>
              {isSelected && (
                <Icon name="check" className="RipperdocModal__OptionCheck" />
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
