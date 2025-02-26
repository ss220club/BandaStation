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
