import '../styles/interfaces/AntagInfoLootGoblin.scss';

import { useState } from 'react';
import { Box, Icon } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { type Objective, ObjectivePrintout } from './common/Objectives';

type LootEntry = {
  name: string;
  value: number;
};

type PerkOption = {
  id: string;
  name: string;
  desc: string;
  tier: number;
};

type Recipe = {
  name: string;
  effect: string;
  ingredients: { name: string; amount: number }[];
};

type ChosenPerk = {
  id: string;
  tier: number;
  name: string;
  desc: string;
  active: boolean;
};

type Data = {
  objectives: Objective[];
  tier: number;
  influence: number;
  max_influence: number;
  figures: number;
  max_figures: number;
  has_lair: BooleanLike;
  lair_loot: LootEntry[];
  pending_perk_tier: number | null;
  perk_options: PerkOption[];
  perks: ChosenPerk[];
  recipes: Recipe[];
  cauldron_unlocked: BooleanLike;
  cauldron_placed: BooleanLike;
  cauldron_cooldown: number;
};

const PERK_LOOK: Record<string, { icon: string; color: string }> = {
  speed: { icon: 'bolt', color: '#5b3f8c' },
  regen: { icon: 'heart-pulse', color: '#2f7a3a' },
  night_vision: { icon: 'eye', color: '#2c5f86' },
  door_pry: { icon: 'door-open', color: '#8a5a1e' },
  recall: { icon: 'house', color: '#7a3a2f' },
  hearing: { icon: 'shoe-prints', color: '#4a5a2a' },
  steady: { icon: 'anchor', color: '#6b5a2e' },
  trap: { icon: 'link', color: '#5a3a2a' },
  smoke: { icon: 'smog', color: '#4f4f5c' },
};

const MAX_TIER = 6;

enum Tab {
  Perks,
  Lair,
  Cauldron,
  Goal,
}

const TAB_NAMES = {
  [Tab.Perks]: 'Умения',
  [Tab.Lair]: 'Логово',
  [Tab.Cauldron]: 'Котёл',
  [Tab.Goal]: 'Цель',
};

export function AntagInfoLootGoblin() {
  const [tab, setTab] = useState(Tab.Perks);

  return (
    <Window width={480} height={720} theme="LootGoblin">
      <Window.Content scrollable>
        <div className="LootGoblin">
          <div className="LootGoblin__banner">{TAB_NAMES[tab]}</div>
          <div className="LootGoblin__tabs">
            {[Tab.Perks, Tab.Lair, Tab.Cauldron, Tab.Goal].map((item) => (
              <button
                key={item}
                type="button"
                className={
                  item === tab
                    ? 'LootGoblin__tab LootGoblin__tab--selected'
                    : 'LootGoblin__tab'
                }
                onClick={() => setTab(item)}
              >
                {TAB_NAMES[item]}
              </button>
            ))}
          </div>
          <StatusStrip />
          {tab === Tab.Perks && <PerksTab />}
          {tab === Tab.Lair && <LairTab />}
          {tab === Tab.Cauldron && <CauldronTab />}
          {tab === Tab.Goal && <GoalTab />}
        </div>
      </Window.Content>
    </Window>
  );
}

function StatusStrip() {
  const { data } = useBackend<Data>();
  const { tier, influence, max_influence } = data;
  const percent = max_influence ? (influence / max_influence) * 100 : 0;

  return (
    <div className="LootGoblin__status">
      <b>Тир</b>
      <Box style={{ display: 'flex', gap: '4px' }}>
        {Array.from({ length: MAX_TIER }, (_, index) => index + 1).map(
          (step) => {
            let className = 'LootGoblin__tier';
            if (step <= tier) {
              className += ' LootGoblin__tier--reached';
            }
            if (step === tier) {
              className += ' LootGoblin__tier--current';
            }
            return (
              <span key={step} className={className}>
                {step}
              </span>
            );
          },
        )}
      </Box>
      <Box style={{ flexGrow: 1 }}>
        <div className="LootGoblin__row" style={{ fontSize: '11px' }}>
          <span>Жадность</span>
          <span>
            {influence} / {max_influence}
          </span>
        </div>
        <div className="LootGoblin__bar">
          <div
            className="LootGoblin__bar-fill"
            style={{ width: `${Math.min(percent, 100)}%` }}
          />
        </div>
      </Box>
    </div>
  );
}

type PerkCardProps = {
  id: string;
  name: string;
  desc: string;
  tier: number;
  inactive?: boolean;
  onPick?: () => void;
};

function PerkCard(props: PerkCardProps) {
  const { id, name, desc, tier, inactive, onPick } = props;
  const look = PERK_LOOK[id] || { icon: 'star', color: '#5b4a1e' };

  return (
    <div
      className={
        inactive
          ? 'LootGoblin__card LootGoblin__card--inactive'
          : 'LootGoblin__card'
      }
    >
      {!!onPick && (
        <button
          type="button"
          className="LootGoblin__pick"
          aria-label={`Выбрать умение «${name}»`}
          onClick={onPick}
        >
          <Icon name="angles-up" />
        </button>
      )}
      <div className="LootGoblin__card-body">
        <span className="LootGoblin__card-title">{name}</span>
        <span className="LootGoblin__card-desc">{desc}</span>
        <span className="LootGoblin__tag">
          <Icon name="coins" />
          Тир {tier}
          {inactive && ' — неактивно'}
        </span>
      </div>
      <div className="LootGoblin__medal">
        <div
          className="LootGoblin__medal-core"
          style={{ background: look.color }}
        >
          <Icon name={look.icon} />
        </div>
      </div>
    </div>
  );
}

function PerksTab() {
  const { act, data } = useBackend<Data>();
  const { pending_perk_tier, perk_options, perks } = data;

  return (
    <>
      {!!pending_perk_tier && (
        <div className="LootGoblin__notice">
          Доступен выбор умения тира {pending_perk_tier}
        </div>
      )}
      {!!pending_perk_tier &&
        perk_options.map((option) => (
          <PerkCard
            key={option.id}
            id={option.id}
            name={option.name}
            desc={option.desc}
            tier={option.tier}
            onPick={() => act('choose_perk', { perk: option.id })}
          />
        ))}
      <div className="LootGoblin__panel">
        <b>Выбранные умения</b>
        {perks.length ? (
          perks.map((perk) => (
            <PerkCard
              key={perk.tier}
              id={perk.id}
              name={perk.name}
              desc={perk.desc}
              tier={perk.tier}
              inactive={!perk.active}
            />
          ))
        ) : (
          <span className="LootGoblin__muted">
            Умения открываются со второго тира.
          </span>
        )}
      </div>
    </>
  );
}

function LairTab() {
  const { data } = useBackend<Data>();
  const { has_lair, figures, max_figures, lair_loot } = data;

  return (
    <>
      {!has_lair && (
        <div className="LootGoblin__notice">
          Логова нет. Обустройте его способностью «Обустроить логово» на
          верхнем уровне станции.
        </div>
      )}
      <div className="LootGoblin__panel">
        <div className="LootGoblin__row">
          <b>Коллекционные фигурки</b>
          <b>
            {figures}/{max_figures}
          </b>
        </div>
        <div className="LootGoblin__figures">
          {Array.from({ length: max_figures }, (_, index) => index).map(
            (slot) => (
              <div
                key={slot}
                className={
                  slot < figures
                    ? 'LootGoblin__figure LootGoblin__figure--filled'
                    : 'LootGoblin__figure'
                }
              >
                {slot < figures && <Icon name="chess-pawn" />}
              </div>
            ),
          )}
        </div>
      </div>
      <div className="LootGoblin__panel">
        <b>Ценности в логове</b>
        {lair_loot.length ? (
          lair_loot.map((entry, index) => (
            <div key={index} className="LootGoblin__entry">
              <span>{entry.name}</span>
              <span className="LootGoblin__tag">+{entry.value}</span>
            </div>
          ))
        ) : (
          <span className="LootGoblin__muted">Пока пусто.</span>
        )}
      </div>
    </>
  );
}

function CauldronTab() {
  const { data } = useBackend<Data>();
  const { recipes, cauldron_unlocked, cauldron_placed, cauldron_cooldown } =
    data;

  let status = 'Котёл готов к варке.';
  if (!cauldron_unlocked) {
    status = 'Котёл откроется на тире 5.';
  } else if (!cauldron_placed) {
    status = 'Котёл не поставлен: используйте «Поставить котёл» рядом с логовом.';
  } else if (cauldron_cooldown > 0) {
    status = `Котёл остывает: ещё ${cauldron_cooldown} с.`;
  }

  return (
    <>
      <div className="LootGoblin__notice">{status}</div>
      {recipes.map((recipe) => (
        <div key={recipe.name} className="LootGoblin__card">
          <div className="LootGoblin__card-body">
            <span className="LootGoblin__card-title">{recipe.name}</span>
            <span className="LootGoblin__card-desc">{recipe.effect}</span>
            {recipe.ingredients.map((ingredient) => (
              <span key={ingredient.name} className="LootGoblin__tag">
                {ingredient.name} × {ingredient.amount}
              </span>
            ))}
          </div>
          <div className="LootGoblin__medal">
            <div
              className="LootGoblin__medal-core"
              style={{ background: '#4f6b2a' }}
            >
              <Icon name="flask" />
            </div>
          </div>
        </div>
      ))}
      <span className="LootGoblin__muted">
        Чужак, выпивший гоблинское зелье, получит отравление.
      </span>
    </>
  );
}

function GoalTab() {
  const { data } = useBackend<Data>();
  const { objectives, tier } = data;

  return (
    <div className="LootGoblin__panel">
      <b>
        Цель — тир {tier} из {MAX_TIER}
      </b>
      <ObjectivePrintout objectives={objectives} titleMessage="" />
    </div>
  );
}
