import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, Image, LabeledList, NoticeBox, Section, Stack } from 'tgui-core/components';
import { resolveAsset } from '../assets';

type WarrantField = {
  label: string;
  value: string;
  hint?: string;
};

type WarrantData = {
  title?: string | null;
  subtitle?: string | null;
  subject_label?: string | null;
  subject?: string | null;
  intro?: string | null;
  fields?: WarrantField[];
  notes?: string[];
  type?: string | null;
  logo?: string | null;
};

type Data = {
  warrant?: WarrantData | null;
};

const DEFAULT_TITLE = 'Голографический ордер';

export const HoloWarrant = () => {
  const { data } = useBackend<Data>();
  const warrant = data.warrant;

  return (
    <Window title={DEFAULT_TITLE} width={520} height={600}>
      <Window.Content scrollable>
        {!warrant ? (
          <NoticeBox>В проекторе нет загруженного ордера.</NoticeBox>
        ) : (
          <WarrantView warrant={warrant} />
        )}
      </Window.Content>
    </Window>
  );
};

const WarrantView = ({ warrant }: { warrant: WarrantData }) => {
  const {
    title,
    subtitle,
    subject_label,
    subject,
    intro,
    fields = [],
    notes = [],
    logo,
  } = warrant;

  const headerTitle = title || DEFAULT_TITLE;
  const headerSubtitle = subtitle || '';
  const subjectTitle = subject_label || 'Объект';
  const subjectValue = subject && subject.length ? subject : '—';

  const logoSrc = logo ? resolveAsset(logo) : null;
  const hasFields = fields.length > 0;
  const hasNotes = notes.length > 0;

  return (
    <>
      <Stack align="center" mb={2}>
        {logoSrc && (
          <Stack.Item mr={2}>
            <Image src={logoSrc} width="64px" height="64px" style={{ imageRendering: "pixelated" }} />
          </Stack.Item>
        )}
        <Stack.Item grow>
          <Box bold fontSize={1.4}>{headerTitle}</Box>
          {headerSubtitle && <Box>{headerSubtitle}</Box>}
        </Stack.Item>
      </Stack>

      <Section title={subjectTitle}>
        <Box bold>{subjectValue}</Box>
        {intro && intro.length > 0 && (
          <Box mt={1} preserveWhitespace>
            {intro}
          </Box>
        )}
      </Section>

      {hasFields && (
        <Section title="Детали">
          <LabeledList>
            {fields.map((item, index) => (
              <LabeledList.Item key={index} label={item.label}>
                <Box preserveWhitespace>
                  {item.value && item.value.length ? item.value : '—'}
                </Box>
                {item.hint && (
                  <Box mt={0.5} color="label">
                    {item.hint}
                  </Box>
                )}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      )}

      {hasNotes && (
        <Section title="Инструкции">
          {notes.map((line, index) => (
            <Box
              key={index}
              preserveWhitespace
              mb={index === notes.length - 1 ? 0 : 1}
            >
              {line}
            </Box>
          ))}
        </Section>
      )}
    </>
  );
};


