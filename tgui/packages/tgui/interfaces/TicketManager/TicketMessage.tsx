import { createElement, ReactNode } from 'react';
import { Box, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { CONNECTED, DISCONNECTED, TICKET_LOG } from './constants';
import { toLocalTime } from './helpers';
import { ManagerData } from './types';

function splitMessage(message: string) {
  const wrapper = document.createElement('div');
  wrapper.innerHTML = message;

  const textParts: string[] = [];
  const blockElements: ReactNode[] = [];
  for (const node of Array.from(wrapper.childNodes)) {
    if (node.nodeType === Node.TEXT_NODE) {
      textParts.push(node.textContent || '');
    } else if (
      node.nodeType === Node.ELEMENT_NODE &&
      isInlineTag((node as HTMLElement).tagName.toLowerCase())
    ) {
      textParts.push((node as HTMLElement).outerHTML);
    } else if (node.nodeType === Node.ELEMENT_NODE) {
      const element = node as HTMLElement;
      const props: Record<string, any> = {};
      for (const attribute of Array.from(element.attributes)) {
        props[attribute.name] = attribute.value;
      }
      blockElements.push(createElement(element.tagName.toLowerCase(), props));
    }
  }

  return {
    textElements: textParts.length > 0 && (
      <Box as="span" dangerouslySetInnerHTML={{ __html: textParts.join('') }} />
    ),
    blockElements: blockElements,
  };
}

function isInlineTag(tag: string): boolean {
  return [
    'b',
    'i',
    'u',
    'span',
    'a',
    'strong',
    'em',
    'small',
    'abbr',
    'code',
    'br',
  ].includes(tag);
}

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

  const { textElements, blockElements } = splitMessage(message);
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
          {blockElements.length > 0 && (
            <div className="TicketMessage__Embed">{blockElements}</div>
          )}
          {textElements}
          <div className="ticket-time">{toLocalTime(time)}</div>
        </div>
      </Stack.Item>
      <Stack.Item grow />
    </Stack>
  );
}
