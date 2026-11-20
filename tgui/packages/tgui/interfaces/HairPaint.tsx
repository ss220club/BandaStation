import { useEffect, useMemo, useRef, useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import {
  Box,
  Button,
  Icon,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { InputButtons } from './common/InputButtons';
import { AdvancedCanvas } from './common/SpriteEditor/Components/AdvancedCanvas';
import { localizeCoords } from './common/SpriteEditor/helpers';
import { Dir } from './common/SpriteEditor/Types/types';
import {
  DIRECTIONS,
  EMPTY_PIXEL,
  editable,
  emptyPaint,
  type Frames,
  type Paint,
  type Point,
  packPaint,
  paintedFrame,
  paintStroke,
  previewFrame,
  SIZE,
} from './HairPaint/model';

type Data = {
  frames: Frames;
  backgrounds: Frames;
  paint: Paint | null;
  facial: boolean;
  error: string | null;
  response: number;
  color_picker_open: boolean;
  brush_color: string | null;
  brush_color_revision: number;
};

type Stroke = { direction: Dir; last: Point; before: Paint; color: string };
const TOOLS = [
  { id: 'paint', icon: 'paintbrush', label: 'Кисть', hint: 'ЛКМ — рисовать' },
  {
    id: 'erase',
    icon: 'eraser',
    label: 'Ластик',
    hint: 'Вернуть исходный цвет. Быстро: ПКМ',
  },
  {
    id: 'pick',
    icon: 'eye-dropper',
    label: 'Пипетка',
    hint: 'Взять цвет с рисунка. Быстро: Alt + ЛКМ',
  },
] as const;
const LABELS = {
  [Dir.SOUTH]: 'Спереди',
  [Dir.WEST]: 'Слева',
  [Dir.NORTH]: 'Сзади',
  [Dir.EAST]: 'Справа',
};

export function HairPaint() {
  const { data, act } = useBackend<Data>();
  const { frames, backgrounds, error, facial } = data;
  const [paint, setPaint] = useState<Paint>(() => data.paint ?? emptyPaint());
  const paintRef = useRef(paint);
  const [direction, setDirection] = useState(Dir.SOUTH);
  const [showGrid, setShowGrid] = useState(false);
  const [showCharacter, setShowCharacter] = useState(true);
  const [zoom, setZoom] = useState(1);
  const viewportRef = useRef<HTMLDivElement>(null);
  const panRef = useRef<Point | null>(null);
  const [panning, setPanning] = useState(false);
  const [tool, setTool] = useState<(typeof TOOLS)[number]['id']>('paint');
  const palette = useMemo(
    () => [
      ...new Set(
        DIRECTIONS.flatMap((direction) =>
          paintedFrame(frames[direction], paint[direction])
            .flat()
            .filter((pixel) => pixel.slice(7) !== '00')
            .map((pixel) => pixel.slice(0, 7).toLowerCase()),
        ),
      ),
    ],
    [frames, paint],
  );
  const [color, setColor] = useState(() => palette[0] ?? '#000000');
  const [history, setHistory] = useState<Paint[]>([]);
  const strokeRef = useRef<Stroke | null>(null);
  const [saving, setSaving] = useState(false);
  useEffect(() => setSaving(false), [data.response]);
  useEffect(() => {
    const stopPan = () => {
      panRef.current = null;
      setPanning(false);
    };
    const movePan = (event: MouseEvent) => {
      const viewport = viewportRef.current;
      const previous = panRef.current;
      if (!viewport || !previous) return;
      if (!(event.buttons & 4)) return stopPan();
      event.preventDefault();
      viewport.scrollLeft -= event.clientX - previous[0];
      viewport.scrollTop -= event.clientY - previous[1];
      panRef.current = [event.clientX, event.clientY];
    };
    const endPan = (event: MouseEvent) => {
      if (event.button === 1) stopPan();
    };
    window.addEventListener('mousemove', movePan);
    window.addEventListener('mouseup', endPan);
    window.addEventListener('blur', stopPan);
    return () => {
      window.removeEventListener('mousemove', movePan);
      window.removeEventListener('mouseup', endPan);
      window.removeEventListener('blur', stopPan);
    };
  }, []);
  useEffect(() => {
    const viewport = viewportRef.current;
    if (!viewport) return;
    viewport.scrollLeft = (viewport.scrollWidth - viewport.clientWidth) / 2;
    viewport.scrollTop = (viewport.scrollHeight - viewport.clientHeight) / 2;
  }, [zoom]);
  useEffect(() => {
    if (data.brush_color) setColor(data.brush_color);
  }, [data.brush_color, data.brush_color_revision]);

  const updatePaint = (next: Paint) => {
    paintRef.current = next;
    setPaint(next);
  };
  const finishStroke = () => {
    const stroke = strokeRef.current;
    if (
      stroke &&
      stroke.before[stroke.direction] !== paintRef.current[stroke.direction]
    ) {
      setHistory((previous) => [...previous.slice(-29), stroke.before]);
    }
    strokeRef.current = null;
  };
  const plot = (point: Point) => {
    const stroke = strokeRef.current;
    if (!stroke) return;
    const next = paintStroke(
      paintRef.current[stroke.direction],
      frames[stroke.direction],
      stroke.last,
      point,
      stroke.color,
    );
    updatePaint({ ...paintRef.current, [stroke.direction]: next });
    stroke.last = point.map((value) =>
      Math.max(0, Math.min(SIZE - 1, value)),
    ) as Point;
  };
  const rotate = (step: number) => {
    finishStroke();
    setDirection(DIRECTIONS[(DIRECTIONS.indexOf(direction) + step + 4) % 4]);
  };
  const openPicker = () => {
    finishStroke();
    act('pick_color', { color });
  };
  const changeZoom = (next: number) => {
    finishStroke();
    setZoom(Math.max(1, Math.min(3, next)));
  };

  return (
    <Window
      width={540}
      height={740}
      theme="ss220"
      title={facial ? 'Редактор бороды' : 'Редактор волос'}
    >
      <Window.Content>
        <Stack fill vertical>
          {!!error && (
            <Stack.Item>
              <NoticeBox danger>{error}</NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item grow basis={0} minHeight={0}>
            <Section fill className="HairPaint__drawing">
              <Stack fill vertical align="center">
                <Stack.Item>
                  <Stack align="center">
                    {TOOLS.map((entry) => (
                      <Stack.Item key={entry.id}>
                        <Button
                          icon={entry.icon}
                          selected={tool === entry.id}
                          tooltip={entry.hint}
                          disabled={saving}
                          onClick={() => {
                            finishStroke();
                            setTool(entry.id);
                          }}
                        >
                          {entry.label}
                        </Button>
                      </Stack.Item>
                    ))}
                    <Stack.Item>
                      <Button
                        icon="undo"
                        tooltip="Отменить последний штрих"
                        disabled={saving || !history.length}
                        onClick={() => {
                          finishStroke();
                          updatePaint(history[history.length - 1]);
                          setHistory(history.slice(0, -1));
                        }}
                      >
                        Отмена
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button.Confirm
                        icon="trash"
                        tooltip="Сбросить рисунок на всех сторонах"
                        confirmContent="Сбросить всё?"
                        disabled={saving}
                        onClick={() => {
                          finishStroke();
                          setHistory((previous) => [
                            ...previous.slice(-29),
                            paintRef.current,
                          ]);
                          updatePaint(emptyPaint());
                        }}
                      >
                        Сброс
                      </Button.Confirm>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item
                  grow
                  basis={0}
                  minHeight={0}
                  width="100%"
                  className="HairPaint__canvas"
                  onContextMenu={(event) => event.preventDefault()}
                >
                  <div
                    ref={viewportRef}
                    className="HairPaint__viewport"
                    style={{ cursor: panning ? 'grabbing' : undefined }}
                    onMouseDownCapture={(event) => {
                      if (event.button !== 1) return;
                      event.preventDefault();
                      event.stopPropagation();
                      finishStroke();
                      panRef.current = [event.clientX, event.clientY];
                      setPanning(true);
                    }}
                    onAuxClick={(event) => {
                      if (event.button === 1) event.preventDefault();
                    }}
                    onMouseDown={(event) => event.stopPropagation()}
                  >
                    <Box
                      width={`${zoom * 100}%`}
                      height={`${zoom * 100}%`}
                      position="relative"
                    >
                      <AdvancedCanvas
                        width="100%"
                        height="100%"
                        style={{
                          position: 'absolute',
                          inset: 0,
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                        }}
                        backdropColor="#17212b"
                        showGrid={showGrid}
                        data={
                          showCharacter
                            ? previewFrame(
                                backgrounds[direction],
                                frames[direction],
                                paint[direction],
                              )
                            : paintedFrame(frames[direction], paint[direction])
                        }
                        onMouseDown={(event, ref) => {
                          if (
                            saving ||
                            (event.button !== 0 && event.button !== 2)
                          ) {
                            event.preventDefault();
                            return;
                          }
                          const point = localizeCoords(
                            event,
                            ref,
                            SIZE,
                            SIZE,
                          ).map(Math.floor) as Point;
                          if (
                            event.button === 0 &&
                            (event.altKey || tool === 'pick')
                          ) {
                            if (editable(frames[direction], ...point)) {
                              setColor(
                                paintedFrame(
                                  frames[direction],
                                  paintRef.current[direction],
                                )[point[1]][point[0]].slice(0, 7),
                              );
                            }
                            event.preventDefault();
                            return;
                          }
                          strokeRef.current = {
                            direction,
                            last: point,
                            before: paintRef.current,
                            color:
                              event.button === 2 || tool === 'erase'
                                ? EMPTY_PIXEL
                                : color,
                          };
                          plot(point);
                        }}
                        onMouseMove={(event, ref) => {
                          if (!saving)
                            plot(
                              localizeCoords(event, ref, SIZE, SIZE).map(
                                Math.floor,
                              ) as Point,
                            );
                        }}
                        onMouseUp={finishStroke}
                      />
                    </Box>
                  </div>
                </Stack.Item>
                <Stack.Item align="stretch">
                  <Stack align="center" justify="space-between">
                    <Stack.Item>
                      <Stack align="center">
                        <Stack.Item>
                          <Button
                            icon="chevron-left"
                            tooltip="Повернуть вид влево"
                            disabled={saving}
                            onClick={() => rotate(-1)}
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Box width={5} textAlign="center">
                            {LABELS[direction]}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="chevron-right"
                            tooltip="Повернуть вид вправо"
                            disabled={saving}
                            onClick={() => rotate(1)}
                          />
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      <Stack align="center">
                        <Stack.Item>
                          <Button
                            icon="search-minus"
                            tooltip="Уменьшить масштаб"
                            disabled={saving || zoom === 1}
                            onClick={() => changeZoom(zoom - 1)}
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            tooltip="Вписать холст в окно"
                            disabled={saving}
                            onClick={() => changeZoom(1)}
                          >
                            {zoom}×
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="search-plus"
                            tooltip="Увеличить масштаб"
                            disabled={saving || zoom === 3}
                            onClick={() => changeZoom(zoom + 1)}
                          />
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                    <Stack.Item>
                      <Stack align="center">
                        <Stack.Item>
                          <Button
                            icon="border-all"
                            selected={showGrid}
                            tooltip="Показать границы пикселей"
                            disabled={saving}
                            onClick={() => {
                              finishStroke();
                              setShowGrid(!showGrid);
                            }}
                          >
                            Сетка
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="user"
                            selected={showCharacter}
                            tooltip="Показать персонажа под рисунком"
                            disabled={saving}
                            onClick={() => {
                              finishStroke();
                              setShowCharacter(!showCharacter);
                            }}
                          >
                            Персонаж
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Stack align="center">
                <Stack.Item>
                  <Button
                    className="HairPaint__brushColor"
                    width={4}
                    height={3}
                    style={{ backgroundColor: color }}
                    tooltip="Выбрать цвет кисти"
                    disabled={saving || data.color_picker_open}
                    onClick={openPicker}
                  >
                    <Icon
                      name="eye-dropper"
                      className="HairPaint__brushColorIcon"
                    />
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Box textColor="label">Цвет кисти</Box>
                  <Box>{color.toUpperCase()}</Box>
                </Stack.Item>
              </Stack>
              <Box mt={1} pt={1}>
                <Box textColor="label" mb={1}>
                  Цвета рисунка
                </Box>
                <Box className="HairPaint__palette">
                  {palette.map((paletteColor) => (
                    <Box
                      key={paletteColor}
                      className={`HairPaint__swatch${color === paletteColor ? ' HairPaint__swatch--selected' : ''}`}
                    >
                      <Button
                        width={2}
                        height={2}
                        m={0}
                        style={{ backgroundColor: paletteColor }}
                        tooltip={
                          color === paletteColor
                            ? `${paletteColor} — текущий цвет`
                            : paletteColor
                        }
                        disabled={saving}
                        onClick={() => setColor(paletteColor)}
                      />
                    </Box>
                  ))}
                </Box>
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <InputButtons
              input=""
              disabled={saving}
              message={saving ? 'Сохранение…' : undefined}
              on_submit={() => {
                if (saving) return;
                finishStroke();
                setSaving(true);
                act('save', { frames: packPaint(paintRef.current, frames) });
              }}
              on_cancel={() => {
                if (saving) return;
                setSaving(true);
                act('cancel');
              }}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
