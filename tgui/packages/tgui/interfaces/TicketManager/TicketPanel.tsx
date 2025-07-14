import { useEffect, useRef, useState } from 'react';
import { Button, Input, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { toLocalTime } from './helpers';
import { ManagerData } from './types';

export function TicketPanel(props) {
  const { act } = useBackend();
  const { allTickets, ticketNumber, setSelectedTicket } = props;

  const selectedTicket = allTickets.find(
    (ticket) => ticket.number === ticketNumber,
  );
  const { number, initiator, initiatorCkey, messages } = selectedTicket;

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
    <Stack fill vertical g={0}>
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
          <Input
            fluid
            autoFocus
            selfClear
            placeholder="Введите сообщение..."
            onEnter={(value) =>
              act('reply', { ticketNumber: number, message: value })
            }
          />
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
