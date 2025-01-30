import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, Stack } from 'tgui-core/components';
import { exhaustiveCheck } from 'tgui-core/exhaustive';

import { PageButton } from '../components/PageButton';
import { PreferencesMenuData } from '../types';
import { AntagsPage } from './AntagsPage';
import { JobsPage } from './JobsPage';
import { LoadoutPage } from './loadout';
import { MainPage } from './MainPage';
import { QuirksPage } from './QuirksPage';
import { SpeciesPage } from './SpeciesPage';
import { VoicePage } from './VoicePage'; // BANDASTATION ADD - TTS

enum Page {
  Antags,
  Main,
  Jobs,
  Species,
  Quirks,
  Loadout,
  Voice, // BANDASTATION EDIT ADD - TTS
}

type ProfileProps = {
  activeSlot: number;
  onClick: (index: number) => void;
  profiles: (string | null)[];
};

function CharacterProfiles(props: ProfileProps) {
  const { activeSlot, onClick, profiles } = props;

  return (
    <Stack justify="center" wrap>
      {profiles.map((profile, slot) => (
        <Stack.Item key={slot} mb={1}>
          <Button
            selected={slot === activeSlot}
            onClick={() => {
              onClick(slot);
            }}
            fluid
          >
            {profile ?? 'Новый персонаж'}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
}

export function CharacterPreferenceWindow(props) {
  const { act, data } = useBackend<PreferencesMenuData>();

  const [currentPage, setCurrentPage] = useState(Page.Main);

  let pageContents;

  switch (currentPage) {
    case Page.Antags:
      pageContents = <AntagsPage />;
      break;
    case Page.Jobs:
      pageContents = <JobsPage />;
      break;
    case Page.Main:
      pageContents = (
        <MainPage openSpecies={() => setCurrentPage(Page.Species)} />
      );

      break;
    case Page.Species:
      pageContents = (
        <SpeciesPage closeSpecies={() => setCurrentPage(Page.Main)} />
      );

      break;
    case Page.Quirks:
      pageContents = <QuirksPage />;
      break;

    case Page.Loadout:
      pageContents = <LoadoutPage />;
      break;

    // BANDASTATION ADDITION START - TTS
    case Page.Voice:
      pageContents = <VoicePage />;
      break;
    // BANDASTATION ADDITION END - TTS

    default:
      exhaustiveCheck(currentPage);
  }

  return (
    <Stack vertical fill>
      <Stack.Item>
        <CharacterProfiles
          activeSlot={data.active_slot - 1}
          onClick={(slot) => {
            act('change_slot', {
              slot: slot + 1,
            });
          }}
          profiles={data.character_profiles}
        />
      </Stack.Item>
      {!data.content_unlocked && (
        <Stack.Item align="center">
          Купите BYOND премиум, чтобы открыть больше слотов!
        </Stack.Item>
      )}
      <Stack.Divider />
      <Stack.Item>
        <Stack fill>
          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Main}
              setPage={setCurrentPage}
              otherActivePages={[Page.Species]}
            >
              Персонаж
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Loadout}
              setPage={setCurrentPage}
            >
              Снаряжение
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Jobs}
              setPage={setCurrentPage}
            >
              {/*
                    Fun fact: This isn't "Jobs" so that it intentionally
                    catches your eyes, because it's really important!
                  */}
              Должности
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Antags}
              setPage={setCurrentPage}
            >
              Антагонисты
            </PageButton>
          </Stack.Item>

          <Stack.Item grow>
            <PageButton
              currentPage={currentPage}
              page={Page.Quirks}
              setPage={setCurrentPage}
            >
              Черты
            </PageButton>
          </Stack.Item>

          {Boolean(data.tts_enabled) && (
            <Stack.Item grow>
              <PageButton
                currentPage={currentPage}
                page={Page.Voice}
                setPage={setCurrentPage}
              >
                Голос
              </PageButton>
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item grow>{pageContents}</Stack.Item>
    </Stack>
  );
}
