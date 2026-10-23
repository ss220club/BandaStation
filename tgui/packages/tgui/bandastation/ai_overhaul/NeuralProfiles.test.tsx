import { describe, it } from 'bun:test';
import assert from 'node:assert/strict';
import { fireEvent, render, screen } from '@testing-library/react';
import { renderToStaticMarkup } from 'react-dom/server';
import { CpuThermalStatus } from './Common';
import { NeuralProfiles, type WorkProfile } from './NeuralProfiles';

const profiles: WorkProfile[] = [1, 2, 3].map((slot) => ({
  slot,
  saved: false,
  name: `Профиль ${slot}`,
  program_count: 0,
  cpu_share: 0,
}));

describe('Личные профили ИИ', () => {
  it('сохраняет введённое имя в выбранный слот и не применяет пустой профиль', () => {
    const calls: unknown[] = [];
    render(
      <NeuralProfiles
        profiles={profiles}
        report={[]}
        act={(...args) => calls.push(args)}
      />,
    );
    fireEvent.click(screen.getAllByText('Применить')[1]);
    assert.equal(calls.length, 0);
    fireEvent.change(screen.getAllByRole('textbox')[1], {
      target: { value: 'Наблюдение' },
    });
    fireEvent.click(screen.getAllByText('Сохранить текущее')[1]);
    assert.deepEqual(calls, [
      ['save_profile', { slot: 2, name: 'Наблюдение' }],
    ]);
  });

  it('применяет профиль сразу, а перезапись и удаление требуют второго нажатия', () => {
    const calls: unknown[] = [];
    render(
      <NeuralProfiles
        profiles={[
          {
            ...profiles[0],
            saved: true,
            name: 'Наука',
            program_count: 2,
            cpu_share: 0.5,
          },
        ]}
        report={['Недостаточно RAM: <b>текст</b>']}
        act={(...args) => calls.push(args)}
      />,
    );
    assert.ok(screen.getByText('Недостаточно RAM: <b>текст</b>'));
    fireEvent.click(screen.getByText('Применить'));
    assert.deepEqual(calls, [['apply_profile', { slot: 1 }]]);
    fireEvent.click(screen.getByText('Сохранить текущее'));
    assert.equal(calls.length, 1);
    fireEvent.click(screen.getByText('Перезаписать?'));
    assert.deepEqual(calls[1], ['save_profile', { slot: 1, name: 'Наука' }]);
    fireEvent.click(screen.getByText('Удалить'));
    assert.equal(calls.length, 2);
    fireEvent.click(screen.getByText('Удалить профиль?'));
    assert.deepEqual(calls[2], ['delete_profile', { slot: 1 }]);
  });

  it('объясняет троттлинг только при известных мощностях', () => {
    for (const nominal of [undefined, NaN, 0, 1]) {
      assert.equal(
        renderToStaticMarkup(
          <CpuThermalStatus nominal={nominal} effective={1} />,
        ),
        '',
      );
    }
    const markup = renderToStaticMarkup(
      <CpuThermalStatus nominal={2} effective={0.5} />,
    );
    assert.ok(
      markup.includes('25%') &&
        markup.includes('0.50') &&
        markup.includes('2.00'),
    );
  });
});
