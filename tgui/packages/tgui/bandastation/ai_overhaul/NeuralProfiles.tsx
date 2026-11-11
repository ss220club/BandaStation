import { useState } from 'react';
import { Box, Button, Input, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

export type WorkProfile = {
  slot: number;
  saved: BooleanLike;
  name: string;
  program_count: number;
  cpu_share: number;
};

export function NeuralProfiles({
  profiles,
  report,
  act,
}: {
  profiles: WorkProfile[];
  report: string[];
  act: (action: string, params: Record<string, unknown>) => void;
}) {
  return (
    <Section title="Личные профили работы">
      <Box color="label" mb={2}>
        Сохраните до трёх наборов программ, приоритетов, назначений CPU и
        передачи свободного CPU на исследования. Профиль применяется вручную и
        перезапускает обычные программы. Сначала запускается компрессор, затем
        более важные программы. Одноразовые команды не повторяются. Профиль
        сохраняется у вашего ИИ до конца смены.
      </Box>
      {!!report.length && (
        <NoticeBox>
          {report.map((line, index) => (
            <Box key={index}>{line}</Box>
          ))}
        </NoticeBox>
      )}
      <div className="AiOS__historyGrid">
        {profiles.map((profile) => (
          <ProfileSlot
            key={`${profile.slot}:${profile.name}:${profile.saved}`}
            profile={profile}
            act={act}
          />
        ))}
      </div>
    </Section>
  );
}

function ProfileSlot({
  profile,
  act,
}: {
  profile: WorkProfile;
  act: (action: string, params: Record<string, unknown>) => void;
}) {
  const [name, setName] = useState(profile.name);
  return (
    <Section
      title={`Слот ${profile.slot} · ${profile.saved ? profile.name : 'пусто'}`}
    >
      <Box color="label" mb={1}>
        {profile.saved
          ? `Программ: ${profile.program_count} · CPU на исследования и перезарядку: ${(profile.cpu_share * 100).toFixed(0)}%`
          : 'Сохраните текущие настройки в этот слот.'}
      </Box>
      <Box mb={1}>
        <Input
          fluid
          maxLength={32}
          value={name}
          onChange={setName}
          placeholder="Название профиля"
        />
      </Box>
      <div className="AiOS__filters">
        <Button
          icon="play"
          disabled={!profile.saved}
          onClick={() => act('apply_profile', { slot: profile.slot })}
        >
          Применить
        </Button>
        {profile.saved ? (
          <Button.Confirm
            icon="save"
            disabled={!name.trim()}
            confirmContent="Перезаписать?"
            onClick={() => act('save_profile', { slot: profile.slot, name })}
          >
            Сохранить текущее
          </Button.Confirm>
        ) : (
          <Button
            icon="save"
            disabled={!name.trim()}
            onClick={() => act('save_profile', { slot: profile.slot, name })}
          >
            Сохранить текущее
          </Button>
        )}
        <Button.Confirm
          icon="trash"
          disabled={!profile.saved}
          confirmContent="Удалить профиль?"
          onClick={() => act('delete_profile', { slot: profile.slot })}
        >
          Удалить
        </Button.Confirm>
      </div>
    </Section>
  );
}
