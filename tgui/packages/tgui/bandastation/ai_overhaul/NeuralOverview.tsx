import { Button, NoticeBox, ProgressBar, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { NeuralGlyph } from './NeuralGlyph';
import { safeRatio } from './resourceMath';

type OverviewData = {
  core_status: string;
  core_status_label?: string;
  current_cpu: number;
  used_cpu: number;
  current_ram: number;
  used_ram: number;
  temperature: number;
  temperature_limit: number;
  telemetry_recording: BooleanLike;
  available_projects: {
    name: string;
    display_name?: string;
    assigned_cpu: number;
    research_progress: number;
    research_cost: number;
  }[];
  completed_projects: {
    name: string;
    display_name?: string;
    running: BooleanLike;
  }[];
  events: { id: number; time: string; message: string; severity: string }[];
};

export function NeuralOverview({
  data,
  onNavigate,
}: {
  data: OverviewData;
  onNavigate: (destination: string) => void;
}) {
  const jobs = (data.available_projects || []).filter(
    (project) => project.assigned_cpu > 0,
  );
  const programs = (data.completed_projects || []).filter(
    (project) => project.running,
  );
  const margin =
    data.temperature_limit > 0 && Number.isFinite(data.temperature)
      ? data.temperature_limit - data.temperature
      : undefined;
  return (
    <div className="AiOS__overview">
      <Section className="AiOS__overviewModel" title="Распределение ресурсов">
        <div className="AiOS__resourceModel">
          <div className="AiOS__modelEndpoint">
            <span className="AiOS__eyebrow">CPU / ВЫДЕЛЕНО</span>
            <strong>
              {(data.current_cpu || 0).toFixed(2)} <small>ТГц</small>
            </strong>
            <ProgressBar value={data.used_cpu || 0}>
              {Math.round((data.used_cpu || 0) * 100)}% выделено{' '}
            </ProgressBar>
          </div>
          <div className="AiOS__modelCore" aria-hidden="true">
            <NeuralGlyph />
          </div>
          <div className="AiOS__modelEndpoint">
            <span className="AiOS__eyebrow">ПАМЯТЬ / ИСПОЛЬЗУЕТСЯ</span>
            <strong>
              {data.used_ram || 0} <small>/ {data.current_ram || 0} ТБ</small>
            </strong>
            <ProgressBar value={safeRatio(data.used_ram, data.current_ram)}>
              {Math.max(0, data.current_ram - data.used_ram)} ТБ свободно{' '}
            </ProgressBar>
          </div>
        </div>
        <div className="AiOS__modelReadout">
          <span>ЯДРО / {data.core_status_label || 'Неизвестно'}</span>
          <span>
            {margin === undefined
              ? 'ЗАПАС ПО ТЕМПЕРАТУРЕ / НЕИЗВЕСТЕН'
              : `ЗАПАС ПО ТЕМПЕРАТУРЕ / ${margin.toFixed(1)} К`}
          </span>
        </div>
      </Section>
      <div className="AiOS__overviewColumns">
        <Section
          title="Очередь исследований"
          buttons={
            <Button color="transparent" onClick={() => onNavigate('research')}>
              {' '}
              К исследованиям →{' '}
            </Button>
          }
        >
          {!jobs.length && <NoticeBox>Проектам не выделен CPU.</NoticeBox>}
          {jobs.map((project) => (
            <div className="AiOS__queueEntry" key={project.name}>
              <strong>{project.display_name || project.name}</strong>
              <span>{Math.round(project.assigned_cpu * 100)}% CPU</span>
              <ProgressBar
                value={safeRatio(
                  project.research_progress,
                  project.research_cost,
                )}
              >
                {project.research_progress.toFixed(0)} / {project.research_cost}{' '}
                CPU·с{' '}
              </ProgressBar>
            </div>
          ))}
          <div className="AiOS__overviewSummary">
            CPU выделен: {jobs.length} / Всего проектов:{' '}
            {data.available_projects?.length || 0}
          </div>
        </Section>
        <Section
          title="Запущенные программы"
          buttons={
            <Button color="transparent" onClick={() => onNavigate('programs')}>
              {' '}
              К программам →{' '}
            </Button>
          }
        >
          {!programs.length && <NoticeBox>Запущенных программ нет.</NoticeBox>}
          {programs.map((program) => (
            <div key={program.name} className="AiOS__programEntry">
              <span className="AiOS__statusDot" />
              <span className="AiOS__programName">
                {program.display_name || program.name}
              </span>
            </div>
          ))}
          <div className="AiOS__overviewSummary">
            {programs.length} запущено / {data.completed_projects?.length || 0}{' '}
            установлено
          </div>
        </Section>
      </div>
      <Section
        title="Последние наблюдения"
        buttons={
          <Button color="transparent" onClick={() => onNavigate('events')}>
            {' '}
            К журналу →{' '}
          </Button>
        }
      >
        <div className="AiOS__observationCaption">
          {data.telemetry_recording
            ? 'Запись наблюдений включена'
            : 'Телеметрия недоступна'}{' '}
          · Время обнаружения; события вне вашей сети неизвестны.{' '}
        </div>
        {!data.events?.length && <NoticeBox>Местных наблюдений нет.</NoticeBox>}
        {(data.events || []).slice(0, 3).map((event) => (
          <div
            key={event.id}
            className={`AiOS__logEntry${event.severity === 'warning' ? ' AiOS__logEntry--warning' : ''}`}
          >
            <time>{event.time}</time>
            <span>{event.message}</span>
          </div>
        ))}
      </Section>
    </div>
  );
}
