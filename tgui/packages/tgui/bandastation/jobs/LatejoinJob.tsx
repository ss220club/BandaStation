import type { ReactNode } from 'react';
import { Box, Stack } from 'tgui-core/components';

import { JobHudIcon } from './JobHudIcon';

type JobDisplay = {
  description: string;
  public_title?: string;
  character_profile?: string;
  job_icon?: string;
};

export function LatejoinJobTooltip(props: {
  job: JobDisplay;
  children: ReactNode;
}) {
  return (
    <>
      {props.children}
      {props.job.character_profile && (
        <Box mt={0.5} italic>
          {props.job.character_profile}
        </Box>
      )}
    </>
  );
}

export function LatejoinJobIcon(props: {
  job: JobDisplay;
  children: ReactNode;
}) {
  return props.job.job_icon ? (
    <Stack.Item>
      <JobHudIcon icon={props.job.job_icon} />
    </Stack.Item>
  ) : (
    props.children
  );
}

export function latejoinJobTitle(job: JobDisplay, fallback: string): string {
  return job.public_title || fallback;
}
