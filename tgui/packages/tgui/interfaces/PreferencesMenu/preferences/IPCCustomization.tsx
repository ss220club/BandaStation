import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Modal,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { CharacterPreview } from '../../common/CharacterPreview';
import { LoadingScreen } from '../../common/LoadingScreen';
import type { PreferencesMenuData } from '../types';

type IPCCustomizationProps = {
  handleClose: () => void;
};

type ChassisBrand = {
  key: string;
  name: string;
  description: string;
};

type BrainType = {
  key: string;
  name: string;
  description: string;
};

type HEFManufacturer = {
  key: string;
  name: string;
};

type IPCCustomizationData = PreferencesMenuData & {
  ipc_customization: {
    chassis_brand: string;
    brain_type: string;
    hef_head: string;
    hef_chest: string;
    hef_l_arm: string;
    hef_r_arm: string;
    hef_l_leg: string;
    hef_r_leg: string;
  };
  is_ipc: boolean;
  chassis_brands: ChassisBrand[];
  brain_types: BrainType[];
  hef_manufacturers: HEFManufacturer[];
};

// Маппинг брендов на иконки
const BRAND_ICONS: Record<string, string> = {
  unbranded: 'robot',
  morpheus: 'brain',
  etamin: 'industry',
  bishop: 'cross',
  hephaestus: 'hammer',
  wardtakahashi: 'building',
  xion: 'microchip',
  zenghu: 'flask',
  shellguard: 'shield-alt',
  cybersun: 'sun',
  hef: 'puzzle-piece',
};

const BRAIN_ICONS: Record<string, string> = {
  positronic: 'brain',
  mmi: 'head-side-virus',
  borg_core: 'server',
};

export const IPCCustomizationPage = (props: IPCCustomizationProps) => {
  const { act, data } = useBackend<IPCCustomizationData>();
  const [selectedTab, setSelectedTab] = useState<'brain' | 'chassis' | 'hef'>(
    'chassis',
  );

  if (!data.ipc_customization) {
    return <LoadingScreen />;
  }

  // Показываем сообщение если не IPC
  if (!data.is_ipc) {
    return (
      <Modal className="CyberpunkMods CyberpunkMods--ipc">
        <div className="CyberpunkMods__Scanline" />
        <div className="CyberpunkMods__Header">
          <div className="CyberpunkMods__HeaderTitle">
            <Icon name="robot" className="CyberpunkMods__HeaderTitleIcon" />
            <span>КОНФИГУРАЦИЯ КПБ</span>
          </div>
          <Button
            className="CyberpunkMods__HeaderClose"
            icon="times"
            onClick={props.handleClose}
          >
            ЗАКРЫТЬ
          </Button>
        </div>
        <div className="CyberpunkMods__Content">
          <Stack vertical align="center" justify="center" fill>
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
            <Stack.Item mt={2}>
              <Button
                className="CyberpunkMods__ModCardBtn"
                onClick={props.handleClose}
              >
                ЗАКРЫТЬ ИНТЕРФЕЙС
              </Button>
            </Stack.Item>
          </Stack>
        </div>
      </Modal>
    );
  }

  const customization = data.ipc_customization;
  const isHEF = customization.chassis_brand === 'hef';

  // Находим текущий бренд и тип мозга
  const currentBrand = data.chassis_brands.find(
    (b) => b.key === customization.chassis_brand,
  );
  const currentBrain = data.brain_types.find(
    (b) => b.key === customization.brain_type,
  );

  return (
    <Modal className="CyberpunkMods CyberpunkMods--ipc">
      {/* Scanline эффект */}
      <div className="CyberpunkMods__Scanline" />

      {/* Заголовок */}
      <div className="CyberpunkMods__Header">
        <div className="CyberpunkMods__HeaderTitle">
          <Icon name="robot" className="CyberpunkMods__HeaderTitleIcon" />
          <span>КОНФИГУРАЦИЯ КПБ</span>
          <span className="CyberpunkMods__HeaderTitleSubtitle">
            SYNTHETIC INTERFACE v3.14
          </span>
        </div>
        <Button
          className="CyberpunkMods__HeaderClose"
          icon="times"
          onClick={props.handleClose}
        >
          ЗАКРЫТЬ
        </Button>
      </div>

      {/* Основной контент */}
      <div className="CyberpunkMods__Content">
        {/* Левая панель - Категории */}
        <div className="CyberpunkMods__Categories">
          <div className="CyberpunkMods__CategoriesTitle">СИСТЕМЫ</div>

          <div
            className={`CyberpunkMods__Category CyberpunkMods__Category--brain ${selectedTab === 'brain' ? 'CyberpunkMods__Category--active' : ''}`}
            onClick={() => setSelectedTab('brain')}
          >
            <Icon name="brain" className="CyberpunkMods__CategoryIcon" />
            <span className="CyberpunkMods__CategoryName">
              Позитронное ядро
            </span>
          </div>

          <div
            className={`CyberpunkMods__Category CyberpunkMods__Category--chassis ${selectedTab === 'chassis' ? 'CyberpunkMods__Category--active' : ''}`}
            onClick={() => setSelectedTab('chassis')}
          >
            <Icon name="cog" className="CyberpunkMods__CategoryIcon" />
            <span className="CyberpunkMods__CategoryName">Шасси</span>
          </div>

          {isHEF && (
            <div
              className={`CyberpunkMods__Category CyberpunkMods__Category--prosthetics ${selectedTab === 'hef' ? 'CyberpunkMods__Category--active' : ''}`}
              onClick={() => setSelectedTab('hef')}
            >
              <Icon name="puzzle-piece" className="CyberpunkMods__CategoryIcon" />
              <span className="CyberpunkMods__CategoryName">
                Поштучный выбор
              </span>
            </div>
          )}

          {/* Информационная панель */}
          <div
            style={{
              marginTop: 'auto',
              padding: '0.75rem',
              background: 'rgba(0,128,255,0.1)',
              borderTop: '1px solid rgba(0,128,255,0.2)',
              fontSize: '0.7rem',
              color: '#8a8a9a',
            }}
          >
            <Box mb={0.5}>
              <Icon name="info-circle" mr={0.5} />
              СТАТУС СИСТЕМЫ
            </Box>
            <Box color="#0080ff">
              Шасси: {currentBrand?.name || 'Не выбрано'}
            </Box>
            <Box color="#9d4edd">
              Ядро: {currentBrain?.name || 'Не выбрано'}
            </Box>
          </div>
        </div>

        {/* Центральная панель - Превью */}
        <div className="CyberpunkMods__Preview">
          <div className="CyberpunkMods__PreviewCharacter">
            <CharacterPreview height="300px" id={data.character_preview_view} />
          </div>
          <div className="CyberpunkMods__PreviewInfo">
            <div className="CyberpunkMods__PreviewInfoName">
              {currentBrand?.name || 'UNBRANDED'}
            </div>
            <div className="CyberpunkMods__PreviewInfoBrand">
              {currentBrain?.name || 'Positronic Core'}
            </div>
            {currentBrand?.description && (
              <Box
                mt={1}
                fontSize={0.75}
                color="label"
                textAlign="center"
                style={{ maxWidth: '250px' }}
              >
                {currentBrand.description}
              </Box>
            )}
          </div>
        </div>

        {/* Правая панель - Контент вкладки */}
        <div className="CyberpunkMods__List">
          <div className="CyberpunkMods__ListHeader">
            <span className="CyberpunkMods__ListHeaderTitle">
              {selectedTab === 'brain' && 'ТИП ПОЗИТРОННОГО ЯДРА'}
              {selectedTab === 'chassis' && 'БРЕНД ШАССИ'}
              {selectedTab === 'hef' && 'ПОШТУЧНЫЙ ВЫБОР HEF'}
            </span>
          </div>
          <div className="CyberpunkMods__ListContent">
            {selectedTab === 'brain' && (
              <BrainTypeSelector
                brainTypes={data.brain_types}
                currentBrainType={customization.brain_type}
                onSelect={(brain_type) => act('set_brain_type', { brain_type })}
              />
            )}

            {selectedTab === 'chassis' && (
              <ChassisSelector
                chassisBrands={data.chassis_brands}
                currentChassis={customization.chassis_brand}
                onSelect={(brand) => act('set_chassis_brand', { brand })}
              />
            )}

            {selectedTab === 'hef' && isHEF && (
              <HEFPartsSelector
                manufacturers={data.hef_manufacturers}
                currentParts={{
                  hef_head: customization.hef_head,
                  hef_chest: customization.hef_chest,
                  hef_l_arm: customization.hef_l_arm,
                  hef_r_arm: customization.hef_r_arm,
                  hef_l_leg: customization.hef_l_leg,
                  hef_r_leg: customization.hef_r_leg,
                }}
                onSelectPart={(part, manufacturer) =>
                  act('set_hef_part', { part, manufacturer })
                }
              />
            )}
          </div>
        </div>
      </div>
    </Modal>
  );
};

// ============================================
// BRAIN TYPE SELECTOR
// ============================================
type BrainTypeSelectorProps = {
  brainTypes: BrainType[];
  currentBrainType: string;
  onSelect: (brainType: string) => void;
};

function BrainTypeSelector(props: BrainTypeSelectorProps) {
  const { brainTypes, currentBrainType, onSelect } = props;

  return (
    <div className="CyberpunkBrain__List">
      {brainTypes.map((brain) => {
        const isSelected = brain.key === currentBrainType;
        const icon = BRAIN_ICONS[brain.key] || 'brain';

        return (
          <div
            key={brain.key}
            className={`CyberpunkBrain__Item ${isSelected ? 'CyberpunkBrain__Item--selected' : ''}`}
            onClick={() => onSelect(brain.key)}
          >
            <div className="CyberpunkBrain__ItemIcon">
              <Icon name={icon} />
            </div>
            <div className="CyberpunkBrain__ItemInfo">
              <div className="CyberpunkBrain__ItemName">{brain.name}</div>
              <div className="CyberpunkBrain__ItemDesc">{brain.description}</div>
            </div>
            {isSelected && (
              <div className="CyberpunkBrain__ItemCheck">
                <Icon name="check" />
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}

// ============================================
// CHASSIS SELECTOR
// ============================================
type ChassisSelectorProps = {
  chassisBrands: ChassisBrand[];
  currentChassis: string;
  onSelect: (chassis: string) => void;
};

function ChassisSelector(props: ChassisSelectorProps) {
  const { chassisBrands, currentChassis, onSelect } = props;

  return (
    <div className="CyberpunkChassis__Grid">
      {chassisBrands.map((chassis) => {
        const isSelected = chassis.key === currentChassis;
        const icon = BRAND_ICONS[chassis.key] || 'robot';

        return (
          <div
            key={chassis.key}
            className={`CyberpunkChassis__Card ${isSelected ? 'CyberpunkChassis__Card--selected' : ''}`}
            onClick={() => onSelect(chassis.key)}
          >
            <div className="CyberpunkChassis__CardIcon">
              <Icon name={icon} />
            </div>
            <div className="CyberpunkChassis__CardName">{chassis.name}</div>
            {chassis.description && (
              <div className="CyberpunkChassis__CardDesc">
                {chassis.description.length > 60
                  ? chassis.description.substring(0, 60) + '...'
                  : chassis.description}
              </div>
            )}
            {isSelected && (
              <Box
                position="absolute"
                top={0.5}
                right={0.5}
                color="#39ff14"
                style={{ textShadow: '0 0 10px #39ff14' }}
              >
                <Icon name="check-circle" />
              </Box>
            )}
          </div>
        );
      })}
    </div>
  );
}

// ============================================
// HEF PARTS SELECTOR
// ============================================
type HEFPartsSelectorProps = {
  manufacturers: HEFManufacturer[];
  currentParts: {
    hef_head: string;
    hef_chest: string;
    hef_l_arm: string;
    hef_r_arm: string;
    hef_l_leg: string;
    hef_r_leg: string;
  };
  onSelectPart: (part: string, manufacturer: string) => void;
};

function HEFPartsSelector(props: HEFPartsSelectorProps) {
  const { manufacturers, currentParts, onSelectPart } = props;

  const parts = [
    { key: 'hef_head', label: 'Голова', icon: 'head-side-virus' },
    { key: 'hef_chest', label: 'Грудь', icon: 'heart' },
    { key: 'hef_l_arm', label: 'Левая рука', icon: 'hand-paper' },
    { key: 'hef_r_arm', label: 'Правая рука', icon: 'hand-paper' },
    { key: 'hef_l_leg', label: 'Левая нога', icon: 'shoe-prints' },
    { key: 'hef_r_leg', label: 'Правая нога', icon: 'shoe-prints' },
  ];

  return (
    <div className="CyberpunkHEF">
      <div className="CyberpunkHEF__Hint">
        <Icon name="info-circle" mr={0.5} />
        HEF позволяет выбрать разных производителей для каждой части тела.
        Только визуальное отличие, без геймплейных бонусов.
      </div>
      <div className="CyberpunkHEF__Parts">
        {parts.map((part) => (
          <div key={part.key} className="CyberpunkHEF__Part">
            <div className="CyberpunkHEF__PartIcon">
              <Icon name={part.icon} />
            </div>
            <div className="CyberpunkHEF__PartLabel">{part.label}</div>
            <div className="CyberpunkHEF__PartSelect">
              <Dropdown
                width="100%"
                selected={currentParts[part.key as keyof typeof currentParts]}
                options={manufacturers.map((m) => ({
                  value: m.key,
                  displayText: m.name,
                }))}
                onSelected={(value) => onSelectPart(part.key, String(value))}
              />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
