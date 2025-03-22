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
    <Stack id="Paper__Hints" vertical onKeyDown={onKeyDown}>
      {paperReplacementHint.map((value, index) => {
        return (
          <Stack.Item key={index} m={0} className="Paper__Hints--hint">
            <Button
              fluid
              color="transparent"
              className="Paper__Hints--button"
              selected={index === selectedHintButtonId}
              onClick={() => onHintButtonClick(value.key)}
            >
              <Box
                className="Paper__Hints--button--content"
                dangerouslySetInnerHTML={{
                  __html: `
                    <span class='key'>[${value.key}]</span> - <span class='value'>${value.value}</span>
                    <br>
                    <span class='desc'>${value.name}</span>
                  `,
                }}
              />
            </Button>
          </Stack.Item>
        );
      })}
    </Stack>
  );
}
