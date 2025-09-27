import type { BooleanLike } from 'tgui-core/react';

export type MedicalRecordData = {
  assigned_view: string;
  authenticated: BooleanLike;
  station_z: BooleanLike;
  physical_statuses: string[];
  mental_statuses: string[];
  records: MedicalRecord[];
  min_age: number;
  max_age: number;
};

export type MedicalRecord = {
  age: number;
  blood_type: string;
  crew_ref: string;
  dna: string;
  gender: string;
  major_disabilities: string;
  minor_disabilities: string;
  physical_status: string;
  mental_status: string;
  name: string;
  notes: MedicalNote[];
  quirk_notes: string;
  rank: string;
  species: string;
  trim: string;
  insurance_current?: string;
  insurance_desired?: string;
  insurance_payer_account_id?: number;
};

export type MedicalNote = {
  author: string;
  content: string;
  note_ref: string;
  time: string;
};
