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
    <Modal
      style={{
        position: 'absolute',
        left: '35%',
        top: '50%',
        transform: 'translateY(-50%)',
        width: '500px',
        maxWidth: '50vw',
        backgroundColor: 'transparent',
        overflow: 'hidden',
        maxHeight: 'none',
      }}
    >
      <Section
        buttons={
          <Button
            icon="times"
            color="transparent"
            tooltip="Закрыть"
            tooltipPosition="left"
            style={{
              color: 'white',
              fontSize: '1.5rem',
            }}
            onClick={props.handleClose}
          />
        }
        title={
          <Box
            inline
            style={{
              marginLeft: '10px',
              display: 'inline-flex',
              alignItems: 'center',
              gap: '1rem',
              padding: '0.5rem 0',
            }}
          >
            <Icon
              name="robot"
              style={{
                color: '#ffffff',
                fontSize: '1.4rem',
              }}
            />
            <Box
              as="span"
              style={{
                fontSize: '1.3rem',
                fontWeight: 'bold',
                color: '#ffffff',
                textShadow: '0 0 3px rgba(235, 235, 235, 0.5)',
                letterSpacing: '0.05em',
              }}
            >
              Модификации тела
            </Box>
          </Box>
        }
        style={{
          backgroundColor: 'rgba(33, 33, 33)',
          borderRadius: '8px',
          padding: '0',
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
          maxHeight: '70vh',
        }}
      >
        <Box
          style={{
            flex: 1,
            overflowY: 'auto',
            overflowX: 'hidden',
          }}
        >
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

  const appliedModifications = props.bodyModification.filter(
    (bodyModification) =>
      applied_body_modifications.includes(bodyModification.key),
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
    <Box style={{ maxHeight: '70vh', overflowY: 'auto' }}>
      <Table
        style={{
          width: '100%',
          margin: '0',
          borderCollapse: 'collapse',
        }}
      >
        {appliedModifications.map((bodyModification, index) => (
          <BodyModificationRow
            key={bodyModification.key}
            bodyModification={bodyModification}
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
              style={{
                backgroundColor: '#40668C',
                borderBottom: collapsedCategories[category]
                  ? '1px solid rgba(255, 255, 255, 0.1)'
                  : 'none',
              }}
              onClick={() => toggleCategory(category)}
            >
              <Table.Cell
                colSpan={2}
                style={{
                  padding: '4px 12px',
                  cursor: 'pointer',
                  fontWeight: 'bold',
                }}
              >
                <Box inline>
                  <Icon
                    name={
                      collapsedCategories[category]
                        ? 'chevron-right'
                        : 'chevron-down'
                    }
                    style={{
                      marginRight: '0.5rem',
                      padding: '0px 6px',
                      fontWeight: 'bold',
                    }}
                  />
                  {category}
                </Box>
              </Table.Cell>
            </Table.Row>

            {!collapsedCategories[category] &&
              category !== null &&
              mods.map((bodyModification, index) => (
                <BodyModificationRow
                  key={bodyModification.key}
                  bodyModification={bodyModification}
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

  // Берём список брендов и текущий выбранный из data (которое приходит из get_ui_data)
  const manufacturers =
    data.manufacturers?.[props.bodyModification.key] || null;
  const selectedBrand =
    data.selected_manufacturer?.[props.bodyModification.key] ||
    (manufacturers ? Object.keys(manufacturers)[0] : null);

  return (
    <Table.Row
      key={props.bodyModification.key}
      style={{
        paddingTop: '4px',
        paddingBottom: '4px',
        backgroundColor:
          props.index % 2 === 0
            ? 'rgba(255, 255, 255, 0.05)'
            : 'rgba(0, 0, 0, 0.1)',
      }}
    >
      <Table.Cell
        style={{
          verticalAlign: 'middle',
          padding: '0px 12px',
          fontWeight: 'bold',
          whiteSpace: 'nowrap',
        }}
      >
        {props.bodyModification.name}
      </Table.Cell>
      <Table.Cell
        style={{
          textAlign: 'center',
          padding: '4px 12px',
          whiteSpace: 'nowrap',
        }}
      >
        {Array.isArray(manufacturers) && props.added && (
          <Dropdown
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
            style={{
              minWidth: '140px',
            }}
          />
        )}
        {props.added ? (
          <Button
            icon="times"
            color="red"
            style={{
              minWidth: 'fit-content',
              margin: '2px 0',
            }}
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
            icon="plus"
            color={isUsed ? 'grey' : 'green'}
            disabled={isUsed}
            style={{
              minWidth: 'fit-content',
              margin: '2px 0',
            }}
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
