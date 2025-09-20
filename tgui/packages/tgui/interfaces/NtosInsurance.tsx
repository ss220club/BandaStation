import {
  Box,
  Button,
  Dropdown,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { useEffect, useState } from 'react';

const DEFAULT_BILL_REASON_RU = 'Медицинские услуги';
const BILL_MAX_AMOUNT = 100_000;
const BILL_STEP = 10;

type Data = {
  name: string | null;
  insurance_current: string;
  insurance_desired: string;
  payer_account_id: number;
  is_dept: boolean;
  is_med_staff?: boolean;
  is_cmo?: boolean;
  crew_names?: string[];
  surgeries?: { name: string; advanced: boolean; price: number }[];
  surgeries_count?: number;
  pending_bills?: {
    id: number;
    amount: number;
    reason?: string;
    issuer?: string;
    expired?: boolean;
  }[];
  issued_bills?: {
    id: number;
    amount: number;
    reason?: string;
    patient?: string;
  }[];
  cmo_history?: {
    id: number;
    issuer: string;
    patient: string;
    amount: number;
    accepted_at: string;
  }[];
  cmo_insurance_income_total?: number;
  cmo_kiosk_report?: { total: number; covered: number };
};

enum InsuranceTier {
  None = 0,
  Standard = 1,
  Premium = 2,
}

const tierOptions = [
  {
    key: 'none',
    title: 'Нет',
    description: 'Страховки нет.',
    tier: InsuranceTier.None,
  },
  {
    key: 'standard',
    title: 'Стандарт',
    description: 'Скидка в медкиоске: 50%.',
    tier: InsuranceTier.Standard,
  },
  {
    key: 'premium',
    title: 'Премиум',
    description: 'Скидка в медкиоске: 100%.',
    tier: InsuranceTier.Premium,
  },
];

const tierMap = tierOptions.reduce<Record<string, string>>((acc, t) => {
  acc[t.key] = t.title;
  return acc;
}, {});

function tierLabel(v: string) {
  return tierMap[(v || '').toLowerCase()] || 'Нет';
}

export function NtosInsurance() {
  return (
    <NtosWindow width={560} height={650} title="Менеджер страховки">
      <NtosWindow.Content>
        <InsuranceContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
}

function InsuranceContent() {
  const { data } = useBackend<Data>();
  const { name } = data;
  const [tab, setTab] = useState<'billing' | 'tiers' | 'logs'>('billing');

  if (!name) {
    return (
      <NoticeBox danger>
        Вставьте ID‑карту, чтобы управлять страховкой.
      </NoticeBox>
    );
  }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Tabs textAlign="center">
          <Tabs.Tab
            selected={tab === 'billing'}
            onClick={() => setTab('billing')}
          >
            Биллинг
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 'tiers'} onClick={() => setTab('tiers')}>
            Тарифы
          </Tabs.Tab>
          {Boolean(data.is_cmo) ? (
            <Tabs.Tab selected={tab === 'logs'} onClick={() => setTab('logs')}>
              Логи
            </Tabs.Tab>
          ) : null}
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        {tab === 'billing' && <BillingTab />}
        {tab === 'tiers' && <TiersTab />}
        {tab === 'logs' && Boolean(data.is_cmo) && <CmoLogs />}
      </Stack.Item>
    </Stack>
  );
}

function BillingTab() {
  const { act, data } = useBackend<Data>();
  const [patient, setPatient] = useState('');
  const [amount, setAmount] = useState(0);
  const [reason, setReason] = useState(DEFAULT_BILL_REASON_RU);
  const pendingBills = data.pending_bills ?? [];
  const issuedBills = data.issued_bills ?? [];
  const surgeries = data.surgeries ?? [];
  const [surgeryIdx, setSurgeryIdx] = useState<string>('');
  const [localPending, setLocalPending] = useState(pendingBills);
  const [localIssued, setLocalIssued] = useState(issuedBills);

  useEffect(() => setLocalPending(pendingBills), [data.pending_bills]);
  useEffect(() => setLocalIssued(issuedBills), [data.issued_bills]);

  function handleSelectSurgery(value: string | number) {
    const idx = Number(value);
    if (!Number.isNaN(idx) && surgeries[idx]) {
      const s = surgeries[idx];
      setSurgeryIdx(String(idx));
      setAmount(s.price || 0);
      setReason(s.name || DEFAULT_BILL_REASON_RU);
    } else {
      setSurgeryIdx('');
    }
  }

  function handleSelectPatient(value: string | number) {
    setPatient(String(value));
    setAmount(0);
    setReason(DEFAULT_BILL_REASON_RU);
  }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Статус страховки">
          <LabeledList>
            <LabeledList.Item label="Имя">{data.name}</LabeledList.Item>
            <LabeledList.Item label="Текущий">
              {tierLabel(data.insurance_current)}
            </LabeledList.Item>
            <LabeledList.Item label="Желаемый">
              {tierLabel(data.insurance_desired)}
            </LabeledList.Item>
            <LabeledList.Item label="Счёт страховки">
              {data.payer_account_id > 0 ? data.payer_account_id : '—'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      {localPending.length ? (
        <Stack.Item>
          <Section title="Счета к оплате">
            <LabeledList>
              {localPending.map((b) => (
                <LabeledList.Item
                  key={b.id}
                  label={`От: ${b.issuer || 'Медотдел'}`}
                  buttons={
                    <>
                      <Button
                        onClick={() => {
                          setLocalPending((list) => list.filter((x) => x.id !== b.id));
                          act('accept_bill', { id: b.id });
                        }}
                        disabled={b.expired}
                      >
                        Оплатить
                      </Button>
                      <Button
                        onClick={() => {
                          setLocalPending((list) => list.filter((x) => x.id !== b.id));
                          act('decline_bill', { id: b.id });
                        }}
                        ml={1}
                      >
                        Отклонить
                      </Button>
                    </>
                  }
                >
                  Сумма: {b.amount} кр. — {b.reason || DEFAULT_BILL_REASON_RU}
                  {Boolean(b.expired) && (
                    <Box inline ml={1} color="bad">
                      (истёк срок)
                    </Box>
                  )}
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Stack.Item>
      ) : null}

      {Boolean(data.is_med_staff) ? (
        <Stack.Item>
          <Section title="Выставить счёт пациенту">
            <LabeledList>
              <LabeledList.Item label="Имя пациента">
                <Dropdown
                  selected={patient}
                  displayText={patient || 'Выберите...'}
                  options={(data.crew_names ?? []).map((n) => ({
                    value: n,
                    displayText: n,
                  }))}
                  onSelected={handleSelectPatient}
                  width="60%"
                />
              </LabeledList.Item>
              <LabeledList.Item label="Операция">
                <Dropdown
                  selected={surgeryIdx}
                  displayText={
                    surgeryIdx !== '' && surgeries[Number(surgeryIdx)]
                      ? `${surgeries[Number(surgeryIdx)].name} — ${surgeries[Number(surgeryIdx)].price} кр.`
                      : surgeries.length ? 'Выберите...' : 'Нет данных'
                  }
                  options={surgeries.map((s, i) => ({
                    value: String(i),
                    displayText: `${s.name} — ${s.price} кр.${s.advanced ? ' • продв.' : ''}`,
                  }))}
                  onSelected={handleSelectSurgery}
                  disabled={surgeries.length === 0}
                  width="60%"
                />
                {surgeryIdx !== '' && (
                  <Button ml={1} onClick={() => setSurgeryIdx('')}>
                    Сбросить
                  </Button>
                )}
              </LabeledList.Item>
              <LabeledList.Item label="Сумма">
                <NumberInput
                  value={amount}
                  minValue={0}
                  maxValue={BILL_MAX_AMOUNT}
                  step={BILL_STEP}
                  width="25%"
                  onChange={setAmount}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Основание">
                <Input value={reason} onChange={setReason} width="60%" />
              </LabeledList.Item>
            </LabeledList>
            <Box mt={1}>
              <Button
                color="bad"
                disabled={!patient || amount <= 0}
                onClick={() =>
                  act('bill_patient', { name: patient, amount, reason })
                }
              >
                Выставить счёт
              </Button>
            </Box>
          </Section>
        </Stack.Item>
      ) : null}

      {Boolean(data.is_med_staff) && localIssued.length ? (
        <Stack.Item>
          <Section title="Выставленные счета">
            <LabeledList>
              {localIssued.map((b) => (
                <LabeledList.Item
                  key={b.id}
                  label={`Пациент: ${b.patient || '—'}`}
                  buttons={
                    <Button.Confirm
                      color="bad"
                      onClick={() => {
                        setLocalIssued((list) => list.filter((x) => x.id !== b.id));
                        act('cancel_bill', { id: b.id });
                      }}
                    >
                      Отменить
                    </Button.Confirm>
                  }
                >
                  Сумма: {b.amount} кр. — {b.reason || DEFAULT_BILL_REASON_RU}
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Stack.Item>
      ) : null}
    </Stack>
  );
}

function TiersTab() {
  const { act, data } = useBackend<Data>();
  const desired = (data.insurance_desired || '').toLowerCase();
  const tierDisabled = !data.name || data.is_dept || data.payer_account_id <= 0;

  return (
    <Section title="Тарифы страховки">
      <Stack>
        {tierOptions.map((t, i) => (
          <Stack.Item key={t.key} grow ml={i === 0 ? 0 : 1}>
            <Section title={t.title}>
              <Box>{t.description}</Box>
              <Box mt={1}>
                <Button
                  selected={desired === t.key}
                  disabled={tierDisabled || desired === t.key}
                  onClick={() => act('set_tier', { tier: t.tier })}
                >
                  Выбрать
                </Button>
              </Box>
            </Section>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
}

function CmoLogs() {
  const { act, data } = useBackend<Data>();
  const hist = data.cmo_history ?? [];
  const [localHist, setLocalHist] = useState(hist);
  useEffect(() => setLocalHist(hist), [data.cmo_history]);
  const kiosk = data.cmo_kiosk_report ?? { total: 0, covered: 0 };
  const totalInsurance = data.cmo_insurance_income_total ?? 0;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Принятые счета">
          <LabeledList>
            {localHist.length === 0 && <LabeledList.Item label="Нет данных" />}
            {localHist.map((h) => (
              <LabeledList.Item
                key={h.id}
                label={`Пациент: ${h.patient}`}
                buttons={
                  <Button.Confirm
                    color="bad"
                    onClick={() => {
                      setLocalHist((list) => list.filter((x) => x.id !== h.id));
                      act('cmo_refund', { id: h.id });
                    }}
                  >
                    Вернуть
                  </Button.Confirm>
                }
              >
                Сумма: {h.amount} кр. — От: {h.issuer} — Время: {h.accepted_at}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Страховые взносы (payroll)">
          <Box>Итого поступило: {totalInsurance} кр.</Box>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Отчёт по вендоматам">
          <LabeledList>
            <LabeledList.Item label="Выручка">{`${kiosk.total} кр.`}</LabeledList.Item>
            <LabeledList.Item label="Покрыто страховкой">{`${kiosk.covered} кр.`}</LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
}
