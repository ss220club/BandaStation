import { CheckboxInput, type FeatureToggle } from '../base';

export const rds_limit: FeatureToggle = {
  name: 'Неограниченные галлюцинации',
  description:
    'Включение этого пункта снимет ограничения на галлюцинации, \
    в результате чего они станут более частыми, навязчивыми и (как правило) дурными.',
  component: CheckboxInput,
};
