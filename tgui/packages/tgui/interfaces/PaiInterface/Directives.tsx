import { useBackend } from 'tgui/backend';
import {
  BlockQuote,
  Box,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';
import { decodeHtmlEntities } from 'tgui-core/string';

import { DIRECTIVE_COMPREHENSION, DIRECTIVE_ORDER } from './constants';
import type { PaiData } from './types';

/** Shows the hardcoded PAI info along with any supplied orders. */
export function DirectiveDisplay(props) {
  const { data } = useBackend<PaiData>();
  const { directives = [], master_name } = data;
  const displayedLaw = directives?.length
    ? decodeHtmlEntities(directives[0])
    : 'Отсуствуют.';

  return (
    <Stack fill vertical>
      <Stack.Item grow={2}>
        <Section fill scrollable title="Логическое ядро">
          <Box color="label">
            {DIRECTIVE_COMPREHENSION}
            <br />
            <br />
            {DIRECTIVE_ORDER}
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Директивы">
          {!master_name ? (
            'Отсуствуют.'
          ) : (
            <LabeledList>
              <LabeledList.Item label="Основная">
                Служи своему мастеру.
              </LabeledList.Item>
              <LabeledList.Item label="Дополнительные">
                <BlockQuote>{displayedLaw}</BlockQuote>
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
}
