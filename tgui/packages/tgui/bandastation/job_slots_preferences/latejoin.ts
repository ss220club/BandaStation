import type {
  LatejoinDepartment,
  LatejoinDepartmentAvailability,
  LatejoinDepartmentMetadata,
} from './types';

// Static metadata may enrich the current server list, never restore hidden jobs.
export function mergeLatejoinDepartments(
  departments: Record<string, LatejoinDepartmentAvailability>,
  metadata: Record<string, LatejoinDepartmentMetadata>,
): Record<string, LatejoinDepartment> {
  return Object.fromEntries(
    Object.entries(departments).map(([name, department]) => [
      name,
      {
        ...metadata[name],
        ...department,
        jobs: Object.fromEntries(
          Object.entries(department.jobs).map(([jobName, job]) => [
            jobName,
            {
              ...metadata[name]?.jobs[jobName],
              ...job,
            },
          ]),
        ),
      },
    ]),
  );
}
