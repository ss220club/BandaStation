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
    name: 'Решённые',
    icon: 'circle-check',
    color: 'good',
    state: TICKET_STATE.Resolved,
  },
  {
    name: 'Закрытые',
    icon: 'trash-can',
    color: 'bad',
    state: TICKET_STATE.Closed,
  },
];
