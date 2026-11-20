import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { TEXTAREA_INPUT_HEIGHT } from './constants';
import { PrimaryView } from './PrimaryView';
import type { PaperContext } from './types';

export function PaperSheet(props) {
  const { data } = useBackend<PaperContext>();
  const { paper_color, paper_name } = data;
  const compact = data.compact_layout && !data.held_item_details; // BANDASTATION ADDITION - Compact reading mode for fine notices.

  return (
    <Window
      title={paper_name}
      theme="paper220"
      // BANDASTATION EDIT START - Keep the full window for pens and stamps.
      width={compact ? 520 : 600}
      height={compact ? 320 : 500 + TEXTAREA_INPUT_HEIGHT}
      // BANDASTATION EDIT END
    >
      <Window.Content backgroundColor={paper_color}>
        <PrimaryView />
      </Window.Content>
    </Window>
  );
}
