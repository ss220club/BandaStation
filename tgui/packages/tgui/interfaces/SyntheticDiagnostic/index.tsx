import React from 'react';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { useBackend } from '../../backend';
import { Window } from '../../layouts';

type Component = {
  name: string;
  status: string;
  status_color: string;
  damage: number;
  details: string;
};

type Bodypart = {
  name: string;
  status: string;
  damage: number;
  max_damage: number;
  brute: number;
  burn: number;
  panel_status: string;
};

type SystemMessage = {
  type: string;
  message: string;
};

type Surgery = {
  name: string;
  desc: string;
  tool_rec: string;
};

type Zone = {
  id: string;
  name: string;
};

type PatientData = {
  name: string;
  type: string;
  id: string;
  status: string;
  status_color: string;
  integrity: number;
  integrity_max: number;
  integrity_percent: number;
  mechanical_damage: number;
  electrical_damage: number;
  system_damage: number;
  cooling_damage: number;
  components: Component[];
  bodyparts: Bodypart[];
  system_messages: SystemMessage[];
  os_version?: string;
  os_manufacturer?: string;
};

type SyntheticDiagnosticData = {
  patient?: PatientData;
  error?: string;
  patient_name?: string;
  patient_species?: string;
  target_zone?: string;
  has_table: boolean;
  surgeries?: Surgery[];
  zones?: Zone[];
};

export const SyntheticDiagnostic = (props) => {
  const { act, data } = useBackend<SyntheticDiagnosticData>();
  const {
    patient,
    error,
    patient_name,
    patient_species,
    has_table,
    surgeries,
    target_zone,
    zones,
  } = data;

  // КРИТИЧНО: используем React.useRef для сохранения вкладки
  const [selectedTab, setSelectedTab] = React.useState(0);

  return (
    <Window width={850} height={900}>
      <Window.Content scrollable>
        <Section title="Диагностический терминал синтетиков">
          {/* ЕСЛИ НЕТ СТОЛА */}
          {!has_table && (
            <Box color="bad" fontSize="1.2em" textAlign="center" my={2}>
              <Box bold>⚠ Диагностический стол не подключён</Box>
            </Box>
          )}

          {/* ЕСЛИ ОШИБКА */}
          {has_table && error && (
            <Box color="bad" fontSize="1.1em" textAlign="center" my={2}>
              <Box bold mb={1}>
                ⚠ {error}
              </Box>
              {patient_name && (
                <Box fontSize="0.9em" color="label">
                  Пациент: {patient_name} ({patient_species})
                </Box>
              )}
            </Box>
          )}

          {/* ЕСЛИ ПАЦИЕНТ ОБНАРУЖЕН */}
          {patient && (
            <>
              {/* ТАБЫ */}
              <Tabs>
                <Tabs.Tab
                  selected={selectedTab === 0}
                  onClick={() => setSelectedTab(0)}
                >
                  📊 Диагностика
                </Tabs.Tab>
                <Tabs.Tab
                  selected={selectedTab === 1}
                  onClick={() => setSelectedTab(1)}
                >
                  🔧 Операции
                </Tabs.Tab>
                <Tabs.Tab
                  selected={selectedTab === 2}
                  onClick={() => setSelectedTab(2)}
                >
                  💻 Операционная система
                </Tabs.Tab>
              </Tabs>

              {/* ВКЛАДКА ДИАГНОСТИКА */}
              {selectedTab === 0 && (
                <Stack vertical mt={1}>
                  {/* БАЗОВАЯ ИНФОРМАЦИЯ */}
                  <Stack.Item>
                    <Section title="Базовая информация">
                      <LabeledList>
                        <LabeledList.Item label="Имя">
                          <Box bold>{patient.name}</Box>
                        </LabeledList.Item>
                        <LabeledList.Item label="ID">
                          {patient.id}
                        </LabeledList.Item>
                        <LabeledList.Item label="Тип">
                          <Box color="label">{patient.type}</Box>
                        </LabeledList.Item>
                        <LabeledList.Item label="Статус системы">
                          <Box
                            bold
                            color={
                              patient.status_color === 'good'
                                ? 'good'
                                : patient.status_color === 'average'
                                  ? 'average'
                                  : 'bad'
                            }
                          >
                            {patient.status}
                          </Box>
                        </LabeledList.Item>
                      </LabeledList>
                    </Section>
                  </Stack.Item>

                  {/* ЦЕЛОСТНОСТЬ КОРПУСА */}
                  <Stack.Item>
                    <Section title="Целостность корпуса">
                      <LabeledList>
                        <LabeledList.Item label="Общая целостность">
                          <ProgressBar
                            value={patient.integrity}
                            minValue={-100}
                            maxValue={patient.integrity_max}
                            ranges={{
                              good: [70, Infinity],
                              average: [30, 70],
                              bad: [-Infinity, 30],
                            }}
                          >
                            {patient.integrity_percent}%
                          </ProgressBar>
                        </LabeledList.Item>

                        <LabeledList.Item label="Механические повреждения">
                          <ProgressBar
                            value={patient.mechanical_damage}
                            minValue={0}
                            maxValue={200}
                            ranges={{
                              good: [-Infinity, 20],
                              average: [20, 80],
                              bad: [80, Infinity],
                            }}
                          >
                            {patient.mechanical_damage}
                          </ProgressBar>
                        </LabeledList.Item>

                        <LabeledList.Item label="Повреждения проводки">
                          <ProgressBar
                            value={patient.electrical_damage}
                            minValue={0}
                            maxValue={200}
                            ranges={{
                              good: [-Infinity, 20],
                              average: [20, 80],
                              bad: [80, Infinity],
                            }}
                          >
                            {patient.electrical_damage}
                          </ProgressBar>
                        </LabeledList.Item>

                        <LabeledList.Item label="Системные ошибки">
                          <ProgressBar
                            value={patient.system_damage}
                            minValue={0}
                            maxValue={200}
                            ranges={{
                              good: [-Infinity, 20],
                              average: [20, 80],
                              bad: [80, Infinity],
                            }}
                          >
                            {patient.system_damage}
                          </ProgressBar>
                        </LabeledList.Item>

                        <LabeledList.Item label="Перегрев системы">
                          <ProgressBar
                            value={patient.cooling_damage}
                            minValue={0}
                            maxValue={200}
                            ranges={{
                              good: [-Infinity, 20],
                              average: [20, 80],
                              bad: [80, Infinity],
                            }}
                          >
                            {patient.cooling_damage}
                          </ProgressBar>
                        </LabeledList.Item>
                      </LabeledList>
                    </Section>
                  </Stack.Item>

                  {/* КОМПОНЕНТЫ */}
                  <Stack.Item>
                    <Section title="Установленные компоненты">
                      <Table>
                        <Table.Row header>
                          <Table.Cell width="30%">Компонент</Table.Cell>
                          <Table.Cell width="20%">Статус</Table.Cell>
                          <Table.Cell>Детали</Table.Cell>
                        </Table.Row>
                        {patient.components.map((component, idx) => (
                          <Table.Row key={idx}>
                            <Table.Cell>
                              <Box bold>{component.name}</Box>
                            </Table.Cell>
                            <Table.Cell>
                              <Box
                                color={
                                  component.status_color === 'good'
                                    ? 'good'
                                    : component.status_color === 'average'
                                      ? 'average'
                                      : 'bad'
                                }
                              >
                                {component.status}
                              </Box>
                            </Table.Cell>
                            <Table.Cell>
                              <Box fontSize="0.9em">{component.details}</Box>
                            </Table.Cell>
                          </Table.Row>
                        ))}
                      </Table>
                    </Section>
                  </Stack.Item>

                  {/* КОНЕЧНОСТИ С ПАНЕЛЯМИ */}
                  <Stack.Item>
                    <Section title="Статус конечностей">
                      <Table>
                        <Table.Row header>
                          <Table.Cell>Конечность</Table.Cell>
                          <Table.Cell>Статус</Table.Cell>
                          <Table.Cell>Панель</Table.Cell>
                          <Table.Cell>Урон</Table.Cell>
                          <Table.Cell>Механ.</Table.Cell>
                          <Table.Cell>Электр.</Table.Cell>
                        </Table.Row>
                        {patient.bodyparts.map((part, idx) => (
                          <Table.Row key={idx}>
                            <Table.Cell>
                              <Box bold>{part.name}</Box>
                            </Table.Cell>
                            <Table.Cell>
                              <Box
                                color={
                                  part.status === 'Подключена' ||
                                  part.status === 'Подключён'
                                    ? 'good'
                                    : 'bad'
                                }
                              >
                                {part.status}
                              </Box>
                            </Table.Cell>
                            <Table.Cell>
                              <Box
                                fontSize="0.85em"
                                color={
                                  part.panel_status === 'Закрыта'
                                    ? 'good'
                                    : part.panel_status === 'Открыта'
                                      ? 'average'
                                      : part.panel_status === 'Подготовлена'
                                        ? 'label'
                                        : 'bad'
                                }
                              >
                                {part.panel_status}
                              </Box>
                            </Table.Cell>
                            <Table.Cell>
                              {part.max_damage > 0 ? (
                                <ProgressBar
                                  value={part.damage}
                                  minValue={0}
                                  maxValue={part.max_damage}
                                  ranges={{
                                    good: [-Infinity, part.max_damage * 0.3],
                                    average: [
                                      part.max_damage * 0.3,
                                      part.max_damage * 0.7,
                                    ],
                                    bad: [part.max_damage * 0.7, Infinity],
                                  }}
                                >
                                  {part.damage}/{part.max_damage}
                                </ProgressBar>
                              ) : (
                                '—'
                              )}
                            </Table.Cell>
                            <Table.Cell>{part.brute}</Table.Cell>
                            <Table.Cell>{part.burn}</Table.Cell>
                          </Table.Row>
                        ))}
                      </Table>
                    </Section>
                  </Stack.Item>

                  {/* СИСТЕМНЫЕ СООБЩЕНИЯ */}
                  <Stack.Item>
                    <Section title="Системные сообщения">
                      <Stack vertical>
                        {patient.system_messages.map((msg, index) => (
                          <Stack.Item key={index}>
                            <Box
                              p={1}
                              backgroundColor={
                                msg.type === 'critical'
                                  ? 'rgba(200, 0, 0, 0.2)'
                                  : msg.type === 'warning'
                                    ? 'rgba(200, 150, 0, 0.2)'
                                    : 'rgba(0, 150, 0, 0.2)'
                              }
                              bold={msg.type === 'critical'}
                              color={
                                msg.type === 'critical'
                                  ? 'bad'
                                  : msg.type === 'warning'
                                    ? 'average'
                                    : 'good'
                              }
                            >
                              {msg.message}
                            </Box>
                          </Stack.Item>
                        ))}
                      </Stack>
                    </Section>
                  </Stack.Item>
                </Stack>
              )}

              {/* ВКЛАДКА ОПЕРАЦИИ */}
              {selectedTab === 1 && (
                <Stack vertical mt={1}>
                  {/* ВЫБОР ЗОНЫ ТЕЛА */}
                  <Stack.Item>
                    <Section title="Выбор зоны тела">
                      <Stack fill>
                        {zones &&
                          zones.map((zone) => (
                            <Stack.Item key={zone.id} grow>
                              <Button
                                fluid
                                selected={target_zone === zone.id}
                                color={
                                  target_zone === zone.id ? 'good' : 'default'
                                }
                                onClick={() =>
                                  act('change_zone', { new_zone: zone.id })
                                }
                              >
                                {zone.name}
                              </Button>
                            </Stack.Item>
                          ))}
                      </Stack>
                      {target_zone && zones && (
                        <Box mt={1} textAlign="center" color="label">
                          Выбранная зона:{' '}
                          <Box as="span" bold color="good">
                            {zones.find((z) => z.id === target_zone)?.name}
                          </Box>
                        </Box>
                      )}
                    </Section>
                  </Stack.Item>

                  {/* СПИСОК ОПЕРАЦИЙ */}
                  <Stack.Item>
                    <Section title="Доступные операции прямо сейчас">
                      {!target_zone && (
                        <Box
                          textAlign="center"
                          color="average"
                          my={2}
                          p={2}
                          backgroundColor="rgba(100, 100, 100, 0.1)"
                        >
                          <Box fontSize="1.1em" bold mb={1}>
                            ⚠ Выберите зону тела
                          </Box>
                          <Box>
                            Используйте кнопки выше для выбора зоны тела.
                          </Box>
                        </Box>
                      )}

                      {target_zone && surgeries && surgeries.length > 0 && (
                        <>
                          <Box mb={1} p={1} backgroundColor="rgba(0,150,0,0.1)">
                            <Box bold color="good">
                              ✓ Найдено операций: {surgeries.length}
                            </Box>
                            <Box fontSize="0.9em" color="label">
                              Это операции, которые можно выполнить прямо сейчас
                            </Box>
                          </Box>
                          <Table>
                            <Table.Row header>
                              <Table.Cell width="35%">Операция</Table.Cell>
                              <Table.Cell width="45%">Описание</Table.Cell>
                              <Table.Cell width="20%">Инструмент</Table.Cell>
                            </Table.Row>
                            {surgeries.map((surgery, index) => (
                              <Table.Row key={index}>
                                <Table.Cell>
                                  <Box bold color="good">
                                    ► {surgery.name}
                                  </Box>
                                </Table.Cell>
                                <Table.Cell>
                                  <Box fontSize="0.9em">{surgery.desc}</Box>
                                </Table.Cell>
                                <Table.Cell>
                                  <Box italic color="label">
                                    {surgery.tool_rec}
                                  </Box>
                                </Table.Cell>
                              </Table.Row>
                            ))}
                          </Table>
                        </>
                      )}

                      {target_zone && surgeries && surgeries.length === 0 && (
                        <Box
                          textAlign="center"
                          color="label"
                          my={2}
                          p={2}
                          backgroundColor="rgba(100, 100, 100, 0.1)"
                        >
                          <Box fontSize="1.1em" mb={1}>
                            ℹ Нет доступных операций
                          </Box>
                          <Box>
                            Для выбранной зоны сейчас нет доступных операций.
                            <br />
                            Возможно, нужно выполнить предыдущие шаги.
                          </Box>
                        </Box>
                      )}
                    </Section>
                  </Stack.Item>

                  {/* ИНСТРУКЦИЯ */}
                  <Stack.Item>
                    <Section title="Инструкция по операциям">
                      <Stack vertical>
                        <Stack.Item>
                          <Box
                            p={1}
                            mb={1}
                            backgroundColor="rgba(50, 100, 200, 0.15)"
                          >
                            <Box bold mb={0.5} color="label">
                              🔧 Грудная клетка / Голова (работа с органами):
                            </Box>
                            <Box ml={1} fontSize="0.9em">
                              1. Открыть панель (отвёртка)
                              <br />
                              2. Подготовить электронику (мультитул)
                              <br />
                              3. Установить/Извлечь органы (органы или
                              мультитул)
                            </Box>
                          </Box>
                        </Stack.Item>

                        <Stack.Item>
                          <Box
                            p={1}
                            mb={1}
                            backgroundColor="rgba(100, 150, 50, 0.15)"
                          >
                            <Box bold mb={0.5} color="label">
                              🔨 Руки / Ноги (ремонт):
                            </Box>
                            <Box ml={1} fontSize="0.9em">
                              1. Открыть панель (отвёртка)
                              <br />
                              2. Заварить брут-урон (сварка) или починить
                              берн-урон (кабель)
                              <br />
                              3. Закрыть панель (отвёртка)
                            </Box>
                          </Box>
                        </Stack.Item>

                        <Stack.Item>
                          <Box p={1} backgroundColor="rgba(200, 50, 50, 0.15)">
                            <Box bold mb={0.5} color="label">
                              ⚠ Снятие конечности:
                            </Box>
                            <Box ml={1} fontSize="0.9em">
                              1. Отключить электронику (мультитул)
                              <br />
                              2. Открутить конечность (гаечный ключ)
                            </Box>
                          </Box>
                        </Stack.Item>
                      </Stack>
                    </Section>
                  </Stack.Item>
                </Stack>
              )}

              {/* ВКЛАДКА ОС */}
              {selectedTab === 2 && (
                <Stack vertical mt={1}>
                  <Stack.Item>
                    <Section title="Операционная система">
                      <LabeledList>
                        <LabeledList.Item label="Версия ОС">
                          <Box color="good">
                            {patient.os_version || 'IPC-OS v2.4.1'}
                          </Box>
                        </LabeledList.Item>
                        <LabeledList.Item label="Производитель">
                          {patient.os_manufacturer || 'Generic Systems'}
                        </LabeledList.Item>
                        <LabeledList.Item label="Статус">
                          <Box color="good">Система стабильна</Box>
                        </LabeledList.Item>
                        <LabeledList.Item label="Время работы">
                          247:35:12
                        </LabeledList.Item>
                      </LabeledList>
                    </Section>
                  </Stack.Item>

                  <Stack.Item>
                    <Section title="Системные логи">
                      <Box
                        fontFamily="monospace"
                        fontSize="0.85em"
                        p={1}
                        backgroundColor="rgba(0, 0, 0, 0.3)"
                        style={{
                          maxHeight: '200px',
                          overflowY: 'auto',
                        }}
                      >
                        <Box color="good">
                          [OK] Позитронное ядро: Инициализация успешна
                        </Box>
                        <Box color="good">
                          [OK] Источник питания: 97% (4890/5000 units)
                        </Box>
                        <Box color="good">
                          [OK] Система охлаждения: Эффективность 100%
                        </Box>
                        <Box color="good">
                          [OK] Оптические сенсоры: Калибровка завершена
                        </Box>
                        <Box color="good">[OK] Аудио сенсоры: Тест пройден</Box>
                        <Box color="good">
                          [OK] Голосовой синтезатор: Готов к работе
                        </Box>
                        <Box color="label" mt={0.5}>
                          [INFO] Все системы функционируют нормально
                        </Box>
                      </Box>
                    </Section>
                  </Stack.Item>
                </Stack>
              )}
            </>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
