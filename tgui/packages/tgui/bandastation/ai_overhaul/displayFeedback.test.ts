import { describe, it } from 'bun:test';
import assert from 'node:assert/strict';
import { displayFeedback } from './displayFeedback';

describe('local display feedback', () => {
  it('does not invent faults when observations are absent or invalid', () => {
    assert.equal(displayFeedback().level, 0);
    assert.equal(
      displayFeedback({ cpuReserved: NaN, integrityPercent: Infinity }).level,
      0,
    );
    assert.equal(
      displayFeedback({ temperatures: [{ value: 0, limit: 288 }] }).level,
      0,
    );
    assert.equal(
      displayFeedback({ memoryUsed: 0, memoryCapacity: 0 }).level,
      0,
    );
  });

  it('responds progressively to project reservations without claiming throttling', () => {
    for (const [share, level] of [
      [0.5, 0],
      [0.75, 1],
      [0.9, 2],
      [0.98, 3],
    ]) {
      const result = displayFeedback({
        cpuReserved: share,
        cpuScope: 'projects',
      });
      assert.equal(result.level, level);
      if (level) assert.equal(result.reason, 'ПРОЕКТЫ: CPU ВЫДЕЛЕН');
    }
  });

  it('distinguishes fully allocated network capacity from overloaded project budgets', () => {
    assert.equal(
      displayFeedback({ cpuReserved: 1, cpuScope: 'network' }).level,
      2,
    );
    assert.equal(
      displayFeedback({ cpuReserved: 1.1, cpuScope: 'network' }).level,
      3,
    );
    assert.equal(
      displayFeedback({ memoryUsed: 1, memoryCapacity: 1 }).level,
      2,
    );
    assert.equal(
      displayFeedback({ memoryUsed: 1.1, memoryCapacity: 1 }).level,
      3,
    );
    assert.equal(
      displayFeedback({ memoryUsed: 1, memoryCapacity: 0 }).level,
      3,
    );
  });

  it('uses kelvin headroom and the actual reported limit', () => {
    for (const [value, level] of [
      [273, 0],
      [278, 1],
      [285, 2],
      [288, 3],
      [302, 3],
    ]) {
      assert.equal(
        displayFeedback({ temperatures: [{ value, limit: 288 }] }).level,
        level,
      );
    }
    assert.equal(
      displayFeedback({ temperatures: [{ value: 302, limit: 350 }] }).level,
      0,
    );
  });

  it('responds to the hottest observed core without hiding a more severe fault', () => {
    const result = displayFeedback({
      cpuReserved: 1,
      cpuScope: 'projects',
      temperatures: [
        { value: 273, limit: 288 },
        { value: 290, limit: 288 },
      ],
    });
    assert.deepEqual(result, { level: 3, reason: 'ТЕМПЕРАТУРА ЯДРА' });
  });

  it('uses normalized integrity and clears feedback when observations recover', () => {
    for (const [integrityPercent, level] of [
      [100, 0],
      [80, 1],
      [64, 2],
      [35, 3],
      [0, 3],
    ]) {
      assert.equal(displayFeedback({ integrityPercent }).level, level);
    }
    assert.equal(
      displayFeedback({ cpuReserved: 0.2, integrityPercent: 100 }).level,
      0,
    );
  });
});
