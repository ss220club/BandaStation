import '../../styles/interfaces/NanoMap.scss';

import type { ReactNode } from 'react';
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

type Props = Partial<{
  /** Content on map. Like buttons. Use only NanoMap.xxx components */
  children: ReactNode;
  /** Name of PNG map image. Example: 'Cyberiad_nanomap_z2' */
  mapUrl: string;
  /** Called when zoom level changes. Returns zoom level */
  onZoom: (zoom: number) => void;
}>;

const defaultZoom = 0.225;

export function NanoMap(props: Props) {
  const { children, mapUrl, onZoom } = props;
  const mapImage = (
    <img className="NanoMap__Image" src={resolveAsset(mapUrl || '')} />
  );

  return (
    <TransformWrapper
      centerOnInit
      initialScale={defaultZoom}
      minScale={defaultZoom}
      maxScale={2}
      smooth={false}
      wheel={{ step: 0.25 }}
      doubleClick={{ mode: 'reset' }}
      onZoomStop={({ state }) => onZoom && onZoom(state.scale)}
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

function NanoMapControls() {
  const { zoomIn, zoomOut, centerView } = useControls();
  return (
    <Stack justify="center" className="NanoMap__Minimap--controls">
      <Stack.Item>
        <Button
          className="NanoMap__Minimap--button"
          icon="plus"
          onClick={() => zoomIn(2)}
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
          onClick={() => zoomOut(2)}
        />
      </Stack.Item>
    </Stack>
  );
}

function NanoMapZSelector() {
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
}

/**
 * It's imposible to make types now, cause <Button> props is not exported
 */
/*
type NanoMapButtonProps = {
  posX: number;
  posY: number;
  zoom?: number;
}
*/
function MapButton(props) {
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
          tooltipPosition={'top-end'}
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
}

NanoMap.Button = MapButton;
