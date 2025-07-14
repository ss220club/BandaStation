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
  ticketId: number;
  ticketState: TICKET_STATE;
}) {
  const { act } = useBackend();
  const { ticketId, ticketState } = props;

  return (
    <Stack>
      {ticketState !== TICKET_STATE.Open ? (
        <Stack.Item>
          <Button
            icon="eye"
            tooltip="Открыть закрытый/решённый ранее тикет"
            onClick={() => act('reopen', { ticketNumber: ticketId })}
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
              onClick={() => act('resolve', { ticketNumber: ticketId })}
            >
              Решить
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="trash-can"
              color="bad"
              tooltip="Закрыть тикет"
              onClick={() => act('close', { ticketNumber: ticketId })}
            >
              Закрыть
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="exchange"
              tooltip="Перенаправить тикет менторам"
              onClick={() => act('convert', { ticketNumber: ticketId })}
            />
          </Stack.Item>
        </>
      )}
    </Stack>
  );
}
