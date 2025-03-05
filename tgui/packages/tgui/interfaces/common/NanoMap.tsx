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
   * Allowed values: 'top-left', 'top-right', 'bottom-left', 'bottom-right'
   * Default: 'top-left'
   */
  minimapPosition?: MinimapPosition;
  /** All needed map data from backend */
  mapData: MapData;
  /** Called when level changes. Returns current level */
  changeLevel: (level: number) => void;
  /** Called when zoom level changes. Returns zoom level */
  onZoom?: (zoom: number) => void;
};

type MinimapPosition =
  | 'top-left'
  | 'top-right'
  | 'bottom-left'
  | 'bottom-right';

const defaultScale = 0.25;
const minScale = defaultScale / 2;
const maxScale = defaultScale * 4;

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
    changeLevel,
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

  return (
    <TransformWrapper
      centerOnInit
      initialScale={minScale}
      minScale={minScale}
      maxScale={maxScale}
      smooth={false}
      wheel={{ step: defaultScale / 2 }}
      panning={{ velocityDisabled: mapPrefs.velocity }}
      doubleClick={{ disabled: true }}
      onZoomStop={({ state }) => {
        onZoom && onZoom(state.scale);
        setZoom(state.scale);
      }}
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
                currentLevel={currentLevel}
                setCurrentLevel={setCurrentLevel}
                changeLevel={changeLevel}
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
  const {
    children,
    prefs,
    setPrefs,
    mapData,
    currentLevel,
    setCurrentLevel,
    changeLevel,
  } = props;

  return (
    <Stack vertical className="NanoMap__Buttons">
      <NanoMapLevelSelector
        mapData={mapData}
        currentLevel={currentLevel}
        setCurrentLevel={setCurrentLevel}
        changeLevel={changeLevel}
      />
      <Stack.Item>{children}</Stack.Item>
      <Stack.Item mt={0.5}>
        <Button
          icon={'gear'}
          tooltip="Параметры"
          tooltipPosition="right"
          onClick={() => setPrefs(!prefs)}
        />
      </Stack.Item>
    </Stack>
  );
}

function NanoMapLevelSelector(props) {
  const { mapData, currentLevel, setCurrentLevel, changeLevel } = props;

  function changeAllLevels(level) {
    setCurrentLevel(level);
    changeLevel(level);
  }

  return (
    <Stack.Item grow>
      <Stack vertical>
        {mapData.min_floor !== mapData.maxFloor && (
          <>
            <Stack.Item>
              <Button
                icon="chevron-up"
                disabled={currentLevel >= mapData.maxFloor}
                onClick={() => changeAllLevels(currentLevel + 1)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="chevron-down"
                disabled={
                  currentLevel > mapData.maxFloor ||
                  currentLevel <= mapData.minFloor
                }
                onClick={() => {
                  changeAllLevels(currentLevel - 1);
                }}
              />
            </Stack.Item>
          </>
        )}
        {mapData.lavalandLevel > 0 && (
          <Stack.Item>
            <Button
              icon="volcano"
              selected={currentLevel === mapData.lavalandLevel}
              tooltip="Лаваленд"
              onClick={() => {
                if (currentLevel === mapData.lavalandLevel) {
                  changeAllLevels(mapData.mainFloor);
                } else {
                  changeAllLevels(mapData.lavalandLevel);
                }
              }}
            />
          </Stack.Item>
        )}
      </Stack>
    </Stack.Item>
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

/** TODO: Add types when <Button /> types will exported */
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
