import '../../styles/interfaces/NanoMap.scss';

import { type ReactNode, useState } from 'react';
import {
  KeepScale,
  MiniMap,
  TransformComponent,
  TransformWrapper,
  useControls,
} from 'react-zoom-pan-pinch';
import { Button, Section, Stack } from 'tgui-core/components';

import { resolveAsset } from '../../assets';

type Props = Partial<{
  /** Content on map. Like buttons. Use only NanoMap.xxx components */
  children: ReactNode;
  /** Additional control buttons container. */
  buttons: ReactNode;
  /** Name of PNG map image. Example: 'Cyberiad_nanomap_z2' */
  mapImage: string;
  /** Called when zoom level changes. Returns zoom level */
  onZoom: (zoom: number) => void;
}>;

const defaultZoom = 0.225;

export function NanoMap(props: Props) {
  const { children, buttons, mapImage, onZoom } = props;
  const [velocity, setVelocity] = useState(true);
  const image = (
    <img className="NanoMap__Image" src={resolveAsset(mapImage || '')} />
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
      panning={{ velocityDisabled: velocity }}
      onZoomStop={({ state }) => onZoom && onZoom(state.scale)}
    >
      <Section fill>
        <Stack fill vertical>
          <Stack.Item grow style={{ position: 'relative' }}>
            <div className="NanoMap__Minimap--container">
              <NanoMapButtons velocity={velocity} setVelocity={setVelocity}>
                {buttons}
              </NanoMapButtons>
              <MiniMap className="NanoMap__Minimap" width={150}>
                {image}
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
              {image}
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
    <div className="NanoMap__Controls">
      <Stack.Item>
        <Button icon="plus" onClick={() => zoomIn(2)} />
      </Stack.Item>
      <Stack.Item grow textAlign="center">
        <Button fluid onClick={() => centerView()}>
          Центр
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button icon="minus" onClick={() => zoomOut(2)} />
      </Stack.Item>
    </div>
  );
}

function NanoMapButtons(props) {
  const { children, velocity, setVelocity } = props;
  return (
    <Stack vertical className="NanoMap__Buttons">
      <Stack.Item grow>{children}</Stack.Item>
      <Stack.Item mt={0.5}>
        <Button
          icon={'wind'}
          selected={!velocity}
          tooltip="Инерция"
          tooltipPosition="right"
          onClick={() => setVelocity(!velocity)}
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
  const { tracking = false, zoom = defaultZoom, posX, posY, ...rest } = props;
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
          {...rest}
          className="NanoMap__Object"
          tooltipPosition={'top-end'}
          onClick={(event) => {
            tracking && zoomToElement(`Camera-${posX}_${posY}`, zoom, 200);
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
