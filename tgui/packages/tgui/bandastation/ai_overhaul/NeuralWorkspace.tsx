import { type PropsWithChildren, type ReactNode, useState } from 'react';
import { Button } from 'tgui-core/components';

export function NeuralWorkspace({
  children,
  navigation,
  instruments,
  focus = false,
}: PropsWithChildren<{
  navigation: ReactNode;
  instruments: ReactNode;
  focus?: boolean;
}>) {
  const [expanded, setExpanded] = useState(false);
  return (
    <div
      className={`AiOS__workspaceLayout${focus ? ' AiOS__workspaceLayout--focus' : ''}`}
    >
      <div className="AiOS__railNavigation">{navigation}</div>
      <div className="AiOS__instrumentToggle">
        <Button
          fluid
          color="transparent"
          icon={expanded ? 'chevron-up' : 'sliders'}
          aria-expanded={expanded}
          onClick={() => setExpanded(!expanded)}
        >
          {expanded ? 'Скрыть приборы' : 'Показать приборы'}
        </Button>
      </div>
      <main className="AiOS__workArea">{children}</main>
      <aside
        className={`AiOS__sideRail${expanded ? ' AiOS__sideRail--expanded' : ''}`}
        aria-label="Доступная телеметрия"
      >
        <div className="AiOS__instrumentHeading">
          <span className="AiOS__statusDot" /> ТЕКУЩИЕ ПОКАЗАНИЯ{' '}
        </div>
        <div className="AiOS__railInstruments">{instruments}</div>
        <div className="AiOS__instrumentFootnote">
          ТОЛЬКО МЕСТНЫЕ НАБЛЮДЕНИЯ
        </div>
      </aside>
    </div>
  );
}
