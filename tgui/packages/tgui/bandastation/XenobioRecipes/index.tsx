import { Box, Button, Stack } from 'tgui-core/components';
import { useBackend } from '../../backend';
import type { ReactionEntry } from './DetailPanel';
import { DetailPanel } from './DetailPanel';
import { RandomRecipeMinigame } from './RandomRecipeMinigame';
import type { SlimeEntry } from './XenobioMenu';
import { XenobioMenu } from './XenobioMenu';

export type XenobioRecipesData = {
  slimes: SlimeEntry[];
  research_points: Record<string, number>;
  recipe_cost: number;
  xenobio_study_cost?: number;
  loaded_slime_path: string | null;
  selected_slime: string | null;
  selected_slime_lore: string | null;
  selected_slime_pool_reactions: string[];
  selected_slime_reactions: ReactionEntry[];
  slime_study_available: boolean;
  random_recipe_available: boolean;
  minigame_active?: boolean;
  minigame_terminal_lines?: string[];
  minigame_terminal_words?: { word: string; line: number; start: number }[];
  minigame_last_likeness?: number | null;
  minigame_correct_length?: number;
  minigame_attempts_left?: number;
  minigame_bonus_segment?: {
    line: number;
    start: number;
    length: number;
  } | null;
  minigame_bonus_claimed?: boolean;
};

export function XenobioRecipesLayout() {
  const { act, data } = useBackend<XenobioRecipesData>();
  const {
    slimes = [],
    research_points = {},
    recipe_cost = 100,
    xenobio_study_cost = 5,
    loaded_slime_path = null,
    selected_slime,
    selected_slime_lore,
    selected_slime_pool_reactions = [],
    selected_slime_reactions = [],
    slime_study_available = false,
    random_recipe_available = true,
    minigame_active = false,
    minigame_terminal_lines = [],
    minigame_terminal_words = [],
    minigame_last_likeness = null,
    minigame_correct_length = 0,
    minigame_attempts_left = 7,
    minigame_bonus_segment = null,
    minigame_bonus_claimed = false,
  } = data;

  //const points = research_points['General Research'] ?? 0;
  const xenobioPoints = research_points['Xenobio'] ?? 0;
  const canBuyRandom =
    xenobioPoints >= recipe_cost && random_recipe_available && !minigame_active;
  const selectedSlime = selected_slime
    ? slimes.find((s) => s.path === selected_slime)
    : null;
  const selectedSlimeName =
    selectedSlime?.display_name ?? selectedSlime?.name ?? 'Слайм';
  const selectedReactionCount = selectedSlime?.reaction_count ?? 0;

  return (
    <Box
      className="XenobioRecipes"
      style={{
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
        backgroundColor: 'rgba(15,18,28,0.98)',
      }}
    >
      {}
      <Box
        className="XenobioRecipes__Header"
        style={{
          flexShrink: 0,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '0.4rem 0.6rem',
          borderBottom: '1px solid rgba(80,100,140,0.35)',
          backgroundColor: 'rgba(30,38,55,0.6)',
        }}
      >
        <span style={{ fontWeight: 'bold', fontSize: '1.05rem' }}>
          Рецепты слаймов
        </span>
        <Stack>
          <Button icon="pen" onClick={() => act('open_notes')}>
            Заметки
          </Button>
          <Button
            icon="dice"
            disabled={!canBuyRandom}
            onClick={() => act('open_random_recipe')}
          >
            Реконструктор реакций ({recipe_cost} ксенобио)
          </Button>
          <Box bold style={{ marginLeft: '0.5rem', alignSelf: 'center' }}>
            Очки ксенобиологии: {xenobioPoints}
          </Box>
        </Stack>
      </Box>

      {}
      <Box
        className="XenobioRecipes__Body"
        style={{
          flex: 1,
          display: 'flex',
          minHeight: 0,
        }}
      >
        {minigame_active ? (
          <RandomRecipeMinigame
            lines={minigame_terminal_lines}
            words={minigame_terminal_words}
            lastLikeness={minigame_last_likeness ?? null}
            correctLength={minigame_correct_length ?? 0}
            attemptsLeft={minigame_attempts_left ?? 7}
            bonusSegment={minigame_bonus_segment ?? null}
            bonusClaimed={minigame_bonus_claimed ?? false}
            onGuess={(word) => act('guess_word', { word })}
            onClaimBonus={() => act('claim_bonus_attempt')}
            onCancel={() => act('cancel_random_recipe_minigame')}
          />
        ) : (
          <>
            <Box
              className="XenobioRecipes__MapWrap"
              style={{
                flex: 1,
                minWidth: 0,
                position: 'relative',
              }}
            >
              <XenobioMenu
                slimes={slimes}
                selectedPath={selected_slime}
                onSelect={(path) =>
                  act('open_slime_detail', { slime_path: path })
                }
              />
            </Box>
            {selected_slime && (
              <DetailPanel
                slimeName={selectedSlimeName}
                lore={selected_slime_lore}
                poolReactions={selected_slime_pool_reactions}
                reactions={selected_slime_reactions}
                reactionCount={selectedReactionCount}
                selectedSlimePath={selected_slime}
                loadedSlimePath={loaded_slime_path}
                recipeCost={xenobio_study_cost}
                researchPoints={xenobioPoints}
                studyAvailable={slime_study_available}
                onClose={() => act('close_slime_detail')}
                onStudySlimeProperty={() =>
                  act('study_slime_property', { slime_path: selected_slime })
                }
              />
            )}
          </>
        )}
      </Box>
    </Box>
  );
}
