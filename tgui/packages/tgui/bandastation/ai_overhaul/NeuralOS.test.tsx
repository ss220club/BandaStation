import { describe, it, spyOn } from 'bun:test';
import assert from 'node:assert/strict';
import { act, fireEvent, render, screen } from '@testing-library/react';
import { storage } from 'common/storage';
import { configAtom, store } from '../../events/store';
import { NeuralShell, useNeuralOS } from './NeuralOS';

function SettingsProbe() {
  const display = useNeuralOS();
  return (
    <>
      <output aria-label="Эффекты">{display.effects}</output>
      <button type="button" onClick={() => display.chooseEffects('off')}>
        Выключить
      </button>
    </>
  );
}

async function checkLatePreference(changeByUser: boolean) {
  const previousConfig = store.get(configAtom);
  const previousMatchMedia = Object.getOwnPropertyDescriptor(
    window,
    'matchMedia',
  );
  Object.defineProperty(window, 'matchMedia', {
    configurable: true,
    value: () => ({
      matches: false,
      addEventListener() {},
      removeEventListener() {},
    }),
  });
  store.set(configAtom, {
    client: { ckey: 'preferences-test', address: '', computer_id: '' },
    interface: { name: 'test', layout: 'default' },
    refreshing: 0,
    status: 2,
    title: 'Test',
    user: { name: 'Test', observer: 0 },
    window: {
      fancy: 1,
      key: 'preferences',
      locked: 0,
      scale: 0,
      size: [700, 600],
    },
  });
  let resolvePreference: (value: string) => void = () => {};
  const get = spyOn(storage, 'get').mockImplementation(
    () =>
      new Promise<string>((resolve) => {
        resolvePreference = resolve;
      }),
  );
  const set = spyOn(storage, 'set').mockResolvedValue(undefined);
  const view = render(
    <NeuralShell application="Проверка настроек">
      <SettingsProbe />
    </NeuralShell>,
  );
  try {
    await act(async () => {
      await new Promise((resolve) => window.setTimeout(resolve, 1550));
    });
    assert.equal(screen.getByLabelText('Эффекты').textContent, 'soft');
    if (changeByUser) {
      fireEvent.click(screen.getByText('Выключить'));
    }
    await act(async () => resolvePreference(changeByUser ? 'full' : 'off'));
    assert.equal(screen.getByLabelText('Эффекты').textContent, 'off');
  } finally {
    view.unmount();
    get.mockRestore();
    set.mockRestore();
    store.set(configAtom, previousConfig);
    if (previousMatchMedia) {
      Object.defineProperty(window, 'matchMedia', previousMatchMedia);
    } else {
      Reflect.deleteProperty(window, 'matchMedia');
    }
  }
}

describe('Поздняя загрузка настроек NT OS', () => {
  it('применяет сохранённое значение после временного fallback', async () => {
    await checkLatePreference(false);
  });
  it('сохраняет новый выбор игрока при позднем ответе хранилища', async () => {
    await checkLatePreference(true);
  });
});
