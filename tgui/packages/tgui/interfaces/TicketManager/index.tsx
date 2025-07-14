import { useState } from 'react';
import { Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { availableTabs, TICKET_STATE } from './constants';
import { Ticket } from './Ticket';
import { TicketPanel } from './TicketPanel';
import { ManagerData, TicketProps, TicketsMainPageProps } from './types';

export function TicketManager() {
  const { data } = useBackend<ManagerData>();
  const { allTickets } = data;
  const [selectedTicket, setSelectedTicket] = useState<number | null>();

  return (
    <Window title="Ticket Manager" theme="ss220" width={550} height={650}>
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
  const [selectedTab, setSelectedTab] = useState(TICKET_STATE.Open);

  return (
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
            {allTickets.map((ticket: TicketProps) => (
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
