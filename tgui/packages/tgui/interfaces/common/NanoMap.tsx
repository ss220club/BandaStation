import '../../styles/interfaces/NanoMap.scss';

import { useLocalStorage } from '@uidotdev/usehooks';
import { type ReactNode, useEffect } from 'react';
import {
  KeepScale,
  MiniMap,
  TransformComponent,
  TransformWrapper,
  useControls,
} from 'react-zoom-pan-pinch';
import { Button, Image, Stack } from 'tgui-core/components';
import { clamp01 } from 'tgui-core/math';
import { type BooleanLike, classes } from 'tgui-core/react';

import { resolveAsset } from '../../assets';

export type MapData = {
  name: string;
  minFloor: number;
  mainFloor: number;
  maxFloor: number;
  lavalandLevel: number;
};

type Props = {
  /** Content on map. Like buttons. Use only NanoMap.xxx components */
  children?: ReactNode;
  /** Additional control buttons container */
  buttons?: ReactNode;
  /** Allows you to disable minimap */
  minimapDisabled?: BooleanLike;
  /**
   * Changes minimap position.
   ** Allowed values: 'top-left', 'top-right', 'bottom-left', 'bottom-right'
   ** Default: 'top-left'
   */
  minimapPosition?: MinimapPosition;
  /** All needed map data from backend */
  mapData: MapData;
  /** Called when level changes. Returns current level */
  onLevelChange: (level: number) => void;
};

type MinimapPosition =
  | 'top-left'
  | 'top-right'
  | 'bottom-left'
  | 'bottom-right';

const defaultScale = 0.125;
const maxScale = defaultScale * 8;

const defaultMapSize = 4080;
const tileSize = defaultMapSize / 255;

/** Converts object position to pixel position.*/
function posToPx(pos: number) {
  return `${pos * tileSize - tileSize}px`;
}

export function NanoMap(props: Props) {
  const {
    children,
    buttons,
    mapData,
    minimapDisabled,
    minimapPosition,
    onLevelChange,
  } = props;

  const [minimap, setMinimap] = useLocalStorage('nanomap-minimap', true);
  const [mapState, setMapState] = useLocalStorage('nanomap-state', {
    scale: defaultScale,
    positionX: 0,
    positionY: 0,
    currentLevel: mapData.mainFloor,
  });

  function getMapImage(level: number) {
    const { name, lavalandLevel, minFloor } = mapData;
    const image =
      level === lavalandLevel && lavalandLevel !== minFloor
        ? 'Lavaland_nanomap_z1.png'
        : `${name}_nanomap_z${level - 1}.png`;

    return (
      <Image
        width={`${defaultMapSize}px`}
        height={`${defaultMapSize}px`}
        src={resolveAsset(image)}
      />
    );
  }

  function handleTransformed({ state }) {
    setMapState((prev) => ({
      ...prev,
      positionX: state.positionX,
      positionY: state.positionY,
      scale: state.scale,
    }));
  }

  // Send component data to UI, if he has useState for them.
  useEffect(() => {
    onLevelChange?.(mapState.currentLevel);
  }, [mapState.currentLevel]);

  const mapImage = getMapImage(mapState.currentLevel);
  return (
    <TransformWrapper
      centerOnInit={mapState.positionX === 0 && mapState.positionY === 0}
      minScale={defaultScale}
      maxScale={maxScale}
      initialScale={mapState.scale}
      initialPositionX={mapState.positionX}
      initialPositionY={mapState.positionY}
      wheel={{ step: defaultScale }}
      doubleClick={{ disabled: true }}
      panning={{ velocityDisabled: true }}
      onWheel={handleTransformed}
      onPanningStop={handleTransformed}
    >
      <Stack
        fill
        vertical
        className={classes([
          'NanoMap',
          minimapPosition && `NanoMap--${minimapPosition}`,
        ])}
      >
        <Stack.Item grow minHeight={0} minWidth={0}>
          <div
            className={classes([
              'NanoMap__Minimap--container',
              (minimapDisabled || !minimap) && 'NanoMap__Minimap--disabled',
            ])}
          >
            <NanoMapButtons
              mapData={mapData}
              mapState={mapState}
              setMapState={setMapState}
              minimap={minimap}
              setMinimap={setMinimap}
            >
              {buttons}
            </NanoMapButtons>
            {!minimapDisabled && minimap && (
              <MiniMap className="NanoMap__Minimap" width={150}>
                {mapImage}
              </MiniMap>
            )}
            <NanoMapControls zoom={mapState.scale} setMapState={setMapState} />
          </div>
          <TransformComponent wrapperStyle={{ width: '100%', height: '100%' }}>
            {mapImage}
            <div>{children}</div>
          </TransformComponent>
        </Stack.Item>
      </Stack>
    </TransformWrapper>
  );
}

function NanoMapControls(props) {
  const { zoom } = props;
  const { zoomIn, zoomOut, centerView } = useControls();

  return (
    <div className="NanoMap__Controls">
      <Button icon="minus" onClick={() => zoomOut(maxScale)} />
      <Button fluid width="100%" onClick={() => centerView()}>
        <div
          className="NanoMap__Controls--zoom"
          style={{ width: `${clamp01(zoom) * 100}%` }}
        />
        Центр
      </Button>
      <Button icon="plus" onClick={() => zoomIn(maxScale)} />
    </div>
  );
}

function NanoMapButtons(props) {
  const { children, mapData, mapState, setMapState, minimap, setMinimap } =
    props;
  return (
    <Stack fill vertical className="NanoMap__Buttons">
      <Stack.Item grow>
        <NanoMapLevelSelector
          mapData={mapData}
          mapState={mapState}
          setMapState={setMapState}
        />
      </Stack.Item>
      <Stack.Item>{children}</Stack.Item>
      <Stack.Item>
        <Button
          selected={!minimap}
          icon={minimap ? 'eye' : 'eye-slash'}
          onClick={() => setMinimap(!minimap)}
        />
      </Stack.Item>
    </Stack>
  );
}

function NanoMapLevelSelector(props) {
  const { mapData, mapState, setMapState } = props;
  const { minFloor, maxFloor, mainFloor, lavalandLevel } = mapData;
  const { currentLevel } = mapState;

  function setLevel(level: number) {
    setMapState((prev) => ({
      ...prev,
      currentLevel: level,
    }));
  }

  return (
    <Stack vertical>
      {minFloor !== maxFloor && (
        <>
          <Stack.Item>
            <Button
              icon="chevron-up"
              disabled={currentLevel >= maxFloor}
              onClick={() => setLevel(currentLevel + 1)}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="chevron-down"
              disabled={currentLevel > maxFloor || currentLevel <= minFloor}
              onClick={() => setLevel(currentLevel - 1)}
            />
          </Stack.Item>
        </>
      )}
      {lavalandLevel > maxFloor && (
        <Stack.Item>
          <Button
            icon="volcano"
            selected={currentLevel === lavalandLevel}
            tooltip="Лаваленд"
            onClick={() =>
              setLevel(
                currentLevel === lavalandLevel ? mainFloor : lavalandLevel,
              )
            }
          />
        </Stack.Item>
      )}
    </Stack>
  );
}

/** TODO: Add types when <Button> types will exported */
function MapButton(props) {
  const { posX, posY, hidden, highlighted, ...rest } = props;
  const buttonId = `${posX}_${posY}`;

  return (
    <div
      id={props.selected ? 'selected' : buttonId}
      className={classes([
        'NanoMap__Object--wrapper',
        hidden && 'NanoMap__Object--hidden',
        props.selected && 'NanoMap__Object--selected',
        highlighted && 'highlighted',
      ])}
      style={{ left: posToPx(posX), bottom: posToPx(posY) }}
    >
      <KeepScale>
        <div className="NanoMap__Object--inner">
          {highlighted && <div className="NanoMap__Object--highlighted" />}
          <Button
            {...rest}
            className={classes([
              'NanoMap__Object',
              props.circular && 'NanoMap__Object--circular',
              props.selected && 'NanoMap__Object--selected',
            ])}
            tooltipPosition="top-end"
            onClick={(event) => {
              if (props.onClick) {
                props.onClick(event);
              }
            }}
          />
        </div>
      </KeepScale>
    </div>
  );
}

NanoMap.Button = MapButton;
