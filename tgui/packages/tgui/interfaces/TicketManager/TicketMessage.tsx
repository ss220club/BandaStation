import DOMPurify from 'dompurify';
import { createElement, type ReactNode } from 'react';
import { Box, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { CONNECTED, DISCONNECTED, TICKET_LOG } from './constants';
import { toLocalTime } from './helpers';
import type { ManagerData, MessageProps } from './types';

function splitMessage(message: string) {
  const clean = DOMPurify.sanitize(message, {
    ALLOWED_TAGS: [
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
      'audio',
      'img',
    ],
    ALLOWED_ATTR: [
      'href',
      'src',
      'alt',
      'title',
      'controls',
      'type',
      'rel',
      'target',
      'class',
    ],
  });

  const wrapper = document.createElement('div');
  wrapper.innerHTML = clean;

  // Text nodes must stay inside the sanitized markup: textContent decodes
  // entities, and re-inserting it as HTML turns escaped text back into tags.
  let blockElement: ReactNode = null;
  for (const element of Array.from(wrapper.children)) {
    const tagName = element.tagName.toLowerCase();
    if (isInlineTag(tagName)) {
      continue;
    }

    if (!blockElement) {
      const props: Record<string, string> = {};
      for (const attribute of Array.from(element.attributes)) {
        props[attribute.name] = attribute.value;
      }
      blockElement = createElement(tagName, props);
    }
    element.remove();
  }

  return {
    textElements: wrapper.hasChildNodes() && (
      <Box as="span" dangerouslySetInnerHTML={{ __html: wrapper.innerHTML }} />
    ),
    blockElement,
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

type TicketMessageProps = {
  hasStaffAccess: boolean;
  messageHolder: MessageProps;
};

export function TicketMessage(props: TicketMessageProps) {
  const { data } = useBackend<ManagerData>();
  const { userKey } = data;
  const { messageHolder, hasStaffAccess } = props;
  const { sender, message, time } = messageHolder;

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
      hasStaffAccess && (
        <Stack fill className="TicketMessage TicketMessage__Log">
          <div className="ticket-message">{message}</div>
          <div className="ticket-time">{toLocalTime(time)}</div>
        </Stack>
      )
    );
  }

  const { textElements, blockElement } = splitMessage(message);
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
          {blockElement && (
            <div className="TicketMessage__Embed">{blockElement}</div>
          )}
          {textElements}
          <div className="ticket-time">{toLocalTime(time)}</div>
        </div>
      </Stack.Item>
      <Stack.Item grow />
    </Stack>
  );
}
