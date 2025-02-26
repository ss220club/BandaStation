export const getConditionColor = (condition) => {
  switch (condition) {
    case 'Живой':
      return 'green';
    case 'Без сознания':
      return 'yellow';
    case 'В крите':
      return 'orange';
    case 'Мёртв':
      return 'red';
    case 'Наблюдает':
      return 'grey';
    default:
      return '';
  }
};

export const getPingColor = (ping) => {
  switch (true) {
    case ping < 100:
      return 'green';
    case ping > 100:
      return 'orange';
    case ping > 220:
      return 'red';
    default:
      return '';
  }
};
