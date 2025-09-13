import { Box, Button, Dropdown, Input, LabeledList, NoticeBox, NumberInput, ProgressBar, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { PropsWithChildren, useEffect, useMemo, useRef, useState } from 'react';

// Loader timing constants
const MIN_LOADER_MS = 900; // Keep loader visible at least this long
const FINALIZE_DELAY_MS = 120; // Small delay before hiding loader
const STEP_WITH_NAME = 0.12; // Progress step when data is present
const STEP_NO_NAME = 0.02; // Progress step when data is not present yet
const CAP_WITHOUT_NAME = 0.92; // Cap progress until name appears

// Busy handling
const BUSY_FALLBACK_MS = 2500; // Fallback to clear busy if no update comes
// Texts
const DEFAULT_BILL_REASON_RU = 'Медицинские услуги';
// Ephemeral UI message timeout
const BILL_MSG_AUTOHIDE_MS = 4000;

// Tier helpers
type TierKey = 'none' | 'standard' | 'premium';
const TIER_LABEL_RU: Record<TierKey, string> = {
  none: 'Нет',
  standard: 'Стандарт',
  premium: 'Премиум',
};
const isTierKey = (v: string): v is TierKey => v === 'none' || v === 'standard' || v === 'premium';
const toTierKey = (v: string | null | undefined): TierKey | null => {
  if (!v) return null;
  const s = v.toLowerCase();
  return isTierKey(s) ? s : null;
};
const tierLabelRu = (v: string) => {
  const key = toTierKey(v);
  return key ? TIER_LABEL_RU[key] : '—';
};
// Normalize BYOND assoc-lists to arrays for safe rendering
const toArray = <T,>(v: unknown): T[] => (Array.isArray(v) ? v : v ? (Object.values(v as Record<string, T>)) : []);

type Data = {
  name: string | null;
  insurance_current: string;
  insurance_desired: string;
  payer_account_id: number;
  is_dept: boolean;
  is_med_staff?: boolean;
  is_cmo?: boolean;
  bill_last_msg?: string;
  bill_last_ok?: boolean;
  crew_names?: string[];
  surgeries?: { name: string; price: number; advanced?: boolean }[];
  tariffs?: { name: string; price: number }[];
  pending_bills?: { id: number; amount: number; reason?: string; issuer?: string; created_at?: number; expired?: boolean }[];
  issued_bills?: { id: number; amount: number; reason?: string; patient?: string; created_at?: number; expired?: boolean }[];
  cmo_history?: { id: number; issuer: string; patient: string; amount: number; accepted_at: string; refunded?: boolean }[];
  cmo_insurance_income_total?: number;
  cmo_kiosk_report?: { total: number; covered: number };
};

type NtosInsuranceProps = Record<string, never>;

enum InsuranceTier {
  None = 0,
  Standard = 1,
  Premium = 2,
}
type Actions = {
  set_tier: { tier: InsuranceTier };
  bill_patient: { name: string; amount: number; reason: string };
  accept_bill: { id: number };
  decline_bill: { id: number };
  cancel_bill: { id: number };
  cmo_refund: { id: number };
};

export function NtosInsurance(_: NtosInsuranceProps) {
  const { data } = useBackend<Data>();
  const { name } = data;
  const [progress, setProgress] = useState(0);
  const [showLoader, setShowLoader] = useState(true);
  const finalizeTimeoutRef = useRef<number | null>(null);

  useEffect(() => {
    let raf = 0;
    let pct = 0;
    const start = performance.now();
    const tick = () => {
      const step = name != null ? STEP_WITH_NAME : STEP_NO_NAME;
      pct = Math.min(1, pct + step);
      if (name == null && pct > CAP_WITHOUT_NAME) pct = CAP_WITHOUT_NAME;
      setProgress(pct);
      // Fallback: if we have no account data, finalize once we reached the cap
      if (name == null && pct >= CAP_WITHOUT_NAME) {
        const elapsed = performance.now() - start;
        const remaining = Math.max(0, MIN_LOADER_MS - elapsed);
        if (finalizeTimeoutRef.current == null) {
          finalizeTimeoutRef.current = window.setTimeout(
            () => setShowLoader(false),
            FINALIZE_DELAY_MS + remaining,
          );
        }
        return;
      }
      if (pct >= 1) {
        const elapsed = performance.now() - start;
        const remaining = Math.max(0, MIN_LOADER_MS - elapsed);
        if (finalizeTimeoutRef.current == null) {
          finalizeTimeoutRef.current = window.setTimeout(
            () => setShowLoader(false),
            FINALIZE_DELAY_MS + remaining,
          );
        }
        return;
      }
      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => {
      cancelAnimationFrame(raf);
      if (finalizeTimeoutRef.current != null) {
        clearTimeout(finalizeTimeoutRef.current);
        finalizeTimeoutRef.current = null;
      }
    };
  }, [name]);

  return (
    <NtosWindow width={560} height={650} title="Менеджер страховки">
      <NtosWindow.Content scrollable>
        {showLoader ? (
          <LoadingScreen progress={progress} />
        ) : (
          <FadeIn>
            {!name ? <NoAccountPrompt /> : <InsuranceContent />}
          </FadeIn>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
}

// New prompt for absent ID card
function NoAccountPrompt() {
  return (
    <NoticeBox danger>Вставьте ID‑карту, чтобы управлять страховкой.</NoticeBox>
  );
}

function InsuranceContent() {
  const { act, data } = useBackend<Data>();
  const { name, insurance_current, insurance_desired, payer_account_id } = data;
  const [busy, setBusy] = useState(false);
  const busyTimeoutRef = useRef<number | null>(null);
  const [activeTab, setActiveTab] = useState<'billing' | 'tiers' | 'logs'>('billing');
  const [targetName, setTargetName] = useState('');
  const [billAmount, setBillAmount] = useState(0);
  const [billReason, setBillReason] = useState(DEFAULT_BILL_REASON_RU);
  const [selectedTariff, setSelectedTariff] = useState('');
  const [selectedSurgery, setSelectedSurgery] = useState('');
  // Optimistic hide of processed pending bills until backend refresh arrives
  const [hiddenPendingIds, setHiddenPendingIds] = useState<number[]>([]);
  // Reset dependent fields when target patient changes
  useEffect(() => {
    setSelectedTariff('');
    setSelectedSurgery('');
    setBillAmount(0);
    setBillReason(DEFAULT_BILL_REASON_RU);
  }, [targetName]);
  // Local, auto-hiding bill message
  const [visibleBill, setVisibleBill] = useState<{ msg: string; ok?: boolean } | null>(null);
  const billMsgTimeoutRef = useRef<number | null>(null);

  const desiredKey = toTierKey(insurance_desired);
  const baseDisabled = !name || data.is_dept || payer_account_id <= 0 || busy;
  const surgeries = toArray<{ name: string; price: number; advanced?: boolean }>(data.surgeries);
  const tariffs = toArray<{ name: string; price: number }>(data.tariffs);
  type ActFn = <K extends keyof Actions>(action: K, params: Actions[K]) => void;
  const doAct: ActFn = (action, params) => act(action, params);
  const withBusy = (fn: () => void) => {
    if (busy) return;
    setBusy(true);
    busyTimeoutRef.current = window.setTimeout(() => setBusy(false), BUSY_FALLBACK_MS);
    fn();
  };
  const withBusyAct: ActFn = (action, params) => withBusy(() => doAct(action, params));

  // Clear busy when desired tier updates, or ensure cleanup
  useEffect(() => {
    setBusy(false);
    if (busyTimeoutRef.current != null) {
      clearTimeout(busyTimeoutRef.current);
      busyTimeoutRef.current = null;
    }
  }, [insurance_desired]);

  // Reset busy when billing-related server state updates
  useEffect(() => {
    setBusy(false);
    if (busyTimeoutRef.current != null) {
      clearTimeout(busyTimeoutRef.current);
      busyTimeoutRef.current = null;
    }
  }, [data.bill_last_msg, data.bill_last_ok, data.pending_bills?.length, data.issued_bills?.length]);

  // Reconcile hidden ids with fresh backend data
  const pendingIdsKey = useMemo(
    () => (data.pending_bills || []).map((b) => b.id).join(','),
    [data.pending_bills],
  );
  useEffect(() => {
    const current = new Set((data.pending_bills || []).map((b) => b.id));
    setHiddenPendingIds((ids) => ids.filter((id) => current.has(id)));
  }, [pendingIdsKey]);

  // Auto-hide billing message after a short delay, even if backend keeps it
  useEffect(() => {
    if (!data.bill_last_msg) return;
    // Show new message
    setVisibleBill({ msg: data.bill_last_msg, ok: data.bill_last_ok });
    if (billMsgTimeoutRef.current != null) {
      clearTimeout(billMsgTimeoutRef.current);
      billMsgTimeoutRef.current = null;
    }
    billMsgTimeoutRef.current = window.setTimeout(() => {
      setVisibleBill(null);
      billMsgTimeoutRef.current = null;
    }, BILL_MSG_AUTOHIDE_MS);
    return () => {
      if (billMsgTimeoutRef.current != null) {
        clearTimeout(billMsgTimeoutRef.current);
        billMsgTimeoutRef.current = null;
      }
    };
  }, [data.bill_last_msg, data.bill_last_ok]);

  useEffect(() => () => {
    if (busyTimeoutRef.current != null) {
      clearTimeout(busyTimeoutRef.current);
      busyTimeoutRef.current = null;
    }
  }, []);

  return (
    <>
      <Box mb={1}>
        <Tabs textAlign="center">
          <Tabs.Tab selected={activeTab === 'billing'} onClick={() => setActiveTab('billing')}>
            Биллинг
          </Tabs.Tab>
          <Tabs.Tab selected={activeTab === 'tiers'} onClick={() => setActiveTab('tiers')}>
            Тарифы
          </Tabs.Tab>
          {!!data.is_cmo && (
            <Tabs.Tab selected={activeTab === 'logs'} onClick={() => setActiveTab('logs')}>
              Логи
            </Tabs.Tab>
          )}
        </Tabs>
      </Box>
      {activeTab === 'tiers' ? (
        <InsuranceTiers
          desiredKey={desiredKey}
          baseDisabled={baseDisabled}
          busy={busy}
          withBusyAct={withBusyAct}
        />
      ) : activeTab === 'logs' ? (
        <CmoLogs />
      ) : (
        <Stack fill vertical>
      <Stack.Item>
        {Boolean(data.is_dept) && (
          <NoticeBox danger>
            Департаментские счета не могут управлять личной страховкой.
          </NoticeBox>
        )}
        <Section title="Статус страховки">
          <LabeledList>
            <LabeledList.Item label="Имя">{name}</LabeledList.Item>
            <LabeledList.Item label="Текущий">{tierLabelRu(insurance_current)}</LabeledList.Item>
            <LabeledList.Item label="Желаемый">{tierLabelRu(insurance_desired)}</LabeledList.Item>
            <LabeledList.Item label="Счёт страховки">
              {payer_account_id > 0 ? payer_account_id : '—'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      {visibleBill?.msg && (
        <Stack.Item>
          {visibleBill.ok ? (
            <NoticeBox success>{visibleBill.msg}</NoticeBox>
          ) : (
            <NoticeBox danger>{visibleBill.msg}</NoticeBox>
          )}
        </Stack.Item>
      )}
      {(() => {
        const visiblePending = (data.pending_bills || []).filter((b) => !hiddenPendingIds.includes(b.id));
        return visiblePending.length > 0;
      })() && (
        <Stack.Item>
          <Section title="Счета к оплате">
            <LabeledList>
              {(data.pending_bills || [])
                .filter((b) => !hiddenPendingIds.includes(b.id))
                .sort((a, b) => (b.created_at || 0) - (a.created_at || 0))
                .map((b) => (
                <LabeledList.Item
                  key={b.id}
                  label={`От: ${b.issuer || 'Медотдел'}`}
                  buttons={
                    <>
                      <Button
                        color="good"
                        disabled={busy || b.expired}
                        onClick={() => {
                      if (busy) return;
                      setHiddenPendingIds((ids) => (ids.includes(b.id) ? ids : ids.concat(b.id)));
                      withBusyAct('accept_bill', { id: b.id });
                        }}
                      >
                        Оплатить
                      </Button>
                      <Button
                        color="bad"
                        disabled={busy}
                        onClick={() => {
                          if (busy) return;
                          setHiddenPendingIds((ids) => (ids.includes(b.id) ? ids : ids.concat(b.id)));
                          withBusyAct('decline_bill', { id: b.id });
                        }}
                        ml={1}
                      >
                        Отклонить
                      </Button>
                    </>
                  }
                >
                  {`Сумма: ${b.amount} кр. — ${b.reason || DEFAULT_BILL_REASON_RU}`}
                  {!!b.expired && (
                    <Box inline ml={1} color="bad">
                      (истёк срок)
                    </Box>
                  )}
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        </Stack.Item>
      )}
      {false && (
      <Stack.Item>
        <Section title="Настройка страховки">
          <Box>
            <Button
              selected={desiredKey === 'none'}
              disabled={baseDisabled || desiredKey === 'none'}
              onClick={() => {
                if (baseDisabled || desiredKey === 'none') return;
                setBusy(true);
                busyTimeoutRef.current = window.setTimeout(() => setBusy(false), BUSY_FALLBACK_MS);
                act('set_tier', { tier: InsuranceTier.None });
              }}
            >
              Нет
            </Button>
            <Button
              selected={desiredKey === 'standard'}
              disabled={baseDisabled || desiredKey === 'standard'}
              onClick={() => {
                if (baseDisabled || desiredKey === 'standard') return;
                setBusy(true);
                busyTimeoutRef.current = window.setTimeout(() => setBusy(false), BUSY_FALLBACK_MS);
                act('set_tier', { tier: InsuranceTier.Standard });
              }}
              ml={1}
            >
              Стандарт
            </Button>
            <Button
              selected={desiredKey === 'premium'}
              disabled={baseDisabled || desiredKey === 'premium'}
              onClick={() => {
                if (baseDisabled || desiredKey === 'premium') return;
                setBusy(true);
                busyTimeoutRef.current = window.setTimeout(() => setBusy(false), BUSY_FALLBACK_MS);
                act('set_tier', { tier: InsuranceTier.Premium });
              }}
              ml={1}
            >
              Премиум
            </Button>
          </Box>
        </Section>
      </Stack.Item>
      )}
      {Boolean(data.is_med_staff) && (
        <Stack.Item>
          <Section title="Выставить счёт пациенту">
            <LabeledList>
              <LabeledList.Item label="Имя пациента">
                <Dropdown
                  selected={targetName}
                  displayText={targetName || 'Выберите...'}
                  placeholder="Выберите..."
                  options={(data.crew_names || []).map((n) => ({ displayText: n, value: n }))}
                  width="60%"
                  onSelected={(value) => {
                    setTargetName(String(value));
                    setSelectedTariff('');
                    setSelectedSurgery('');
                    setBillAmount(0);
                    setBillReason(DEFAULT_BILL_REASON_RU);
                  }}
                />
              </LabeledList.Item>
              {!!data.tariffs?.length && (
                <LabeledList.Item label="Тариф">
                  <Dropdown
                    selected={selectedTariff}
                    displayText={selectedTariff || 'Выбрать...'}
                    placeholder="Выбрать..."
                    options={(data.tariffs || []).map((t) => ({ displayText: `${t.name} — ${t.price} кр.`, value: t.name }))}
                    width="60%"
                    onSelected={(value) => {
                      const name = String(value);
                      setSelectedTariff(name);
                      const t = (data.tariffs || []).find((x) => x.name === name);
                      if (t) {
                        setBillAmount(t.price);
                        if (!billReason || billReason === DEFAULT_BILL_REASON_RU) setBillReason(name);
                      }
                    }}
                  />
                </LabeledList.Item>
              )}
              {!!data.surgeries?.length && (
                <LabeledList.Item label="Операция">
                  <Dropdown
                    selected={selectedSurgery}
                    displayText={selectedSurgery || 'Выбрать...'}
                    placeholder="Выбрать..."
                    options={(data.surgeries || []).map((s) => ({ displayText: `${s.name} — ${s.price} кр.`, value: s.name }))}
                    width="60%"
                    onSelected={(value) => {
                      const name = String(value);
                      setSelectedSurgery(name);
                      setBillReason(name);
                      const s = (data.surgeries || []).find((x) => x.name === name);
                      if (s) setBillAmount(s.price);
                    }}
                  />
                </LabeledList.Item>
              )}
              <LabeledList.Item label="Сумма">
                <NumberInput value={billAmount} minValue={0} maxValue={100000} step={10} onChange={setBillAmount} width="25%" />
              </LabeledList.Item>
              <LabeledList.Item label="Основание">
                <Input value={billReason} onChange={setBillReason} placeholder="Причина" width="60%" />
              </LabeledList.Item>
            </LabeledList>
            <Box mt={1}>
              <Button
                color="bad"
                disabled={busy || !targetName || billAmount <= 0}
                onClick={() => {
                  if (busy || !targetName || billAmount <= 0) return;
                  withBusyAct('bill_patient', { name: targetName, amount: billAmount, reason: billReason });
                }}
              >
                Выставить счёт
              </Button>
            </Box>
          </Section>
        </Stack.Item>
      )}

      {Boolean(data.is_med_staff) && Boolean(data.issued_bills?.length) && (
        <Stack.Item>
          <Section title="Выставленные счета">
            <LabeledList>
              {[...(data.issued_bills || [])]
                .sort((a, b) => (b.created_at || 0) - (a.created_at || 0))
                .map((b) => (
                  <LabeledList.Item
                    key={b.id}
                    label={`Пациент: ${b.patient || '—'}`}
                    buttons={
                      <Button.Confirm
                        color="bad"
                        disabled={busy}
                        onClick={() => {
                          if (busy) return;
                          withBusyAct('cancel_bill', { id: b.id });
                        }}
                      >
                        Удалить
                      </Button.Confirm>
                    }
                  >
                    {`Сумма: ${b.amount} кр. — ${b.reason || DEFAULT_BILL_REASON_RU}`}
                    {!!b.expired && (
                      <Box inline ml={1} color="bad">
                        (истёк срок)
                      </Box>
                    )}
                  </LabeledList.Item>
                ))}
            </LabeledList>
          </Section>
        </Stack.Item>
      )}
        </Stack>
      )}
    </>
  );
}

type InsuranceTiersProps = {
  desiredKey: TierKey | null;
  baseDisabled: boolean;
  busy: boolean;
  withBusyAct: <K extends keyof Actions>(action: K, params: Actions[K]) => void;
};

function InsuranceTiers({ desiredKey, baseDisabled, busy, withBusyAct }: InsuranceTiersProps) {
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Тарифы страховки">
          <Stack>
            <Stack.Item grow>
              <Section title="Нет">
                <Box>Без льгот. Полная стоимость услуг.</Box>
                <Box mt={1}>
                  <Button
                    selected={desiredKey === 'none'}
                    disabled={baseDisabled || desiredKey === 'none'}
                    onClick={() => {
                      if (baseDisabled || desiredKey === 'none' || busy) return;
                      withBusyAct('set_tier', { tier: InsuranceTier.None });
                    }}
                  >
                    Выбрать
                  </Button>
                </Box>
              </Section>
            </Stack.Item>
            <Stack.Item grow ml={1}>
              <Section title="Стандарт">
                <Box>Скидка в медкиоске: 50%.</Box>
                <Box mt={1}>
                  <Button
                    selected={desiredKey === 'standard'}
                    disabled={baseDisabled || desiredKey === 'standard'}
                    onClick={() => {
                      if (baseDisabled || desiredKey === 'standard' || busy) return;
                      withBusyAct('set_tier', { tier: InsuranceTier.Standard });
                    }}
                  >
                    Выбрать
                  </Button>
                </Box>
              </Section>
            </Stack.Item>
            <Stack.Item grow ml={1}>
              <Section title="Премиум">
                <Box>Скидка в медкиоске: 100%.</Box>
                <Box mt={1}>
                  <Button
                    selected={desiredKey === 'premium'}
                    disabled={baseDisabled || desiredKey === 'premium'}
                    onClick={() => {
                      if (baseDisabled || desiredKey === 'premium' || busy) return;
                      withBusyAct('set_tier', { tier: InsuranceTier.Premium });
                    }}
                  >
                    Выбрать
                  </Button>
                </Box>
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
}

function FadeIn({ children, duration = 180, offset = 6 }: PropsWithChildren<{ duration?: number; offset?: number }>) {
  const [entered, setEntered] = useState(false);
  useEffect(() => {
    const id = requestAnimationFrame(() => setEntered(true));
    return () => cancelAnimationFrame(id);
  }, []);
  return (
    <Box
      style={{
        opacity: entered ? 1 : 0,
        transform: entered ? 'translateY(0)' : `translateY(${offset}px)`,
        transition: `opacity ${duration}ms ease, transform ${duration}ms ease`,
      }}
    >
      {children}
    </Box>
  );
}

function LoadingScreen({ progress }: { progress: number }) {
  return (
    <Section title="Загрузка">
      <ProgressBar value={progress}>
        <span aria-live="polite">{Math.round(progress * 100)}%</span>
      </ProgressBar>
    </Section>
  );
}

function CmoLogs() {
  const { act, data } = useBackend<Data>();
  const hist = data.cmo_history || [];
  const kiosk = data.cmo_kiosk_report || { total: 0, covered: 0 };
  const totalInsurance = data.cmo_insurance_income_total || 0;
  const [busyId, setBusyId] = useState<number | null>(null);
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Принятые счета">
          <LabeledList>
            {hist.length === 0 && (
              <LabeledList.Item label="Нет данных" />
            )}
            {hist.map((h) => (
              <LabeledList.Item
                key={h.id}
                label={`Пациент: ${h.patient}`}
                buttons={
                  <Button.Confirm
                    color="bad"
                    disabled={h.refunded || busyId === h.id}
                    onClick={() => {
                      if (busyId != null) return;
                      setBusyId(h.id);
                      act('cmo_refund', { id: h.id });
                      setTimeout(() => setBusyId(null), 1500);
                    }}
                  >
                    {h.refunded ? 'Возвращено' : 'Вернуть'}
                  </Button.Confirm>
                }
              >
                {`Сумма: ${h.amount} кр. — От: ${h.issuer} — Время: ${h.accepted_at}`}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Страховые взносы (payroll)">
          <Box>{`Итого поступило: ${totalInsurance} кр.`}</Box>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Отчёт по вендоматам">
          <LabeledList>
            <LabeledList.Item label="Выручка">
              {`${kiosk.total} кр.`}
            </LabeledList.Item>
            <LabeledList.Item label="Покрыто страховкой">
              {`${kiosk.covered} кр.`}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
}
