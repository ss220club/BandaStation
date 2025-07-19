import { useState } from 'react';
import { Button, Modal, Section, Stack, TextArea } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type HelpData = {
  adminCount: number;
  maxMessageLength: number;
  ticketTypes: TicketType[];
};

type TicketType = {
  name: string;
  type: string;
};

/**
 * TODO:
 * Так как менторов всё ещё нет, этот интерфейс кастрирован.
 * После имплементации менторов, надо удалить Admin из selectedType,
 * а так же раскомментить кнопку выбора типа тикета
 */
export const TicketCreation = (props) => {
  const { act, data } = useBackend<HelpData>();
  const { adminCount, ticketTypes, maxMessageLength } = data;
  const [helpMessage, setHelpMessage] = useState('');
  const [selectedType, setSelectedType] = useState('Admin');
  const [selectTypeModal, setSelectTypeModal] = useState(false);

  return (
    <Window title="Создание тикета" theme="ss220" height={300} width={500}>
      <Window.Content>
        {(!selectedType || selectTypeModal) && (
          <Modal>
            <Section title="Чья помощь вам нужна?" color="label">
              Пожалуйста, выберите какой тикет создать. <br />
              Администрация может помочь вам в решении OOC проблем. <br />
              Менторы могут помочь в решении внутриигровых проблем.
              <Stack textAlign="center" mt={1}>
                {ticketTypes.map((ticketType) => (
                  <Stack.Item key={ticketType.type} grow>
                    <Button
                      fluid
                      selected={selectedType === ticketType.type}
                      onClick={() => {
                        setSelectedType(ticketType.type);
                        setSelectTypeModal(false);
                      }}
                    >
                      {ticketType.name} тикет
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Modal>
        )}
        <Section
          fill
          title={`Админов в сети: ${adminCount}`}
          buttons={
            /*
            <Button onClick={() => setSelectTypeModal(true)}>
              Выбрать тип тикета
            </Button>
          */ ''
          }
        >
          <Stack vertical fill>
            <Stack.Item grow>
              <TextArea
                autoFocus
                fluid
                height="100%"
                maxLength={maxMessageLength}
                placeholder={
                  selectedType === 'Admin'
                    ? 'Опишите вашу проблему...'
                    : 'С чем вам нужна помощь?'
                }
                onChange={setHelpMessage}
                onEnter={() => {
                  act('create_ticket', {
                    message: helpMessage,
                    ticketType: selectedType,
                  });
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                fluid
                color="good"
                textAlign="center"
                disabled={!helpMessage || !selectedType}
                onClick={() =>
                  act('create_ticket', {
                    message: helpMessage,
                    ticketType: selectedType,
                  })
                }
              >
                Отправить
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
