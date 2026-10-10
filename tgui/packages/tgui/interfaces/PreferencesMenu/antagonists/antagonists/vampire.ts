import { type Antagonist, Category } from '../base';

const Vampire: Antagonist = {
  key: 'vampire',
  name: 'Вампир',
  description: [
    `
      Утолите жажду, высасывая кровь из живых жертв, чтобы развить
      сверхъестественные способности. Избегайте солнечного света и
      отдыхайте в гробу, чтобы восстановиться.
    `,
  ],
  category: Category.Roundstart,
};

export default Vampire;
