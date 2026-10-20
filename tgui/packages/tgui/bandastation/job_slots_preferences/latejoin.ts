type Departments = Record<string, { jobs: Record<string, unknown> }>;

// Apply visibility to the result of the native merge; metadata cannot restore a hidden job.
export function retainAvailableLatejoinJobs(
  departments: Departments,
  available: Departments,
) {
  for (const name of Object.keys(departments)) {
    if (!available[name]) {
      delete departments[name];
      continue;
    }
    for (const job of Object.keys(departments[name].jobs)) {
      if (!Object.hasOwn(available[name].jobs, job)) {
        delete departments[name].jobs[job];
      }
    }
  }
}
