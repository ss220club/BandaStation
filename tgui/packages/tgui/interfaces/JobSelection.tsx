import { toMerged } from 'es-toolkit';
import { Color } from 'tgui-core/color';
import {
  Box,
  Button,
  Icon,
  NoticeBox,
  Section,
  Stack,
  StyleableSection,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
// SS220 EDIT - START
import { retainAvailableLatejoinJobs } from '../bandastation/job_slots_preferences/latejoin';
import {
  LatejoinJobIcon,
  LatejoinJobTooltip,
  latejoinJobTitle,
} from '../bandastation/jobs/LatejoinJob';
// SS220 EDIT - END
import {
  DEPARTMENTS_RU,
  JOBS_RU,
  ReverseJobsRu,
} from '../bandastation/ru_jobs'; // BANDASTATION EDIT
import { Window } from '../layouts';
import { JOB2ICON } from './common/JobToIcon';

type Job = {
  unavailable_reason: string | null;
  command: BooleanLike;
  open_slots: number;
  used_slots: number;
  prioritized: BooleanLike;
  description: string;
  jobIcon: string;
};

type Department = {
  color: string;
  jobs: Record<string, Job>;
  open_slots: number;
};

type Data = {
  departments_static: Record<string, Department>;
  departments: Record<string, Department>;
  alert_state: string;
  shuttle_status: string;
  disable_jobs_for_non_observers: BooleanLike;
  priority: BooleanLike;
  round_duration: string;
  edit_slot: number; // SS220 EDIT: server profile context.
};

type JobEntryProps = {
  jobName: string;
  job: Job;
  department: Department;
  jobIcon: string;
  onClick: () => void;
};

function JobEntry(props: JobEntryProps) {
  const { jobName, job, department, onClick } = props;

  const jobIcon = JOB2ICON[ReverseJobsRu(jobName)] || null;

  return (
    <Button
      fluid
      style={{
        // Try not to think too hard about this one.
        backgroundColor: job.unavailable_reason
          ? '#949494' // Grey background
          : job.prioritized
            ? '#16fc0f' // Bright green background
            : Color.fromHex(department.color).darken(10).toString(),
        color: job.unavailable_reason
          ? '#616161' // Dark grey font
          : Color.fromHex(department.color).darken(90).toString(),
        fontSize: '1.1rem',
        cursor: job.unavailable_reason ? 'initial' : 'pointer',
      }}
      tooltip={
        // SS220 EDIT - START
        <LatejoinJobTooltip job={job}>
          {job.unavailable_reason ||
            (job.prioritized ? (
              <>
                <p style={{ marginTop: '0px' }}>
                  <b>The HoP wants more people in this job!</b>
                </p>
                {job.description}
              </>
            ) : (
              job.description
            ))}
        </LatejoinJobTooltip>
        // SS220 EDIT - END
      }
      tooltipPosition="top"
      onClick={() => {
        !job.unavailable_reason && onClick();
      }}
    >
      <Stack fill>
        {/* SS220 EDIT - START */}
        <LatejoinJobIcon job={job}>
          {jobIcon && (
            <Stack.Item>
              <Icon style={{ marginRight: '0.1em' }} name={jobIcon} />
            </Stack.Item>
          )}
        </LatejoinJobIcon>
        {/* SS220 EDIT - END */}
        <Stack.Item grow>
          {job.command ? (
            <b>{latejoinJobTitle(job, JOBS_RU[jobName] || jobName)}</b>
          ) : (
            latejoinJobTitle(job, JOBS_RU[jobName] || jobName)
          )}
        </Stack.Item>
        <Stack.Item>
          <span
            style={{
              whiteSpace: 'nowrap',
            }}
          >
            {job.used_slots} / {job.open_slots}
          </span>
        </Stack.Item>
      </Stack>
    </Button>
  );
}

type DepartmentEntryProps = {
  name: string;
  department: Department;
};

function DepartmentEntry(props: DepartmentEntryProps) {
  const { name, department } = props;
  const { act, data } = useBackend<Data>(); // SS220 EDIT: capture the rendered slot.

  return (
    <Box minWidth="30%">
      <StyleableSection
        title={
          <>
            {name}
            <span
              style={{
                fontSize: '1rem',
                whiteSpace: 'nowrap',
                position: 'absolute',
                right: '1em',
                color: Color.fromHex(department.color).darken(60).toString(),
              }}
            >
              {`позиций доступно: ${department.open_slots}`}
            </span>
          </>
        }
        style={{
          backgroundColor: department.color,
          marginBottom: '1em',
          breakInside: 'avoid-column',
        }}
        titleStyle={{
          'border-bottom-color': Color.fromHex(department.color)
            .darken(50)
            .toString(),
        }}
        textStyle={{
          color: Color.fromHex(department.color).darken(80).toString(),
        }}
      >
        <Stack vertical>
          {Object.entries(department.jobs).map(([name, job]) => (
            <Stack.Item key={name}>
              <JobEntry
                key={name}
                jobName={name}
                job={job}
                jobIcon={job.jobIcon}
                department={department}
                onClick={() => {
                  act('select_job', { job: name, edit_slot: data.edit_slot }); // SS220 EDIT
                }}
              />
            </Stack.Item>
          ))}
        </Stack>
      </StyleableSection>
    </Box>
  );
}

export function JobSelection(props) {
  const { act, data } = useBackend<Data>();
  if (!data?.departments_static) {
    return null; // Stop TGUI whitescreens with TGUI-dev!
  }

  const departments: Record<string, Department> = toMerged(
    data.departments,
    data.departments_static,
  );

  retainAvailableLatejoinJobs(departments, data.departments); // SS220 EDIT: prune hidden entries after the native merge.

  const { shuttle_status, round_duration } = data;

  return (
    <Window width={1012} height={shuttle_status ? 690 : 666 /* Hahahahahaha */}>
      <Window.Content>
        <Section
          buttons={
            <Button
              // SS220 EDIT - START
              onClick={() =>
                act('select_job', { job: 'Random', edit_slot: data.edit_slot })
              }
              // SS220 EDIT - END
              tooltip="Случайно выбрать профессию. Вы можете повторно выбирать случайную профессию или отказаться от этого."
            >
              Случайная профессия!
            </Button>
          }
          fill
          scrollable
          title={
            <>
              {shuttle_status && <NoticeBox info>{shuttle_status}</NoticeBox>}
              <Box as="span" color="label">
                It is currently {round_duration} into the shift.
              </Box>
            </>
          }
        >
          <Box style={{ columns: '20em' }}>
            {Object.entries(departments).map(([name, department]) => (
              <DepartmentEntry
                key={name}
                name={DEPARTMENTS_RU[name] || name}
                department={department}
              />
            ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
}
