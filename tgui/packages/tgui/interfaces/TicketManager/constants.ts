export enum TICKET_STATE {
  Open = 0,
  Closed = 1,
  Resolved = 2,
}

export const availableTabs = [
  {
    name: 'Открытые',
    icon: 'envelope-open-text',
    color: 'average',
    state: TICKET_STATE.Open,
  },
  {
    name: 'Закрытые',
    icon: 'trash-can',
    color: 'good',
    state: TICKET_STATE.Closed | TICKET_STATE.Resolved,
  },
];
