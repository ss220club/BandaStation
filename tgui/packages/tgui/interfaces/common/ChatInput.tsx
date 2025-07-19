import '../../styles/interfaces/ChatInput.scss';

import { ReactNode, useEffect, useRef, useState } from 'react';
import { KEY } from 'tgui-core/keys';
import { classes } from 'tgui-core/react';

type ChatInputProps = {
  /** Custom css classes */
  className?: string;
  /** The placeholder text when everything is cleared */
  placeholder?: string;
  /** Text of the input */
  value: string;
  /** Disables the input. Outlined in gray */
  disabled?: boolean;
  /** The maximum length of the input value */
  maxLength?: number;
  /** Buttons right of the input */
  buttons?: ReactNode;
  /** Fires each time the input has been changed */
  onChange: (value: string) => void;
  /** Fires once the enter key is pressed */
  onEnter: (value: string) => void;
};

export function ChatInput(props: ChatInputProps) {
  const {
    className,
    value,
    placeholder = 'Начинайте писать...',
    disabled,
    buttons,
    maxLength,
    onChange,
    onEnter,
  } = props;

  const [editing, setEditing] = useState(false);
  const textRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const text = textRef.current;
    if (text && text.innerText !== value) {
      text.innerText = value;
    }
  }, [value]);

  function handleInput() {
    const text = textRef.current;
    if (!text) {
      return;
    }

    let newValue = text.innerText;
    if (text.innerHTML === '<br>') {
      text.innerHTML = '';
      newValue = '';
    }

    if (maxLength && newValue.length > maxLength) {
      newValue = newValue.slice(0, maxLength);
      text.innerText = newValue;

      const range = document.createRange();
      const sel = window.getSelection();
      range.selectNodeContents(text);
      range.collapse(false);
      sel?.removeAllRanges();
      sel?.addRange(range);
    }

    onChange(newValue);
  }

  function handlePaste(event: React.ClipboardEvent<HTMLDivElement>) {
    event.preventDefault();

    const text = event.clipboardData.getData('text/plain');
    const selection = window.getSelection();
    if (!selection || !selection.rangeCount) {
      return;
    }

    selection.deleteFromDocument();
    selection.getRangeAt(0).insertNode(document.createTextNode(text));
    selection.collapseToEnd();
    textRef.current?.scrollTo(0, textRef.current.scrollHeight);
    handleInput();
  }

  function handleKeyDown(event: React.KeyboardEvent<HTMLDivElement>): void {
    event.stopPropagation();
    if (event.key === KEY.Enter && !disabled) {
      event.preventDefault();
      onEnter?.(textRef.current?.innerText || '');
    }
    return;
  }

  return (
    <div
      className={classes([
        'ChatInput',
        disabled && 'ChatInput--disabled',
        editing && 'editing',
      ])}
    >
      <div
        ref={textRef}
        contentEditable={!disabled}
        data-placeholder={placeholder}
        className={classes([
          'ChatInput__Text',
          !value && 'ChatInput__Text--placeholder',
          className,
        ])}
        autoCorrect="off"
        spellCheck={false}
        onBlur={() => setEditing(false)}
        onFocus={() => setEditing(true)}
        onInput={handleInput}
        onKeyDown={handleKeyDown}
        onPaste={handlePaste}
      />
      {maxLength && (
        <div className="ChatInput__LeftCharacters">
          {maxLength - value.length}
        </div>
      )}
      {buttons && <div className="ChatInput__Buttons">{buttons}</div>}
    </div>
  );
}
