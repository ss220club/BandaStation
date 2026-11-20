import { describe, it } from 'bun:test';
import assert from 'node:assert/strict';
import { fireEvent, render, screen } from '@testing-library/react';
import { type ComponentProps, useState } from 'react';
import { NeuralCatalog } from './NeuralCatalog';

type Items = ComponentProps<typeof NeuralCatalog>['items'];

const projects: Items = Array.from({ length: 6 }, (_, index) => ({
  name: `Canonical project ${index + 1}`,
  label: `Проект ${index + 1}`,
  category: 'Камеры и обзор',
  description: `Описание ${index + 1}`,
  status: index === 4 ? 'Выполняется' : 'Готов к исследованию',
  tone: index === 4 ? 'active' : 'ready',
  memory: 1,
  cpu: index === 4 ? 0.5 : 0,
}));

function Catalog({
  items = projects,
  filterKey = 'all',
  onSelect,
}: {
  items?: Items;
  filterKey?: string;
  onSelect?: (name: string) => void;
}) {
  const [selected, setSelected] = useState('');
  return (
    <NeuralCatalog
      items={items}
      selected={selected}
      filterKey={filterKey}
      onSelect={(name) => {
        setSelected(name);
        onSelect?.(name);
      }}
      tools={<div>Поиск проектов</div>}
    >
      <div>Досье: {selected}</div>
    </NeuralCatalog>
  );
}

describe('Каталог исследований ИИ', () => {
  it('показывает по четыре проекта и ограничивает перелистывание', () => {
    const { container } = render(<Catalog />);
    assert.equal(container.querySelectorAll('[data-project]').length, 4);
    assert.ok(screen.queryByText('Проект 1'));
    assert.equal(screen.queryByText('Проект 5'), null);
    assert.equal(
      (screen.getByRole('button', { name: 'Назад' }) as HTMLButtonElement)
        .disabled,
      true,
    );
    fireEvent.click(screen.getByRole('button', { name: 'Далее' }));
    assert.equal(container.querySelectorAll('[data-project]').length, 2);
    assert.ok(screen.queryByText('Проект 5'));
    assert.equal(screen.queryByText('Проект 1'), null);
    assert.equal(
      (screen.getByRole('button', { name: 'Далее' }) as HTMLButtonElement)
        .disabled,
      true,
    );
    fireEvent.click(screen.getByRole('button', { name: 'Назад' }));
    assert.ok(screen.queryByText('Проект 1'));
  });

  it('передаёт ключ проекта и возвращает страницу и фокус после досье', () => {
    const selected: string[] = [];
    const { container } = render(
      <Catalog onSelect={(name) => selected.push(name)} />,
    );
    fireEvent.click(screen.getByRole('button', { name: 'Далее' }));
    fireEvent.click(screen.getByRole('button', { name: /Проект 5/ }));
    assert.deepEqual(selected, ['Canonical project 5']);
    assert.equal(container.querySelectorAll('[data-project]').length, 0);
    assert.equal(screen.queryByText('Поиск проектов'), null);
    assert.equal(
      document.activeElement?.getAttribute('aria-label'),
      'Досье выбранного проекта',
    );
    assert.ok(screen.queryByText('Досье: Canonical project 5'));
    fireEvent.click(screen.getByRole('button', { name: 'К каталогу' }));
    assert.equal(container.querySelectorAll('[data-project]').length, 2);
    assert.equal(
      (document.activeElement as HTMLElement).dataset.project,
      'Canonical project 5',
    );
    assert.ok(screen.queryByText('Поиск проектов'));
  });

  it('сбрасывает страницу и закрывает досье при смене фильтра', () => {
    const { rerender } = render(<Catalog />);
    fireEvent.click(screen.getByRole('button', { name: 'Далее' }));
    rerender(<Catalog filterKey="search" />);
    assert.ok(screen.queryByText('Проект 1'));
    assert.equal(screen.queryByText('Проект 5'), null);
    fireEvent.click(screen.getByRole('button', { name: /Проект 1/ }));
    assert.ok(screen.queryByText('Досье: Canonical project 1'));
    rerender(<Catalog filterKey="category" />);
    assert.equal(screen.queryByText('Досье: Canonical project 1'), null);
    assert.ok(screen.queryByText('Проект 1'));
  });

  it('обновляет режим «В работе» при завершении выбранного проекта', () => {
    const { container, rerender } = render(<Catalog />);
    fireEvent.click(screen.getByRole('button', { name: /В работе/ }));
    assert.equal(container.querySelectorAll('[data-project]').length, 1);
    assert.ok(screen.queryByText('Проект 5'));
    fireEvent.click(screen.getByRole('button', { name: /Проект 5/ }));
    rerender(
      <Catalog
        items={projects.filter((item) => item.name !== projects[4].name)}
      />,
    );
    assert.equal(screen.queryByText('Досье: Canonical project 5'), null);
    assert.ok(screen.queryByText('В этой категории нет проектов в работе.'));
    fireEvent.click(screen.getByRole('button', { name: /Все проекты/ }));
    assert.equal(container.querySelectorAll('[data-project]').length, 4);
  });

  it('обрабатывает пустой каталог и сокращение числа страниц', () => {
    const { container, rerender } = render(<Catalog />);
    fireEvent.click(screen.getByRole('button', { name: 'Далее' }));
    rerender(<Catalog items={projects.slice(0, 2)} />);
    assert.equal(container.querySelectorAll('[data-project]').length, 2);
    assert.ok(screen.queryByText('Проект 1'));
    rerender(<Catalog items={[]} />);
    assert.equal(container.querySelectorAll('[data-project]').length, 0);
    assert.ok(
      screen.queryByText(
        'Нет проектов. Измените категорию или поисковый запрос.',
      ),
    );
    for (const name of ['Назад', 'Далее']) {
      assert.equal(
        (screen.getByRole('button', { name }) as HTMLButtonElement).disabled,
        true,
      );
    }
  });

  it('показывает названия и описания как текст', () => {
    const { container } = render(
      <Catalog
        items={[
          {
            ...projects[0],
            label: '<b>Наблюдение</b>',
            description: '<img src="missing" onerror="alert(1)">',
          },
        ]}
      />,
    );
    assert.ok(screen.queryByText('<b>Наблюдение</b>'));
    assert.ok(screen.queryByText('<img src="missing" onerror="alert(1)">'));
    assert.equal(container.querySelector('b, img, script'), null);
  });
});
