import './PreferencesMenu.scss';

import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Icon,
  Modal,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { LoadingScreen } from '../../common/LoadingScreen';
import { BodyModification, PreferencesMenuData } from '../types';
import { useServerPrefs } from '../useServerPrefs';

type BodyModificationsProps = {
  handleClose: () => void;
};

export const BodyModificationsPage = (props: BodyModificationsProps) => {
  const serverData = useServerPrefs();
  if (!serverData) {
    return <LoadingScreen />;
  }

  return (
    <Modal className="PreferencesMenu__Augs">
      <Section
        buttons={
          <Button
            icon="times"
            color="transparent"
            tooltip="Закрыть"
            tooltipPosition="left"
            className="PreferencesMenu__Augs-Close"
            onClick={props.handleClose}
          />
        }
        title={
          <Box inline className="PreferencesMenu__Augs-Header">
            <Icon name="robot" />
            <Box as="span" className="PreferencesMenu__Augs-Title">
              Модификации тела
            </Box>
          </Box>
        }
        className="PreferencesMenu__Augs-Section"
      >
        <Box className="PreferencesMenu__Augs-Content">
          <BodyModificationsPageInner
            bodyModification={serverData.body_modifications}
          />
        </Box>
      </Section>
    </Modal>
  );
};

const BodyModificationsPageInner = (props: {
  bodyModification: BodyModification[];
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const {
    applied_body_modifications = [],
    incompatible_body_modifications = [],
  } = data;
  const [collapsedCategories, setCollapsedCategories] = useState<
    Record<string, boolean>
  >({});

  const appliedModifications = props.bodyModification.filter((mod) =>
    applied_body_modifications.includes(mod.key),
  );

  const modificationsByCategory: Record<string, BodyModification[]> = {};
  props.bodyModification.forEach((mod) => {
    const category = mod.category;
    if (category) {
      if (!modificationsByCategory[category]) {
        modificationsByCategory[category] = [];
      }
      modificationsByCategory[category].push(mod);
    }
  });

  const toggleCategory = (category: string) => {
    setCollapsedCategories((prev) => ({
      ...prev,
      [category]: !prev[category],
    }));
  };

  return (
    <Box className="PreferencesMenu__Augs-TableWrapper">
      <Table className="PreferencesMenu__Augs-Table">
        {appliedModifications.map((mod, index) => (
          <BodyModificationRow
            key={mod.key}
            bodyModification={mod}
            added
            index={index}
          />
        ))}

        {appliedModifications.length > 0 && (
          <Table.Row>
            <Table.Cell colSpan={2}>
              <Divider />
            </Table.Cell>
          </Table.Row>
        )}

        {Object.entries(modificationsByCategory).map(([category, mods]) => (
          <>
            <Table.Row
              key={`category-${category}`}
              className="PreferencesMenu__Augs-CategoryRow"
              data-collapsed={collapsedCategories[category] || false}
              onClick={() => toggleCategory(category)}
            >
              <Table.Cell colSpan={2}>
                <Box inline>
                  <Icon
                    name={
                      collapsedCategories[category]
                        ? 'chevron-right'
                        : 'chevron-down'
                    }
                  />
                  {category}
                </Box>
              </Table.Cell>
            </Table.Row>

            {!collapsedCategories[category] &&
              mods.map((mod, index) => (
                <BodyModificationRow
                  key={mod.key}
                  bodyModification={mod}
                  added={false}
                  usedKeys={[
                    ...applied_body_modifications,
                    ...incompatible_body_modifications,
                  ]}
                  index={index}
                />
              ))}
          </>
        ))}
      </Table>
    </Box>
  );
};

const BodyModificationRow = (props: {
  bodyModification: BodyModification;
  added: boolean;
  usedKeys?: string[];
  index: number;
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const isUsed = props.usedKeys?.includes(props.bodyModification.key) || false;
  const manufacturers =
    data.manufacturers?.[props.bodyModification.key] || null;
  const selectedBrand =
    data.selected_manufacturer?.[props.bodyModification.key] ||
    (manufacturers ? manufacturers[0] : null);

  return (
    <Table.Row
      key={props.bodyModification.key}
      className={`PreferencesMenu__Augs-Row ${
        props.index % 2 === 0 ? 'even' : 'odd'
      }`}
    >
      <Table.Cell className="PreferencesMenu__Augs-Name">
        {props.bodyModification.name}
      </Table.Cell>
      <Table.Cell className="PreferencesMenu__Augs-Actions">
        {Array.isArray(manufacturers) && props.added && (
          <Dropdown
            className="PreferencesMenu__Augs-Dropdown"
            selected={selectedBrand ?? ''}
            options={manufacturers.map((brand: string) => ({
              value: brand,
              displayText: brand === 'None' ? 'Без протеза' : brand,
            }))}
            onSelected={(brand) =>
              act('set_body_modification_manufacturer', {
                body_modification_key: props.bodyModification.key,
                manufacturer: brand,
              })
            }
          />
        )}
        {props.added ? (
          <Button
            className="PreferencesMenu__Augs-Button"
            icon="times"
            color="red"
            onClick={() =>
              act('remove_body_modification', {
                body_modification_key: props.bodyModification.key,
              })
            }
            fluid
          >
            Удалить
          </Button>
        ) : (
          <Button
            className="PreferencesMenu__Augs-Button"
            icon="plus"
            color={isUsed ? 'grey' : 'green'}
            disabled={isUsed}
            onClick={() =>
              act('apply_body_modification', {
                body_modification_key: props.bodyModification.key,
              })
            }
            fluid
          >
            Добавить
          </Button>
        )}
      </Table.Cell>
    </Table.Row>
  );
};
