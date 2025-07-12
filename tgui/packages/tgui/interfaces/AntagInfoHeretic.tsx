import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Flex,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  type Objective,
  ObjectivePrintout,
  ReplaceObjectivesButton,
} from './common/Objectives';

const hereticRed = {
  color: '#e03c3c',
};

const hereticBlue = {
  fontWeight: 'bold',
  color: '#2185d0',
};

const hereticPurple = {
  fontWeight: 'bold',
  color: '#bd54e0',
};

const hereticGreen = {
  fontWeight: 'bold',
  color: '#20b142',
};

const hereticYellow = {
  fontWeight: 'bold',
  color: 'yellow',
};

type IconParams = {
  icon: string;
  state: string;
  frame: number;
  dir: number;
  moving: BooleanLike;
};

type Knowledge = {
  path: string;
  icon_params: IconParams;
  name: string;
  desc: string;
  gainFlavor: string;
  cost: number;
  bgr: string;
  disabled: BooleanLike;
  finished: BooleanLike;
  ascension: BooleanLike;
};

type KnowledgeInfo = {
  knowledge_tiers: KnowledgeTier[];
};

type KnowledgeTier = {
  nodes: Knowledge[];
};

type Info = {
  charges: number;
  total_sacrifices: number;
  ascended: BooleanLike;
  objectives: Objective[];
  can_change_objective: BooleanLike;
};

const IntroductionSection = (props) => {
  const { data, act } = useBackend<Info>();
  const { objectives, ascended, can_change_objective } = data;

  return (
    <Stack justify="space-evenly" height="100%" width="100%">
      <Stack.Item grow>
        <Section title="Вы Еретик!" fill fontSize="14px">
          <Stack vertical>
            <FlavorSection />
            <Stack.Divider />
            <GuideSection />
            <Stack.Divider />
            <InformationSection />
            <Stack.Divider />
            {!ascended && (
              <Stack.Item>
                <ObjectivePrintout
                  fill
                  titleMessage={
                    can_change_objective
                      ? 'Для вознесения вам нужно выполнить следующие задачи'
                      : 'Используйте свои темные знания, чтобы выполнить персональные цели'
                  }
                  objectives={objectives}
                  objectiveFollowup={
                    <ReplaceObjectivesButton
                      can_change_objective={can_change_objective}
                      button_title={'Отвергнуть вознесение'}
                      button_colour={'red'}
                      button_tooltip={
                        'Отвернитесь от Мансуса, чтобы выполнить задание по своему выбору. Выбрав эту опцию, вы не сможете возвыситься!'
                      }
                    />
                  }
                />
              </Stack.Item>
            )}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const FlavorSection = () => {
  return (
    <Stack.Item>
      <Stack vertical textAlign="center" fontSize="14px">
        <Stack.Item>
          <i>
            Еще один день на бессмысленной работе. Вы чувствуете&nbsp;
            <span style={hereticBlue}>мерцание</span>
            &nbsp;вокруг себя, когда что-то&nbsp;
            <span style={hereticRed}>странное</span>
            &nbsp;в воздухе озаряет вас. Вы смотрите внутрь себя и находите то,
            что изменит вашу жизнь.
          </i>
        </Stack.Item>
        <Stack.Item>
          <b>
            <span style={hereticPurple}>Врата Мансуса</span>
            &nbsp;открылись для вашего разума.
          </b>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const GuideSection = () => {
  return (
    <Stack.Item>
      <Stack vertical fontSize="12px">
        <Stack.Item>
          - Ищите на станции рушащие реальность&nbsp;
          <span style={hereticPurple}>влияния</span>. Они не видны обычному
          глазу. Нажмите&nbsp;
          <b>правой кнопкой мыши</b> по ним чтобы получить&nbsp;
          <span style={hereticBlue}>очки знаний</span>. После добычи, они вскоре
          становятся видимыми для всех. Сноведения о Мансусе помогут найти их.
        </Stack.Item>
        <Stack.Item>
          - Используйте ваше&nbsp;
          <span style={hereticRed}>живое сердце</span>
          &nbsp;, чтобы найти&nbsp;
          <span style={hereticRed}>цели для жертвоприношения</span>, но будьте
          аккуратны: пульсируя, оно будет издавать звук сердцебиения на коротком
          расстоянии. Эта способность связана с вашим <b>сердцем</b> - если вы
          его потеряете, совершите ритуал, чтобы вернуть её.
        </Stack.Item>
        <Stack.Item>
          - Нарисуйте&nbsp;
          <span style={hereticGreen}>руну трансмутации</span>, используя
          инструмент для рисования (ручка или карандаш) на полу. Необходимо
          иметь&nbsp;
          <span style={hereticGreen}>хватку Мансуса</span>
          &nbsp;в вашей другой руке. Эта руна позволяет совершать ритуалы и
          жертвоприношения.
        </Stack.Item>
        <Stack.Item>
          - Следуйте за зовом <span style={hereticRed}>живого сердца</span>,
          чтобы найти свои цели. Принесите их на&nbsp;
          <span style={hereticGreen}>руну трансмутации</span> в критическом, или
          хуже, состоянии для&nbsp;
          <span style={hereticRed}>жертвоприношения</span>, которое даст&nbsp;
          <span style={hereticBlue}>очки знаний</span>. Мансус примет{' '}
          <b>ТОЛЬКО</b> цели, указанные вашим&nbsp;
          <span style={hereticRed}>живым сердцем</span>.
        </Stack.Item>
        <Stack.Item>
          - Сделайте себе <span style={hereticYellow}>фокусировку</span>, чтобы
          читать более продвинутые заклинания, которые помогут вам для более
          сложных жертвоприношений.
        </Stack.Item>
        <Stack.Item>
          - Выполните все свои задачи, чтобы узнать{' '}
          <span style={hereticYellow}>финальный ритуал</span>. Завершите его,
          чтобы стать всемогущим!
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const InformationSection = (props) => {
  const { data } = useBackend<Info>();
  const { charges, total_sacrifices, ascended } = data;
  return (
    <Stack.Item>
      <Stack vertical fill>
        {!!ascended && (
          <Stack.Item>
            <Stack align="center">
              <Stack.Item>Вы</Stack.Item>
              <Stack.Item fontSize="24px">
                <Box inline color="yellow">
                  ВОЗВЫСИЛИСЬ
                </Box>
                !
              </Stack.Item>
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          Доступно <span style={hereticBlue}>очков знаний</span>:{' '}
          <b>{charges || 0}</b>&nbsp;
        </Stack.Item>
        <Stack.Item>
          Жертвоприношений сделано: <b>{total_sacrifices || 0}</b>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const KnowledgeTree = (props) => {
  const { data, act } = useBackend<KnowledgeInfo>();
  const { knowledge_tiers } = data;

  return (
    <Section title="Древо знаний" fill scrollable>
      <Box textAlign="center" fontSize="32px">
        <span style={hereticYellow}>DAWN</span>
      </Box>
      <Stack vertical>
        {knowledge_tiers.length === 0
          ? 'None!'
          : knowledge_tiers.map((tier, i) => (
              <Stack.Item key={i}>
                <Flex
                  justify="center"
                  align="center"
                  backgroundColor="transparent"
                  wrap="wrap"
                >
                  {tier.nodes.map((node) => (
                    <Flex.Item key={node.name}>
                      <Button
                        color="transparent"
                        tooltip={`${node.name}:
                          ${node.desc}`}
                        onClick={
                          node.disabled || node.finished
                            ? undefined
                            : () => act('research', { path: node.path })
                        }
                        width={node.ascension ? '192px' : '64px'}
                        height={node.ascension ? '192px' : '64px'}
                        m="8px"
                        style={{
                          borderRadius: '50%',
                        }}
                      >
                        <DmIcon
                          icon="icons/ui_icons/antags/heretic/knowledge.dmi"
                          icon_state={
                            node.disabled
                              ? 'node_locked'
                              : node.finished
                                ? 'node_finished'
                                : node.bgr
                          }
                          height={node.ascension ? '192px' : '64px'}
                          width={node.ascension ? '192px' : '64px'}
                          top="0px"
                          left="0px"
                          position="absolute"
                        />
                        <DmIcon
                          icon={node.icon_params.icon}
                          icon_state={node.icon_params.state}
                          frame={node.icon_params.frame}
                          direction={node.icon_params.dir}
                          movement={node.icon_params.moving}
                          height={node.ascension ? '152px' : '64px'}
                          width={node.ascension ? '152px' : '64px'}
                          top={node.ascension ? '20px' : '0px'}
                          left={node.ascension ? '20px' : '0px'}
                          position="absolute"
                        />
                        <Box
                          position="absolute"
                          top="0px"
                          left="0px"
                          backgroundColor="black"
                          textColor="white"
                          bold
                        >
                          {!node.finished &&
                            (node.cost > 0 ? node.cost : 'FREE')}
                        </Box>
                      </Button>
                      {!!node.ascension && (
                        <Box textAlign="center" fontSize="32px">
                          <span style={hereticPurple}>DUSK</span>
                        </Box>
                      )}
                    </Flex.Item>
                  ))}
                </Flex>
                <hr />
              </Stack.Item>
            ))}
      </Stack>
    </Section>
  );
};

const ResearchInfo = (props) => {
  const { data } = useBackend<Info>();
  const { charges } = data;

  return (
    <Stack vertical fill>
      <Stack.Item fontSize="20px" textAlign="center">
        Доступные <span style={hereticBlue}>очки знаний</span> :{' '}
        <b>{charges || 0}</b>&nbsp;.
      </Stack.Item>
      <Stack.Item grow>
        <KnowledgeTree />
      </Stack.Item>
    </Stack>
  );
};

export const AntagInfoHeretic = (props) => {
  const { data } = useBackend<Info>();
  const { ascended } = data;

  const [currentTab, setTab] = useState(0);

  return (
    <Window width={675} height={635}>
      <Window.Content
        style={{
          backgroundImage: 'none',
          background: ascended
            ? 'radial-gradient(circle, rgba(24,9,9,1) 54%, rgba(31,10,10,1) 60%, rgba(46,11,11,1) 80%, rgba(47,14,14,1) 100%);'
            : 'radial-gradient(circle, rgba(9,9,24,1) 54%, rgba(10,10,31,1) 60%, rgba(21,11,46,1) 80%, rgba(24,14,47,1) 100%);',
        }}
      >
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="info"
                selected={currentTab === 0}
                onClick={() => setTab(0)}
              >
                Информация
              </Tabs.Tab>
              <Tabs.Tab
                icon={currentTab === 1 ? 'book-open' : 'book'}
                selected={currentTab === 1}
                onClick={() => setTab(1)}
              >
                Исследования
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {(currentTab === 0 && <IntroductionSection />) || <ResearchInfo />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
