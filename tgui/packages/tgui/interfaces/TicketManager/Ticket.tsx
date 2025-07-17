import { Dispatch } from 'react';
import { Button, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { TICKET_STATE } from './constants';
import { toLocalTime } from './helpers';
import { TicketProps } from './types';

export function Ticket(
  props: TicketProps & { setSelectedTicket: Dispatch<number> },
) {
  const {
    number,
    type,
    initiator,
    openedTime,
    closedTime,
    messages,
    setSelectedTicket,
  } = props;

  return (
    <Stack
      vertical
      className={classes(['Ticket', type && `Ticket--${type}`])}
      onClick={() => setSelectedTicket(number)}
    >
      <Stack fill className="Ticket__Header">
        <Stack.Item className="Ticket__Id">#{number}</Stack.Item>
        <Stack.Item grow className="Ticket__Initiator">
          {initiator}
        </Stack.Item>
        <Stack.Item className="Ticket__TimeStamp">
          {toLocalTime(openedTime)}
          {closedTime && ` - ${toLocalTime(closedTime)}`}
        </Stack.Item>
      </Stack>
      <Stack.Item className="Ticket__FirstMessage">
        {messages[0].message}
      </Stack.Item>
    </Stack>
  );
}

export function TicketInteractions(props: {
  ticketID: number;
  ticketState: TICKET_STATE;
}) {
  const { act } = useBackend();
  const { ticketID, ticketState } = props;

  return (
    <Stack>
      {ticketState !== TICKET_STATE.Open ? (
        <Stack.Item>
          <Button
            icon="eye"
            tooltip="Открыть закрытый/решённый ранее тикет"
            onClick={() => act('reopen', { ticketID: ticketID })}
          >
            Открыть
          </Button>
        </Stack.Item>
      ) : (
        <>
          <Stack.Item>
            <Button
              icon="check"
              color="good"
              tooltip="Пометить тикет как решённый"
              onClick={() => act('resolve', { ticketID: ticketID })}
            >
              Решить
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="trash-can"
              color="bad"
              tooltip="Закрыть тикет"
              onClick={() => act('close', { ticketID: ticketID })}
            >
              Закрыть
            </Button>
          </Stack.Item>
          {/* NEEDED MENTOR SYSTEM
          <Stack.Item>
            <Button
              icon="exchange"
              tooltip="Перенаправить тикет менторам"
              onClick={() => act('convert', { ticketID: ticketID })}
            />
          </Stack.Item>
           */}
        </>
      )}
    </Stack>
  );
}

export function TicketAdminInteractions(props: { ticketID: number }) {
  const { act } = useBackend();
  const { ticketID } = props;

  return (
    <Stack fill wrap textAlign="center">
      <Stack.Item grow>
        <Button
          fluid
          onClick={() => act('view_variables', { ticketID: ticketID })}
        >
          View Variables
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        <Button
          fluid
          onClick={() => act('traitor_panel', { ticketID: ticketID })}
        >
          Traitor Panel
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        <Button
          fluid
          onClick={() => act('player_panel', { ticketID: ticketID })}
        >
          Player Panel
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          color="purple"
          icon="phone"
          tooltip="Голос в голове"
          onClick={() => act('subtlepm', { ticketID: ticketID })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="red"
          icon="hand-fist"
          tooltip="Наказать"
          onClick={() => act('smite', { ticketID: ticketID })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="blue"
          icon="scroll"
          tooltip="Логи"
          onClick={() => act('logs', { ticketID: ticketID })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          color="grey"
          icon="ghost"
          tooltip="Наблюдать"
          onClick={() => act('follow', { ticketID: ticketID })}
        />
      </Stack.Item>
    </Stack>
  );
}
