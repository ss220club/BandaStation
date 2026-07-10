import { Window } from '../layouts';
import { Box } from 'tgui-core/components';
import { useState } from 'react';
const regions = [
  {
    id: "dark_forest",
    name: "Тёмный Лес",
    x: 90,
    y: 70,
    w: 280,
    h: 240,
    color: "rgba(0,120,40,.18)",
    description: "..."
  },
];

export const NewSydneyMap = () => {
  const [hovered, setHovered] = useState(null);
  return (
  <Window
    title="Карта региона"
    width={1400}
    height={900}
  >
    <Window.Content scrollable>
      <Box
    style={{
      position: 'relative',
      width: '1332px',
      height: '1181px',
      margin: '0 auto',
    }}
  >
    <img
      src="worldmap.png"
      style={{
        width: '1332px',
        height: '1181px',
        display: 'block',
      }}
    />

    {/* Здесь будут регионы */}

      </Box>
      <Box
        title={`Тёмный Лес

      Густой лесной массив бывшего заповедника "Уиллоу-Парк", окутанный вечным туманом и нависающими токсичными облаками. Она одной из первых оказалась под радиоактивным воздействием из-за непосредственной близости к региону станции "Синдей-Нова".
      Посередине локации - расположены радиоактивные озёра с аномальными образованиями. На западе находится периферийная инфраструктура горнодобывающего комплекса "НаноТрейзен" - "Мистериус" с прилегающей к ней заправочной станцией. На северо-востоке - неизвестная заброшенная шахта, выведенная из эксплуатации ещё задолго до катастрофы. На юго-востоке - отдел грузоперевозок "У Джека" и трансформаторная станция.
      По данным разведки группировки "Чистильщиков" - здесь наблюдается высокая активность аномалий и неизвестных существ.`}
      style={{
        position: 'absolute',
        left: '90px',
        top: '70px',
        width: '280px',
        height: '240px',
        background: 'rgba(0,120,40,0.18)',
        border: '2px solid rgba(0,255,80,0.45)',
        cursor: 'pointer',
      }}

        onMouseEnter={() =>
        setHovered({
            title: "Тёмный Лес",
            desc: "Густой лесной массив..."
        })
    }

    onMouseLeave={() =>
        setHovered(null)
      }
      />
      </Window.Content>
    </Window>
  );
};
