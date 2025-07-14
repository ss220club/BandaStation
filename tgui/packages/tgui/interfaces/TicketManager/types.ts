import { SetStateAction } from 'jotai';
import { Dispatch } from 'react';
import { BooleanLike } from 'tgui-core/react';

export type ManagerData = {
  activeTickets: ActiveTicket[];
  closedTickets: ClosedTicket[];
};

export type ActiveTicket = {
  number: number;
  initiator: string;
  initiatorCkey: string;
  type: string;
  openedTime: string;
  closedTime: string;
  messages: Message[];
  replied: BooleanLike;
};

export type ClosedTicket = ActiveTicket & {
  state: number;
};

export type Message = {
  sender: string;
  message: string;
  time: string;
};

export type TicketProps = {
  ticket: ActiveTicket;
  setSelectedTicket: Dispatch<SetStateAction<number>>;
};
