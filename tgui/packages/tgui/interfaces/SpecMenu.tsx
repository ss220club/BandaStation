import { Button, Divider, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Specialization = {
  action: 'hemomancer' | 'umbrae' | 'gargantua' | 'dantalion';
  description: string;
  fullPower: string[];
  name: string;
  powers: string[];
};

const specializations: Specialization[] = [
  {
    action: 'hemomancer',
    name: 'Hemomancer',
    description: 'Focuses on blood magic and the manipulation of blood around you.',
    powers: [
      'Vampiric claws: Unlocked at 150 blood. Summon a robust pair of claws that attack rapidly, drain a target\'s blood, and heal you.',
      'Blood Barrier: Unlocked at 250 blood. Select two turfs and create a wall between them.',
      'Blood tendrils: Unlocked at 250 blood. Slow everyone in a targeted 3x3 area after a short delay.',
      'Sanguine pool: Unlocked at 400 blood. Travel at high speeds for a short duration, leaving blood splatters behind.',
      'Predator senses: Unlocked at 600 blood. Locate anyone within the same sector as you.',
      'Blood eruption: Unlocked at 800 blood. Turn nearby blood splatters into spikes that impale anyone standing on them.',
    ],
    fullPower: [
      'The blood bringer\'s rite: Rapidly drain the blood of nearby people to heal yourself and quickly remove incapacitating effects.',
    ],
  },
  {
    action: 'umbrae',
    name: 'Umbrae',
    description: 'Focuses on darkness, stealth, ambushing, and mobility.',
    powers: [
      'Cloak of darkness: Unlocked at 150 blood. Become nearly invisible and move rapidly in darkness, but take more burn damage.',
      'Shadow anchor: Unlocked at 250 blood. Create an anchor, then return to it with a second cast. It cannot cross Z-levels.',
      'Shadow snare: Unlocked at 250 blood. Summon a subtle trap that blinds and immobilizes its first victim, but withers in light.',
      'Dark passage: Unlocked at 400 blood. Teleport to a turf on screen.',
      'Extinguish: Unlocked at 600 blood. Snuff out nearby lights.',
      'Shadow boxing: Unlocked at 800 blood. Send shadow clones at a target while you remain nearby.',
    ],
    fullPower: [
      'Eternal darkness: Envelop yourself in unholy darkness. Nearby creatures freeze and projectiles deal less damage inside it.',
      'You also gain permanent X-ray vision.',
    ],
  },
  {
    action: 'gargantua',
    name: 'Gargantua',
    description: 'Focuses on tenacity and melee damage.',
    powers: [
      'Rejuvenate: Heal faster based on how much damage you have taken.',
      'Blood swell: Unlocked at 150 blood. Gain resistance to physical damage, stuns, and stamina damage for 30 seconds. You cannot fire guns while it is active.',
      'Seismic stomp: Unlocked at 250 blood. Stomp to send out a shockwave that knocks people back.',
      'Blood rush: Unlocked at 250 blood. Gain a short speed boost.',
      'Blood swell II: Unlocked at 400 blood. Your melee attacks deal 10 additional damage.',
      'Overwhelming force: Unlocked at 600 blood. Force open doors you bump into and resist being pushed or pulled.',
      'Demonic grasp: Unlocked at 800 blood. Send out a demonic hand to snare and throw someone.',
      'Charge: Unlocked at 800 blood. Charge at a target, destroying obstacles and bowling over victims.',
    ],
    fullPower: [
      'Desecrated Duel: Leap at a visible enemy to create an arena, greatly increasing your regeneration and resistance to internal damage.',
    ],
  },
  {
    action: 'dantalion',
    name: 'Dantalion',
    description: 'Focuses on thralling and illusions.',
    powers: [
      'Enthrall: Unlocked at 150 blood. Bind a target to your will while standing still. It does not work on mindshielded or already enthralled people.',
      'Thrall cap: Begin with one thrall. The cap increases at 400 blood, 600 blood, and full power, to a maximum of four.',
      'Thrall commune: Unlocked at 150 blood. Speak with your thralls; they can reply in the same channel.',
      'Subspace swap: Unlocked at 250 blood. Swap positions with a target.',
      'Pacify: Unlocked at 250 blood. Prevent a target from causing harm for 40 seconds.',
      'Decoy: Unlocked at 400 blood. Briefly turn invisible and leave an illusion behind.',
      'Rally thralls: Unlocked at 600 blood. Remove incapacitating effects from nearby thralls.',
      'Blood bond: Unlocked at 800 blood. Nearby thralls share incoming damage with you while they remain in range.',
    ],
    fullPower: [
      'Mass Hysteria: Blind nearby victims and make them perceive others as random animals.',
    ],
  },
];

export function SpecMenu() {
  return (
    <Window title="Specialisation Menu" width={1100} height={600} theme="nologo">
      <Window.Content>
        <Stack fill>
          {specializations.map((specialization) => (
            <SpecializationColumn
              key={specialization.action}
              specialization={specialization}
            />
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
}

function SpecializationColumn({ specialization }: { specialization: Specialization }) {
  const { act } = useBackend();

  return (
    <Stack.Item grow basis="25%">
      <Section
        fill
        scrollable
        title={specialization.name}
        buttons={
          <Button content="Choose" onClick={() => act(specialization.action)} />
        }
      >
        <h3>{specialization.description}</h3>
        {specialization.powers.map((power) => (
          <PowerDescription key={power} power={power} />
        ))}
        <b>Full power</b>
        <Divider />
        {specialization.fullPower.map((power) => (
          <PowerDescription key={power} power={power} />
        ))}
      </Section>
    </Stack.Item>
  );
}

function PowerDescription({ power }: { power: string }) {
  const separator = power.indexOf(': ');
  if (separator === -1) {
    return <p>{power}</p>;
  }

  return (
    <p>
      <b>{power.slice(0, separator)}</b>
      {power.slice(separator)}
    </p>
  );
}
