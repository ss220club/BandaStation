import { describe, it } from 'bun:test';
import assert from 'node:assert/strict';
import { fireEvent, render, screen } from '@testing-library/react';
import { SubnetPanel } from './SubnetPanel';

describe('Резерв CPU подсети', () => {
  it('сохраняет бюджет при переходе из автоматического режима с неполным расходом', () => {
    const calls: [string, number][] = [];
    render(
      <SubnetPanel
        subnets={[
          { ref: 'alpha', name: 'Альфа', quota: -1, cpu: 5, budget: 10 },
        ]}
        available={10}
        locked={false}
        activityLocked={false}
        onQuota={(ref, amount) => calls.push([ref, amount])}
        onRename={() => {}}
        onActivity={() => {}}
      />,
    );
    fireEvent.click(screen.getByText('Зарезервировать долю'));
    assert.deepEqual(calls, [['alpha', 1]]);
  });
});
