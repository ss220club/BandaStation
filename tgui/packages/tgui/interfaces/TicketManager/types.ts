import { Dispatch } from 'react';
import { BooleanLike } from 'tgui-core/react';

export type ManagerData = {
  ticketToOpen: number;
  userKey: string;
  isAdmin: BooleanLike;
  isMentor: BooleanLike;
  allTickets: TicketProps[];
};

export type TicketProps = {
  number: number;
  state: number;
  initiator: string;
  initiatorCkey: string;
  type: string;
  openedTime: string;
  closedTime: string;
  writers: string[];
  adminReplied: BooleanLike;
  initiatorReplied: BooleanLike;
  messages: MessageProps[];
};

export type MessageProps = {
  sender: string;
  message: string;
  time: string;
};

export type TicketsMainPageProps = {
  allTickets: TicketProps[];
  setSelectedTicket: Dispatch<number>;
};
