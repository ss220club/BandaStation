import { useDispatch, useSelector } from 'tgui/backend';
import { selectEmotes } from './selectors';

export const useEmotes = () => {
  const emotes = useSelector(selectEmotes);
  const dispatch = useDispatch();
  return {
    ...emotes,
    toggle: () => dispatch({ type: 'emotes/toggle' }),
  };
};
