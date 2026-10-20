import { Color } from 'tgui-core/color';
import {
  Box,
  Button,
  NoticeBox,
  Section,
  Stack,
  StyleableSection,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
// BANDASTATION ADDITION START: selected-character data and server-authoritative merge.
import { mergeLatejoinDepartments } from '../bandastation/job_slots_preferences/latejoin';
import type {
  LatejoinCharacterData,
  LatejoinDepartment,
  LatejoinDepartmentAvailability,
  LatejoinDepartmentMetadata,
  LatejoinJob,
} from '../bandastation/job_slots_preferences/types';
import { JobHudIcon } from '../bandastation/jobs/JobHudIcon'; // BANDASTATION ADDITION
// BANDASTATION ADDITION END
import {
  DEPARTMENTS_RU,
  JOBS_RU,
  ReverseJobsRu,
} from '../bandastation/ru_jobs'; // BANDASTATION EDIT
import { Window } from '../layouts';
import { JOB2ICON } from './common/JobToIcon';

type Data = {
  departments_static: Record<string, LatejoinDepartmentMetadata>;
  departments: Record<string, LatejoinDepartmentAvailability>;
  alert_state: string;
  shuttle_status: string;
  disable_jobs_for_non_observers: BooleanLike;
  priority: BooleanLike;
  round_duration: string;
} & LatejoinCharacterData; // BANDASTATION ADDITION

type JobEntryProps = {
  jobName: string;
  job: LatejoinJob;
  department: LatejoinDepartment;
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
        <>
          {job.prioritized && !job.unavailable_reason && (
            <Box bold>The HoP wants more people in this job!</Box>
          )}
          <Box>{job.unavailable_reason || job.description}</Box>
          <Box mt={0.5} italic>
            {job.character_profile}
          </Box>
        </>
      }
      tooltipPosition="top"
      onClick={() => {
        !job.unavailable_reason && onClick();
      }}
    >
      <Stack fill>
        {(job.job_icon || jobIcon) && ( // BANDASTATION EDIT: shared modular icon renderer.
          <Stack.Item>
            <JobHudIcon icon={job.job_icon} fallback={jobIcon} />
          </Stack.Item>
        )}
        <Stack.Item grow>
          {job.command ? (
            <b>{job.public_title || JOBS_RU[jobName] || jobName}</b>
          ) : (
            job.public_title || JOBS_RU[jobName] || jobName
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
  department: LatejoinDepartment;
};

function DepartmentEntry(props: DepartmentEntryProps) {
  const { name, department } = props;
  const { act, data } = useBackend<Data>();

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
                  act('select_job', { job: name, edit_slot: data.edit_slot });
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

  // BANDASTATION EDIT: enrich only the current server list with static metadata.
  const departments = mergeLatejoinDepartments(
    data.departments,
    data.departments_static,
  );

  const { shuttle_status, round_duration } = data;

  return (
    <Window width={1012} height={shuttle_status ? 690 : 666 /* Hahahahahaha */}>
      <Window.Content>
        <Section
          buttons={
            <Button
              onClick={() =>
                act('select_job', { job: 'Random', edit_slot: data.edit_slot })
              }
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
