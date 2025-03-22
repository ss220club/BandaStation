import { KeyboardEvent } from 'react';
import { Box, Button, Stack } from 'tgui-core/components';

import { PaperReplacement } from './types';

type ReplacementHintProps = {
  paperReplacementHint: PaperReplacement[];
  selectedHintButtonId: number;
  onKeyDown: (event: KeyboardEvent<HTMLDivElement>) => void;
  onHintButtonClick: (buttonKey: string) => void;
};

export function ReplacementHint(props: ReplacementHintProps) {
  const {
    paperReplacementHint,
    selectedHintButtonId,
    onKeyDown,
    onHintButtonClick,
  } = props;

  return (
    <Stack vertical onKeyDown={onKeyDown}>
      {paperReplacementHint.map((value, index) => {
        return (
          <Stack.Item key={index}>
            <Button
              fluid
              selected={index === selectedHintButtonId}
              onClick={() => onHintButtonClick(value.key)}
            >
              <Box
                dangerouslySetInnerHTML={{
                  __html: `${value.key} [${value.name}] - ${value.value}`,
                }}
              />
            </Button>
          </Stack.Item>
        );
      })}
    </Stack>
  );
}
