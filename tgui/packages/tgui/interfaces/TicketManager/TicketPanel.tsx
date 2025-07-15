import { useEffect, useRef, useState } from 'react';
import { Button, Input, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { TICKET_STATE } from './constants';
import { toLocalTime } from './helpers';
import { TicketInteractions } from './Ticket';
import { ManagerData } from './types';

export function TicketPanel(props) {
  const { act, data } = useBackend<ManagerData>();
  const { isAdmin, isMentor } = data;
  const { allTickets, ticketNumber, setSelectedTicket } = props;

  const selectedTicket = allTickets.find(
    (ticket) => ticket.number === ticketNumber,
  );
  const { number, initiator, initiatorCkey, messages, state, type } =
    selectedTicket;

  const [showScrollButton, setShowScrollButton] = useState(false);
  const sectionRef = useRef<HTMLDivElement>(null);
  const shouldScrollRef = useRef(true);
  const firstRender = useRef(true);

  function scrollToBottom(ignoreBottom?: boolean, nonSmooth?: boolean) {
    const section = sectionRef.current;
    if (!section) {
      return;
    }

    if (shouldScrollRef.current || ignoreBottom) {
      section.scrollTo({
        top: section.scrollHeight,
        behavior: nonSmooth ? 'auto' : 'smooth',
      });
    }
  }

  useEffect(() => {
    const section = sectionRef.current;
    if (!section) {
      return;
    }

    const handleScroll = () => {
      const isBottom =
        section.scrollHeight - section.scrollTop - section.offsetHeight <= 200;
      shouldScrollRef.current = isBottom;
      setShowScrollButton((prev) => (prev !== !isBottom ? !isBottom : prev));
    };

    section.addEventListener('scroll', handleScroll);
    return () => {
      section.removeEventListener('scroll', handleScroll);
    };
  });

  useEffect(() => {
    const nonSmooth = firstRender.current;
    firstRender.current = false;

    scrollToBottom(false, nonSmooth);
  }, [messages]);

  return (
    <Stack
      fill
      vertical
      g={0}
      className={classes(['TicketPanel', `Ticket--${type}`])}
    >
      <Stack.Item grow position="relative">
        <Stack.Item
          className={classes([
            'TicketPanel__ScrollButton',
            showScrollButton && 'TicketPanel__ScrollButton--active',
          ])}
        >
          <Button icon="arrow-down" onClick={() => scrollToBottom(true)}>
            К последним сообщениям
          </Button>
        </Stack.Item>
        <Section
          ref={sectionRef}
          fill
          scrollable
          title={`Тикет #${number} - ${initiator}`}
          buttons={
            <Button
              color="red"
              icon="times"
              onClick={() => setSelectedTicket(false)}
            />
          }
        >
          <Stack vertical>
            {messages.map((message) => (
              <TicketMessage
                key={message.time}
                initiatorCkey={initiatorCkey}
                message={message}
              />
            ))}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item style={{ zIndex: 1 }}>
        <Section>
          <Stack fill>
            <Stack.Item grow>
              <Input
                fluid
                autoFocus
                selfClear
                disabled={state !== TICKET_STATE.Open}
                placeholder={
                  state === TICKET_STATE.Open
                    ? 'Введите сообщение...'
                    : 'Тикет закрыт!'
                }
                onEnter={(value) =>
                  act('reply', { ticketNumber: number, message: value })
                }
              />
            </Stack.Item>
            {(isAdmin || isMentor) && (
              <Stack.Item>
                <TicketInteractions ticketId={number} ticketState={state} />
              </Stack.Item>
            )}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
}

function TicketMessage(props) {
  const { data } = useBackend<ManagerData>();
  const { sender, message, time } = props.message;
  const messageSender = data.userCkey === sender;

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
          <div className="ticket-message">{message}</div>
          <div className="ticket-time">{toLocalTime(time)}</div>
        </div>
      </Stack.Item>
      <Stack.Item grow />
    </Stack>
  );
}
