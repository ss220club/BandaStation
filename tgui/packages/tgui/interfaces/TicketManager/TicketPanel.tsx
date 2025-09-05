import { useEffect, useRef, useState } from 'react';
import { Button, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { ChatInput } from '../common/ChatInput';
import { TICKET_STATE, TYPING_TIMEOUT } from './constants';
import { TicketAdminInteractions, TicketInteractions } from './Ticket';
import { TicketMessage } from './TicketMessage';
import { TicketPanelEmbed } from './TicketPanelEmbed';
import { TicketPanelEmoji } from './TicketPanelEmoji';
import type { ManagerData } from './types';

export function TicketPanel(props) {
  const { act, data } = useBackend<ManagerData>();
  const { userKey, isAdmin, isMentor, maxMessageLength, replyCooldown } = data;
  const { allTickets, ticketNumber, setSelectedTicket } = props;

  const selectedTicket = allTickets.find(
    (ticket) => ticket.number === ticketNumber,
  );
  const {
    number,
    initiator,
    initiatorCkey,
    messages,
    state,
    type,
    linkedAdmin,
    writers,
  } = selectedTicket;

  const ticketOpen = state === TICKET_STATE.Open;

  const [inputMessage, setInputMessage] = useState('');
  const [showScrollButton, setShowScrollButton] = useState(false);

  const sectionRef = useRef<HTMLDivElement>(null);
  const shouldScrollRef = useRef(true);
  const firstRender = useRef(true);

  const typingTimeoutRef = useRef<NodeJS.Timeout>(null);
  const isWritingRef = useRef(false);

  function handleTyping() {
    if (!isWritingRef.current) {
      act('start_writing', { ticketId: number });
      isWritingRef.current = true;
    }

    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }

    typingTimeoutRef.current = setTimeout(() => {
      act('stop_writing', { ticketId: number });
      isWritingRef.current = false;
    }, TYPING_TIMEOUT);
  }

  function handleEnter(value: string) {
    if (isWritingRef.current) {
      isWritingRef.current = false;
    }

    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current);
    }

    act('reply', { ticketId: number, message: value });
    setInputMessage('');
  }

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
      <Stack.Item>
        <Section
          fitted={!isAdmin}
          title={
            <Stack fill align="center">
              <Stack.Item fontSize={1}>
                <Button
                  icon="arrow-left"
                  onClick={() => setSelectedTicket(false)}
                />
              </Stack.Item>
              <Stack.Item grow className="TicketPanel__Title">
                Тикет #{number} - {initiator}
              </Stack.Item>
              {(isAdmin || isMentor) && (
                <Stack.Item>
                  <TicketInteractions
                    linkedAdmin={linkedAdmin}
                    ticketId={number}
                    ticketState={state}
                  />
                </Stack.Item>
              )}
            </Stack>
          }
        >
          {!!isAdmin && <TicketAdminInteractions ticketId={number} />}
        </Section>
      </Stack.Item>
      {!!isAdmin && <Stack.Divider />}
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
        <Section ref={sectionRef} fill scrollable>
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
          <TypingIndicator writers={writers} userKey={userKey} />
          <ChatInput
            value={inputMessage}
            placeholder={ticketOpen ? 'Введите сообщение...' : 'Тикет закрыт!'}
            maxLength={maxMessageLength}
            cooldown={!isAdmin && !isMentor && replyCooldown}
            disabled={!ticketOpen || (!isAdmin && !linkedAdmin)}
            onChange={(value) => {
              setInputMessage(value);
              handleTyping();
            }}
            onEnter={handleEnter}
            buttons={
              <>
                <TicketPanelEmbed
                  insertEmbed={(embed) => {
                    setInputMessage((prev) => prev + embed);
                  }}
                />
                <TicketPanelEmoji
                  insertEmoji={(emoji) => {
                    setInputMessage((prev) => prev + emoji);
                  }}
                />
              </>
            }
          />
        </Section>
      </Stack.Item>
    </Stack>
  );
}

function TypingIndicator(props) {
  const { writers, userKey } = props;
  const others = writers.filter((writer) => writer !== userKey);

  let writersText;
  if (others.length === 1) {
    writersText = `${others[0]} печатает...`;
  }

  if (others.length === 2) {
    writersText = `${others[0]} и ${others[1]} печатают...`;
  }

  if (others.length > 2) {
    writersText = 'Несколько человек печатают...';
  }

  return (
    others.length > 0 && (
      <Stack className="TicketPanel__Writers">
        <Stack className="TicketPanel__Writers--indicator" g={0.5}>
          <div />
          <div />
          <div />
        </Stack>
        <Stack.Item grow> {writersText} </Stack.Item>
      </Stack>
    )
  );
}
