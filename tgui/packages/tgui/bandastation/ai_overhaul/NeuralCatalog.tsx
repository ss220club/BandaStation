import {
  type PropsWithChildren,
  type ReactNode,
  useEffect,
  useRef,
  useState,
} from 'react';
import { Icon } from 'tgui-core/components';

const pageSize = 4;
const categoryIcons: Record<string, string> = {
  'Сенсорные HUD': 'eye',
  'Камеры и обзор': 'video',
  Индукция: 'bolt',
  Наблюдение: 'satellite-dish',
  Эффективность: 'microchip',
  'Управление киборгами': 'robot',
};
type CatalogItem = {
  name: string;
  label?: string;
  category: string;
  description: string;
  status: string;
  tone: 'active' | 'ready' | 'locked';
  memory: number;
  cpu: number;
  progress?: number;
};

export function NeuralCatalog({
  children,
  tools,
  items,
  selected,
  onSelect,
  filterKey,
  title = 'КАТАЛОГ ПРОЕКТОВ',
}: PropsWithChildren<{
  items: CatalogItem[];
  selected?: string;
  onSelect: (name: string) => void;
  filterKey: string;
  title?: string;
  tools?: ReactNode;
}>) {
  const [pageState, setPageState] = useState({ key: filterKey, page: 0 });
  const [activeOnly, setActiveOnly] = useState(false);
  const [opened, setOpened] = useState({ key: '', name: '' });
  const viewKey = `${filterKey}:${activeOnly}`;
  useEffect(() => {
    setPageState({ key: viewKey, page: 0 });
  }, [viewKey]);
  const visible = activeOnly
    ? items.filter((item) => item.tone === 'active')
    : items;
  const pages = Math.max(1, Math.ceil(visible.length / pageSize));
  const page = Math.min(
    pageState.key === viewKey ? pageState.page : 0,
    pages - 1,
  );
  const focusedName =
    opened.key === viewKey &&
    opened.name === selected &&
    visible.some((item) => item.name === opened.name)
      ? opened.name
      : '';
  const catalog = useRef<HTMLDivElement>(null);
  const detail = useRef<HTMLDivElement>(null);
  const returnTo = useRef('');
  useEffect(() => {
    if (focusedName) {
      detail.current?.focus();
    } else if (returnTo.current) {
      const button = Array.from(
        catalog.current?.querySelectorAll<HTMLButtonElement>(
          'button[data-project]',
        ) || [],
      ).find((node) => node.dataset.project === returnTo.current);
      button?.focus();
      returnTo.current = '';
    }
  }, [focusedName]);
  const activeCount = items.filter((item) => item.tone === 'active').length;
  return (
    <div className="AiOS__catalogBrowser" ref={catalog}>
      {!focusedName && tools}
      <div className="AiOS__catalogToolbar">
        {focusedName ? (
          <button
            type="button"
            className="Button Button--color--transparent"
            onClick={() => {
              returnTo.current = focusedName;
              setOpened({ key: '', name: '' });
            }}
          >
            <Icon name="arrow-left" /> К каталогу
          </button>
        ) : (
          <div className="AiOS__catalogModes" aria-label="Режим каталога">
            <button
              type="button"
              className={`Button Button--color--transparent${!activeOnly ? ' Button--selected' : ''}`}
              aria-pressed={!activeOnly}
              onClick={() => setActiveOnly(false)}
            >
              Все проекты · {items.length}
            </button>
            <button
              type="button"
              className={`Button Button--color--transparent${activeOnly ? ' Button--selected' : ''}`}
              aria-pressed={activeOnly}
              onClick={() => setActiveOnly(true)}
            >
              В работе · {activeCount}
            </button>
          </div>
        )}
        <span className="AiOS__catalogCaption">
          {focusedName ? 'ДОСЬЕ ПРОЕКТА' : title}
        </span>
      </div>
      {focusedName ? (
        <div
          className="AiOS__projectDetail"
          role="region"
          ref={detail}
          tabIndex={-1}
          aria-label="Досье выбранного проекта"
        >
          {children}
        </div>
      ) : (
        <>
          <div className="AiOS__projectGrid" aria-label="Каталог проектов">
            {visible
              .slice(page * pageSize, (page + 1) * pageSize)
              .map((item, index) => (
                <button
                  type="button"
                  key={item.name}
                  data-project={item.name}
                  className={`AiOS__projectCard AiOS__projectCard--${item.tone}`}
                  onClick={() => {
                    onSelect(item.name);
                    setOpened({ key: viewKey, name: item.name });
                  }}
                >
                  <span className="AiOS__projectCardTop">
                    <span className="AiOS__projectEmblem" aria-hidden="true">
                      <Icon name={categoryIcons[item.category] || 'flask'} />
                    </span>
                    <span className="AiOS__projectCategory">
                      {item.category}
                    </span>
                    <span className="AiOS__projectAddress">
                      {String(page * pageSize + index + 1).padStart(2, '0')}
                    </span>
                  </span>
                  <span className="AiOS__projectName">
                    {item.label || item.name}
                  </span>
                  <span className="AiOS__projectPreview">
                    {item.description}
                  </span>
                  <span className="AiOS__projectCardStatus">
                    <Icon
                      name={
                        item.tone === 'active'
                          ? 'circle-play'
                          : item.tone === 'locked'
                            ? 'lock'
                            : 'circle-check'
                      }
                    />{' '}
                    {item.status}
                    {item.progress !== undefined && (
                      <strong>{Math.round(item.progress * 100)}%</strong>
                    )}
                  </span>
                  {item.progress !== undefined && (
                    <span className="AiOS__projectTrack" aria-hidden="true">
                      <span
                        style={{
                          width: `${Math.max(0, Math.min(1, item.progress)) * 100}%`,
                        }}
                      />
                    </span>
                  )}
                  <span className="AiOS__projectCardFoot">
                    <span>
                      ПАМЯТЬ {item.memory} ТБ
                      {item.cpu > 0 && ` / CPU ${(item.cpu * 100).toFixed(0)}%`}
                    </span>
                    <Icon name="arrow-right" />
                  </span>
                </button>
              ))}
          </div>
          {!visible.length && (
            <div className="AiOS__catalogEmpty">
              {activeOnly
                ? 'В этой категории нет проектов в работе.'
                : 'Нет проектов. Измените категорию или поисковый запрос.'}
            </div>
          )}
          <nav className="AiOS__catalogPager" aria-label="Страницы каталога">
            <button
              type="button"
              className="Button Button--color--transparent"
              disabled={page === 0}
              onClick={() => setPageState({ key: viewKey, page: page - 1 })}
            >
              <Icon name="chevron-left" /> Назад
            </button>
            <span aria-live="polite">
              {visible.length
                ? `${page * pageSize + 1}–${Math.min((page + 1) * pageSize, visible.length)}`
                : '0'}{' '}
              из {visible.length} · Страница {page + 1} / {pages}
            </span>
            <button
              type="button"
              className="Button Button--color--transparent"
              disabled={page + 1 >= pages}
              onClick={() => setPageState({ key: viewKey, page: page + 1 })}
            >
              Далее <Icon name="chevron-right" />
            </button>
          </nav>
        </>
      )}
    </div>
  );
}
