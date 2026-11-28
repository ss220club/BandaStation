import { describe, it } from 'bun:test';
import assert from 'node:assert/strict';
import { renderToStaticMarkup } from 'react-dom/server';
import { NeuralTelemetry, type TelemetryHistory } from './NeuralTelemetry';

const sample = (time: number, segment: number) => ({
  time,
  segment,
  source: 'Ядро <b>ИИ</b>',
  cpu: 0,
  cpu_reserved: 0,
  ram: 0,
  ram_used: 0,
  temperature: 280,
  temperature_limit: 288,
});

describe('Личная история телеметрии', () => {
  it('не соединяет разные сеансы и не дорисовывает данные до текущего времени', () => {
    const history: TelemetryHistory = {
      now: 120,
      age: 8,
      recording: false,
      samples: [sample(100, 1), sample(102, 1), sample(110, 2), sample(112, 2)],
    };
    const markup = renderToStaticMarkup(<NeuralTelemetry history={history} />);
    const lines = [...markup.matchAll(/<polyline[^>]*points="([^"]+)"/g)];
    assert.equal(lines.length, 12);
    for (const [, points] of lines) {
      const coordinates = points
        .split(' ')
        .map((point) => point.split(',').map(Number));
      assert.equal(coordinates.length, 2);
      assert.ok(
        coordinates.every(
          ([x, y]) => Number.isFinite(x) && Number.isFinite(y) && x < 596,
        ),
      );
      assert.ok(coordinates[1][0] - coordinates[0][0] < 10);
    }
    assert.ok(markup.includes('нет связи'));
    assert.ok(markup.includes('8 с назад'));
    assert.ok(markup.includes('Ядро &lt;b&gt;ИИ&lt;/b&gt;'));
    assert.ok(!markup.includes('NaN') && !markup.includes('Infinity'));
  });

  it('показывает отдельный первый замер точками', () => {
    const markup = renderToStaticMarkup(
      <NeuralTelemetry
        history={{
          now: 100,
          age: 0,
          recording: true,
          samples: [sample(100, 1)],
        }}
      />,
    );
    assert.equal((markup.match(/<circle /g) || []).length, 6);
    assert.ok(!markup.includes('NaN') && !markup.includes('Infinity'));
  });

  it('не выдумывает показания до первого подключения и после истечения истории', () => {
    for (const age of [null, 125]) {
      const markup = renderToStaticMarkup(
        <NeuralTelemetry
          history={{ now: 200, age, recording: false, samples: [] }}
        />,
      );
      assert.ok(markup.includes('В этом интервале нет измерений'));
      assert.ok(!markup.includes('<svg'));
      assert.ok(
        markup.includes(age === null ? 'Измерений ещё нет' : '125 с назад'),
      );
    }
  });
});
