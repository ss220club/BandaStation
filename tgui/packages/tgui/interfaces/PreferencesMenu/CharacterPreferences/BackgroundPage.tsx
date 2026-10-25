import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { sanitizeText } from 'tgui/sanitize';
import { Box, Button, Section, Stack, TextArea } from 'tgui-core/components';

import type {
  BackgroundEntry,
  BackgroundPreference,
  PreferencesMenuData,
} from '../types';
import { useServerPrefs } from '../useServerPrefs';

export function BackgroundPage() {
  const { data } = useBackend<PreferencesMenuData>();
  const serverData = useServerPrefs();

  return (
    <Stack vertical>
      {data.sierra_background.map((preference) => (
        <Stack.Item key={preference.category}>
          <BackgroundCategory
            key={`${data.active_slot}-${data.character_preferences.misc.species}-${preference.category}`}
            preference={preference}
            entries={serverData?.sierra_background?.[preference.category] ?? {}}
          />
        </Stack.Item>
      ))}
    </Stack>
  );
}

function BackgroundCategory(props: {
  preference: BackgroundPreference;
  entries: Record<string, BackgroundEntry>;
}) {
  const { preference, entries } = props;
  const { act } = useBackend<PreferencesMenuData>();
  const [showChoices, setShowChoices] = useState(false);
  const [showDescription, setShowDescription] = useState(false);
  const selected = entries[preference.value];

  return (
    <Section
      title={
        <Box mr={10} style={{ overflowWrap: 'anywhere' }}>
          <Button
            color="transparent"
            icon={showChoices ? 'chevron-down' : 'chevron-right'}
            onClick={() => setShowChoices(!showChoices)}
          >
            {preference.label}
          </Button>
          {' — '}
          {selected?.name ?? preference.value}
        </Box>
      }
      buttons={
        <Button
          icon={showDescription ? 'minus' : 'plus'}
          selected={showDescription}
          onClick={() => setShowDescription(!showDescription)}
        >
          {showDescription ? 'Скрыть' : 'Расширить'}
        </Button>
      }
    >
      {showDescription && selected && (
        <>
          <Box
            style={{ whiteSpace: 'pre-wrap', overflowWrap: 'anywhere' }}
            dangerouslySetInnerHTML={{
              __html: sanitizeText(selected.description),
            }}
          />
          {!!selected.extra && (
            <Box
              mt={1}
              style={{ whiteSpace: 'pre-wrap', overflowWrap: 'anywhere' }}
              dangerouslySetInnerHTML={{ __html: sanitizeText(selected.extra) }}
            />
          )}
        </>
      )}
      {showChoices && (
        <Box mt={showDescription ? 1 : 0}>
          {preference.choices.map((id) => (
            <Button
              key={id}
              selected={id === preference.value}
              onClick={() => {
                act('set_preference', {
                  preference: preference.preference,
                  value: id,
                });
                setShowDescription(true);
              }}
              style={{ whiteSpace: 'normal', maxWidth: '100%' }}
            >
              {entries[id]?.name ?? id}
            </Button>
          ))}
        </Box>
      )}
      {preference.category === 'culture' &&
        (preference.language_names || preference.name_generation) && (
          <Box mt={1}>
            {preference.language_names && (
              <Box>
                <b>Языки воспитания:</b>{' '}
                {preference.language_names.length
                  ? preference.language_names.join(', ')
                  : 'Дополнительные языки не добавляются.'}
              </Box>
            )}
            {!!preference.language_names?.length && (
              <Box color="label" fontSize="0.9em">
                Знание языка не гарантирует возможность говорить на нём.
              </Box>
            )}
            {preference.name_generation && (
              <>
                <Box mt={0.5}>
                  <b>Имена:</b> {preference.name_generation}
                </Box>
                <Box color="label" fontSize="0.9em">
                  Смена воспитания сохраняет введённое имя. Для нового имени
                  используйте кнопку генерации.
                </Box>
              </>
            )}
          </Box>
        )}
      <Box mt={1} bold>
        Личные подробности
      </Box>
      <Box color="label" mb={0.5}>
        {preference.notes_prompt}
      </Box>
      <TextArea
        fluid
        height="6em"
        aria-label={`Личные подробности: ${preference.label}`}
        value={preference.notes}
        maxLength={preference.notes_max_length}
        onBlur={(value) => {
          if (value !== preference.notes) {
            act('set_preference', {
              preference: preference.notes_preference,
              value,
            });
          }
        }}
      />
      <Box color="label" fontSize="0.9em" mt={0.5}>
        Необязательно. Сохраняется при выходе из поля. Shift+Enter — новая
        строка.
      </Box>
    </Section>
  );
}
