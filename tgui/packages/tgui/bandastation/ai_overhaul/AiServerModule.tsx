import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { NetworkHeader } from './Common';
import { NeuralShell } from './NeuralOS';

type Cpu = { ref: string; name: string; speed: number; power: number };
type Memory = { ref: string; name: string; capacity: number };
type Data = {
  panel_open: BooleanLike;
  cpu_slots: number;
  ram_slots: number;
  cpus: Cpu[];
  memory: Memory[];
  total_cpu: number;
  total_ram: number;
  power: number;
};

export function AiServerModule() {
  const { act, data } = useBackend<Data>();
  const cpus = data.cpus || [];
  const memory = data.memory || [];
  return (
    <Window title="Серверный модуль" width={700} height={650}>
      <Window.Content fitted className="AiOS">
        <NeuralShell application="Состав серверного модуля">
          <NetworkHeader
            title="Серверный модуль"
            signal={data.panel_open ? 'busy' : 'nominal'}
            status={
              data.panel_open ? 'КОРПУС ОТКРЫТ / ОБСЛУЖИВАНИЕ' : 'КОРПУС ЗАКРЫТ'
            }
            subtitle="CPU и планки RAM устанавливаются вручную. Исследования открывают дополнительные разъёмы."
          />
          <Section title="Характеристики">
            <LabeledList>
              <LabeledList.Item label="Производительность CPU">
                {data.total_cpu.toFixed(2)} ТГц
              </LabeledList.Item>
              <LabeledList.Item label="Оперативная память">
                {data.total_ram} ТБ
              </LabeledList.Item>
              <LabeledList.Item label="Потребление">
                {data.power.toFixed(0)} Вт
              </LabeledList.Item>
            </LabeledList>
          </Section>
          {!data.panel_open && (
            <NoticeBox>
              Откройте корпус отвёрткой, чтобы установить или извлечь детали.
            </NoticeBox>
          )}
          <Section title={`Процессоры — ${cpus.length}/${data.cpu_slots}`}>
            {!cpus.length ? (
              <Box color="label">Процессоры не установлены.</Box>
            ) : (
              <Table>
                {cpus.map((cpu) => (
                  <Table.Row key={cpu.ref}>
                    <Table.Cell>{cpu.name}</Table.Cell>
                    <Table.Cell collapsing>
                      {cpu.speed.toFixed(2)} ТГц · {cpu.power.toFixed(0)} Вт
                    </Table.Cell>
                    <Table.Cell collapsing textAlign="right">
                      <Button
                        icon="eject"
                        disabled={!data.panel_open}
                        onClick={() => act('eject_cpu', { ref: cpu.ref })}
                      >
                        Извлечь
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            )}
          </Section>
          <Section title={`Память — ${memory.length}/${data.ram_slots}`}>
            {!memory.length ? (
              <Box color="label">Планки RAM не установлены.</Box>
            ) : (
              <Table>
                {memory.map((ram) => (
                  <Table.Row key={ram.ref}>
                    <Table.Cell>{ram.name}</Table.Cell>
                    <Table.Cell collapsing>{ram.capacity} ТБ</Table.Cell>
                    <Table.Cell collapsing textAlign="right">
                      <Button
                        icon="eject"
                        disabled={!data.panel_open}
                        onClick={() => act('eject_ram', { ref: ram.ref })}
                      >
                        Извлечь
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            )}
          </Section>
          <div className="AiOS__observationCaption">
            CPU печатаются на принтере плат; RAM и пустой корпус — на протолате.
            Вставляйте детали в открытый корпус. Перед установкой в серверный
            шкаф закройте его отвёрткой.
          </div>
        </NeuralShell>
      </Window.Content>
    </Window>
  );
}
