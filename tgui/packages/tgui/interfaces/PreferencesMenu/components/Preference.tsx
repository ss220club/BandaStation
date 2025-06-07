import { ReactNode } from 'react';
import { Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

type PreferenceProps = {
  id: string;
  name?: string;
  description?: string;
  childrenClassName?: string;
  children: ReactNode;
};

export function Preference(props: PreferenceProps) {
  const { id, name, description, childrenClassName, children } = props;
  const className = 'PreferencesMenu__Preference';

  return (
    <Stack key={id} className={className}>
      <Stack.Item grow>
        <Stack vertical g={0}>
          <Stack.Item className={`${className}--name`}>{name || id}</Stack.Item>
          {description && (
            <Stack.Item className={`${className}--desc`}>
              {description}
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
      <Stack
        className={classes([
          `${className}--control`,
          `${className}--${childrenClassName || 'Preferences'}`,
        ])}
      >
        {children}
      </Stack>
    </Stack>
  );
}
