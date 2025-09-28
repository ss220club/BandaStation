import { useBackend } from '../../backend';
import { Button } from 'tgui-core/components';
import { Window } from '../../layouts';
import { TEXTAREA_INPUT_HEIGHT } from './constants';
import { PrimaryView } from './PrimaryView';
import type { PaperContext } from './types';

export function PaperSheet() {
  const { data, act } = useBackend<PaperContext>();
  const {
    paper_color,
    paper_name,
    current_side,
    is_stack,
    stack_page_index,
    stack_page_count,
    can_prev,
    can_next,
  } = data as any;

  const pageIndex = Number(stack_page_index ?? 1);
  const pageCount = Number(stack_page_count ?? 1);
  const onStack = Boolean(is_stack);

  // для одиночного листа current_side: 'front' | 'back'
  const sideLabel = current_side === 'back' ? 'Back' : 'Front';

  return (
    <Window
      title={paper_name}
      theme="paper220"
      width={600}
      height={500 + TEXTAREA_INPUT_HEIGHT}
      buttons={
        onStack ? (
          <>
            <Button
              icon="angle-left"
              tooltip="Previous page"
              disabled={can_prev === false || pageIndex <= 1}
              onClick={() => act('stack_prev')}
            />
            <span style={{ margin: '0 8px' }}>
              {pageIndex} / {pageCount}
            </span>
            <Button
              icon="angle-right"
              tooltip="Next page"
              disabled={can_next === false || pageIndex >= pageCount}
              onClick={() => act('stack_next')}
            />
            <Button
              ml={1}
              icon="file-export"
              tooltip="Remove the sheet for this page"
              onClick={() => act('remove_paper_current')}
            />
          </>
        ) : (
          <Button
            className="Paper__FlipBtn"
            icon="file-lines"
            iconPosition="right"
            onClick={() => act('flip_side')}
          >
            {`Paper: ${sideLabel}`}
          </Button>
        )
      }
    >
      <Window.Content backgroundColor={paper_color}>
        <PrimaryView />
      </Window.Content>
    </Window>
  );
}
