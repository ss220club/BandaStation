import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Divider,
  Icon,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { GroupTitle } from '../GroupTitle';
import { findIcon } from '../helpers';
import { type CraftingData, type Diet, MODE, type Recipe } from '../types';
import { AtomContent } from './AtomContent';
import { FoodtypeContent } from './FoodtypeContent';
import { ToolContent } from './ToolContent';

type Props = {
  busy: BooleanLike;
  craftable: boolean;
  item: Recipe;
  mode: BooleanLike;
};

type IngredientProps = {
  amount: number;
  atom_id: string;
  busy?: BooleanLike;
  mode?: BooleanLike;
};

function RecipeIngredient(props: IngredientProps) {
  const { amount, atom_id: raw_id, mode, busy } = props;
  const { act, data } = useBackend<CraftingData>();
  const [isOpen, setIsOpen] = useState(false);

  const atom_id = Number(raw_id);

  const recipe =
    mode === MODE.cooking
      ? data?.recipes?.find((r) => r.id === atom_id)
      : undefined;

  if (!recipe) {
    return <AtomContent atom_id={raw_id} amount={amount} />;
  }

  const craftable = Boolean(data?.craftability?.[recipe.ref]);

  return (
    <Box style={{ position: 'relative', display: 'block' }}>
      <Box
        style={{ cursor: 'pointer', textDecoration: 'underline dotted' }}
        onClick={() => setIsOpen(!isOpen)}
      >
        <AtomContent atom_id={raw_id} amount={amount} />
      </Box>

      {isOpen && (
        <Box
          style={{
            position: 'absolute',
            top: '100%',
            left: '0',
            zIndex: 100,
            backgroundColor: '#1b1b1b',
            border: '1px solid #444',
            borderRadius: '4px',
            boxShadow: '0 4px 12px rgba(0,0,0,0.6)',
            minWidth: '220px',
          }}
          p={1}
        >
          <Stack mb={1} align="center" justify="space-between">
            <Stack.Item bold style={{ textTransform: 'capitalize' }}>
              {recipe.name}
            </Stack.Item>
            <Stack.Item>
              <Button
                compact
                icon="xmark"
                color="transparent"
                onClick={() => setIsOpen(false)}
              />
            </Stack.Item>
          </Stack>

          {recipe.reqs && (
            <Box mb={1}>
              {Object.keys(recipe.reqs).map((req_id) => (
                <RecipeIngredient
                  key={req_id}
                  atom_id={req_id}
                  amount={recipe.reqs[req_id]}
                  mode={mode}
                  busy={busy}
                />
              ))}
            </Box>
          )}

          {!!recipe.steps?.length && (
            <Box mb={1}>
              <GroupTitle title="Steps" />
              <ul style={{ paddingLeft: '20px', margin: 0 }}>
                {recipe.steps.map((step) => (
                  <li key={step}>{step}</li>
                ))}
              </ul>
            </Box>
          )}

          {!recipe.non_craftable && (
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  disabled={!craftable || busy}
                  icon={busy ? 'circle-notch' : 'utensils'}
                  iconSpin={!!busy}
                  onClick={() => {
                    act('make', { recipe: recipe.ref });
                    setIsOpen(false);
                  }}
                >
                  Создать
                </Button>
              </Stack.Item>
              {!!recipe.mass_craftable && (
                <Stack.Item>
                  <Button
                    disabled={!craftable || busy}
                    icon="repeat"
                    iconSpin={!!busy}
                    tooltip="Продолжать создание, пока не закончатся ингредиенты."
                    tooltipPosition="top"
                    onClick={() => {
                      act('make_mass', { recipe: recipe.ref });
                      setIsOpen(false);
                    }}
                  />
                </Stack.Item>
              )}
            </Stack>
          )}
        </Box>
      )}
    </Box>
  );
}

export function RecipeContentCompact(props: Props) {
  const { item, craftable, busy, mode } = props;
  const { act, data } = useBackend<CraftingData>();

  return (
    <Section>
      <Stack my={-0.75}>
        <Stack.Item>
          <Box className={findIcon(item.id, data)} />
        </Stack.Item>
        <Stack.Item grow>
          <Stack>
            <Stack.Item grow>
              <Box mb={0.5} bold style={{ textTransform: 'capitalize' }}>
                {item.name}
              </Box>
              <Box style={{ textTransform: 'capitalize' }} color="gray">
                {Array.from(
                  Object.keys(item.reqs).map((id) => {
                    const atom_id = Number(id);

                    const name = data.atom_data[atom_id - 1]?.name;
                    const is_reagent = data.atom_data[atom_id - 1]?.is_reagent;
                    const amount = item.reqs[atom_id];
                    return is_reagent
                      ? `${name}\xa0${amount}u`
                      : amount > 1
                        ? `${name}\xa0${amount}x`
                        : name;
                  }),
                ).join(', ')}

                {item.chem_catalysts &&
                  ', ' +
                    Object.keys(item.chem_catalysts)
                      .map((id) => {
                        const atom_id = Number(id);

                        const name = data.atom_data[atom_id - 1]?.name;
                        const is_reagent =
                          data.atom_data[atom_id - 1]?.is_reagent;
                        const amount = item.chem_catalysts[atom_id];
                        return is_reagent
                          ? `${name}\xa0${amount}u`
                          : amount > 1
                            ? `${name}\xa0${amount}x`
                            : name;
                      })
                      .join(', ')}

                {item.tool_paths &&
                  ', ' +
                    item.tool_paths
                      .map((item) => data.atom_data[Number(item) - 1]?.name)
                      .join(', ')}
                {item.machinery &&
                  ', ' +
                    item.machinery
                      .map((item) => data.atom_data[Number(item) - 1]?.name)
                      .join(', ')}
                {item.structures &&
                  ', ' +
                    item.structures
                      .map((item) => data.atom_data[Number(item) - 1]?.name)
                      .join(', ')}
              </Box>
            </Stack.Item>
            <Stack.Item>
              {!item.non_craftable ? (
                <Box>
                  {!!item.tool_behaviors && (
                    <Tooltip
                      content={`Инструменты: ${item.tool_behaviors.join(', ')}`}
                    >
                      <Icon p={1} name="screwdriver-wrench" />
                    </Tooltip>
                  )}
                  <Button
                    my={0.3}
                    lineHeight={2.5}
                    align="center"
                    disabled={!craftable || busy}
                    icon={
                      busy
                        ? 'circle-notch'
                        : mode === MODE.cooking
                          ? 'utensils'
                          : 'hammer'
                    }
                    iconSpin={!!busy}
                    onClick={() =>
                      act('make', {
                        recipe: item.ref,
                      })
                    }
                  >
                    Создать
                  </Button>
                  {!!item.mass_craftable && (
                    <Button
                      my={0.3}
                      lineHeight={2.5}
                      width="32px"
                      align="center"
                      tooltip="Продолжать создание, пока не закончатся ингредиенты."
                      tooltipPosition="top"
                      disabled={!craftable || busy}
                      icon="repeat"
                      iconSpin={!!busy}
                      onClick={() =>
                        act('make_mass', {
                          recipe: item.ref,
                        })
                      }
                    />
                  )}
                </Box>
              ) : (
                item.steps && (
                  <Tooltip
                    content={item.steps.map((step) => (
                      <Box key={step}>{step}</Box>
                    ))}
                  >
                    <Box fontSize={1.5} p={1}>
                      <Icon name="circle-question-o" />
                    </Box>
                  </Tooltip>
                )
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
}

type FullProps = Props & {
  diet: Diet;
};

export function RecipeContent(props: FullProps) {
  const { item, craftable, busy, mode, diet } = props;
  const { act, data } = useBackend<CraftingData>();

  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Box textAlign="center" minWidth="64px" minHeight="64px" mr={1}>
            <Box
              style={{
                transform: 'scale(1.5)',
              }}
              m="16px"
              className={findIcon(item.id, data)}
            />
          </Box>
        </Stack.Item>
        <Stack.Item grow>
          <Stack>
            <Stack.Item grow={5}>
              <Box mb={1} bold style={{ textTransform: 'capitalize' }}>
                {item.name}
              </Box>
              {item.desc && <Box color="gray">{item.desc}</Box>}
              {!!item.has_food_effect && (
                <Box my={2} color="pink">
                  <Icon name="wand-magic-sparkles" mr={1} />
                  Special effect on consumption.
                </Box>
              )}
              <Box style={{ textTransform: 'capitalize' }}>
                {item.reqs && (
                  <Box>
                    <GroupTitle
                      title={
                        mode === MODE.cooking ? 'Ingredients' : 'Materials'
                      }
                    />
                    {Object.keys(item.reqs).map((atom_id) => (
                      <RecipeIngredient
                        key={atom_id}
                        atom_id={atom_id}
                        amount={item.reqs[atom_id]}
                        mode={mode}
                        busy={busy}
                      />
                    ))}
                  </Box>
                )}
                {item.chem_catalysts && (
                  <Box>
                    <GroupTitle title="Catalysts" />
                    {Object.keys(item.chem_catalysts).map((atom_id) => (
                      <AtomContent
                        key={atom_id}
                        atom_id={atom_id}
                        amount={item.chem_catalysts[atom_id]}
                      />
                    ))}
                  </Box>
                )}
                {(item.tool_paths || item.tool_behaviors) && (
                  <Box>
                    <GroupTitle title="Tools" />
                    {item.tool_paths?.map((tool) => (
                      <AtomContent key={tool} atom_id={tool} amount={1} />
                    ))}
                    {item.tool_behaviors?.map((tool) => (
                      <ToolContent key={tool} tool={tool} />
                    ))}
                  </Box>
                )}
                {item.machinery && (
                  <Box>
                    <GroupTitle title="Machinery" />
                    {item.machinery.map((atom_id) => (
                      <AtomContent key={atom_id} atom_id={atom_id} amount={1} />
                    ))}
                  </Box>
                )}
                {item.structures && (
                  <Box>
                    <GroupTitle title="Structures" />
                    {item.structures.map((atom_id) => (
                      <AtomContent key={atom_id} atom_id={atom_id} amount={1} />
                    ))}
                  </Box>
                )}
              </Box>
              {!!item.steps?.length && (
                <Box>
                  <GroupTitle title="Steps" />
                  <ul style={{ paddingLeft: '20px' }}>
                    {item.steps.map((step) => (
                      <li key={step}>{step}</li>
                    ))}
                  </ul>
                </Box>
              )}
            </Stack.Item>
            <Stack.Item pl={1} grow={2}>
              <Stack vertical>
                <Stack.Item>
                  {!item.non_craftable && (
                    <Stack>
                      <Stack.Item grow>
                        <Button
                          lineHeight={2.5}
                          align="center"
                          fluid
                          disabled={!craftable || busy}
                          icon={
                            busy
                              ? 'circle-notch'
                              : mode === MODE.cooking
                                ? 'utensils'
                                : 'hammer'
                          }
                          iconSpin={!!busy}
                          onClick={() =>
                            act('make', {
                              recipe: item.ref,
                            })
                          }
                        >
                          Создать
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        {!!item.mass_craftable && (
                          <Button
                            minWidth="30px"
                            lineHeight={2.5}
                            align="center"
                            tooltip="Repeat this craft until you run out of ingredients."
                            tooltipPosition="top"
                            disabled={!craftable || busy}
                            icon="repeat"
                            iconSpin={!!busy}
                            onClick={() =>
                              act('make_mass', {
                                recipe: item.ref,
                              })
                            }
                          />
                        )}
                      </Stack.Item>
                    </Stack>
                  )}
                </Stack.Item>
                <Stack.Item>
                  {!!item.complexity && (
                    <Box color="gray" width="104px" lineHeight={1.5} mt={1}>
                      Сложность: {item.complexity}
                    </Box>
                  )}
                  {!!item.foodtypes && item.foodtypes.length > 0 && (
                    <Box color="gray" width="104px" lineHeight={1.5} mt={1}>
                      <Divider />
                      {item.foodtypes.map((foodtype) => (
                        <FoodtypeContent
                          key={item.ref + foodtype}
                          type={foodtype}
                          diet={diet}
                        />
                      ))}
                    </Box>
                  )}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
