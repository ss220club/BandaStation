import '../../styles/interfaces/NanoMap.scss';

import { useState } from 'react';
import {
  TransformWrapper,
  TransformComponent,
  KeepScale,
  useControls,
} from 'react-zoom-pan-pinch';
import {
  Button,
  Icon,
  LabeledList,
  Section,
  Slider,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';

const defaultZoom = 0.225;
export function NanoMap(props) {
  const { children, mapUrl, objects, onObjectClick } = props;
  const [zoom, setZoom] = useState(defaultZoom);

  return (
    <TransformWrapper
      centerOnInit
      initialScale={defaultZoom}
      minScale={defaultZoom}
      maxScale={8}
      onZoomStop={({ state }) => setZoom(state.scale)}
    >
      <Section fill>
        <Stack fill vertical>
          <Stack.Item>
            <Stack fill justify="space-between">
              <Stack.Item>
                <NanoMapControls />
              </Stack.Item>
              <Stack.Item>
                <NanoMapZSelector />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item grow>
            <TransformComponent
              wrapperStyle={{
                overflow: 'hidden',
                width: '100%',
                height: '100%',
              }}
            >
              <div>
                <img src={resolveAsset(mapUrl)} />
                <div>
                  {objects.map((object) => (
                    <div
                      style={{
                        position: 'absolute',
                        left: object.x * 8 + 'px',
                        bottom: object.y * 8 + 'px',
                        transform: 'translate(-100%, 50%)',
                        zIndex: 2,
                      }}
                    >
                      <KeepScale>
                        <Button
                          className="NanoMap__Object"
                          key={object.ref}
                          tooltip={object.name}
                          onClick={() => onObjectClick(object)}
                        />
                      </KeepScale>
                    </div>
                  ))}
                </div>
              </div>
            </TransformComponent>
          </Stack.Item>
        </Stack>
      </Section>
    </TransformWrapper>
  );
}

const NanoMapControls = (props, context) => {
  const { act } = useBackend();
  const { zoomIn, zoomOut, centerView } = useControls();

  return (
    <Stack>
      <Stack.Item>
        <Button
          icon="plus"
          tooltip="Увеличить"
          tooltipPosition="bottom-start"
          onClick={() => zoomIn()}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="minus"
          tooltip="Уменьшить"
          tooltipPosition="bottom-start"
          onClick={() => zoomOut()}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="arrows-to-circle"
          tooltip="Центрировать"
          tooltipPosition="bottom"
          onClick={() => centerView()}
        />
      </Stack.Item>
    </Stack>
  );
};

const NanoMapZSelector = (props, context) => {
  const { act } = useBackend();
  return (
    <Stack>
      <Stack.Item>
        <Button
          icon={'chevron-down'}
          tooltip={'Уровнем ниже'}
          tooltipPosition={'bottom-end'}
          onClick={() => act('switch_z_level', { z_dir: -1 })}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          icon={'chevron-up'}
          tooltip={'Уровнем выше'}
          tooltipPosition={'bottom-end'}
          onClick={() => act('switch_z_level', { z_dir: 1 })}
        />
      </Stack.Item>
    </Stack>
  );
};
