import '../../styles/interfaces/NanoMap.scss';

import { useLocalStorage } from '@uidotdev/usehooks';
import { type ReactNode, useRef, useState } from 'react';
import {
  KeepScale,
  MiniMap,
  TransformComponent,
  TransformWrapper,
  useControls,
} from 'react-zoom-pan-pinch';
import {
  Button,
  Icon,
  Image,
  LabeledList,
  Modal,
  Section,
  Stack,
} from 'tgui-core/components';
import { clamp01 } from 'tgui-core/math';
import { BooleanLike, classes } from 'tgui-core/react';

import { resolveAsset } from '../../assets';
import { useSharedState } from '../../backend';

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
  /** UI name for shared state */
  uiName?: string;
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
    uiName,
    minimapDisabled,
    minimapPosition,
    onLevelChange,
  } = props;

  const [prefs, setPrefs] = useState(false);
  const [mapPrefs, setMapPrefs] = useLocalStorage('nanomap-preferences', {
    minimap: true,
    minimapPosition: 'top-left',
  });
  const [mapState, setMapState] = uiName
    ? useSharedState(`${uiName}-nanomap`, {
        scale: defaultScale,
        positionX: 0,
        positionY: 0,
        currentLevel: mapData.mainFloor,
      })
    : useState({
        scale: defaultScale,
        positionX: 0,
        positionY: 0,
        currentLevel: mapData.mainFloor,
      });

  function getMapImage(level) {
    const { name, lavalandLevel, minFloor } = mapData;
    let imageAsset;
    if (level === lavalandLevel && lavalandLevel !== minFloor) {
      imageAsset = resolveAsset(`Lavaland_nanomap_z1.png`);
    } else {
      imageAsset = resolveAsset(`${name}_nanomap_z${level - 1}.png`);
    }
    return (
      <Image
        width={`${defaultMapSize}px`}
        height={`${defaultMapSize}px`}
        src={imageAsset}
      />
    );
  }

  // Send component data to UI, if he has useState for them.
  onLevelChange && onLevelChange(mapState.currentLevel);
  function handleTransformed({ state }) {
    setMapState({
      scale: state.scale,
      positionX: state.positionX,
      positionY: state.positionY,
      currentLevel: mapState.currentLevel,
    });
  }

  return (
    <TransformWrapper
      centerOnInit={mapState.positionX === 0 && mapState.positionY === 0}
      minScale={defaultScale}
      maxScale={maxScale}
      initialScale={mapState.scale}
      initialPositionX={mapState.positionX}
      initialPositionY={mapState.positionY}
      smooth={false}
      wheel={{ step: defaultScale }}
      panning={{ velocityDisabled: true }}
      doubleClick={{ disabled: true }}
      alignmentAnimation={{ animationTime: 0 }}
      onZoomStop={handleTransformed}
      onPanningStop={handleTransformed}
    >
      <Section fill>
        {prefs && (
          <NanoMapPreferences
            setPrefs={setPrefs}
            mapPrefs={mapPrefs}
            setMapPrefs={setMapPrefs}
            minimapDisabled={minimapDisabled}
          />
        )}
        <Stack fill vertical>
          <Stack.Item
            grow
            minWidth={0}
            minHeight={0}
            className={classes([
              'NanoMap',
              `NanoMap--${minimapPosition ? minimapPosition : mapPrefs.minimapPosition}`,
            ])}
          >
            <div
              className={classes([
                'NanoMap__Minimap--container',
                minimapDisabled
                  ? 'NanoMap__Minimap--disabled'
                  : !mapPrefs.minimap && 'NanoMap__Minimap--disabled',
              ])}
            >
              <NanoMapButtons
                mapData={mapData}
                mapState={mapState}
                setMapState={setMapState}
                prefs={prefs}
                setPrefs={setPrefs}
              >
                {buttons}
              </NanoMapButtons>
              {!minimapDisabled && mapPrefs.minimap && (
                <MiniMap className="NanoMap__Minimap" width={150}>
                  {getMapImage(mapState.currentLevel)}
                </MiniMap>
              )}
              <NanoMapControls zoom={mapState.scale} />
            </div>
            <NanoMapTransformComponent
              mapState={mapState}
              uiName={uiName}
              getMapImage={getMapImage}
            >
              {children}
            </NanoMapTransformComponent>
          </Stack.Item>
        </Stack>
      </Section>
    </TransformWrapper>
  );
}

function NanoMapTransformComponent(props) {
  const { children, mapState, uiName, getMapImage } = props;
  const { setTransform } = useControls();
  const mapStateRef = useRef(mapState);

  if (uiName) {
    const prevMapState = mapStateRef.current;
    if (JSON.stringify(prevMapState) !== JSON.stringify(mapState)) {
      setTransform(mapState.positionX, mapState.positionY, mapState.scale);
    }
    mapStateRef.current = mapState;
  }

  return (
    <TransformComponent wrapperStyle={{ width: '100%', height: '100%' }}>
      {getMapImage(mapState.currentLevel)}
      <div>{children}</div>
    </TransformComponent>
  );
}

function NanoMapControls(props) {
  const { zoom } = props;
  const { zoomIn, zoomOut, centerView } = useControls();

  return (
    <div className="NanoMap__Controls">
      <Button icon="plus" onClick={() => zoomIn(maxScale)} />
      <Button fluid width="100%" onClick={() => centerView()}>
        <div
          className="NanoMap__Controls--zoom"
          style={{ width: `${clamp01(zoom) * 100}%` }}
        />
        Центр
      </Button>
      <Button icon="minus" onClick={() => zoomOut(maxScale)} />
    </div>
  );
}

function NanoMapButtons(props) {
  const { children, prefs, setPrefs, mapData, mapState, setMapState } = props;
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
      <Stack.Item mt={0.5}>
        <Button
          icon="gear"
          tooltip="Параметры"
          tooltipPosition="right"
          onClick={() => setPrefs(!prefs)}
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
    setMapState({
      scale: mapState.scale,
      positionX: mapState.positionX,
      positionY: mapState.positionY,
      currentLevel: level,
    });
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
          <Stack.Item mt={0.5}>
            <Button
              icon="chevron-down"
              disabled={currentLevel > maxFloor || currentLevel <= minFloor}
              onClick={() => setLevel(currentLevel - 1)}
            />
          </Stack.Item>
        </>
      )}
      {lavalandLevel > maxFloor && (
        <Stack.Item mt={minFloor !== maxFloor && 0.5}>
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

function NanoMapPreferences(props) {
  const { mapPrefs, setMapPrefs, setPrefs, minimapDisabled } = props;
  const minimapPositions: Record<MinimapPosition, number> = {
    'top-left': -90,
    'top-right': 0,
    'bottom-left': 180,
    'bottom-right': 90,
  };

  const cannotSetPrefText = minimapDisabled
    ? 'В данном интерфейсе нельзя изменять параметры мини-карты, и её состояние.'
    : undefined;

  return (
    <Modal p={0.5}>
      <Section
        m={0}
        title="Параметры карты"
        backgroundColor="rgba(0, 0, 0, 0.33)"
        buttons={
          <Button color="red" icon="times" onClick={() => setPrefs(false)} />
        }
      >
        <LabeledList>
          <LabeledList.Item label="Позиция мини-карты">
            <Stack wrap width={5}>
              {Object.keys(minimapPositions).map((key) => (
                <Button
                  key={key}
                  color="transparent"
                  selected={mapPrefs.minimapPosition === key}
                  onClick={() =>
                    setMapPrefs((old) => ({ ...old, minimapPosition: key }))
                  }
                >
                  <Icon
                    name="location-arrow"
                    rotation={minimapPositions[key]}
                  />
                </Button>
              ))}
            </Stack>
          </LabeledList.Item>
          <LabeledList.Item label="Мини-карта">
            <Button.Checkbox
              checked={mapPrefs.minimap}
              disabled={minimapDisabled}
              tooltip={cannotSetPrefText}
              onClick={() =>
                setMapPrefs((old) => ({ ...old, minimap: !old.minimap }))
              }
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Modal>
  );
}

/** TODO: Add types when <Button> types will exported */
function MapButton(props) {
  const { posX, posY, hidden, ...rest } = props;
  const buttonId = `${posX}_${posY}`;

  return (
    <div
      id={props.selected ? 'selected' : buttonId}
      className={classes([
        'NanoMap__Object--wrapper',
        hidden && 'NanoMap__Object--hidden',
      ])}
      style={{ left: posToPx(posX), bottom: posToPx(posY) }}
    >
      <KeepScale>
        <Button
          {...rest}
          className="NanoMap__Object"
          tooltipPosition={'top-end'}
          onClick={(event) => {
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

/** TODO: Add types when <Button> types will exported */
function MapMarker(props) {
  const { posX, posY, hidden, color, highlighted, ...rest } = props;
  const markerId = `${posX}_${posY}`;

  return (
    <div
      id={props.selected ? 'selected' : markerId}
      className={classes([
        'NanoMap__Marker--wrapper',
        hidden && 'NanoMap__Marker--hidden',
        props.selected && 'NanoMap__Marker--selected',
        highlighted && 'highlighted',
      ])}
      style={{ left: posToPx(posX), bottom: posToPx(posY) }}
    >
      <KeepScale>
        <div className="NanoMap__Marker--container">
          <div className={highlighted && 'NanoMap__Marker--highlighted'} />
          <Button
            {...rest}
            className={classes([
              'NanoMap__Marker',
              props.selected && 'NanoMap__Marker--selected',
            ])}
            style={{ backgroundColor: color }}
            tooltipPosition={'top-end'}
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

NanoMap.Marker = MapMarker;
