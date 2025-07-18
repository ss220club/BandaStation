import { Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { CONNECTED, DISCONNECTED, TICKET_LOG } from './constants';
import { toLocalTime } from './helpers';
import { ManagerData } from './types';

export function TicketMessage(props) {
  const { data } = useBackend<ManagerData>();
  const { isAdmin, userKey } = data;
  const { sender, message, time } = props.message;
  const messageSender = userKey === sender;

  if (sender === DISCONNECTED || sender === CONNECTED) {
    return (
      <Stack
        fill
        className={classes([
          'TicketMessage__Connection',
          sender === CONNECTED && 'TicketMessage__Connection--connected',
        ])}
      >
        <div className="ticket-message">{message}</div>
        <div className="ticket-time">{toLocalTime(time)}</div>
      </Stack>
    );
  }

  if (sender === TICKET_LOG) {
    return (
      !!isAdmin && (
        <Stack fill className="TicketMessage TicketMessage__Log">
          <div className="ticket-message">{message}</div>
          <div className="ticket-time">{toLocalTime(time)}</div>
        </Stack>
      )
    );
  }

  return (
    <Stack fill reverse={messageSender} className="TicketMessage__Wrapper">
      <Stack.Item
        className={classes([
          'TicketMessage',
          messageSender && 'TicketMessage--sendedMessage',
        ])}
      >
        <div className="TicketMessage__Sender">{sender}</div>
        <div className="TicketMessage__Content">
          {message}
          <div className="ticket-time">{toLocalTime(time)}</div>
        </div>
      </Stack.Item>
      <Stack.Item grow />
    </Stack>
  );
}
