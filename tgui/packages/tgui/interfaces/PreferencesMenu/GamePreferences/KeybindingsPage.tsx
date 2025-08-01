import { range, sortBy } from 'es-toolkit';
import { Component } from 'react';
import { resolveAsset } from 'tgui/assets';
import { useBackend } from 'tgui/backend';
import {
  Button,
  KeyListener,
  Stack,
  TrackOutsideClicks,
} from 'tgui-core/components';
import type { KeyEvent } from 'tgui-core/events';
import { fetchRetry } from 'tgui-core/http';
import { isEscape, KEY } from 'tgui-core/keys';

import { LoadingScreen } from '../../common/LoadingScreen';
import { Preference } from '../components/Preference';
import type { PreferencesMenuData } from '../types';
import { TabbedMenu } from './TabbedMenu';

type Keybinding = {
  name: string;
  description?: string;
};

type Keybindings = Record<string, Record<string, Keybinding>>;

type KeybindingsPageState = {
  keybindings?: Keybindings;
  lastKeyboardEvent?: KeyboardEvent;
  selectedKeybindings?: PreferencesMenuData['keybindings'];

  /**
   * The current hotkey that the user is rebinding.
   *
   * First element is the hotkey name, the second is the slot.
   */
  rebindingHotkey?: [string, number];
};

function isStandardKey(event: KeyboardEvent): boolean {
  return (
    event.key !== KEY.Alt &&
    event.key !== KEY.Control &&
    event.key !== KEY.Shift &&
    !isEscape(event.key)
  );
}

const KEY_CODE_TO_BYOND: Record<string, string> = {
  DEL: 'Delete',
  DOWN: 'South',
  END: 'Southwest',
  HOME: 'Northwest',
  INSERT: 'Insert',
  LEFT: 'West',
  PAGEDOWN: 'Southeast',
  PAGEUP: 'Northeast',
  RIGHT: 'East',
  UP: 'North',
  ' ': 'Space',
};

/**
 * So, as it turns out, KeyboardEvent seems to be broken with IE 11, the
 * DOM_KEY_LOCATION_X codes are all undefined. See this to see why it's 3:
 * https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/location
 */
const DOM_KEY_LOCATION_NUMPAD = 3;
function sortKeybindings(array: [string, Keybinding][]) {
  return sortBy(array, [([, keybinding]) => keybinding.name]);
}

function formatKeyboardEvent(event: KeyboardEvent): string {
  let text = '';

  if (event.altKey) {
    text += 'Alt';
  }

  if (event.ctrlKey) {
    text += 'Ctrl';
  }

  if (event.shiftKey) {
    text += 'Shift';
  }

  if (event.location === DOM_KEY_LOCATION_NUMPAD) {
    text += 'Numpad';
  }

  if (isStandardKey(event)) {
    const key = event.key.toUpperCase();
    text += KEY_CODE_TO_BYOND[key] || key;
  }

  return text;
}

class KeybindingButton extends Component<{
  currentHotkey?: string;
  onClick?: () => void;
  typingHotkey?: string;
}> {
  shouldComponentUpdate(nextProps) {
    return (
      this.props.typingHotkey !== nextProps.typingHotkey ||
      this.props.currentHotkey !== nextProps.currentHotkey
    );
  }

  render() {
    const { currentHotkey, onClick, typingHotkey } = this.props;
    const child = (
      <Button
        fluid
        textAlign="center"
        captureKeys={typingHotkey === undefined}
        selected={typingHotkey !== undefined}
        onClick={(event) => {
          event.stopPropagation();
          onClick?.();
        }}
      >
        {typingHotkey || currentHotkey || 'Пусто'}
      </Button>
    );

    if (typingHotkey && onClick) {
      return (
        // onClick will cancel it
        <TrackOutsideClicks onOutsideClick={onClick}>
          {child}
        </TrackOutsideClicks>
      );
    } else {
      return child;
    }
  }
}

type ResetToDefaultButtonProps = {
  keybindingId: string;
};

function ResetToDefaultButton(props: ResetToDefaultButtonProps) {
  const { act } = useBackend<PreferencesMenuData>();
  return (
    <Button
      fluid
      textAlign="center"
      onClick={() => {
        act('reset_keybinds_to_defaults', {
          keybind_name: props.keybindingId,
        });
      }}
    >
      Сбросить
    </Button>
  );
}

export class KeybindingsPage extends Component<any, KeybindingsPageState> {
  cancelNextKeyUp?: number;
  keybindingOnClicks: Record<string, (() => void)[]> = {};
  lastKeybinds?: PreferencesMenuData['keybindings'];

  state: KeybindingsPageState = {
    lastKeyboardEvent: undefined,
    keybindings: undefined,
    selectedKeybindings: undefined,
    rebindingHotkey: undefined,
  };

  constructor(props) {
    super(props);
    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.handleKeyUp = this.handleKeyUp.bind(this);
  }

  componentDidMount() {
    this.populateSelectedKeybindings();
    this.populateKeybindings();
  }

  componentDidUpdate() {
    const { data } = useBackend<PreferencesMenuData>();
    // keybindings is static data, so it'll pass `===` checks.
    // This'll change when resetting to defaults.
    if (data.keybindings !== this.lastKeybinds) {
      this.populateSelectedKeybindings();
    }
  }

  setRebindingHotkey(value?: string) {
    const { act } = useBackend<PreferencesMenuData>();
    this.setState((state) => {
      let selectedKeybindings = state.selectedKeybindings;
      if (!selectedKeybindings) {
        return state;
      }

      if (!state.rebindingHotkey) {
        return state;
      }

      selectedKeybindings = { ...selectedKeybindings };

      const [keybindName, slot] = state.rebindingHotkey;

      if (selectedKeybindings[keybindName]) {
        if (value) {
          selectedKeybindings[keybindName][
            Math.min(selectedKeybindings[keybindName].length, slot)
          ] = value;
        } else {
          selectedKeybindings[keybindName].splice(slot, 1);
        }
      } else if (!value) {
        return state;
      } else {
        selectedKeybindings[keybindName] = [value];
      }

      act('set_keybindings', {
        keybind_name: keybindName,
        hotkeys: selectedKeybindings[keybindName],
      });

      return {
        lastKeyboardEvent: undefined,
        rebindingHotkey: undefined,
        selectedKeybindings,
      };
    });
  }

  handleKeyDown(keyEvent: KeyEvent) {
    const event = keyEvent.event;
    const rebindingHotkey = this.state.rebindingHotkey;

    if (!rebindingHotkey) {
      return;
    }

    event.preventDefault();
    this.cancelNextKeyUp = keyEvent.code;

    if (isStandardKey(event)) {
      this.setRebindingHotkey(formatKeyboardEvent(event));
      return;
    } else if (isEscape(event.key)) {
      this.setRebindingHotkey(undefined);
      return;
    }

    this.setState({
      lastKeyboardEvent: event,
    });
  }

  handleKeyUp(keyEvent: KeyEvent) {
    if (this.cancelNextKeyUp === keyEvent.code) {
      this.cancelNextKeyUp = undefined;
      keyEvent.event.preventDefault();
    }

    const { lastKeyboardEvent, rebindingHotkey } = this.state;
    if (rebindingHotkey && lastKeyboardEvent) {
      this.setRebindingHotkey(formatKeyboardEvent(lastKeyboardEvent));
    }
  }

  getKeybindingOnClick(keybindingId: string, slot: number): () => void {
    if (!this.keybindingOnClicks[keybindingId]) {
      this.keybindingOnClicks[keybindingId] = [];
    }

    if (!this.keybindingOnClicks[keybindingId][slot]) {
      this.keybindingOnClicks[keybindingId][slot] = () => {
        if (this.state.rebindingHotkey === undefined) {
          this.setState({
            lastKeyboardEvent: undefined,
            rebindingHotkey: [keybindingId, slot],
          });
        } else {
          this.setState({
            lastKeyboardEvent: undefined,
            rebindingHotkey: undefined,
          });
        }
      };
    }

    return this.keybindingOnClicks[keybindingId][slot];
  }

  getTypingHotkey(keybindingId: string, slot: number): string | undefined {
    const { lastKeyboardEvent, rebindingHotkey } = this.state;

    if (!rebindingHotkey) {
      return undefined;
    }

    if (rebindingHotkey[0] !== keybindingId || rebindingHotkey[1] !== slot) {
      return undefined;
    }

    if (lastKeyboardEvent === undefined) {
      return '...';
    }

    return formatKeyboardEvent(lastKeyboardEvent);
  }

  async populateKeybindings() {
    const keybindingsResponse = await fetchRetry(
      resolveAsset('keybindings.json'),
    );
    const keybindingsData: Keybindings = await keybindingsResponse.json();

    this.setState({
      keybindings: keybindingsData,
    });
  }

  populateSelectedKeybindings() {
    const { data } = useBackend<PreferencesMenuData>();

    this.lastKeybinds = data.keybindings;
    this.setState({
      selectedKeybindings: Object.fromEntries(
        Object.entries(data.keybindings).map(([keybind, hotkeys]) => {
          return [keybind, hotkeys.filter((value) => value !== 'Пусто')];
        }),
      ),
    });
  }

  render() {
    const { act } = useBackend();
    const keybindings = this.state.keybindings;

    if (!keybindings) {
      return <LoadingScreen />;
    }

    const keybindingEntries = Object.entries(keybindings);
    return (
      <>
        <KeyListener
          onKeyDown={this.handleKeyDown}
          onKeyUp={this.handleKeyUp}
        />

        <Stack fill vertical>
          <TabbedMenu
            buttons={
              <Button.Confirm
                fluid
                textAlign="center"
                onClick={() => act('reset_all_keybinds')}
              >
                Сбросить хоткеи
              </Button.Confirm>
            }
            categories={keybindingEntries.map(([category, keybindings]) => {
              return [
                category,
                sortKeybindings(Object.entries(keybindings)).map(
                  ([keybindingId, keybinding]: [string, Keybinding]) => {
                    const keys = (this.state.selectedKeybindings?.[
                      keybindingId
                    ] || []) as string[];

                    const children = (
                      <Preference
                        key={keybindingId}
                        id={keybindingId}
                        name={keybinding.name}
                        description={keybinding.description}
                        childrenClassName="Keybindings"
                      >
                        {range(0, 3).map((key) => (
                          <Stack.Item key={key} grow>
                            <KeybindingButton
                              currentHotkey={keys[key]}
                              typingHotkey={this.getTypingHotkey?.(
                                keybindingId,
                                key,
                              )}
                              onClick={this.getKeybindingOnClick?.(
                                keybindingId,
                                key,
                              )}
                            />
                          </Stack.Item>
                        ))}
                        <Stack.Item>
                          <ResetToDefaultButton keybindingId={keybindingId} />
                        </Stack.Item>
                      </Preference>
                    );
                    return {
                      name: keybinding.name,
                      children,
                    };
                  },
                ),
              ];
            })}
          />
        </Stack>
      </>
    );
  }
}
