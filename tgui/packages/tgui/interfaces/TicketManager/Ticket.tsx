import { Dispatch } from 'react';
import { Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { toLocalTime } from './helpers';
import { TicketProps } from './types';

export function Ticket(
  props: TicketProps & { setSelectedTicket: Dispatch<number> },
) {
  const { number, type, initiator, openedTime, messages, setSelectedTicket } =
    props;

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
        </Stack.Item>
      </Stack>
      <Stack.Item className="Ticket__FirstMessage">
        {messages[0].message}
      </Stack.Item>
    </Stack>
  );
}
