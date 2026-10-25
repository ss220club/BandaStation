import { Box } from 'tgui-core/components';

import type { Feature, FeatureChoicedServerData } from '../base';
import { FeatureDropdownInput } from '../dropdowns';

type SkrellCasteServerData = FeatureChoicedServerData & {
  descriptions: Record<string, string>;
};

export const skrell_caste: Feature<string, string, SkrellCasteServerData> = {
  name: 'Каста',
  component: (props) => (
    <>
      <FeatureDropdownInput {...props} />
      <Box mt={1} style={{ whiteSpace: 'pre-wrap' }}>
        {props.serverData?.descriptions[props.value]}
      </Box>
      <Box mt={1} color="label">
        Каста наследуется и не зависит от культуры воспитания.
      </Box>
    </>
  ),
};
