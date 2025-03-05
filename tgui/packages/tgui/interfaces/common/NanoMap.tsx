import '../../styles/interfaces/NanoMap.scss';

import { type ReactNode, useState } from 'react';
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
import { useLocalStorage } from 'usehooks-ts';
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
  /** Enables centering on selected target */
  selectedTarget?: BooleanLike;
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
  /** Called when zoom level changes. Returns zoom level */
  onZoom?: (zoom: number) => void;
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
    selectedTarget,
    onLevelChange,
    onZoom,
  } = props;

  const [prefs, setPrefs] = useState(false);
  const [zoom, setZoom] = useState(defaultScale);
  const [currentLevel, setCurrentLevel] = useState(mapData.mainFloor);
  const [mapPrefs, setMapPrefs] = useLocalStorage('nanomap-preferences', {
    velocity: true,
    minimap: true,
    minimapPosition: 'top-left',
  });

  function getMapImage(level) {
    let imageAsset;
    if (level === mapData.lavalandLevel) {
      imageAsset = resolveAsset(`Lavaland_nanomap_z1.png`);
    } else {
      imageAsset = resolveAsset(`${mapData.name}_nanomap_z${level - 1}.png`);
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
  onZoom && onZoom(zoom);
  onLevelChange && onLevelChange(currentLevel);

  return (
    <TransformWrapper
      centerOnInit
      initialScale={defaultScale}
      minScale={defaultScale}
      maxScale={maxScale}
      smooth={false}
      wheel={{ step: defaultScale }}
      panning={{ velocityDisabled: mapPrefs.velocity }}
      doubleClick={{ disabled: true }}
      onZoomStop={({ state }) => state.scale}
      onTransformed={({ state }) => setZoom(state.scale)}
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
                level={currentLevel}
                setLevel={setCurrentLevel}
                prefs={prefs}
                setPrefs={setPrefs}
              >
                {buttons}
              </NanoMapButtons>
              {!minimapDisabled && mapPrefs.minimap && (
                <MiniMap className="NanoMap__Minimap" width={150}>
                  {getMapImage(currentLevel)}
                </MiniMap>
              )}
              <NanoMapControls zoom={zoom} selectedTarget={selectedTarget} />
            </div>
            <TransformComponent
              wrapperStyle={{ width: '100%', height: '100%' }}
            >
              {getMapImage(currentLevel)}
              <div>{children}</div>
            </TransformComponent>
          </Stack.Item>
        </Stack>
      </Section>
    </TransformWrapper>
  );
}

function NanoMapControls(props) {
  const { zoom, selectedTarget } = props;
  const { zoomIn, zoomOut, centerView, zoomToElement } = useControls();
  return (
    <div className="NanoMap__Controls">
      <Button icon="plus" onClick={() => zoomIn(maxScale)} />
      <Button
        fluid
        width="100%"
        onClick={() =>
          selectedTarget ? zoomToElement('selected', 200) : centerView()
        }
      >
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
  const { children, prefs, setPrefs, mapData, level, setLevel } = props;
  return (
    <Stack fill vertical className="NanoMap__Buttons">
      <Stack.Item grow>
        <NanoMapLevelSelector
          mapData={mapData}
          level={level}
          setLevel={setLevel}
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
  const { mapData, level, setLevel } = props;
  return (
    <Stack vertical>
      {mapData.min_floor !== mapData.maxFloor && (
        <>
          <Stack.Item>
            <Button
              icon="chevron-up"
              disabled={level >= mapData.maxFloor}
              onClick={() => setLevel(level + 1)}
            />
          </Stack.Item>
          <Stack.Item mt={0.5}>
            <Button
              icon="chevron-down"
              disabled={level > mapData.maxFloor || level <= mapData.minFloor}
              onClick={() => setLevel(level - 1)}
            />
          </Stack.Item>
        </>
      )}
      {mapData.lavalandLevel > 0 && (
        <Stack.Item mt={mapData.min_floor !== mapData.maxFloor && 0.5}>
          <Button
            icon="volcano"
            selected={level === mapData.lavalandLevel}
            tooltip="Лаваленд"
            onClick={() =>
              setLevel(
                level === mapData.lavalandLevel
                  ? mapData.mainFloor
                  : mapData.lavalandLevel,
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
          <LabeledList.Item
            label="Инерция"
            tooltip="Если включено, карта продолжит двигаться по инерции после отпускания мыши при перемещении."
          >
            <Button.Checkbox
              checked={!mapPrefs.velocity}
              onClick={() =>
                setMapPrefs((old) => ({ ...old, velocity: !old.velocity }))
              }
            />
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
  const { tracking = false, zoom, posX, posY, ...rest } = props;
  const { zoomToElement } = useControls();
  const buttonId = `${posX}_${posY}`;
  return (
    <div
      id={props.selected ? 'selected' : buttonId}
      className="NanoMap__Object--wrapper"
      style={{ left: posToPx(posX), bottom: posToPx(posY) }}
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
