const initialState = {
  visible: false,
  list: {},
};

export const emotesReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === 'emotes/toggle') {
    return {
      ...state,
      visible: !state.visible,
    };
  }
  if (type === 'emotes/setList') {
    return {
      ...state,
      list: payload,
    };
  }
  return state;
};
