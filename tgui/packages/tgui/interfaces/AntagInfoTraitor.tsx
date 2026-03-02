import {
  BlockQuote,
  Button,
  Dimmer,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
//  BANDASTATION EDIT END (re_traitorsecondary)
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

const allystyle = {
  fontWeight: 'bold',
  color: 'yellow',
};

const badstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const goalstyle = {
  color: 'lightblue',
  fontWeight: 'bold',
};

type Info = {
  has_codewords: BooleanLike;
  phrases: string;
  responses: string;
  theme: string;
  allies: string;
  goal: string;
  intro: string;
  code: string;
  failsafe_code: string;
  //  BANDASTATION ADDITION START (re_traitorsecondary)
  replacement_code: string;
  replacement_frequency: string;
  //  BANDASTATION ADDITION END (re_traitorsecondary)
  has_uplink: BooleanLike;
  uplink_intro: string;
  uplink_unlock_info: string;
  given_uplink: BooleanLike;
  objectives: Objective[];
};

const IntroductionSection = (props) => {
  const { act, data } = useBackend<Info>();
  const { intro, objectives } = data;
  return (
    <Section fill title="Введение" scrollable>
      <Stack vertical fill>
        <Stack.Item fontSize="25px">{intro}</Stack.Item>
        <Stack.Item grow>
          <ObjectivePrintout objectives={objectives} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const EmployerSection = (props) => {
  const { data } = useBackend<Info>();
  const { allies, goal } = data;
  return (
    <Section
      fill
      title="Наниматель"
      scrollable
      buttons={
        <Button
          icon="hammer"
          tooltip={`
            Это внутриигровое предложение для заскучавших предателей.
            Вы не обязаны следовать ему, если только вы не хотите
            использовать это для генерации идей для раунда.`}
          tooltipPosition="bottom-start"
        >
          Политика
        </Button>
      }
    >
      <Stack vertical fill>
        <Stack.Item grow>
          <Stack vertical>
            <Stack.Item>
              <span style={allystyle}>
                Ваши обязанности:
                <br />
              </span>
              <BlockQuote>{allies}</BlockQuote>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item mb={1}>
              <span style={goalstyle}>
                От нанимателя:
                <br />
              </span>
              <BlockQuote>{goal}</BlockQuote>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const UplinkSection = (props) => {
  //  BANDASTATION EDIT START (re_traitorsecondary) ORIIGNAL:
  /*
    const { has_uplink, uplink_intro, uplink_unlock_info, code, failsafe_code } =
    data;
  */
  const { data } = useBackend<Info>();
  const {
    has_uplink,
    uplink_intro,
    uplink_unlock_info,
    code,
    failsafe_code,
    replacement_code,
    replacement_frequency,
  } = data;
  //  BANDASTATION EDIT END (re_traitorsecondary)
  //  BANDASTATION ADDITION START (re_traitorsecondary)
  return (
    <Section title="Аплинк" mb={!has_uplink && -1}>
      <Stack fill>
        {(!has_uplink && (
          <Dimmer>
            <Stack.Item fontSize="16px">
              <Section textAlign="Center">
                Ваш аплинк пропал или уничтожен. <br />
                Создайте маяк Синдиката а потом что нибудь скажите
                <br />
                <span style={goalstyle}>
                  <b>{replacement_code}</b>
                </span>{' '}
                on frequency{' '}
                <span style={goalstyle}>
                  <b>{replacement_frequency}</b>
                </span>{' '}
                после синхронизации с маяком.
              </Section>
            </Stack.Item>
          </Dimmer>
        )) || (
          //  BANDASTATION ADDITION END (re_traitorsecondary) i hate tgui(((
          <>
            <Stack.Item bold>
              {uplink_intro}
              <br />
              {code && <span style={goalstyle}>Код: {code}</span>}
              <br />
              {failsafe_code && (
                <span style={badstyle}>Запасной код: {failsafe_code}</span>
              )}
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item align="center">
              <BlockQuote>{uplink_unlock_info}</BlockQuote>
            </Stack.Item>
          </>
        )}
      </Stack>
      <br />
      {(has_uplink && (
        <Section textAlign="Center">
          Если вы потеряли ваш аплинк, то вы можете созать маяк Синдиката и
          что-то сказать{' '}
          <span style={goalstyle}>
            <b>{replacement_code}</b>
          </span>{' '}
          на определённой частоте{' '}
          <span style={goalstyle}>
            <b>{replacement_frequency}</b>
          </span>{' '}
          после синхронизации с маяком.
        </Section>
      )) || (
        <Section>
          {' '}
          <br />
          <br />
        </Section>
      )}
    </Section>
  );
};

const CodewordsSection = (props) => {
  const { data } = useBackend<Info>();
  const { has_codewords, phrases, responses } = data;
  return (
    <Section title="Кодовые слова" mb={!has_codewords && -1}>
      <Stack fill>
        {(!has_codewords && (
          <BlockQuote>
            Вам не были предоставлены кодовые слова. Вы должны использовать
            альтернативные способы поиска потенциальных союзников. Но будьте
            осторожны, так как каждый может быть потенциальным противником.
          </BlockQuote>
        )) || (
          <>
            <Stack.Item grow basis={0}>
              <BlockQuote>
                Ваш наниматель предоставил вам кодовые слова для идентификации
                других агентов. Используйте слова во время обычных разговора,
                если считаете, что говорите с агентом. Но будьте осторожны, так
                как каждый может быть потенциальным противником.
                <span style={badstyle}>
                  &ensp;Вы запомнили кодовые слова, позволяющие распозновать их,
                  когда вы их услышите.
                </span>
              </BlockQuote>
            </Stack.Item>
            <Stack.Divider mr={1} />
            <Stack.Item grow basis={0}>
              <Stack vertical>
                <Stack.Item>Кодовые фразы:</Stack.Item>
                <Stack.Item bold textColor="blue">
                  {phrases}
                </Stack.Item>
                <Stack.Item>Кодовые ответы:</Stack.Item>
                <Stack.Item bold textColor="red">
                  {responses}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </>
        )}
      </Stack>
    </Section>
  );
};

export const AntagInfoTraitor = (props) => {
  const { data } = useBackend<Info>();
  const { theme, given_uplink } = data;
  return (
    <Window width={620} height={580} theme={theme}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item width="70%">
                <IntroductionSection />
              </Stack.Item>
              <Stack.Item width="30%">
                <EmployerSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          {!!given_uplink && (
            <Stack.Item>
              <UplinkSection />
            </Stack.Item>
          )}
          <Stack.Item>
            <CodewordsSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
