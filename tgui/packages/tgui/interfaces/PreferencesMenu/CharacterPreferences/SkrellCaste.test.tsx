import { afterEach, describe, expect, it, spyOn } from 'bun:test';
import { fireEvent, render, screen } from '@testing-library/react';
import * as actions from 'tgui/events/act';
import { gameDataAtom, resetStore, store } from 'tgui/events/store';

import type { Species } from '../types';
import { ServerPrefs, useServerPrefs } from '../useServerPrefs';
import { SpeciesPage } from './SpeciesPage';

const donor = (await Bun.file(
  new URL(
    '../../../../../../modular_bandastation/sierra_background/data/skrell.json',
    import.meta.url,
  ),
).json()) as {
  castes: Record<string, { name: string; description: string }>;
};

const casteData = {
  choices: Object.keys(donor.castes),
  display_names: Object.fromEntries(
    Object.entries(donor.castes).map(([id, caste]) => [id, caste.name]),
  ),
  descriptions: Object.fromEntries(
    Object.entries(donor.castes).map(([id, caste]) => [id, caste.description]),
  ),
};

function species(name: string): Species {
  return {
    name,
    desc: `Описание вида: ${name}`,
    lore: [`История вида: ${name}`],
    icon: name,
    use_skintones: false,
    sexes: true,
    enabled_features: [],
    perks: { positive: [], negative: [], neutral: [] },
  };
}

function setData(
  selectedSpecies = 'skrell',
  castes: Record<string, string> = { skrell_caste: 'Qerr-Katish' },
  slot = 1,
) {
  store.set(gameDataAtom, {
    active_slot: slot,
    character_preview_view: 'test-preview',
    character_preferences: {
      misc: { species: selectedSpecies },
      manually_rendered_features: castes,
    },
  });
}

function TestSpeciesPage() {
  const defaults = useServerPrefs();
  if (!defaults) {
    throw new Error('Preference context defaults are missing.');
  }
  return (
    <ServerPrefs.Provider
      value={{
        ...defaults,
        species: { human: species('Человек'), skrell: species('Скрелл') },
        skrell_caste: casteData,
      }}
    >
      <SpeciesPage closeSpecies={() => {}} />
    </ServerPrefs.Provider>
  );
}

afterEach(() => {
  resetStore();
  sessionStorage.clear();
});

describe('Skrell caste preference', () => {
  it('offers all five Russian names and displays each full source description', async () => {
    const sendAct = spyOn(actions, 'sendAct').mockImplementation(() => {});
    try {
      setData();
      render(<TestSpeciesPage />);

      expect(screen.getByText('Каста')).toBeDefined();
      expect(
        screen.getByText(
          'Каста наследуется и не зависит от культуры воспитания.',
        ),
      ).toBeDefined();
      expect(casteData.choices).toEqual([
        'Qerr-Katish',
        'Malish-Katish',
        'Kanin-Katish',
        'Talum-Katish',
        'Raskinta-Katish',
      ]);
      expect(document.body.textContent).toContain(
        donor.castes['Qerr-Katish'].description,
      );

      for (const [id, caste] of Object.entries(donor.castes)) {
        fireEvent.click(document.querySelector('.Dropdown__control')!);
        const option = await screen.findByText(caste.name, {
          selector: '.Dropdown__menu--entry',
        });
        fireEvent.click(option);

        expect(sendAct).toHaveBeenLastCalledWith('set_preference', {
          preference: 'skrell_caste',
          value: id,
        });
        expect(
          document.querySelector('.Dropdown__selected-text')?.textContent,
        ).toBe(caste.name);
        expect(document.body.textContent).toContain(caste.description);
      }
    } finally {
      sendAct.mockRestore();
    }
  });

  it('uses only the server preference availability to show the caste field', () => {
    setData('human', {});
    const view = render(<TestSpeciesPage />);
    expect(screen.queryByText('Каста')).toBeNull();

    setData('skrell', {});
    view.rerender(<TestSpeciesPage />);
    expect(screen.queryByText('Каста')).toBeNull();

    setData();
    view.rerender(<TestSpeciesPage />);
    expect(screen.getByText('Каста')).toBeDefined();

    setData('human', {});
    view.rerender(<TestSpeciesPage />);
    expect(screen.queryByText('Каста')).toBeNull();
  });

  it('shows the saved caste when changing character slots and reopening the page', () => {
    setData();
    const view = render(<TestSpeciesPage />);
    expect(document.body.textContent).toContain(
      donor.castes['Qerr-Katish'].description,
    );

    setData('skrell', { skrell_caste: 'Talum-Katish' }, 2);
    view.rerender(<TestSpeciesPage />);
    expect(document.body.textContent).toContain(
      donor.castes['Talum-Katish'].description,
    );
    expect(document.body.textContent).not.toContain(
      donor.castes['Qerr-Katish'].description,
    );

    view.unmount();
    render(<TestSpeciesPage />);
    expect(document.body.textContent).toContain(
      donor.castes['Talum-Katish'].description,
    );
  });
});
