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
import { clamp01 } from 'tgui-core/math';
import { BooleanLike } from 'tgui-core/react';
import { useLocalStorage } from 'usehooks-ts';

import { resolveAsset } from '../../assets';

type Props = Partial<{
  /** Content on map. Like buttons. Use only NanoMap.xxx components */
  children: ReactNode;
  /** Additional control buttons container. */
  buttons: ReactNode;
  /** Name of PNG map image. Example: 'Cyberiad_nanomap_z2' */
  mapImage: string;
  /**
   * Do we have any target in selection?
   * If yes then center button will teleport you to it
   */
  selectedTarget: BooleanLike;
  /** Called when zoom level changes. Returns zoom level */
  onZoom: (zoom: number) => void;
}>;

const defaultScale = 0.25;
const minScale = defaultScale / 2;
const maxScale = defaultScale * 4;

/**
 * Converts object position to pixel position.
 */
const defaultMapSize = 4080;
const tileSize = defaultMapSize / 255;
function posToPx(pos: number) {
  return `${pos * tileSize - tileSize}px`;
}

export function NanoMap(props: Props) {
  const { children, buttons, mapImage, selectedTarget, onZoom } = props;
  const [velocity, setVelocity] = useLocalStorage('nanomap-velocity', true);
  const [zoom, setZoom] = useState(defaultScale);
  const image = (
    <img
      style={{
        width: `${defaultMapSize}px`,
        height: `${defaultMapSize}px`,
      }}
      src={resolveAsset(mapImage || '')}
    />
  );

  return (
    <TransformWrapper
      centerOnInit
      initialScale={defaultScale}
      minScale={minScale}
      maxScale={maxScale}
      smooth={false}
      wheel={{ step: defaultScale / 2 }}
      panning={{ velocityDisabled: velocity }}
      doubleClick={{ disabled: true }}
      onZoomStop={({ state }) => {
        onZoom && onZoom(state.scale);
        setZoom(state.scale);
      }}
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
              <NanoMapControls
                zoom={zoom}
                setZoom={setZoom}
                selectedTarget={selectedTarget}
              />
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

function NanoMapControls(props) {
  const { zoom, setZoom, selectedTarget } = props;
  const { zoomIn, zoomOut, centerView, zoomToElement } = useControls();

  return (
    <div className="NanoMap__Controls">
      <Stack.Item>
        <Button
          icon="plus"
          onClick={() => {
            zoomIn(maxScale);
            setZoom(maxScale);
          }}
        />
      </Stack.Item>
      <Stack.Item grow textAlign="center">
        <Button
          fluid
          onClick={() =>
            selectedTarget ? zoomToElement('selected', zoom, 200) : centerView()
          }
        >
          <div
            className="NanoMap__Controls--zoom"
            style={{
              width: `${clamp01(zoom) * 100}%`,
            }}
          />
          Центр
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="minus"
          onClick={() => {
            zoomOut(maxScale);
            setZoom(minScale);
          }}
        />
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
  const { tracking = false, zoom = defaultScale, posX, posY, ...rest } = props;
  const { zoomToElement } = useControls();
  const buttonId = `${posX}_${posY}`;
  return (
    <div
      id={props.selected ? 'selected' : buttonId}
      style={{
        position: 'absolute',
        left: posToPx(posX),
        bottom: posToPx(posY),
        transform: 'translate(17.5%, 5%)',
        zIndex: 2,
      }}
    >
      <KeepScale>
        <Button
          {...rest}
          className="NanoMap__Object"
          tooltipPosition={'top-end'}
          onClick={(event) => {
            tracking && zoomToElement(buttonId, zoom, 200);
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
