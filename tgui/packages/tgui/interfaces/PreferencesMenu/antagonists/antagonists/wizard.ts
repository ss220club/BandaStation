import { multiline } from 'common/string';

import { Antagonist, Category } from '../base';

export const WIZARD_MECHANICAL_DESCRIPTION = multiline`
      Выбирайте из множества мощных заклинаний, чтобы вызвать хаос
      на космической станции 13.
    `;

const Wizard: Antagonist = {
  key: 'wizard',
  name: 'Маг',
  description: [
    `"GREETINGS. WE'RE THE WIZARDS OF THE WIZARD'S FEDERATION."`,
    WIZARD_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Wizard;
