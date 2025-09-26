import { useState, useEffect, useCallback } from 'react';
import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Button, Input, LabeledList, Section, Stack, TextArea, NoticeBox, Image } from 'tgui-core/components';

type Warrant = {
  id: string;
  namewarrant: string;
  jobwarrant: string;
  charges: string;
  auth: string;
  idauth: string;
  arrestsearch: string;
  subject_icon?: string | null;
};

type CrewMember = {
  name: string;
  job: string;
};

type Data = {
  warrants?: Warrant[] | null;
  active?: Warrant | null;
  crew_manifest?: CrewMember[];
};

export const NtosDigitalWarrant = () => {
  const { act, data } = useBackend<Data>();
  const { active, crew_manifest = [] } = data;
  const warrants = data.warrants ?? [];
  const [showCrewManifest, setShowCrewManifest] = useState(false);

  return (
    <NtosWindow title="Цифровые ордера" width={500} height={530}>
      <NtosWindow.Content>
        {active ? (
          showCrewManifest ? (
            <CrewManifest
              crew={crew_manifest}
              onSelect={(name, job) => {
                act('edit_name', { name, job });
                setShowCrewManifest(false);
              }}
              onClose={() => setShowCrewManifest(false)}
            />
          ) : (
            <WarrantEditor
              warrant={active}
              act={act}
              onShowCrewManifest={() => setShowCrewManifest(true)}
            />
          )
        ) : (
          <WarrantList warrants={warrants} act={act} />
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

type WarrantEditorProps = {
  warrant: Warrant;
  act: (action: string, params?: any) => void;
  onShowCrewManifest: () => void;
};

const WarrantEditor = (props: WarrantEditorProps) => {
	const { warrant, act, onShowCrewManifest } = props;
	const [chargesDraft, setChargesDraft] = useState(warrant.charges || "");
	const maxChargesLen = 1000;

	// Синхронизация при смене активного ордера
	useEffect(() => {
		setChargesDraft(warrant.charges || "");
	}, [warrant.id]);

	const saveCharges = useCallback(() => {
		const trimmed = chargesDraft.trim();
		if(trimmed !== warrant.charges) {
			act('edit_charges', { charges: trimmed });
		}
		act('save');
	}, [chargesDraft, warrant.charges, act]);

	const onKeyDown = (e: any) => {
		if(e.ctrlKey && e.key === 'Enter') {
			e.preventDefault();
			saveCharges();
		}
	};

	const alreadySigned = !!(warrant.auth && warrant.auth !== 'Unauthorized');
	const sameIdSigned = !!(warrant.idauth && warrant.idauth !== 'Unauthorized');
	const isNew = !warrant.id || warrant.id.length === 0;

	const subjectIcon = warrant.subject_icon ? (
		<img
			style={{ border: '1px solid #666', imageRendering: 'pixelated' }}
			src={`data:image/png;base64,${warrant.subject_icon}`}
			alt={warrant.namewarrant}
			width={90}
			height={64}
		/>
	) : (
		<span style={{ opacity: 0.5 }}>нет иконки</span>
	);

	return (
		<Section title={warrant.namewarrant}>
			<LabeledList>
				<LabeledList.Item label="Фотография">
					{subjectIcon}
				</LabeledList.Item>
				<LabeledList.Item label="Выбрать из манифеста">
					<Button onClick={onShowCrewManifest}>Выбрать</Button>
				</LabeledList.Item>
				<LabeledList.Item label="Имя">
					{warrant.namewarrant}
				</LabeledList.Item>
				<LabeledList.Item label="Должность">
					{warrant.jobwarrant}
				</LabeledList.Item>
				<LabeledList.Item label="Обвинения">
					<TextArea
						value={chargesDraft}
						onChange={(value: string) => value.length <= maxChargesLen && setChargesDraft(value)}
						onKeyDown={onKeyDown}
						height={8}
            width={24}
						placeholder="Опишите основания..."
					/>
					<Stack mt={0.5} justify="space-between">
						<Stack.Item>Ctrl+Enter = Сохранить</Stack.Item>
						<Stack.Item>{chargesDraft.trim().length}/{maxChargesLen}</Stack.Item>
					</Stack>
				</LabeledList.Item>
				<LabeledList.Item label="Авторизовал">
					{warrant.auth}
					<Button ml={1} disabled={alreadySigned} onClick={() => act('authorize')}>
						Авторизовать ордер
					</Button>
				</LabeledList.Item>
				<LabeledList.Item label="Авторизация доступа">
					{warrant.idauth}
					<Button ml={1} disabled={sameIdSigned} onClick={() => act('authorize_access')}>
						Авторизовать доступ
					</Button>
				</LabeledList.Item>
			</LabeledList>
			<Stack mt={2} justify="space-between">
				<Button onClick={saveCharges}>Сохранить</Button>
				<Button disabled={isNew} onClick={() => act('delete', { id: warrant.id })}>Удалить</Button>
				<Button onClick={() => act('back')}>Назад</Button>
			</Stack>
		</Section>
	);
};

type CrewManifestProps = {
  crew: CrewMember[];
  onSelect: (name: string, job: string) => void;
  onClose: () => void;
};

const CrewManifest = (props: CrewManifestProps) => {
  const { crew, onSelect, onClose } = props;
  const [search, setSearch] = useState('');

  const filteredCrew = crew.filter(
    (member) =>
      member.name.toLowerCase().includes(search.toLowerCase()) ||
      member.job.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <Section
      title="Манифест экипажа"
      buttons={<Button onClick={onClose}>Назад</Button>}
    >
      <Input
        placeholder="Поиск по имени или должности"
        onChange={(value: string) => setSearch(value)}
        mb={1}
      />
      {filteredCrew.map((member) => (
        <Stack key={member.name} justify="space-between" mb={1}>
          <Stack.Item grow>
            {member.name} - {member.job}
          </Stack.Item>
            <Button onClick={() => onSelect(member.name, member.job)}>
              Выбрать
            </Button>
        </Stack>
      ))}
    </Section>
  );
};

type WarrantListProps = {
  warrants: Warrant[];
  act: (action: string, params?: any) => void;
};

const WarrantList = (props: WarrantListProps) => {
  const { warrants, act } = props;
  return (
    <Section
      title="Ордеры"
      buttons={
        <>
          <Button onClick={() => act('add_arrest')}>Ордер на арест</Button>
          <Button onClick={() => act('add_search')}>Ордер на обыск</Button>
        </>
      }
    >
      {warrants.length ? (
        warrants.map((warrant) => (
          <Stack key={warrant.id} justify="space-between" mb={1}>
            <Stack.Item grow>
              {warrant.namewarrant}: {warrant.charges}
            </Stack.Item>
            <Button onClick={() => act('open', { id: warrant.id })}>Открыть</Button>
            <Button onClick={() => act('delete', { id: warrant.id })}>Удалить</Button>
          </Stack>
        ))
      ) : (
        'Ордеров нет.'
      )}
    </Section>
  );
};
