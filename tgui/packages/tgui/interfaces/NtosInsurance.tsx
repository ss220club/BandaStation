import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { PropsWithChildren, useEffect, useRef, useState } from 'react';

// Loader timing constants
const MIN_LOADER_MS = 900; // Keep loader visible at least this long
const FINALIZE_DELAY_MS = 120; // Small delay before hiding loader
const STEP_WITH_NAME = 0.12; // Progress step when data is present
const STEP_NO_NAME = 0.02; // Progress step when data is not present yet
const CAP_WITHOUT_NAME = 0.92; // Cap progress until name appears

// Busy handling
const BUSY_FALLBACK_MS = 2500; // Fallback to clear busy if no update comes

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
  return key ? TIER_LABEL_RU[key] : 'Неизвестно';
};

type Data = {
  name: string | null;
  insurance_current: string;
  insurance_desired: string;
  payer_account_id: number;
  is_dept: boolean;
};

type NtosInsuranceProps = Record<string, never>;

enum InsuranceTier {
  None = 0,
  Standard = 1,
  Premium = 2,
}

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
      // Slightly slower progression for a longer, smoother load
      const step = name != null ? STEP_WITH_NAME : STEP_NO_NAME;
      pct = Math.min(1, pct + step);
      if (name == null && pct > CAP_WITHOUT_NAME) pct = CAP_WITHOUT_NAME;
      setProgress(pct);
      if (pct >= 1) {
        const elapsed = performance.now() - start;
        const remaining = Math.max(0, MIN_LOADER_MS - elapsed);
        finalizeTimeoutRef.current = window.setTimeout(
          () => setShowLoader(false),
          FINALIZE_DELAY_MS + remaining,
        );
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
    <NtosWindow width={420} height={300} title="Insurance Manager">
      <NtosWindow.Content>
        {showLoader ? (
          <LoadingScreen progress={progress} />
        ) : (
          <FadeIn>
            {!name ? <NoAccount /> : <InsuranceContent />}
          </FadeIn>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
}

function NoAccount() {
  return (
    <NoticeBox danger>Вставьте ID‑карту с персональным банковским счётом.</NoticeBox>
  );
}

function InsuranceContent() {
  const { act, data } = useBackend<Data>();
  const { name, insurance_current, insurance_desired, payer_account_id } = data;
  const [busy, setBusy] = useState(false);
  const busyTimeoutRef = useRef<number | null>(null);

  const desiredKey = toTierKey(insurance_desired);
  const baseDisabled = !name || data.is_dept || payer_account_id <= 0 || busy;

  // Clear busy when desired tier updates, or ensure cleanup
  useEffect(() => {
    if (busy) setBusy(false);
    if (busyTimeoutRef.current != null) {
      clearTimeout(busyTimeoutRef.current);
      busyTimeoutRef.current = null;
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [insurance_desired]);

  useEffect(() => () => {
    if (busyTimeoutRef.current != null) {
      clearTimeout(busyTimeoutRef.current);
      busyTimeoutRef.current = null;
    }
  }, []);

  return (
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
            <LabeledList.Item label="Платёжный счёт">
              {payer_account_id > 0 ? payer_account_id : '—'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Установить желаемый уровень">
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
    <Box position="relative" width="100%" height="100%">
      <Box style={{ position: 'absolute', inset: 0 }} align="center">
        <Section title="Загрузка приложения">
          <ProgressBar value={progress}>
            <span aria-live="polite">{Math.round(progress * 100)}%</span>
          </ProgressBar>
        </Section>
      </Box>
    </Box>
  );
}
