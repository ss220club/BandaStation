import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import { safeRatio } from './resourceMath';

type Activity = { category: string; quota: number; cpu: number; jobs: number };
export type Subnet = {
  ref: string;
  name: string;
  quota: number;
  cpu: number;
  activities?: Activity[];
};
type Props = {
  subnets: Subnet[];
  available: number;
  locked: boolean;
  onQuota: (ref: string, amount: number) => void;
  onRename: (ref: string, name: string) => void;
  activityLocked: boolean;
  onActivity: (
    ref: string,
    category: string,
    action: string,
    amount?: number,
  ) => void;
};

export function SubnetPanel(props: Props) {
  const reserved = props.subnets.reduce(
    (sum, subnet) => sum + Math.max(0, subnet.quota),
    0,
  );
  return (
    <Section title="Распределение ресурсов подсетей" className="AiOS__routing">
      <Box color="label" mb={1}>
        {' '}
        Зарезервируйте свободный CPU для кабельного сегмента или разрешите ему
        автоматически делить остаток. Выделения ИИ имеют преимущество.
        Неиспользуемые ручные резервы остаются свободными от задач.{' '}
      </Box>
      <ProgressBar value={Math.min(1, reserved)} color="blue" mb={1}>
        {(reserved * 100).toFixed(0)}% зарезервировано ·{' '}
        {Math.max(0, (1 - reserved) * 100).toFixed(0)}% автоматического пула{' '}
      </ProgressBar>
      {props.locked && (
        <NoticeBox>
          {' '}
          Подключение только для чтения. Требуется доступ к управлению
          ресурсами.{' '}
        </NoticeBox>
      )}
      {!props.subnets.length && (
        <NoticeBox>Подключённых кабельных сегментов нет.</NoticeBox>
      )}
      <Box className="AiOS__catalog">
        {props.subnets.map((subnet) => (
          <SubnetCard
            key={subnet.ref}
            {...props}
            subnet={subnet}
            reserved={reserved}
          />
        ))}
      </Box>
    </Section>
  );
}

function SubnetCard(props: Props & { subnet: Subnet; reserved: number }) {
  const { subnet } = props;
  const [draft, setDraft] = useState<string | null>(null);
  const [showActivities, setShowActivities] = useState(false);
  const manual = subnet.quota >= 0;
  const maximum = Math.max(0, 1 - props.reserved + Math.max(0, subnet.quota));
  const initialQuota = Math.min(
    maximum,
    safeRatio(subnet.cpu, props.available),
  );
  return (
    <Section
      title={subnet.name}
      style={{ gridColumn: showActivities ? '1 / -1' : undefined }}
    >
      <Box className="AiOS__eyebrow">
        {manual ? 'РЕЗЕРВИРУЕМЫЙ КАНАЛ' : 'АВТОМАТИЧЕСКИЙ КАНАЛ'}
      </Box>
      <Stack align="center" mb={1}>
        <Stack.Item grow>
          <Input
            fluid
            value={draft ?? subnet.name}
            maxLength={32}
            disabled={props.locked}
            onChange={setDraft}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="check"
            disabled={
              props.locked ||
              draft === null ||
              !draft.trim() ||
              draft === subnet.name
            }
            onClick={() => {
              if (draft?.trim()) props.onRename(subnet.ref, draft.trim());
              setDraft(null);
            }}
          >
            {' '}
            Сохранить{' '}
          </Button>
        </Stack.Item>
      </Stack>
      <Box fontSize={1.4} bold>
        {subnet.cpu.toFixed(2)}{' '}
        <Box inline color="label" fontSize={1}>
          {' '}
          ТГц на задачи{' '}
        </Box>
      </Box>
      <Box color="label" my={1}>
        {manual && subnet.quota === 0
          ? 'Задачи остановлены: у сегмента нулевая квота.'
          : subnet.cpu === 0
            ? 'CPU не выделен: проверьте активные задачи, ресурсы и резервы.'
            : 'Текущее выделение после резервов ИИ и приоритетов задач.'}
      </Box>
      <Stack wrap align="center">
        <Stack.Item>
          <Button
            selected={!manual}
            disabled={props.locked}
            onClick={() => props.onQuota(subnet.ref, -1)}
          >
            {' '}
            Автоматически{' '}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            selected={manual}
            disabled={props.locked || manual}
            onClick={() => props.onQuota(subnet.ref, initialQuota)}
          >
            {' '}
            Зарезервировать долю{' '}
          </Button>
        </Stack.Item>
        {manual && (
          <Stack.Item>
            <NumberInput
              value={subnet.quota * 100}
              minValue={0}
              maxValue={maximum * 100}
              unit="%"
              step={1}
              width={7}
              disabled={props.locked}
              onChange={(value) => props.onQuota(subnet.ref, value / 100)}
            />
          </Stack.Item>
        )}
      </Stack>
      {!!subnet.activities?.length && (
        <Box mt={1}>
          <Button
            icon={showActivities ? 'chevron-down' : 'chevron-right'}
            onClick={() => setShowActivities(!showActivities)}
          >
            {' '}
            CPU по видам задач{' '}
          </Button>
          {showActivities && (
            <ActivityBudgets {...props} activities={subnet.activities} />
          )}
        </Box>
      )}
    </Section>
  );
}

const activityNames: Record<string, string> = {
  recovery: 'Восстановление ИИ',
  research: 'Исследования ИИ',
  archive: 'Восстановление архива',
  science: 'Помощь исследованиям',
  mining: 'Майнинг кредитов',
};

function ActivityBudgets(
  props: Props & { subnet: Subnet; activities: Activity[] },
) {
  const reserved = props.activities.reduce(
    (sum, activity) => sum + Math.max(0, activity.quota),
    0,
  );
  return (
    <Section title="Планировщик фоновых задач" mt={1}>
      <Box color="label" mb={1}>
        {' '}
        Доли распределяют фоновый CPU сегмента после выделений ИИ. Фиксированная
        доля делится поровну между задачами своего вида; автоматические задачи
        делят остаток по приоритетам. Незадействованные фиксированные доли
        остаются свободными от задач.{' '}
      </Box>
      <ProgressBar value={Math.min(1, reserved)} color="blue" mb={1}>
        {(reserved * 100).toFixed(0)}% фиксировано ·{' '}
        {Math.max(0, (1 - reserved) * 100).toFixed(0)}% автоматически{' '}
      </ProgressBar>
      {props.activityLocked && (
        <NoticeBox>
          Этот оператор может только просматривать доли задач.
        </NoticeBox>
      )}
      {props.activities.map((activity) => {
        const manual = activity.quota >= 0;
        const maximum = Math.max(0, 1 - reserved + Math.max(0, activity.quota));
        const submit = (action: string, amount?: number) =>
          props.onActivity(props.subnet.ref, activity.category, action, amount);
        return (
          <Section
            key={activity.category}
            title={activityNames[activity.category] || activity.category}
          >
            <Box mb={1}>
              {activity.cpu.toFixed(2)} ТГц · Готовых задач: {activity.jobs} ·{' '}
              {manual && activity.quota === 0
                ? 'Остановлено нулевой долей'
                : activity.jobs
                  ? activity.cpu > 0
                    ? 'Вычисления'
                    : 'Ожидание CPU'
                  : 'Нет готовых задач'}
            </Box>
            <Stack wrap align="center">
              <Stack.Item>
                <Button
                  selected={!manual}
                  disabled={props.activityLocked}
                  onClick={() => submit('reset_network_cpu')}
                >
                  {' '}
                  Автоматически{' '}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  selected={manual}
                  disabled={props.activityLocked || manual}
                  onClick={() =>
                    submit(
                      'allocate_network_cpu',
                      Math.min(
                        maximum,
                        safeRatio(activity.cpu, props.subnet.cpu),
                      ),
                    )
                  }
                >
                  {' '}
                  Фиксированная доля{' '}
                </Button>
              </Stack.Item>
              {manual && (
                <Stack.Item>
                  <NumberInput
                    value={activity.quota * 100}
                    minValue={0}
                    maxValue={maximum * 100}
                    unit="%"
                    step={1}
                    width={7}
                    disabled={props.activityLocked}
                    onChange={(value) =>
                      submit('allocate_network_cpu', value / 100)
                    }
                  />
                </Stack.Item>
              )}
              <Stack.Item>
                <Button
                  icon="angles-up"
                  disabled={props.activityLocked}
                  onClick={() => submit('max_network_cpu')}
                >
                  {' '}
                  Выделить остаток{' '}
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        );
      })}
    </Section>
  );
}
