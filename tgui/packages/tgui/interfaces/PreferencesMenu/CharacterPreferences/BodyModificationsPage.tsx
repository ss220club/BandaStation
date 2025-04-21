import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Icon,
  Modal,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { LoadingScreen } from '../../common/LoadingScreen';
import { useServerPrefs } from '../useServerPrefs';
import { BodyModification, PreferencesMenuData } from './data';

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
        width: '400px',
        'background-color': 'transparent',
        'max-width': '40vw',
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
              'font-size': '1.5rem',
              ':hover': {
                color: '#ff5555',
                'background-color': 'rgba(255, 85, 85, 0.1)',
              },
            }}
            onClick={props.handleClose}
          />
        }
        title={
          <Box
            inline
            style={{
              'margin-left': '10px',
              display: 'inline-flex',
              'align-items': 'center',
              gap: '1rem',
              padding: '0.5rem 0',
            }}
          >
            <Icon
              name="robot"
              style={{
                color: '#ffffff',
                'font-size': '1.4rem',
              }}
            />
            <Box
              as="span"
              style={{
                'font-size': '1.3rem',
                'font-weight': 'bold',
                color: '#fffff',
                'text-shadow': '0 0 3px rgba(235, 235, 235, 0.5)',
                'letter-spacing': '0.05em',
              }}
            >
              Модификации тела
            </Box>
          </Box>
        }
        style={{
          position: 'relative',
          'background-color': 'rgba(33, 33, 33)',
          'border-radius': '8px',
          padding: '0',
          'max-height': '70vh',
          overflow: 'hidden',
        }}
      >
        <Box
          style={{
            'max-height': 'calc(70vh - 50px)',
            'overflow-y': 'auto',
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
  const { applied_body_modifications, incomptable_body_modifications } = data;
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
    <Table
      scrollable
      style={{
        width: '100%',
        margin: '0',
        'border-collapse': 'collapse',
      }}
    >
      {appliedModifications.map((bodyModification, index) => (
        <BodyModificationRow
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
              'background-color': '#40668C',
              'border-bottom': collapsedCategories[category]
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
                'font-weight': 'bold',
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
                    'margin-right': '0.5rem',
                    padding: '0px 6px',
                    'font-weight': 'bold',
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
                  ...incomptable_body_modifications,
                ]}
                index={index}
              />
            ))}
        </>
      ))}
    </Table>
  );
};

const BodyModificationRow = (props: {
  bodyModification: BodyModification;
  added: Boolean;
  usedKeys?: string[];
  index: number;
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const isUsed = props.usedKeys?.includes(props.bodyModification.key) || false;
  return (
    <Table.Row
      key={props.bodyModification.key}
      style={{
        'padding-top': '4px',
        'padding-bottom': '4px',
        'background-color':
          props.index % 2 === 0
            ? 'rgba(255, 255, 255, 0.05)'
            : 'rgba(0, 0, 0, 0.1)',
      }}
    >
      <Table.Cell
        style={{
          'vertical-align': 'middle',
          padding: '0px 12px',
          'font-weight': 'bold',
          'white-space': 'nowrap',
        }}
      >
        {props.bodyModification.name}
      </Table.Cell>
      <Table.Cell
        style={{
          'text-align': 'center',
          padding: '4px 12px',
          'white-space': 'nowrap',
        }}
      >
        {props.added ? (
          <Button
            icon="times"
            color="red"
            style={{
              'min-width': 'fit-content',
              margin: '2px 0',
              ':hover': {
                'background-color': isUsed
                  ? 'rgba(100, 100, 100, 0.3)'
                  : 'rgba(50, 255, 50, 0.3)',
              },
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
              'min-width': 'fit-content',
              margin: '2px 0',
              ':hover': {
                'background-color': isUsed
                  ? 'rgba(100, 100, 100, 0.3)'
                  : 'rgba(50, 255, 50, 0.3)',
              },
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
