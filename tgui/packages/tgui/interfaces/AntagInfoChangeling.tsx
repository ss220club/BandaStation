import { useState } from 'react';
import {
  Button,
  Dimmer,
  Dropdown,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  type Objective,
  ObjectivePrintout,
  ReplaceObjectivesButton,
} from './common/Objectives';

const hivestyle = {
  fontWeight: 'bold',
  color: 'yellow',
};

const absorbstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const revivestyle = {
  color: 'lightblue',
  fontWeight: 'bold',
};

const transformstyle = {
  color: 'orange',
  fontWeight: 'bold',
};

const storestyle = {
  color: 'lightgreen',
  fontWeight: 'bold',
};

const hivemindstyle = {
  color: 'violet',
  fontWeight: 'bold',
};

const fallenstyle = {
  color: 'black',
  fontWeight: 'bold',
};

type Memory = {
  name: string;
  story: string;
};

type Info = {
  true_name: string;
  hive_name: string;
  stolen_antag_info: string;
  memories: Memory[];
  objectives: Objective[];
  can_change_objective: BooleanLike;
};

export const AntagInfoChangeling = (props) => {
  return (
    <Window width={720} height={750}>
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        <Stack vertical fill>
          <Stack.Item maxHeight={16}>
            <IntroductionSection />
          </Stack.Item>
          <Stack.Item grow={4}>
            <AbilitiesSection />
          </Stack.Item>
          <Stack.Item>
            <HivemindSection />
          </Stack.Item>
          <Stack.Item grow={3}>
            <Stack fill>
              <Stack.Item grow>
                <MemoriesSection />
              </Stack.Item>
              <Stack.Item grow>
                <VictimPatternsSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const HivemindSection = (props) => {
  const { act, data } = useBackend<Info>();
  const { true_name } = data;
  return (
    <Section fill title="Коллективный разум">
      <Stack vertical fill>
        <Stack.Item textColor="label">
          Все Генокрады, независимо от происхождения, связаны между собой{' '}
          <span style={hivemindstyle}>коллективным разумом</span>. Вы можете
          общаться с другими Генокрадами под вашем псевдонимом,{' '}
          <span style={hivemindstyle}>{true_name}</span>, начав сообщение с{' '}
          <span style={hivemindstyle}>:g</span>. Работайте вместе, и вы
          приведете станцию к новым вершинам ужаса.
        </Stack.Item>
        <Stack.Item>
          <NoticeBox danger>
            Другие Генокрады - сильные союзники, но некоторые Генокрады могут
            предать вас. Генокрады значительно увеличивают свою силу, поглощая
            себе подобных, но будучи поглощенным другим генокрадом, вы станете{' '}
            <span style={fallenstyle}>Падшим генокрадом</span>. Не существует
            более ужасного унижения.
          </NoticeBox>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const IntroductionSection = (props) => {
  const { act, data } = useBackend<Info>();
  const { true_name, hive_name, objectives, can_change_objective } = data;
  return (
    <Section fill title="Введение" style={{ overflowY: 'auto' }}>
      <Stack vertical fill>
        <Stack.Item fontSize="25px">
          Вы {true_name} из
          <span style={hivestyle}> {hive_name}</span>.
        </Stack.Item>
        <Stack.Item>
          <ObjectivePrintout
            objectives={objectives}
            objectiveFollowup={
              <ReplaceObjectivesButton
                can_change_objective={can_change_objective}
                button_title={'Развить новые директивы'}
                button_colour={'green'}
              />
            }
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const AbilitiesSection = () => {
  return (
    <Section fill title="Способности">
      <Stack fill>
        <Stack.Item grow>
          <Stack fill vertical>
            <Stack.Item textColor="label" grow>
              Ваша способность<span style={absorbstyle}>&ensp;Absorb DNA</span>{' '}
              позволяет вам украсть ДНК и воспоминания жертвы. Способность
              <span style={absorbstyle}>&ensp;Extract DNA Sting</span> также
              крадет ДНК жертвы и не поддается обнаружению, но не дает вам их
              воспоминаний или образцов речи.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item textColor="label" grow>
              Ваша способность
              <span style={revivestyle}>&ensp;Reviving Stasis </span>
              позволяет вам возродиться. Это значит, что ничто, кроме полного
              разрушения тела, не сможет остановить вас! Разумеется, это громко,
              поэтому не стоит делать это в присутствии людей, которых вы не
              собираетесь заткнуть.
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <Stack fill vertical>
            <Stack.Item textColor="label" grow>
              Ваша способность
              <span style={transformstyle}>&ensp;Transform</span> позволяет вам
              превратиться в форму тех, у кого вы собрали ДНК, летально и
              нелетально. Он также будет имитировать (НЕ НАСТОЯЩУЮ ОДЕЖДУ)
              одежду, в которую они были одеты, для каждого вашего свободного
              слота.
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item textColor="label" grow>
              <span style={storestyle}>&ensp;Cellular Emporium</span> это место,
              где вы приобретаете новые способности, помимо стартового набора. У
              вас есть 10 генетических очков, которые вы можете потратить на
              способности, и вы можете реадаптироваться после поглощения тела,
              возвращая свои очки для разных наборов.
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const MemoriesSection = (props) => {
  const { data } = useBackend<Info>();
  const { memories } = data;
  const [selectedMemory, setSelectedMemory] = useState(
    (!!memories && memories[0]) || null,
  );
  const memoryMap = {};
  for (const index in memories) {
    const memory = memories[index];
    memoryMap[memory.name] = memory;
  }

  return (
    <Section
      fill
      scrollable={!!memories && !!memories.length}
      title="Украденные воспоминания"
      buttons={
        <Button
          icon="info"
          tooltipPosition="left"
          tooltip={`
            Поглощая цели, вы можете
            получить их воспоминания. Они должны
            помочь вам выдать себя за свою цель!
          `}
        />
      }
    >
      {(!!memories && !memories.length && (
        <Dimmer fontSize="20px">Сначала поглотите жертву!</Dimmer>
      )) || (
        <Stack vertical>
          <Stack.Item>
            <Dropdown
              width="100%"
              selected={selectedMemory?.name}
              options={memories.map((memory) => {
                return memory.name;
              })}
              onSelected={(selected) => setSelectedMemory(memoryMap[selected])}
            />
          </Stack.Item>
          <Stack.Item>{!!selectedMemory && selectedMemory.story}</Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

const VictimPatternsSection = (props) => {
  const { data } = useBackend<Info>();
  const { stolen_antag_info } = data;
  return (
    <Section
      fill
      scrollable={!!stolen_antag_info}
      title="Дополнительная украденная информация"
    >
      {(!!stolen_antag_info && stolen_antag_info) || (
        <Dimmer fontSize="20px">Сначала поглотите жертву!</Dimmer>
      )}
    </Section>
  );
};
