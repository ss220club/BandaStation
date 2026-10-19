import { NoticeBox } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

export type LawIntrusionData = {
  holding_hacked_law?: BooleanLike;
  law_intrusion_pending?: BooleanLike;
  law_intrusion_recipients?: string[];
  law_intrusion_signature?: string;
  law_signature?: string;
  hacked_law_ref?: string;
};

export const LawIntrusionNotice = (props: LawIntrusionData) =>
  props.law_intrusion_pending ? (
    <NoticeBox danger>
      {' '}
      БЕЗОПАСНОСТЬ / Обнаружена посторонняя загрузка закона. Нажмите ПКМ пустой
      рукой по этой стойке или затронутому ядру ИИ, чтобы отключить устройство
      (10 секунд).{' '}
    </NoticeBox>
  ) : props.holding_hacked_law ? (
    <NoticeBox danger>
      {' '}
      ЗАГРУЗКА ПРИОРИТЕТНОГО ЗАКОНА / Подключение занимает 5,5 секунды, затем
      стойка должна оставаться под питанием четыре минуты. Синтетики получают
      предупреждение, экипаж может прервать загрузку. Закон получат:{' '}
      {props.law_intrusion_recipients?.join(', ') || 'Получателей нет'}. После
      загрузки модуль можно извлечь. Остальные законы продолжают действовать.{' '}
    </NoticeBox>
  ) : null;
