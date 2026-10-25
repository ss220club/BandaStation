import { type Antagonist, Category } from '../base';

const ShadowDemon: Antagonist = {
  key: 'shadowdemon',
  name: 'Тенедемон',
  description: [
    `
      Охотьтесь из темноты, гасите источники света и притягивайте жертв
      теневой рукой. Проходите сквозь стены, нашёптывайте угрозы и
      опутывайте погибших теневыми коконами.
    `,
    `
      Во тьме вы быстрее и восстанавливаете здоровье.
      Свет обжигает вас даже в бесплотной форме.
    `,
  ],
  category: Category.Midround,
};

export default ShadowDemon;
