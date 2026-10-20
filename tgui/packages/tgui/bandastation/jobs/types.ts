export type JobVariantsData = {
  job_variants?: Record<
    string,
    {
      title: string | null;
      selected: string | null;
      icon: string;
      variants: { id: string; name: string }[];
      required_tier: number;
      lock_reason: string | null;
    }
  >;
};
