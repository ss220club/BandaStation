import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  Icon,
  LabeledList,
  Modal,
  Section,
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

export const IPCCustomizationPage = (props: IPCCustomizationProps) => {
  const { act, data } = useBackend<IPCCustomizationData>();
  const [selectedTab, setSelectedTab] = useState<'brain' | 'chassis' | 'hef'>(
    'chassis',
  );

  if (!data.ipc_customization) {
    return <LoadingScreen />;
  }

  if (!data.is_ipc) {
    return (
      <Modal className="IPCCustomization">
        <Section
          title="IPC Customization"
          buttons={
            <Button icon="times" color="red" onClick={props.handleClose} />
          }
        >
          <Stack vertical align="center" justify="center" mt={5}>
            <Stack.Item>
              <Icon name="robot" size={5} color="gray" />
            </Stack.Item>
            <Stack.Item fontSize={1.2} color="label" bold>
              Эта кастомизация доступна только для IPC персонажей.
            </Stack.Item>
            <Stack.Item mt={3}>
              <Button fluid onClick={props.handleClose}>
                Закрыть
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Modal>
    );
  }

  const customization = data.ipc_customization;
  const isHEF = customization.chassis_brand === 'hef';

  return (
    <Modal className="IPCCustomization">
      <div className="IPCCustomization__Container">
        {/* HEADER */}
        <div className="IPCCustomization__Header">
          <Box fontSize={1.5} bold>
            <Icon name="robot" mr={1} />
            IPC CUSTOMIZATION
          </Box>
          <Button icon="times" color="red" onClick={props.handleClose} />
        </div>

        {/* MAIN CONTENT */}
        <div className="IPCCustomization__Content">
          {/* LEFT PANEL - TABS */}
          <div className="IPCCustomization__LeftPanel">
            <Stack vertical>
              <Stack.Item>
                <Button
                  fluid
                  icon="brain"
                  color={selectedTab === 'brain' ? 'blue' : 'default'}
                  selected={selectedTab === 'brain'}
                  onClick={() => setSelectedTab('brain')}
                >
                  Позитронное ядро
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  icon="cog"
                  color={selectedTab === 'chassis' ? 'blue' : 'default'}
                  selected={selectedTab === 'chassis'}
                  onClick={() => setSelectedTab('chassis')}
                >
                  Шасси
                </Button>
              </Stack.Item>
              {isHEF && (
                <Stack.Item>
                  <Button
                    fluid
                    icon="puzzle-piece"
                    color={selectedTab === 'hef' ? 'blue' : 'default'}
                    selected={selectedTab === 'hef'}
                    onClick={() => setSelectedTab('hef')}
                  >
                    Поштучный выбор
                  </Button>
                </Stack.Item>
              )}
            </Stack>
          </div>

          {/* CENTER - CHARACTER PREVIEW */}
          <div className="IPCCustomization__Preview">
            <CharacterPreview height="100%" id={data.character_preview_view} />
            <div className="IPCCustomization__PreviewLabel">
              <Box bold fontSize={1.1}>
                {data.chassis_brands.find(
                  (b) => b.key === customization.chassis_brand,
                )?.name || 'Unbranded'}
              </Box>
              <Box color="label" fontSize={0.9}>
                {data.brain_types.find(
                  (b) => b.key === customization.brain_type,
                )?.name || 'Positronic Core'}
              </Box>
            </div>
          </div>

          {/* RIGHT PANEL - CONTENT */}
          <div className="IPCCustomization__RightPanel">
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
  const selectedBrain = brainTypes.find((b) => b.key === currentBrainType);

  return (
    <Section fill scrollable title="Тип позитронного ядра">
      <Stack vertical>
        {brainTypes.map((brain) => (
          <Stack.Item key={brain.key}>
            <Button
              fluid
              color={brain.key === currentBrainType ? 'blue' : 'default'}
              selected={brain.key === currentBrainType}
              onClick={() => onSelect(brain.key)}
              mb={0.5}
            >
              <Stack>
                <Stack.Item grow>
                  <Box bold>{brain.name}</Box>
                  <Box color="label" fontSize={0.9} mt={0.3}>
                    {brain.description}
                  </Box>
                </Stack.Item>
                {brain.key === currentBrainType && (
                  <Stack.Item>
                    <Icon name="check" color="green" />
                  </Stack.Item>
                )}
              </Stack>
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
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
    <Section fill scrollable title="Бренд шасси">
      <Stack vertical>
        {chassisBrands.map((chassis) => (
          <Stack.Item key={chassis.key}>
            <Button
              fluid
              color={chassis.key === currentChassis ? 'blue' : 'default'}
              selected={chassis.key === currentChassis}
              onClick={() => onSelect(chassis.key)}
              mb={0.5}
            >
              <Stack>
                <Stack.Item grow>
                  <Box bold>{chassis.name}</Box>
                  <Box color="label" fontSize={0.9} mt={0.3}>
                    {chassis.description}
                  </Box>
                </Stack.Item>
                {chassis.key === currentChassis && (
                  <Stack.Item>
                    <Icon name="check" color="green" />
                  </Stack.Item>
                )}
              </Stack>
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
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
    <Section fill scrollable title="Поштучный выбор HEF">
      <Box italic color="label" mb={1}>
        Выберите производителя для каждой части тела. Только визуал, без
        бонусов.
      </Box>
      <Stack vertical>
        {parts.map((part) => (
          <Stack.Item key={part.key}>
            <LabeledList>
              <LabeledList.Item
                label={
                  <Box>
                    <Icon name={part.icon} mr={0.5} />
                    {part.label}
                  </Box>
                }
              >
                <Dropdown
                  width="100%"
                  selected={currentParts[part.key]}
                  options={manufacturers.map((m) => m.key)}
                  displayText={(key: string) =>
                    manufacturers.find((m) => m.key === key)?.name || key
                  }
                  onSelected={(value) => onSelectPart(part.key, value)}
                />
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
}
