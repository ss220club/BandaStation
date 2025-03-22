import { KeyboardEvent, useRef, useState } from 'react';
import { Button, Flex, Stack } from 'tgui-core/components';
import { KEY } from 'tgui-core/keys';

import { useBackend } from '../../backend';
import { replacementTokenStartRegex, TEXTAREA_INPUT_HEIGHT } from './constants';
import { canEdit } from './helpers';
import { PreviewView } from './Preview';
import { ReplacementHint } from './ReplacementHint';
import { PaperSheetStamper } from './Stamper';
import { TextAreaSection } from './TextAreaSection';
import { PaperContext, PaperReplacement } from './types';

// Overarching component that holds the primary view for papercode.
export function PrimaryView() {
  const [textAreaActive, setTextAreaActive] = useState(false);
  const [textAreaText, setTextAreaText] = useState('');
  const [textAreaTextForPreview, setTextAreaTextForPreview] = useState('');
  const [activeWriteButtonId, setActiveWriteButtonId] = useState('');
  const [selectedHintButtonId, setSelectedHintButtonId] = useState(0);
  const [paperReplacementHint, setPaperReplacementHint] = useState<
    PaperReplacement[]
  >([]);
  const [lastDistanceFromBottom, setLastDistanceFromBottom] = useState(0);

  // Reference that gets passed to the <Section> holding the main preview.
  // Eventually gets filled with a reference to the section's scroll bar
  // funtionality.
  const scrollableRef = useRef<HTMLDivElement>(null);
  const usedReplacementsRef = useRef<PaperReplacement[]>([]);
  const textAreaRef = useRef<HTMLTextAreaElement>(null);

  const { data } = useBackend<PaperContext>();
  const { held_item_details } = data;
  const writeMode = canEdit(held_item_details);

  // Event handler for the onscroll event. Also gets passed to the <Section>
  // holding the main preview. Updates lastDistanceFromBottom.
  function onScrollHandler(this: GlobalEventHandlers, ev: Event) {
    const scrollable = ev.currentTarget as HTMLDivElement;
    if (scrollable) {
      setLastDistanceFromBottom(scrollable.scrollHeight - scrollable.scrollTop);
    }
  }

  function applyReplacement(buttonKey: string) {
    if (!textAreaRef?.current) {
      return;
    }

    const textAreaValue = textAreaRef.current.value;
    const selectionStart = textAreaRef.current.selectionStart;
    if (!textAreaValue || !selectionStart) {
      return [];
    }

    const match = textAreaValue
      .substring(0, selectionStart)
      .match(replacementTokenStartRegex);

    if (!match) {
      return;
    }

    const matchedText = match[0];
    const matchIndex = match.index;
    if (matchIndex === undefined) {
      return;
    }

    const updatedTextArea =
      textAreaValue.slice(0, matchIndex) +
      `[${buttonKey}]` +
      textAreaValue.slice(matchIndex + matchedText.length);

    setTextAreaText(updatedTextArea);
    setTextAreaTextForPreview(updatedTextArea);
    setPaperReplacementHint([]);
    setSelectedHintButtonId(0);
  }

  function handleKeyDown(event: KeyboardEvent<HTMLDivElement>): void {
    switch (event.key) {
      case KEY.Up:
      case KEY.Down:
        handleArrowKeys(event.key);
        event.preventDefault();
        break;
      case KEY.Enter:
        handleEnterKey();
        event.preventDefault();
        break;
    }
  }

  function handleArrowKeys(key: KEY.Up | KEY.Down) {
    if (key === KEY.Up) {
      setSelectedHintButtonId((id) => Math.max(id - 1, 0));
    } else {
      setSelectedHintButtonId((id) => Math.min(id - 1, 0));
    }
  }

  function handleEnterKey() {}

  return (
    <>
      <PaperSheetStamper scrollableRef={scrollableRef} />
      <Flex direction="column" fillPositionedParent>
        <Flex.Item grow={3} basis={1}>
          <PreviewView
            paperContext={data}
            scrollableRef={scrollableRef}
            handleOnScroll={onScrollHandler}
            activeWriteButtonId={activeWriteButtonId}
            setActiveWriteButtonId={setActiveWriteButtonId}
            textAreaTextForPreview={textAreaTextForPreview}
            setTextAreaActive={setTextAreaActive}
            usedReplacementsRef={usedReplacementsRef}
          />
        </Flex.Item>
        {paperReplacementHint.length > 0 && (
          <Flex.Item>
            <ReplacementHint
              onKeyDown={handleKeyDown}
              paperReplacementHint={paperReplacementHint}
              selectedHintButtonId={selectedHintButtonId}
              onHintButtonClick={applyReplacement}
            />
          </Flex.Item>
        )}

        {writeMode &&
          (textAreaActive ? (
            <Flex.Item shrink={1} height={TEXTAREA_INPUT_HEIGHT + 'px'}>
              <TextAreaSection
                paperContext={data}
                textAreaText={textAreaText}
                activeWriteButtonId={activeWriteButtonId}
                lastDistanceFromBottom={lastDistanceFromBottom}
                usedReplacementsRef={usedReplacementsRef}
                textAreaRef={textAreaRef}
                scrollableRef={scrollableRef}
                handleTextAreaKeyDown={handleKeyDown}
                setTextAreaText={setTextAreaText}
                setTextAreaActive={setTextAreaActive}
                setTextAreaTextForPreview={setTextAreaTextForPreview}
                setPaperReplacementHint={setPaperReplacementHint}
                setActiveWriteButtonId={setActiveWriteButtonId}
              />
            </Flex.Item>
          ) : (
            <Flex.Item>
              <Stack reverse>
                <Stack.Item>
                  <Button
                    align={'right'}
                    iconPosition="right"
                    icon={'up-long'}
                    onClick={() => setTextAreaActive(true)}
                  >
                    Открыть редактор
                  </Button>
                </Stack.Item>
              </Stack>
            </Flex.Item>
          ))}
      </Flex>
    </>
  );
}
