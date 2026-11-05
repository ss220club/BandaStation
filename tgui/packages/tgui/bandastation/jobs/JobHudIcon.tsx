import '../../styles/bandastation/job_hud_icon.scss';

import { Icon } from 'tgui-core/components';

export function JobHudIcon(props: { icon?: string; fallback?: string | null }) {
  if (props.icon) {
    return (
      <img
        className="JobHudIcon"
        src={`data:image/png;base64,${props.icon}`}
        alt=""
      />
    );
  }
  return props.fallback ? <Icon name={props.fallback} /> : null;
}
