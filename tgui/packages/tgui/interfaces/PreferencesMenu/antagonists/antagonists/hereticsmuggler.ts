import { type Antagonist, Category } from '../base';
import { HERETIC_MECHANICAL_DESCRIPTION } from './heretic';

const HereticSmuggler: Antagonist = {
  key: 'hereticsmuggler',
  name: 'Еретик-контрабандист',
  description: [
    'Вариант еретика, который можно получить при прибытии на смену.',
    HERETIC_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Latejoin,
};

export default HereticSmuggler;
