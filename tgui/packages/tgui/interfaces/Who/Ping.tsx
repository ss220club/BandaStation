import { Icon, Stack, Tooltip } from 'tgui-core/components';

export function ShowPing(props) {
  const { user } = props;
  return (
    <Stack wrap>
      <Tooltip content="Текущий пинг" position={'bottom-end'}>
        <Stack.Item color="green">
          <Icon name="clock-rotate-left" /> {Math.round(user.ping.lastPing)}ms
        </Stack.Item>
      </Tooltip>
      <Stack.Divider />
      <Tooltip content="Средний пинг" position={'bottom-end'}>
        <Stack.Item color="orange">
          <Icon name="chart-simple" /> {Math.round(user.ping.avgPing)}ms
        </Stack.Item>
      </Tooltip>
    </Stack>
  );
}
