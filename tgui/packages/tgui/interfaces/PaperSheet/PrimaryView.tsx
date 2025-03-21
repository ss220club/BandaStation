import { RefObject, useRef, useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { TEXTAREA_INPUT_HEIGHT } from './constants';
import { canEdit, getWriteButtonLocation, parseReplacements } from './helpers';
import { PreviewView } from './Preview';
import { PaperSheetStamper } from './Stamper';
import { PaperContext, PaperInput, PaperReplacement } from './types';

// Overarching component that holds the primary view for papercode.
export function PrimaryView() {
  const [textAreaActive, setTextAreaActive] = useState(false);
  const [activeWriteButtonId, setActiveWriteButtonId] = useState('');
  const [lastDistanceFromBottom, setLastDistanceFromBottom] = useState(0);
  const [textAreaText, setTextAreaText] = useState('');
  const [parsedTextBox, setParsedTextBox] = useState('');
  const [usedReplacements, setUsedReplacements] = useState<PaperReplacement[]>(
    [],
  );
  // Reference that gets passed to the <Section> holding the main preview.
  // Eventually gets filled with a reference to the section's scroll bar
  // funtionality.
  const scrollableRef: RefObject<HTMLDivElement> = useRef(null);

  const { act, data } = useBackend<PaperContext>();
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

  return (
    <>
      <PaperSheetStamper scrollableRef={scrollableRef} />
      <Flex direction="column" fillPositionedParent>
        <Flex.Item grow={3} basis={1}>
          <PreviewView
            scrollableRef={scrollableRef}
            handleOnScroll={onScrollHandler}
            textArea={textAreaText}
            activeWriteButtonId={activeWriteButtonId}
            setActiveWriteButtonId={setActiveWriteButtonId}
            parsedTextBox={parsedTextBox}
            setParsedTextBox={setParsedTextBox}
            setTextAreaActive={setTextAreaActive}
            setUsedReplacements={setUsedReplacements}
          />
        </Flex.Item>
        {writeMode &&
          (textAreaActive ? (
            <Flex.Item shrink={1} height={TEXTAREA_INPUT_HEIGHT + 'px'}>
              <TextAreaSection
                activeWriteButtonId={activeWriteButtonId}
                setActiveWriteButtonId={setActiveWriteButtonId}
                textAreaText={textAreaText}
                setTextAreaText={setTextAreaText}
                setParsedTextBox={setParsedTextBox}
                setTextAreaActive={setTextAreaActive}
                scrollableRef={scrollableRef}
                lastDistanceFromBottom={lastDistanceFromBottom}
                usedReplacements={usedReplacements}
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

type TextAreaSectionProps = {
  activeWriteButtonId: string;
  setActiveWriteButtonId: (activeWriteButtonId: string) => any;
  textAreaText: string;
  setTextAreaText: (textAreaText: string) => any;
  setParsedTextBox: (parsedTextBox: string) => any;
  setTextAreaActive: (textAreaActive: boolean) => any;
  scrollableRef: RefObject<HTMLDivElement>;
  lastDistanceFromBottom: number;
  usedReplacements: PaperReplacement[];
};

function TextAreaSection(props: TextAreaSectionProps) {
  const { act, data } = useBackend<PaperContext>();
  const {
    raw_text_input,
    default_pen_font,
    default_pen_color,
    paper_color,
    held_item_details,
    max_length,
  } = data;
  const {
    activeWriteButtonId,
    setActiveWriteButtonId,
    textAreaText,
    setTextAreaText,
    setTextAreaActive,
    setParsedTextBox,
    scrollableRef,
    lastDistanceFromBottom,
    usedReplacements,
  } = props;

  const useFont = held_item_details?.font || default_pen_font;
  const useColor = held_item_details?.color || default_pen_color;
  const useBold = held_item_details?.use_bold || false;

  const savableData = textAreaText.length;

  const dmCharacters =
    raw_text_input?.reduce((lhs: number, rhs: PaperInput) => {
      return lhs + rhs.raw_text.length;
    }, 0) || 0;

  const usedCharacters = dmCharacters + textAreaText.length;

  const tooManyCharacters = usedCharacters > max_length;

  function onConfirmButtonClick() {
    if (!textAreaText.length) {
      return;
    }

    const textAreaTextWithReplacements = parseReplacements(
      `${textAreaText}${!activeWriteButtonId ? '<br>' : ''}`,
      usedReplacements,
    );
    const addTextData = activeWriteButtonId
      ? (() => {
          setActiveWriteButtonId('');

          const location = getWriteButtonLocation(activeWriteButtonId);
          return {
            text: textAreaTextWithReplacements,
            paper_input_ref: location.paperInputRef,
            field_id: location.fieldId + 1,
          };
        })()
      : { text: textAreaTextWithReplacements };

    act('add_text', addTextData);
    setTextAreaText('');
    setParsedTextBox('');
  }

  return (
    <Section
      fill
      fitted
      title="Вставьте текст"
      buttons={
        <>
          <Box inline pr={'5px'} color={tooManyCharacters ? 'bad' : 'default'}>
            {`${usedCharacters} / ${max_length}`}
          </Box>
          <Button.Confirm
            disabled={!savableData || tooManyCharacters}
            color="good"
            onClick={onConfirmButtonClick}
          >
            Сохранить
          </Button.Confirm>
          <Button
            iconPosition="right"
            color={'red'}
            icon={'down-long'}
            onClick={() => setTextAreaActive(false)}
          >
            Скрыть
          </Button>
        </>
      }
    >
      <TextArea
        autoFocus
        scrollbar
        noborder
        value={textAreaText}
        textColor={useColor}
        fontFamily={useFont}
        bold={useBold}
        height="100%"
        backgroundColor={paper_color}
        onInput={(e, text) => {
          setTextAreaText(text);

          if (scrollableRef.current) {
            let thisDistFromBottom =
              scrollableRef.current.scrollHeight -
              scrollableRef.current.scrollTop;
            scrollableRef.current.scrollTop +=
              thisDistFromBottom - lastDistanceFromBottom;
          }
        }}
      />
    </Section>
  );
}
