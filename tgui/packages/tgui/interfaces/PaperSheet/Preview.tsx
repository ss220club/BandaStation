import { Marked } from 'marked';
import { markedSmartypants } from 'marked-smartypants';
import { RefObject, useCallback, useEffect, useMemo, useRef } from 'react';
import { Box, Section } from 'tgui-core/components';
import { debounce } from 'tgui-core/timer';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import { createLogger } from '../../logging';
import { sanitizeText } from '../../sanitize';
import {
  canEdit,
  createWriteButtonId,
  parseReplacements,
  tokenizer,
  walkTokens,
} from './helpers';
import { StampView } from './StampView';
import { PaperContext, PaperInput, PaperReplacement } from './types';

const SPECIAL_TOKENS = {
  nt_logo: (value: string) => {
    const matchArray = value.match(propRegex('width'));
    const widthValue = matchArray ? matchArray[1] : '';
    return `<img src='${resolveAsset('ntlogo.png')}' ${widthValue && `width='${widthValue}`}'>`;
  },
  syndie_logo: (value: string) => {
    const matchArray = value.match(propRegex('width'));
    const widthValue = matchArray ? matchArray[1] : '';
    return `<img src='${resolveAsset('syndielogo.png')}' ${widthValue && `width='${widthValue}`}'>`;
  },
};

function propRegex(propName: string) {
  return new RegExp(`${propName}=([a-zA-Z0-9]+)`, 'i');
}

type PreviewViewProps = {
  scrollableRef: RefObject<HTMLDivElement>;
  handleOnScroll: (this: GlobalEventHandlers, ev: Event) => any;
  textArea: string;
  activeWriteButtonId: string;
  setActiveWriteButtonId: (activeWriteButtonId: string) => any;
  parsedTextBox: string;
  setParsedTextBox: (activeWriteButtonId: string) => any;
  setTextAreaActive: (textAreaActive: boolean) => any;
  setUsedReplacements: (usedReplacements: PaperReplacement[]) => any;
};

// Regex that finds [input_field] fields.
const fieldRegex: RegExp = /\[input_field\]/gi;
const childInputRegex: RegExp = /\[child_(\d+)\]/gi;
const specialTokenRegex: RegExp = /\[(\w+)(?:\s+(?:\w+=\w+))*\]/gi;

/**
 * Real-time text preview section. When not editing, this is simply
 * the component that builds and renders the final HTML output.
 * It parses and sanitises the DM-side raw input and field input data once on
 * creation.
 * It caches writable input fields as a form of state management.
 * This component should be used with a `key` prop that changes
 * when DM-side raw input or field input data have changed.
 * We currently do this by keying the component based on the lengths of the
 * raw and field input arrays.
 */
export function PreviewView(props: PreviewViewProps) {
  const logger = createLogger('PaperPreview');

  const {
    scrollableRef,
    handleOnScroll,
    textArea,
    activeWriteButtonId,
    setActiveWriteButtonId,
    parsedTextBox,
    setParsedTextBox,
    setTextAreaActive,
    setUsedReplacements,
  } = props;

  const { data } = useBackend<PaperContext>();
  const {
    raw_text_input,
    default_pen_font,
    default_pen_color,
    held_item_details,
    advanced_html_user,
    paper_color,
    replacements,
  } = data;

  const editMode = canEdit(held_item_details);
  const fontFace = held_item_details?.font || default_pen_font;
  const fontColor = held_item_details?.color || default_pen_color;
  const fontBold = held_item_details?.use_bold || false;
  const marked = createAndConfigureMarked();
  const parsedDmText = useMemo(
    () =>
      createPreviewFromDM(raw_text_input, default_pen_font, default_pen_color),
    [raw_text_input, default_pen_font, default_pen_color, editMode],
  );

  const oldParseTextBoxDataPropsRef = useRef({
    textArea: textArea,
    fontFace: fontFace,
    fontColor: fontColor,
    fontBold: fontBold,
    advancedHtmlUser: advanced_html_user,
  });

  const parseTextBoxDataCallback = useCallback(
    debounce((textArea, fontFace, fontColor, fontBold, advancedHtmlUser) => {
      setParsedTextBox(
        parseReplacements(
          formatAndProcessRawText(
            textArea,
            fontFace,
            fontColor,
            fontBold,
            advancedHtmlUser,
          ),
          replacements,
        ),
      );
      setUsedReplacements(replacements);
    }, 500),
    [],
  );

  const newParseTextBoxDataProps = {
    textArea: textArea,
    fontFace: fontFace,
    fontColor: fontColor,
    fontBold: fontBold,
    advancedHtmlUser: advanced_html_user,
  };

  if (
    JSON.stringify(oldParseTextBoxDataPropsRef.current) !==
    JSON.stringify(newParseTextBoxDataProps)
  ) {
    oldParseTextBoxDataPropsRef.current = newParseTextBoxDataProps;
    parseTextBoxDataCallback(
      textArea,
      fontFace,
      fontColor,
      fontBold,
      advanced_html_user,
    );
  }

  // Wraps the given raw text in a font span based on the supplied props.
  function setFontInText(
    text: string,
    font: string,
    color: string,
    bold: boolean = false,
  ): string {
    return `<span style="color:${color};font-family:${font};${
      bold ? 'font-weight: bold;' : ''
    }">${text}</span>`;
  }

  // Parses the given raw text through marked for applying markdown.
  function runMarkedDefault(rawText: string) {
    return marked.parse(rawText) as string;
  }

  // Fully formats, sanitises and parses the provided raw text and wraps it
  // as necessary.
  function formatAndProcessRawText(
    rawText: string,
    font: string,
    color: string,
    bold: boolean,
    advanced_html: boolean = false,
    paperInputRef?: string,
  ): string {
    if (!rawText) {
      return '';
    }

    const parsedText = runMarkedDefault(rawText);
    const sanitizedText = sanitizeText(parsedText, advanced_html);
    const fieldedText = createWriteButtons(sanitizedText, paperInputRef);
    const specialTokensParsedText = parseSpecialTokens(fieldedText);

    // Forth, we wrap the created text in the writing implement properties.
    return setFontInText(specialTokensParsedText, font, color, bold);
  }

  function createWriteButtons(text: string, paperInputRef?: string): string {
    let counter = 0;
    return text.replace(fieldRegex, () => {
      return createWriteButton(
        paperInputRef && createWriteButtonId(paperInputRef, counter++),
      );
    });
  }

  function generatePreviewText(
    parsedDmText: string,
    parsedTextBox: string,
    editMode: boolean,
    writeButtonId: string,
  ) {
    return editMode
      ? insertTextAreaPreview(parsedDmText, parsedTextBox, writeButtonId) +
          "<button id='document_end'>Писать в конец</button>"
      : parsedDmText;
  }

  function createWriteButton(id?: string): string {
    return editMode
      ? `<button${id ? ` id='${id}'` : ''} class='write-button'>Write</button>`
      : '';
  }

  function onWriteButtonClick(ev: MouseEvent) {
    const button = ev.target as HTMLInputElement;
    if (button.id === activeWriteButtonId) {
      setActiveWriteButtonId('');
    } else {
      setActiveWriteButtonId(button.id);
      setTextAreaActive(true);
    }
  }

  function onEndWriteButtonClick(ev: MouseEvent) {
    const button = ev.target as HTMLInputElement;
    if (activeWriteButtonId) {
      setActiveWriteButtonId('');
    }

    setTextAreaActive(true);
  }

  // Creates the partial inline HTML for previewing or reading the paper from
  // only static_ui_data from DM.
  function createPreviewFromDM(
    rawTextInput: PaperInput[] | undefined,
    defaultPenFont: string,
    defaultPenColor: string,
  ): string {
    return (
      rawTextInput
        ?.map((paperInput) =>
          formatAndProcessPaperInput(
            paperInput,
            defaultPenFont,
            defaultPenColor,
          ),
        )
        .filter((value) => value)
        .join('') || ''
    );
  }

  function formatAndProcessPaperInput(
    paperInput: PaperInput,
    defaultPenFont: string,
    defaultPenColor: string,
  ) {
    const processedParentPaperInput = formatAndProcessRawText(
      paperInput.raw_text,
      paperInput.font || defaultPenFont,
      paperInput.color || defaultPenColor,
      paperInput.bold || false,
      paperInput.advanced_html,
      paperInput.ref,
    );

    if (!paperInput.children?.length) {
      return processedParentPaperInput;
    }

    return processedParentPaperInput.replaceAll(
      childInputRegex,
      (match, p1) => {
        if (!paperInput.children) {
          return '';
        }
        if (paperInput.children.length < p1) {
          return '';
        }

        return formatAndProcessPaperInput(
          paperInput.children[p1 - 1],
          defaultPenFont,
          defaultPenColor,
        );
      },
    );
  }

  // Inserts text area parsed data before active write button id
  //
  function insertTextAreaPreview(
    text: string,
    insertText: string,
    buttonId: string,
  ): string {
    if (!buttonId) {
      return text + insertText;
    }

    return text.replace(
      new RegExp(`<button[^>]*id=["']${buttonId}["'][^>]*>`),
      (match) => {
        return (
          `<span style='background-color:yellow'>${insertText}</span>` + match
        );
      },
    );
  }

  function parseSpecialTokens(text: string) {
    return text.replace(specialTokenRegex, (match, p1) => {
      const specialTokenResolver: (value: string) => string =
        SPECIAL_TOKENS[p1];

      return specialTokenResolver ? specialTokenResolver(match) : match;
    });
  }

  function createAndConfigureMarked() {
    const markedInstance = new Marked();
    const inputField = {
      name: 'inputField',
      level: 'inline',
      start(src) {
        return src.match(/\[/)?.index;
      },
      tokenizer,
      renderer(token) {
        return `${token.raw}`;
      },
      walkTokens,
    };

    markedInstance.use(
      {
        extensions: [inputField],
        breaks: true,
        gfm: true,
        walkTokens: walkTokens,
        renderer: {
          paragraph(tokens) {
            return marked.parseInline(tokens.text) as string;
          },
        },
      },
      markedSmartypants(),
    );
    return markedInstance;
  }

  const previewText = generatePreviewText(
    parsedDmText,
    parsedTextBox,
    editMode,
    activeWriteButtonId,
  );

  useEffect(() => {
    const activeButtonId = activeWriteButtonId;
    const buttons = document.querySelectorAll("[id^='paperfield_']");
    [].forEach.call(buttons, (button: HTMLButtonElement) => {
      if (button.id === activeButtonId) {
        button.style.backgroundColor = 'white';
      }
      button.addEventListener('click', onWriteButtonClick);
    });
    return () =>
      [].forEach.call(buttons, (button: HTMLButtonElement) => {
        if (button.id === activeButtonId) {
          button.style.backgroundColor = '';
        }
        button.removeEventListener('click', onWriteButtonClick);
      });
  }, [previewText, activeWriteButtonId]);

  useEffect(() => {
    const endButton = document.getElementById('document_end');
    endButton?.addEventListener('click', onEndWriteButtonClick);

    return () => endButton?.removeEventListener('click', onEndWriteButtonClick);
  }, [previewText]);

  const textHTML = {
    __html: `<span class='paper-text'>${previewText}</span>`,
  };

  return (
    <Section
      fill
      fitted
      scrollable
      ref={scrollableRef}
      onScroll={handleOnScroll as any}
    >
      <Box
        fillPositionedParent
        position="relative"
        bottom="100%"
        minHeight="100%"
        backgroundColor={paper_color}
        className="Paper__Page"
        dangerouslySetInnerHTML={textHTML}
        p="10px"
      />
      <StampView />
    </Section>
  );
}
