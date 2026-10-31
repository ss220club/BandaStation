// BANDASTATION ADD START - Перенос ИИ: общая рабочая область восстановления на компьютере.
import { NtosWindow } from '../layouts';
import { AiRestorerWorkspace } from './AiRestorer';

export const NtosAiRestorer = () => {
  return (
    <NtosWindow width={450} height={580}>
      <NtosWindow.Content fitted className="AiOS">
        <AiRestorerWorkspace />
      </NtosWindow.Content>
    </NtosWindow>
  );
};
// BANDASTATION ADD END - Перенос ИИ
