import {
  bresenhamLine,
  getFlattenedSpriteDir,
} from '../common/SpriteEditor/helpers';
import { Dir, type StringLayer } from '../common/SpriteEditor/Types/types';

export const SIZE = 48;
export const EMPTY_PIXEL = '------';
export const DIRECTIONS = [Dir.SOUTH, Dir.WEST, Dir.NORTH, Dir.EAST];
export type Frames = Record<Dir, StringLayer>;
export type Paint = Record<Dir, string>;
export type Point = [number, number];

export const emptyPaint = (): Paint =>
  Object.fromEntries(
    DIRECTIONS.map((direction) => [direction, EMPTY_PIXEL.repeat(SIZE * SIZE)]),
  ) as Paint;

export const editable = (
  frame: StringLayer,
  pixelX: number,
  pixelY: number,
) => {
  const pixel = frame[pixelY]?.[pixelX];
  return !!pixel && pixel.slice(7) !== '00';
};

export const packPaint = (paint: Paint, masks: Frames): Paint =>
  Object.fromEntries(
    DIRECTIONS.map((direction) => [
      direction,
      masks[direction]
        .flatMap((row, pixelY) =>
          row.flatMap((_, pixelX) => {
            const offset = (pixelY * SIZE + pixelX) * 6;
            return editable(masks[direction], pixelX, pixelY)
              ? [paint[direction].slice(offset, offset + 6)]
              : [];
          }),
        )
        .join(''),
    ]),
  ) as Paint;

export function paintStroke(
  frame: string,
  mask: StringLayer,
  start: Point,
  end: Point,
  color: string,
): string {
  const pixels = frame.match(/.{6}/g)!;
  const clamp = (coordinate: number) =>
    Math.max(0, Math.min(SIZE - 1, Math.floor(coordinate)));
  const plot = (pixelX: number, pixelY: number) => {
    if (editable(mask, pixelX, pixelY)) {
      pixels[pixelY * SIZE + pixelX] =
        color === EMPTY_PIXEL ? EMPTY_PIXEL : color.slice(1, 7).toLowerCase();
    }
  };
  const endX = clamp(end[0]);
  const endY = clamp(end[1]);
  bresenhamLine(clamp(start[0]), clamp(start[1]), endX, endY, plot);
  plot(endX, endY);
  return pixels.join('');
}

export const paintedFrame = (base: StringLayer, paint: string): StringLayer =>
  base.map((row, pixelY) =>
    row.map((pixel, pixelX) => {
      const offset = (pixelY * SIZE + pixelX) * 6;
      const color = paint.slice(offset, offset + 6);
      return color === EMPTY_PIXEL || !editable(base, pixelX, pixelY)
        ? pixel
        : `#${color}${pixel.slice(7) || 'ff'}`;
    }),
  );

export function previewFrame(
  background: StringLayer,
  hair: StringLayer,
  paint: string,
) {
  return getFlattenedSpriteDir(
    {
      width: SIZE,
      height: SIZE,
      dirs: 1,
      backdrop: '',
      layers: [
        {
          name: 'Body',
          visible: true,
          data: {
            [Dir.SOUTH]: background,
            [Dir.NORTH]: undefined,
            [Dir.EAST]: undefined,
            [Dir.WEST]: undefined,
          },
        },
        {
          name: 'Hair',
          visible: true,
          data: {
            [Dir.SOUTH]: paintedFrame(hair, paint),
            [Dir.NORTH]: undefined,
            [Dir.EAST]: undefined,
            [Dir.WEST]: undefined,
          },
        },
      ],
    },
    Dir.SOUTH,
    1,
  );
}
