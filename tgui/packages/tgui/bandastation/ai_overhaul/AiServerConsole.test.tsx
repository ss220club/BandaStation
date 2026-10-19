import { describe, it } from 'bun:test';
import assert from 'node:assert/strict';
import { renderToStaticMarkup } from 'react-dom/server';
import { ServerThermalLimits } from './AiServerConsole';

describe('Температурные пороги серверного шкафа', () => {
  it('показывает пороги текущей сети в градусах Цельсия с правилами восстановления', () => {
    for (const bonus of [0, 10]) {
      const markup = renderToStaticMarkup(
        <ServerThermalLimits
          machine={{
            temperature_limit: 288.15 + bonus,
            throttle_temperature: 283.15 + bonus,
            recovery_temperature: 280.15 + bonus,
          }}
        />,
      );
      assert.ok(markup.includes(`Выше ${(10 + bonus).toFixed(1)} °C`));
      assert.ok(markup.includes(`При ${(7 + bonus).toFixed(1)} °C и ниже`));
      assert.ok(markup.includes(`${(15 + bonus).toFixed(1)} °C`));
      assert.ok(markup.includes('частота возвращается постепенно'));
      assert.ok(!markup.includes('NaN') && !markup.includes('Infinity'));
    }
  });

  it('не приписывает ядру или неполным данным серверные пороги', () => {
    for (const values of [
      {},
      { throttle_temperature: 283.15 },
      { throttle_temperature: NaN, recovery_temperature: 280.15 },
      { throttle_temperature: 283.15, recovery_temperature: Infinity },
    ]) {
      assert.equal(
        renderToStaticMarkup(
          <ServerThermalLimits
            machine={{ temperature_limit: 288.15, ...values }}
          />,
        ),
        '',
      );
    }
  });
});
