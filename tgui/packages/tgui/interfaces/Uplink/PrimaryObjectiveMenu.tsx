//  BANDASTATION EDIT START (re_traitorsecondary)
/* ORIGINAL:
import { Box, Button, Section, Stack } from 'tgui-core/components';
*/
import { Box, Button, Dimmer, Section, Stack } from 'tgui-core/components';
//  BANDASTATION EDIT END (re_traitorsecondary)

import { useBackend } from '../../backend';
//  BANDASTATION EDIT START (re_traitorsecondary)
/* ORIGINAL:
import { ObjectiveElement } from './ObjectiveElement';
*/
import { ObjectiveElement } from './ObjectiveMenu';
//  BANDASTATION EDIT END (re_traitorsecondary)
type PrimaryObjectiveMenuProps = {
  primary_objectives;
  //  BANDASTATION ADDITION START (re_traitorsecondary)
  final_objective;
  //  BANDASTATION ADDITION END (re_traitorsecondary)
  can_renegotiate;
};

export const PrimaryObjectiveMenu = (props: PrimaryObjectiveMenuProps) => {
  const { act } = useBackend();
  //  BANDASTATION EDIT START (re_traitorsecondary)
  /*
  ORIGINAL: const { primary_objectives, can_renegotiate } = props;
  */
  const { primary_objectives, final_objective, can_renegotiate } = props;
  //  BANDASTATION EDIT END (re_traitorsecondary)
  //  BANDASTATION ADDITION START (re_traitorsecondary) cant write comments where needed, so it will be left here
   return (
    <Section fill scrollable align="center">
      <Box my={4} bold fontSize={1.2} color="green">
        ПРИВЕТСТВУЕМ, АГЕНТ.
      </Box>
      <Box my={4} bold fontSize={1.2}>
        Агент, это ваши основные задачи. Выполните их любой ценой.
      </Box>
      <Box my={4} bold fontSize={1.2}>
        Выполнение второстепенных целей позволит вам получить дополнительное
        снаряжение.
      </Box>
      {final_objective && (
        <Dimmer>
          <Box
            color="red"
            fontFamily={'Bahnschrift'}
            fontSize={3}
            align={'top'}
            as="span"
          >
            ПРИОРИТЕТНОЕ СООБЩЕНИЕ
            <br />
            ИСТОЧНИК: xxx.xxx.xxx.224:41394
            <br />
            <br />
            \\Обсуждение ваших действий в процессе.
            <br />
            \\Финальная цель подтверждена и достигнута. <br />
            \\Ваша работа здесь завершена, агент.
            <br />
            <br />
            СОЕДИНЕНИЕ РАЗОРВАНО_
          </Box>
        </Dimmer>
      )}
      <Stack vertical>
        {primary_objectives.map((prim_obj, index) => (
          <Stack.Item key={index}>
            <ObjectiveElement
              key={prim_obj.id}
 //  BANDASTATION EDIT END (re_traitorsecondary)
 //  BANDASTATION EDIT START (re_traitorsecondary)
 /*
          <Stack.Item key={index}>
            <ObjectiveElement
              key={prim_obj.id}
              name={prim_obj.task_name}
              description={prim_obj.task_text}
 */
//  BANDASTATION ADDITION START (re_traitorsecondary)
              name={prim_obj['task_name']}
              description={prim_obj['task_text']}
              dangerLevel={{
                minutesLessThan: 0,
                title: 'none',
                gradient:
                  index === primary_objectives.length - 1
                    ? 'reputation-good'
                    : 'reputation-very-good',
              }}
              telecrystalReward={0}
              telecrystalPenalty={0}
              progressionReward={0}
              originalProgression={0}
              hideTcRep
              canAbort={false}
              grow={false}
              finalObjective={false}
//  BANDASTATION ADDITION END (re_traitorsecondary)
            />
          </Stack.Item>
        ))}
      </Stack>
      {!!can_renegotiate && (
        <Box mt={3} mb={5} bold fontSize={1.2} align="center" color="white">
          <Button
            content={'Перезаключить контракт'}
            tooltip={
              'Замените свои текущие основные задачи на пользовательские. Это действие можно совершить лишь единожды.'
            }
            onClick={() => act('renegotiate_objectives')}
          />
        </Box>
      )}
      <Box my={4} fontSize={0.8}>
        <Box>SyndOS Version 3.17</Box>
        <Box color="green">Безопасное соединение</Box>
      </Box>
    </Section>
  );
};
