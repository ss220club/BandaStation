import { Box, Button, Divider, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Power = {
  name?: string;
  description: string;
  blood_required?: number;
};

type Specialization = {
  id: string;
  name: string;
  description: string;
  powers: Power[];
  full_powers: Power[];
};

type Data = {
  subclasses: Specialization[];
  selected_subclass?: string;
};

export function SpecMenu() {
  const { act, data } = useBackend<Data>();
  const { selected_subclass, subclasses } = data;

  return (
    <Window title="Меню специализации" width={1100} height={600} theme="nologo">
      <Window.Content>
        <Stack fill>
          {subclasses.map((subclass) => (
            <SpecializationColumn
              key={subclass.id}
              specialization={subclass}
              canSelect={!selected_subclass}
              selected={selected_subclass === subclass.id}
              onSelect={() => act(subclass.id)}
            />
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
}

type SpecializationColumnProps = {
  specialization: Specialization;
  canSelect: boolean;
  selected: boolean;
  onSelect: () => void;
};

function SpecializationColumn(props: SpecializationColumnProps) {
  const { canSelect, onSelect, selected, specialization } = props;

  return (
    <Stack.Item grow basis="25%">
      <Section
        fill
        scrollable
        title={specialization.name}
        buttons={
          <Button
            content={selected ? 'Выбрано' : canSelect ? 'Выбрать' : 'Недоступно'}
            disabled={!canSelect || selected}
            onClick={onSelect}
          />
        }
      >
        <Box mb={1}>{specialization.description}</Box>
        <Stack vertical>
          {specialization.powers.map((power, index) => (
            <PowerDescription key={`${power.name}-${index}`} power={power} />
          ))}
        </Stack>
        <Divider />
        <Box bold>Полная сила</Box>
        <Stack vertical mt={1}>
          {specialization.full_powers.map((power, index) => (
            <PowerDescription key={`${power.name}-${index}`} power={power} />
          ))}
        </Stack>
      </Section>
    </Stack.Item>
  );
}

function PowerDescription({ power }: { power: Power }) {
  const { blood_required, description, name } = power;

  return (
    <Stack.Item>
      {name && <Box bold inline mr={0.5}>{name}</Box>}
      <Box inline>{description}</Box>
      {blood_required !== undefined && (
        <Box color="label" inline ml={0.5}>
          ({blood_required} крови)
        </Box>
      )}
    </Stack.Item>
  );
}
