import { Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { CONNECTED, DISCONNECTED } from './constants';
import { toLocalTime } from './helpers';
import { ManagerData } from './types';

export function TicketMessage(props) {
  const { data } = useBackend<ManagerData>();
  const { sender, message, time } = props.message;
  const messageSender = data.userKey === sender;

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
