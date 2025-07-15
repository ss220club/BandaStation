import { Dispatch } from 'react';
import { BooleanLike } from 'tgui-core/react';

export type ManagerData = {
  userCkey: string;
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
  messages: MessageProps[];
  replied: BooleanLike;
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
