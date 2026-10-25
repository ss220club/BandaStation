import { afterEach, describe, expect, it, spyOn } from 'bun:test';
import { act, fireEvent, render, screen, within } from '@testing-library/react';
import * as actions from 'tgui/events/act';
import { gameDataAtom, resetStore, store } from 'tgui/events/store';

import type {
  BackgroundCategory,
  BackgroundEntry,
  BackgroundPreference,
} from '../types';
import { ServerPrefs, useServerPrefs } from '../useServerPrefs';
import { BackgroundPage } from './BackgroundPage';

type SourceEntry = BackgroundEntry & { source_refs?: string[] };
type SourceEntries = Record<string, SourceEntry>;

async function readCatalogFile(name: string) {
  return Bun.file(
    new URL(
      `../../../../../../modular_bandastation/sierra_background/data/${name}.json`,
      import.meta.url,
    ),
  ).json();
}

const [cultures, worlds, factions, religions, wiki] = await Promise.all([
  readCatalogFile('cultures'),
  readCatalogFile('worlds'),
  readCatalogFile('factions'),
  readCatalogFile('religions'),
  readCatalogFile('wiki_species'),
]);

const catalog: Record<BackgroundCategory, SourceEntries> = {
  culture: { ...cultures.entries, ...wiki.cultures },
  homeworld: { ...worlds.entries, ...wiki.worlds },
  faction: factions.entries,
  religion: { ...religions.entries, ...wiki.religions },
};

const initialChoices: Record<BackgroundCategory, string> = {
  culture: 'tsf_solar',
  homeworld: 'Earth',
  faction: 'none',
  religion: 'none',
};
const skrellChoices: Record<BackgroundCategory, string> = {
  culture: 'skrell_imperial',
  homeworld: 'KverrBalakk',
  faction: 'none',
  religion: 'none',
};
const labels: Record<BackgroundCategory, string> = {
  culture: 'Культура',
  homeworld: 'Место жительства',
  faction: 'Фракция',
  religion: 'Вера',
};

function preferences(values = initialChoices): BackgroundPreference[] {
  return Object.entries(values).map(([category, value]) => ({
    category: category as BackgroundCategory,
    label: labels[category],
    preference: `sierra_${category}`,
    value,
    choices: Object.keys(catalog[category]),
    notes: '',
    notes_preference: `sierra_${category}_notes`,
    notes_max_length: 4000,
    notes_prompt: `Личные подробности: ${labels[category]}`,
  }));
}

function setData(rows = preferences(), slot = 1, species = 'human') {
  store.set(gameDataAtom, {
    active_slot: slot,
    character_preferences: { misc: { species } },
    sierra_background: rows,
  });
}

function TestBackground() {
  const defaults = useServerPrefs();
  if (!defaults) {
    throw new Error('Preference context defaults are missing.');
  }
  return (
    <ServerPrefs.Provider value={{ ...defaults, sierra_background: catalog }}>
      <BackgroundPage />
    </ServerPrefs.Provider>
  );
}

function sectionFor(row: BackgroundPreference) {
  const section = screen.getByText(row.label).closest('.Section');
  if (!(section instanceof HTMLElement)) {
    throw new Error(`Section ${row.label} is missing.`);
  }
  return section;
}

function plainHtml(html: string) {
  const element = document.createElement('div');
  element.innerHTML = html;
  return element.textContent;
}

afterEach(() => {
  resetStore();
});

describe('BandaStation character background', () => {
  it('shows the backend choices from the complete own lore catalog', () => {
    const rows = preferences();
    setData(rows);
    render(<TestBackground />);

    for (const row of rows) {
      const section = sectionFor(row);
      const selected = catalog[row.category][row.value];
      expect(
        section.querySelector('.Section__titleText')?.textContent,
      ).toContain(selected.name);
      expect(section.textContent).not.toContain(selected.description);

      fireEvent.click(within(section).getByText(row.label));
      for (const choice of row.choices) {
        const name = catalog[row.category][choice].name;
        expect(
          within(section).getAllByText(name, { selector: '.Button__content' })
            .length,
        ).toBeGreaterThan(0);
      }

      fireEvent.click(within(section).getByText('Расширить'));
      expect(section.textContent).toContain(plainHtml(selected.description));
      if (selected.extra) {
        expect(section.textContent).toContain(plainHtml(selected.extra));
      }
    }

    const culture = catalog.culture.tsf_solar;
    expect(culture.description).toContain('\n\n');
    const description = sectionFor(rows[0]).querySelector<HTMLElement>(
      '[style*="white-space: pre-wrap"]',
    );
    expect(description?.textContent).toBe(plainHtml(culture.description));
    expect(description?.style.whiteSpace).toBe('pre-wrap');
  });

  it('renders every own description in full and leaves source references as metadata', () => {
    const rows = preferences();
    setData(rows);
    const view = render(<TestBackground />);

    for (const row of rows) {
      fireEvent.click(within(sectionFor(row)).getByText('Расширить'));
      for (const id of row.choices) {
        row.value = id;
        setData(rows);
        view.rerender(<TestBackground />);
        const section = sectionFor(row);
        const entry = catalog[row.category][id];
        const description = section.querySelector<HTMLElement>(
          '[style*="white-space: pre-wrap"]',
        );
        expect(description?.textContent).toBe(plainHtml(entry.description));
        if (entry.extra) {
          expect(section.textContent).toContain(plainHtml(entry.extra));
        }
        for (const reference of entry.source_refs ?? []) {
          expect(section.textContent).not.toContain(reference);
        }
      }
    }
  });

  it('uses only the options supplied by the backend for the current species', () => {
    const rows = preferences(skrellChoices);
    for (const row of rows) {
      row.choices = [row.value];
    }
    setData(rows, 1, 'skrell');
    render(<TestBackground />);

    for (const row of rows) {
      const section = sectionFor(row);
      fireEvent.click(within(section).getByText(row.label));
      const options = section.querySelectorAll('.Section__content .Button');
      expect(options.length).toBe(1);
      expect(options[0].textContent).toBe(
        catalog[row.category][row.value].name,
      );
    }
  });

  it('sends native preference actions and displays the authoritative new choice', () => {
    const sendAct = spyOn(actions, 'sendAct').mockImplementation(() => {});
    try {
      const rows = preferences();
      setData(rows);
      const view = render(<TestBackground />);

      for (const row of rows) {
        const section = sectionFor(row);
        fireEvent.click(within(section).getByText(row.label));
        const nextId = row.choices.find((id) => id !== row.value)!;
        const next = catalog[row.category][nextId];
        const options = section.querySelectorAll('.Section__content .Button');
        fireEvent.click(options[row.choices.indexOf(nextId)]);
        expect(sendAct).toHaveBeenLastCalledWith('set_preference', {
          preference: row.preference,
          value: nextId,
        });

        row.value = nextId;
        setData(rows);
        view.rerender(<TestBackground />);
        expect(
          section.querySelector('.Section__titleText')?.textContent,
        ).toContain(next.name);
        expect(section.textContent).toContain(plainHtml(next.description));
      }
    } finally {
      sendAct.mockRestore();
    }
  });

  it('shows the server language and naming effects while the culture description is collapsed', () => {
    const rows = preferences();
    rows[0].language_names = ['Общесолнечный', 'Неорусский'];
    rows[0].name_generation = 'Имена из выбранного культурного набора';
    setData(rows);
    render(<TestBackground />);

    const section = sectionFor(rows[0]);
    expect(within(section).queryByText('Скрыть')).toBeNull();
    expect(section.textContent).not.toContain(
      plainHtml(catalog.culture[rows[0].value].description),
    );
    expect(section.textContent).toContain(
      'Языки воспитания: Общесолнечный, Неорусский',
    );
    expect(section.textContent).toContain(
      'Имена: Имена из выбранного культурного набора',
    );
    expect(section.textContent).toContain(
      'Знание языка не гарантирует возможность говорить на нём.',
    );
    expect(section.textContent).toContain(
      'Смена воспитания сохраняет введённое имя.',
    );
    const languages = within(section).getByText('Языки воспитания:');
    const personalDetails = within(section).getByText('Личные подробности');
    expect(
      languages.compareDocumentPosition(personalDetails) &
        Node.DOCUMENT_POSITION_FOLLOWING,
    ).toBeTruthy();
    expect(
      Array.from(section.querySelectorAll('.Button__content')).map(
        (button) => button.textContent,
      ),
    ).toEqual(['Культура', 'Расширить']);
  });

  it('updates derived effects only from the authoritative backend rows', () => {
    const sendAct = spyOn(actions, 'sendAct').mockImplementation(() => {});
    try {
      const rows = preferences();
      rows[0].language_names = ['Общесолнечный'];
      rows[0].name_generation = 'Первое правило имён';
      setData(rows);
      const view = render(<TestBackground />);

      rows[0].value = 'kssp';
      rows[0].language_names = ['Неорусский'];
      rows[0].name_generation = 'Второе правило имён';
      setData(rows);
      view.rerender(<TestBackground />);

      const section = sectionFor(rows[0]);
      expect(section.textContent).toContain('Языки воспитания: Неорусский');
      expect(section.textContent).toContain('Имена: Второе правило имён');
      expect(section.textContent).not.toContain('Первое правило имён');
      expect(section.textContent).not.toContain('Общесолнечный');
      expect(sendAct).not.toHaveBeenCalled();
    } finally {
      sendAct.mockRestore();
    }
  });

  it('handles optional and empty effect data without carrying it between slots or species', () => {
    const rows = preferences();
    rows[0].language_names = ['Общесолнечный'];
    rows[0].name_generation = 'Правило первого слота';
    setData(rows);
    const view = render(<TestBackground />);

    const secondRows = preferences(skrellChoices);
    setData(secondRows, 2, 'skrell');
    view.rerender(<TestBackground />);
    expect(screen.queryByText('Языки воспитания:')).toBeNull();
    expect(screen.queryByText('Имена:')).toBeNull();
    expect(screen.queryByText('Правило первого слота')).toBeNull();

    secondRows[0].language_names = [];
    secondRows[1].language_names = ['Не должно отображаться'];
    secondRows[1].name_generation = 'Не должно отображаться';
    setData(secondRows, 2, 'skrell');
    view.rerender(<TestBackground />);
    expect(sectionFor(secondRows[0]).textContent).toContain(
      'Дополнительные языки не добавляются.',
    );
    expect(screen.queryByText('Имена:')).toBeNull();
    expect(sectionFor(secondRows[1]).textContent).not.toContain(
      'Не должно отображаться',
    );

    secondRows[0].language_names = undefined;
    secondRows[0].name_generation = 'Правило второго слота';
    setData(secondRows, 2, 'skrell');
    view.rerender(<TestBackground />);
    expect(screen.queryByText('Языки воспитания:')).toBeNull();
    expect(sectionFor(secondRows[0]).textContent).toContain(
      'Имена: Правило второго слота',
    );
  });

  it('resets expanded lists and descriptions when the slot or species changes', () => {
    let rows = preferences();
    setData(rows);
    const view = render(<TestBackground />);

    for (const [slot, species] of [
      [2, 'human'],
      [2, 'skrell'],
    ] as const) {
      const section = sectionFor(rows[0]);
      fireEvent.click(within(section).getByText(rows[0].label));
      fireEvent.click(within(section).getByText('Расширить'));
      expect(within(section).getByText('Скрыть')).toBeDefined();

      rows = preferences(species === 'skrell' ? skrellChoices : initialChoices);
      setData(rows, slot, species);
      view.rerender(<TestBackground />);

      const newSection = sectionFor(rows[0]);
      expect(within(newSection).queryByText('Скрыть')).toBeNull();
      expect(
        newSection.querySelectorAll('.Section__content .Button').length,
      ).toBe(0);
    }
  });

  it('keeps personal notes optional and saves each category as plain text on blur', () => {
    const sendAct = spyOn(actions, 'sendAct').mockImplementation(() => {});
    try {
      const rows = preferences();
      setData(rows);
      const view = render(<TestBackground />);

      for (const row of rows) {
        const field = screen.getByLabelText(
          `Личные подробности: ${row.label}`,
        ) as HTMLTextAreaElement;
        expect(field.value).toBe('');
        expect(field.maxLength).toBe(4000);
        const text = `Личный текст: ${row.label}\n<b>Обычный текст</b>`;
        act(() => field.focus());
        fireEvent.change(field, { target: { value: text } });
        expect(sendAct).not.toHaveBeenCalled();

        row.notes = 'Стороннее обновление сохранённого текста';
        setData(rows);
        view.rerender(<TestBackground />);
        expect(field.value).toBe(text);
        expect(field.querySelector('b')).toBeNull();

        act(() => field.blur());
        expect(sendAct).toHaveBeenLastCalledWith('set_preference', {
          preference: row.notes_preference,
          value: text,
        });

        row.notes = text;
        setData(rows);
        view.rerender(<TestBackground />);
        expect(field.value).toBe(text);
        sendAct.mockClear();
      }
    } finally {
      sendAct.mockRestore();
    }
  });

  it('restores the server notes when switching slots or species', () => {
    const rows = preferences();
    rows[0].notes = 'Личные подробности первого персонажа';
    setData(rows);
    const view = render(<TestBackground />);
    const fieldName = `Личные подробности: ${rows[0].label}`;

    expect(
      (screen.getByLabelText(fieldName) as HTMLTextAreaElement).value,
    ).toBe(rows[0].notes);

    const secondRows = preferences();
    secondRows[0].notes = 'Личные подробности второго персонажа';
    setData(secondRows, 2);
    view.rerender(<TestBackground />);
    expect(
      (screen.getByLabelText(fieldName) as HTMLTextAreaElement).value,
    ).toBe(secondRows[0].notes);

    const skrellRows = preferences(skrellChoices);
    skrellRows[0].notes = secondRows[0].notes;
    setData(skrellRows, 2, 'skrell');
    view.rerender(<TestBackground />);
    expect(
      (screen.getByLabelText(fieldName) as HTMLTextAreaElement).value,
    ).toBe(secondRows[0].notes);

    setData(rows, 1);
    view.rerender(<TestBackground />);
    expect(
      (screen.getByLabelText(fieldName) as HTMLTextAreaElement).value,
    ).toBe(rows[0].notes);
  });
});
