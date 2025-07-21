import { useLocalStorage } from '@uidotdev/usehooks';
import { useState } from 'react';
import { Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { TICKET_STATE } from './constants';
import { Ticket } from './Ticket';
import { TicketPanel } from './TicketPanel';
import { ManagerData, TicketProps, TicketsMainPageProps } from './types';

export function TicketManager() {
  const { data } = useBackend<ManagerData>();
  const { allTickets, isAdmin, isMentor, ticketToOpen } = data;
  const [selectedTicket, setSelectedTicket] = useState<number | null>(
    ticketToOpen,
  );
  const userUsing = isAdmin ? 'Админ' : isMentor ? 'Ментор' : 'Игрок';

  return (
    <Window
      title={`Менеджер тикетов - ${userUsing}`}
      theme="ss220"
      width={550}
      height={750}
    >
      <Window.Content>
        {selectedTicket ? (
          <TicketPanel
            allTickets={allTickets}
            ticketNumber={selectedTicket}
            setSelectedTicket={setSelectedTicket}
          />
        ) : (
          <TicketsMainPage
            allTickets={allTickets}
            setSelectedTicket={setSelectedTicket}
          />
        )}
      </Window.Content>
    </Window>
  );
}

function TicketsMainPage(props: TicketsMainPageProps) {
  const { allTickets, setSelectedTicket } = props;
  const [selectedTab, setSelectedTab] = useLocalStorage(
    'ticketManagerTab',
    TICKET_STATE.Open,
  );

  const openTickets = allTickets.filter(
    (ticket: TicketProps) => ticket.state === TICKET_STATE.Open,
  );
  const closedTickets = allTickets.filter(
    (ticket: TicketProps) =>
      ticket.state === TICKET_STATE.Closed ||
      ticket.state === TICKET_STATE.Resolved,
  );
  const selectedTickets =
    selectedTab === TICKET_STATE.Open ? openTickets : closedTickets;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Tabs fluid textAlign="center">
          <Tabs.Tab
            icon="envelope-open-text"
            color="average"
            selected={selectedTab === TICKET_STATE.Open}
            onClick={() => setSelectedTab(TICKET_STATE.Open)}
          >
            Открытые ({allTickets.length - closedTickets.length})
          </Tabs.Tab>
          <Tabs.Tab
            icon="trash-can"
            color="good"
            selected={selectedTab === TICKET_STATE.Closed}
            onClick={() => setSelectedTab(TICKET_STATE.Closed)}
          >
            Закрытые ({closedTickets.length})
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          <Stack vertical reverse>
            {selectedTickets.map((ticket: TicketProps) => (
              <Ticket
                key={ticket.number}
                setSelectedTicket={setSelectedTicket}
                {...ticket}
              />
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
}
