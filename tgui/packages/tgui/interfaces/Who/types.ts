import { BooleanLike } from 'tgui-core/react';

export type WhoData = {
  user: User;
  subject: Subject;
  clients: Record<string, Client[]>;
  modalOpen: BooleanLike;
};

type User = {
  ckey: string;
  admin: BooleanLike;
  ping: Ping;
};

type Subject = {
  key: string | null;
  type: string | null;
  gender: string | null;
  state: string | null;
  ping: Ping | null;
  name: SubjectName | null;
  role: SubjectRole | null;
  health: SubjectHealth | null;
  location: SubjectLocation | null;
  accountAge: number | null;
  accountIp: string | null;
  byondVersion: number | null;
  byondBuild: number | null;
};

type SubjectName = {
  real: string;
  mind: string;
};

type SubjectRole = {
  assigned: string;
  antagonist: string[];
};

type SubjectHealth = {
  brute: number;
  burn: number;
  toxin: number;
  oxygen: number;
  brain: number;
  stamina: number;
};

type SubjectLocation = {
  area: string;
  x: number;
  y: number;
  z: number;
};

type Client = {
  ckey: string;
  ping: Ping;
  status: Status | null;
  adminRank: BooleanLike | null;
  mobRef: string | null;
  accountAge: number | null;
};

type Ping = {
  lastPing: number;
  avgPing: number;
};

type Status = {
  where: string;
  state: string;
  antag: BooleanLike;
};
