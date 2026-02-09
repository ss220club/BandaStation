import { XenobioRecipesLayout } from '../bandastation/XenobioRecipes';
import { Window } from '../layouts';

export const XenobioRecipes = () => {
  return (
    <Window title="Рецепты слаймов" width={1200} height={880}>
      <Window.Content>
        <XenobioRecipesLayout />
      </Window.Content>
    </Window>
  );
};
