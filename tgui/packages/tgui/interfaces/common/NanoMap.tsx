import '../../styles/interfaces/NanoMap.scss';

import {
  KeepScale,
  MiniMap,
  TransformComponent,
  TransformWrapper,
  useControls,
} from 'react-zoom-pan-pinch';
import { Button, Section, Stack } from 'tgui-core/components';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';

const defaultZoom = 0.225;
export function NanoMap(props) {
  const { children, mapUrl, onZoom } = props;
  const mapImage = <img src={resolveAsset(mapUrl)} />;

  return (
    <TransformWrapper
      centerOnInit
      initialScale={defaultZoom}
      minScale={defaultZoom}
      maxScale={2}
      smooth={false}
      wheel={{ step: 0.25 }}
      doubleClick={{ mode: 'reset' }}
      onZoomStop={({ state }) => onZoom(state.scale)}
    >
      <Section fill>
        <Stack fill vertical>
          <Stack.Item grow style={{ position: 'relative' }}>
            <div className="NanoMap__Minimap--container">
              <NanoMapZSelector />
              <MiniMap className="NanoMap__Minimap" width={150}>
                {mapImage}
              </MiniMap>
              <NanoMapControls />
            </div>
            <TransformComponent
              wrapperStyle={{
                overflow: 'hidden',
                width: '100%',
                height: '100%',
              }}
            >
              {mapImage}
              <div>{children}</div>
            </TransformComponent>
          </Stack.Item>
        </Stack>
      </Section>
    </TransformWrapper>
  );
}

const NanoMapControls = () => {
  const { zoomIn, zoomOut, centerView } = useControls();

  return (
    <Stack justify="center" className="NanoMap__Minimap--controls">
      <Stack.Item>
        <Button
          className="NanoMap__Minimap--button"
          icon="plus"
          onClick={() => zoomIn()}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          className="NanoMap__Minimap--button"
          onClick={() => centerView()}
        >
          Центр
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          className="NanoMap__Minimap--button"
          icon="minus"
          onClick={() => zoomOut()}
        />
      </Stack.Item>
    </Stack>
  );
};

const NanoMapZSelector = () => {
  const { act } = useBackend();
  return (
    <Stack vertical className="NanoMap__Minimap--levelSelector">
      <Stack.Item>
        <Button
          className="NanoMap__Minimap--button"
          icon={'chevron-up'}
          onClick={() => act('switch_z_level', { z_dir: 1 })}
        />
      </Stack.Item>

      <Stack.Item>
        <Button
          className="NanoMap__Minimap--button"
          icon={'chevron-down'}
          onClick={() => act('switch_z_level', { z_dir: -1 })}
        />
      </Stack.Item>
    </Stack>
  );
};

const NanoMapButton = (props) => {
  const { zoom = defaultZoom, posX, posY, ...rest } = props;
  const { zoomToElement } = useControls();

  return (
    <div
      id={`Camera-${posX}_${posY}`}
      style={{
        position: 'absolute',
        left: posX * 8 + 'px',
        bottom: posY * 8 + 'px',
        transform: 'translate(-82.5%, 82.5%)',
        zIndex: 2,
      }}
    >
      <KeepScale>
        <Button
          className="NanoMap__Object"
          {...rest}
          onClick={(event) => {
            zoomToElement(`Camera-${posX}_${posY}`, zoom, 200);
            if (props.onClick) {
              props.onClick(event);
            }
          }}
        />
      </KeepScale>
    </div>
  );
};

NanoMap.Button = NanoMapButton;
