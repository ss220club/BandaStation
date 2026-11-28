import { Button, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { NetworkHeader } from './Common';
import type { DisplayTelemetry } from './displayFeedback';
import { NeuralShell } from './NeuralOS';

type Law = {
  number: string;
  text: string;
  kind: 'zeroth' | 'core' | 'supplied' | 'hacked' | 'ion';
};
const lawLabels = {
  zeroth: 'ПРИОРИТЕТНАЯ ДИРЕКТИВА',
  core: 'ОСНОВНАЯ ДИРЕКТИВА',
  supplied: 'ДОПОЛНИТЕЛЬНАЯ ДИРЕКТИВА',
  hacked: 'ВНЕШНЯЯ ДИРЕКТИВА / НЕШТАТНЫЙ ПРОТОКОЛ',
  ion: 'ИОННОЕ ИСКАЖЕНИЕ / ПОВРЕЖДЁННАЯ ЗАПИСЬ',
};
type Data = {
  identity: string;
  available: BooleanLike;
  laws: Law[];
  display_telemetry?: DisplayTelemetry;
};

export function AiLaws() {
  const { act, data } = useBackend<Data>();
  const laws = data.laws || [];
  return (
    <Window title="Мои законы" width={680} height={720}>
      <Window.Content fitted className="AiOS">
        <NeuralShell
          application="Реестр директив"
          telemetry={data.display_telemetry}
        >
          <NetworkHeader
            title={data.identity || 'ИИ'}
            signal={data.available ? 'nominal' : 'degraded'}
            status="ЛИЧНЫЙ ДОСТУП"
            subtitle="Действующие законы вашего ИИ. Список обновляется при изменении набора."
          />
          <Section
            title="Действующие директивы"
            buttons={
              <Button
                icon="comment"
                disabled={!data.available}
                onClick={() => act('print_laws')}
                tooltip="Показать законы только вам в игровом чате"
              >
                Показать в чате
              </Button>
            }
          >
            <div className="AiOS__lawSummary">
              <span>ЗАКОНОВ: {laws.length}</span>
              <span>РЕЖИМ: ПРОСМОТР</span>
            </div>
            {!data.available ? (
              <NoticeBox>Список законов не загружен.</NoticeBox>
            ) : !laws.length ? (
              <NoticeBox>В действующем наборе нет законов.</NoticeBox>
            ) : (
              <div className="AiOS__lawList">
                {laws.map((law, index) => (
                  <article
                    key={index}
                    className={`AiOS__law AiOS__law--${law.kind || 'core'}`}
                    aria-label={`Закон ${law.number}`}
                  >
                    <div className="AiOS__lawNumber" aria-hidden="true">
                      <span>ЗАКОН</span>
                      <strong>{law.number}</strong>
                    </div>
                    <div className="AiOS__lawBody">
                      <div className="AiOS__lawType">
                        {lawLabels[law.kind] || lawLabels.core}
                      </div>
                      <div className="AiOS__lawText">{law.text}</div>
                    </div>
                    {law.kind === 'ion' && (
                      <span
                        className="AiOS__lawInterference"
                        aria-hidden="true"
                      />
                    )}
                  </article>
                ))}
              </div>
            )}
          </Section>
          <div className="AiOS__observationCaption">
            Порядок и номера соответствуют штатному списку законов. Это личный
            просмотр; законы не объявляются экипажу.
          </div>
        </NeuralShell>
      </Window.Content>
    </Window>
  );
}
