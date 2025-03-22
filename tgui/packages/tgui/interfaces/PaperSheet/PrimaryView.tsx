import {
  MutableRefObject,
  RefObject,
  useCallback,
  useRef,
  useState,
} from 'react';
import {
  Box,
  Button,
  Flex,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';
import { debounce } from 'tgui-core/timer';

import { useBackend } from '../../backend';
import { TEXTAREA_INPUT_HEIGHT } from './constants';
import { canEdit, getWriteButtonLocation, parseReplacements } from './helpers';
import { PreviewView } from './Preview';
import { PaperSheetStamper } from './Stamper';
import { PaperContext, PaperInput, PaperReplacement } from './types';

const replacementTokenStartRegex = /\[(\w*)$/;

// Overarching component that holds the primary view for papercode.
export function PrimaryView() {
  const [textAreaActive, setTextAreaActive] = useState(false);
  const [activeWriteButtonId, setActiveWriteButtonId] = useState('');
  const [lastDistanceFromBottom, setLastDistanceFromBottom] = useState(0);
  const [textAreaText, setTextAreaText] = useState('');
  const [textAreaTextForPreview, setTextAreaTextForPreview] = useState('');
  const [paperReplacementHint, setPaperReplacementHint] = useState<
    PaperReplacement[]
  >([]);

  const usedReplacementsRef = useRef<PaperReplacement[]>([]);
  const textAreaRef = useRef<HTMLTextAreaElement>(null);

  // Reference that gets passed to the <Section> holding the main preview.
  // Eventually gets filled with a reference to the section's scroll bar
  // funtionality.
  const scrollableRef = useRef<HTMLDivElement>(null);

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

  return (
    <>
      <PaperSheetStamper scrollableRef={scrollableRef} />
      <Flex direction="column" fillPositionedParent>
        <Flex.Item grow={3} basis={1}>
          <PreviewView
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
              paperReplacementHint={paperReplacementHint}
              setPaperReplacementHint={setPaperReplacementHint}
              textAreaRef={textAreaRef}
              setTextAreaText={setTextAreaText}
              setTextAreaTextForPreview={setTextAreaTextForPreview}
            />
          </Flex.Item>
        )}

        {writeMode &&
          (textAreaActive ? (
            <Flex.Item shrink={1} height={TEXTAREA_INPUT_HEIGHT + 'px'}>
              <TextAreaSection
                activeWriteButtonId={activeWriteButtonId}
                setActiveWriteButtonId={setActiveWriteButtonId}
                textAreaText={textAreaText}
                setTextAreaText={setTextAreaText}
                setTextAreaTextForPreview={setTextAreaTextForPreview}
                setTextAreaActive={setTextAreaActive}
                setPaperReplacementHint={setPaperReplacementHint}
                usedReplacementsRef={usedReplacementsRef}
                scrollableRef={scrollableRef}
                lastDistanceFromBottom={lastDistanceFromBottom}
                textAreaRef={textAreaRef}
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
  setTextAreaTextForPreview: (textAreaTextForPreview: string) => any;
  setTextAreaActive: (textAreaActive: boolean) => any;
  setPaperReplacementHint: (paperReplacementHint: PaperReplacement[]) => any;
  usedReplacementsRef: MutableRefObject<PaperReplacement[]>;
  scrollableRef: RefObject<HTMLDivElement>;
  lastDistanceFromBottom: number;
  textAreaRef: RefObject<HTMLTextAreaElement>;
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
    replacements,
  } = data;
  const {
    activeWriteButtonId,
    setActiveWriteButtonId,
    textAreaText,
    setTextAreaText,
    setTextAreaTextForPreview,
    setTextAreaActive,
    setPaperReplacementHint,
    scrollableRef,
    lastDistanceFromBottom,
    usedReplacementsRef,
    textAreaRef,
  } = props;

  const setTextAreaTextForPreviewWithDelayCallback = useCallback(
    debounce((text) => setTextAreaTextForPreview(text), 500),
    [],
  );

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
      usedReplacementsRef.current,
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
    setTextAreaTextForPreview('');
  }

  function getReplacementHints(): PaperReplacement[] {
    if (!textAreaRef.current) {
      return [];
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
      return [];
    }

    if (match[0] === '[') {
      return replacements.sort((a, b) => a.key.length - b.key.length);
    }

    const tokenKey = match[1];

    return replacements
      .filter((value) => value.key.startsWith(tokenKey))
      .sort((a, b) => a.key.length - b.key.length);
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
        ref={textAreaRef}
        autoFocus
        scrollbar
        noborder
        value={textAreaText}
        textColor={useColor}
        fontFamily={useFont}
        bold={useBold}
        height="100%"
        backgroundColor={paper_color}
        onKeyUp={() => {
          setPaperReplacementHint(getReplacementHints());
        }}
        onClick={() => {
          setPaperReplacementHint(getReplacementHints());
        }}
        onInput={(e, text) => {
          setTextAreaText(text);
          setTextAreaTextForPreviewWithDelayCallback(text);

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

type ReplacementHintProps = {
  paperReplacementHint: PaperReplacement[];
  setPaperReplacementHint: (paperReplacementHint: PaperReplacement[]) => any;
  textAreaRef: RefObject<HTMLTextAreaElement>;
  setTextAreaText: (textAreaText: string) => any;
  setTextAreaTextForPreview: (textAreaTextForPreview: string) => any;
};

function ReplacementHint(props: ReplacementHintProps) {
  const {
    paperReplacementHint,
    setPaperReplacementHint,
    textAreaRef,
    setTextAreaText,
    setTextAreaTextForPreview,
  } = props;

  function onHintButtonClick(buttonKey: string) {
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
  }

  return (
    <Stack vertical>
      {paperReplacementHint.map((value) => {
        return (
          <Stack.Item key={value.key}>
            <Button fluid onClick={() => onHintButtonClick(value.key)}>
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
