import { Dispatch } from 'react';
import { BooleanLike } from 'tgui-core/react';

export type ManagerData = {
  emojis: Record<string, null>; // That's FUCKING CURSED SHIT
  userKey: string;
  ticketToOpen: number;
  maxMessageLength: number;
  replyCooldown: number;
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
  linkedAdmin: string;
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
