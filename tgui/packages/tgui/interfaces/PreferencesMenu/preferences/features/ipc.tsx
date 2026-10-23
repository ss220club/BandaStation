import {
  type Feature,
  type FeatureChoiced,
  type FeatureChoicedServerData,
  FeatureColorInput,
} from './base';
import { FeatureDropdownInput } from './dropdowns';

export const ipc_chassis: FeatureChoiced = {
  name: 'КПБ — корпус',
  component: FeatureDropdownInput,
};

export const ipc_head: FeatureChoiced = {
  name: 'КПБ — голова',
  component: FeatureDropdownInput,
};

type IpcDisplayData = FeatureChoicedServerData & {
  choices_by_head: Record<string, string[]>;
};

export const ipc_screen: Feature<string, string, IpcDisplayData> = {
  name: 'КПБ — дисплей / оптика',
  component: (props) => {
    const { serverData, character_preferences } = props;
    const head = character_preferences.secondary_features.ipc_head;
    const choices =
      serverData && typeof head === 'string'
        ? serverData.choices_by_head[head] || []
        : [];
    return (
      <FeatureDropdownInput
        {...props}
        serverData={serverData ? { ...serverData, choices } : undefined}
      />
    );
  },
};

export const ipc_antenna: FeatureChoiced = {
  name: 'КПБ — головной аксессуар',
  component: FeatureDropdownInput,
};

export const ipc_chassis_color: Feature<string> = {
  name: 'КПБ — оттенок корпуса',
  component: FeatureColorInput,
};

export const ipc_screen_color: Feature<string> = {
  name: 'КПБ — основной цвет дисплея',
  component: FeatureColorInput,
};

export const ipc_screen_color_secondary: Feature<string> = {
  name: 'КПБ — цвет переднего плана дисплея',
  component: FeatureColorInput,
};

export const ipc_antenna_color: Feature<string> = {
  name: 'КПБ — цвет головного аксессуара',
  component: FeatureColorInput,
};
