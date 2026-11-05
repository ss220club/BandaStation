import { Box, Button, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

type Props = {
  network: string | null;
  humanOnly: BooleanLike;
  revision: number;
  canChange: BooleanLike;
  onChange: (humanOnly: number, expected: number) => void;
};

export function ResourcePolicy(props: Props) {
  const humanOnly = !!props.humanOnly;
  return (
    <Section
      title="Доступ к управлению ресурсами"
      buttons={
        <Button.Confirm
          key={`${props.network}:${props.revision}:${humanOnly}`}
          icon="user-shield"
          selected={humanOnly}
          disabled={!props.network || !props.canChange}
          confirmContent={
            humanOnly
              ? 'Разрешить управление синтетикам?'
              : 'Ограничить управление людьми?'
          }
          onClick={() => props.onChange(humanOnly ? 0 : 1, humanOnly ? 1 : 0)}
        >
          {humanOnly ? 'Разрешить синтетиков' : 'Только люди'}
        </Button.Confirm>
      }
    >
      <Box className="AiOS__eyebrow" mb={1}>
        {humanOnly ? 'ТОЛЬКО ОПЕРАТОРЫ-ЛЮДИ' : 'ДОСТУП РАЗРЕШЁН СИНТЕТИКАМ'}
      </Box>
      <Box color="label">
        {' '}
        Действует во всей связанной сети: выделение ресурсов, настройка подсетей
        и управление фоновыми задачами. Камеры, двери, законы и программы ИИ
        продолжают работать. Изменить правило может только оператор-человек с
        доступом РД или телекоммуникаций.{' '}
      </Box>
      <Box color="label" mt={1}>
        {' '}
        Разделённые сегменты сохраняют ограничение. При объединении управление
        остаётся только у людей, если хотя бы одна сеть требует этого.{' '}
      </Box>
    </Section>
  );
}
