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
  LabeledList,
  Modal,
  Section,
  Stack,
} from 'tgui-core/components';
import { clamp01 } from 'tgui-core/math';
import { BooleanLike, classes } from 'tgui-core/react';
import { useLocalStorage } from 'usehooks-ts';

import { resolveAsset } from '../../assets';

type Props = Partial<{
  /** Content on map. Like buttons. Use only NanoMap.xxx components */
  children: ReactNode;
  /** Additional control buttons container */
  buttons: ReactNode;
  /** Name of PNG map image. Example: 'Cyberiad_nanomap_z2' */
  mapImage: string;
  /**
   * Do we have any target in selection?
   * If yes then center button will teleport you to it
   */
  /** Allows you to disable minimap */
  minimapDisabled: BooleanLike;
  /**
   * Changes minimap position.
   * Allowed values: 'top-left', 'top-right', 'bottom-left', 'bottom-right'
   * Default: 'top-left'
   */
  minimapPosition: MinimapPosition;
  /** Enables centering on selected target */
  selectedTarget: BooleanLike;
  /** Called when zoom level changes. Returns zoom level */
  onZoom: (zoom: number) => void;
}>;

type MinimapPosition =
  | 'top-left'
  | 'top-right'
  | 'bottom-left'
  | 'bottom-right';

const minimapPositions: Record<MinimapPosition, number> = {
  'top-left': -90,
  'top-right': 0,
  'bottom-left': 180,
  'bottom-right': 90,
};

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
  const {
    children,
    buttons,
    mapImage,
    minimapDisabled,
    minimapPosition,
    selectedTarget,
    onZoom,
  } = props;
  const [prefs, setPrefs] = useState(false);
  const [zoom, setZoom] = useState(defaultScale);
  const [velocity, setVelocity] = useLocalStorage('nanomap-velocity', true);
  const [minimapPref, setMinimapPref] = useLocalStorage(
    'nanomap-minimap',
    true,
  );
  const [minimapPositionPref, setMinimapPositionPref] = useLocalStorage(
    'nanomap-minimapPosition',
    'top-left',
  );
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
      initialScale={minScale}
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
        {prefs && (
          <NanoMapPreferences
            setPrefs={setPrefs}
            velocity={velocity}
            setVelocity={setVelocity}
            minimapDisabled={minimapDisabled}
            minimapPref={minimapPref}
            setMinimap={setMinimapPref}
            minimapPosition={minimapPositionPref}
            setMinimapPosition={setMinimapPositionPref}
          />
        )}
        <Stack fill vertical>
          <Stack.Item
            grow
            className={classes([
              'NanoMap',
              `NanoMap--${minimapPosition ? minimapPosition : minimapPositionPref}`,
            ])}
          >
            <div
              className={classes([
                'NanoMap__Minimap--container',
                minimapDisabled
                  ? 'NanoMap__Minimap--disabled'
                  : !minimapPref && 'NanoMap__Minimap--disabled',
              ])}
            >
              <NanoMapButtons prefs={prefs} setPrefs={setPrefs}>
                {buttons}
              </NanoMapButtons>
              {!minimapDisabled && minimapPref && (
                <MiniMap className="NanoMap__Minimap" width={150}>
                  {image}
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
  const { children, prefs, setPrefs } = props;
  return (
    <Stack vertical className="NanoMap__Buttons">
      {children}
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

function NanoMapPreferences(props) {
  const {
    setPrefs,
    velocity,
    setVelocity,
    minimapDisabled,
    minimapPref,
    setMinimap,
    minimapPosition,
    setMinimapPosition,
  } = props;
  const cannotSetPrefText = minimapDisabled
    ? 'В данном интерфейсе нельзя изменять параметры мини-карты, и её состояние.'
    : undefined;

  return (
    <Modal p={1}>
      <Section
        fill
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
                  selected={minimapPosition === key}
                  onClick={() => setMinimapPosition(key)}
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
              checked={!velocity}
              onClick={() => setVelocity(!velocity)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Мини-карта">
            <Button.Checkbox
              checked={minimapPref}
              disabled={minimapDisabled}
              tooltip={cannotSetPrefText}
              onClick={() => setMinimap(!minimapPref)}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Modal>
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
