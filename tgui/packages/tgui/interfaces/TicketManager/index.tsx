import { useState } from 'react';
import {
  Button,
  Input,
  Modal,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { availableTabs, TICKET_STATE } from './constants';
import { toLocalTime } from './helpers';
import { ActiveTicket, ManagerData, TicketProps } from './types';

export function TicketManager() {
  const { data } = useBackend<ManagerData>();
  const { activeTickets, closedTickets } = data;
  const [selectedTab, setSelectedTab] = useState(TICKET_STATE.Open);
  const [selectedTicket, setSelectedTicket] = useState<number | null>();

  return (
    <Window title="Ticket Manager" theme="ss220" width={700} height={600}>
      <Window.Content>
        {selectedTicket && (
          <TicketModal
            activeTickets={activeTickets}
            ticketNumber={selectedTicket}
            setSelectedTicket={setSelectedTicket}
          />
        )}
        <Stack fill vertical>
          <Stack.Item>
            <Tabs fluid textAlign="center">
              {availableTabs.map((tab) => (
                <Tabs.Tab
                  key={tab.name}
                  icon={tab.icon}
                  color={tab.color}
                  selected={selectedTab === tab.state}
                  onClick={() => setSelectedTab(tab.state)}
                >
                  {tab.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable>
              <Stack vertical>
                {activeTickets.map((ticket: ActiveTicket) => (
                  <Ticket
                    key={ticket.number}
                    ticket={ticket}
                    setSelectedTicket={setSelectedTicket}
                  />
                ))}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

function Ticket(props: TicketProps) {
  const { ticket, setSelectedTicket } = props;
  const { number, type, initiator, openedTime, messages } = ticket;

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

function TicketModal(props) {
  const { act } = useBackend();
  const { activeTickets, ticketNumber, setSelectedTicket } = props;

  const [newMessage, setNewMessage] = useState('');
  const selectedTicket = activeTickets.find((t) => t.number === ticketNumber);
  const { number, initiator, initiatorCkey, messages } = selectedTicket;

  return (
    <Modal width="95vw" height="90vh">
      <Section
        fill
        title={`Тикет #${number} - ${initiator}`}
        buttons={
          <Button
            color="red"
            icon="times"
            onClick={() => setSelectedTicket(false)}
          />
        }
      >
        <Stack fill vertical>
          <Stack.Item grow>
            <Stack vertical>
              {messages.map((message) => (
                <TicketMessage
                  key={message.time}
                  initiatorCkey={initiatorCkey}
                  message={message}
                />
              ))}
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Input
              fluid
              placeholder="Введите сообщение..."
              value={newMessage}
              onChange={setNewMessage}
              onEnter={(value) => {
                setNewMessage('');
                act('reply', {
                  ticketNumber: number,
                  sender: 'Admin',
                  message: value,
                });
              }}
            />
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
}

function TicketMessage(props) {
  const { sender, message, time } = props.message;
  const reply = sender !== props.initiatorCkey;

  return (
    <Stack fill reverse={reply} className="TicketMessage__Wrapper">
      <Stack.Item
        className={classes(['TicketMessage', reply && 'TicketMessage--reply'])}
      >
        <div className="TicketMessage__Sender">{sender}</div>
        <div className="TicketMessage__Content">{message}</div>
        <div className="TicketMessage__Time">{toLocalTime(time)}</div>
      </Stack.Item>
      <Stack.Item grow />
    </Stack>
  );
}
