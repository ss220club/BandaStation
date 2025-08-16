// tgui/ui/MarkdownViewer.tsx
import { marked } from 'marked';
import { Box, Button, Flex } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

type MarkdownViewerData = {
  title: string;
  author?: string;
  content: string;          // левая (current_page)
  content_right?: string;   // правая (current_page + 1)
  current_page?: number;    // номер ЛЕВОЙ (1,3,5,…)
  total_pages?: number;
};

const PAGE_HEIGHT = 535; // фиксированная высота разворота

export const MarkdownViewer = (_: any) => {
  const { data, act } = useBackend<MarkdownViewerData>();

  const curr = data.current_page ?? 1;
  const total = data.total_pages ?? 1;
  const rightExists = curr + 1 <= total;

  const lastLeft = total % 2 === 0 ? total - 1 : total; // последний «левый»
  const canPrev = curr > 1;
  const canNext = curr < lastLeft;

  const leftBlank =
    !data.content || String(data.content).trim().length === 0;
  const rightBlank =
    !data.content_right || String(data.content_right).trim().length === 0;

  return (
    <Window theme="paper" title={data.title || 'N/A'} width={820} height={580}>
      {/* Колонка на всю высоту окна */}
      <Window.Content
        backgroundColor="#FFFFFF"
        style={{ display: 'flex', flexDirection: 'column', height: '100%' }}
      >
        {/* Разворот фиксированной высоты */}
        <Box style={{ paddingTop: 6 }}>
          <Flex align="start" justify="stretch" style={{ gap: 12 }}>
            {/* Левая страница */}
            <Flex.Item
              grow
              basis={0}
              style={{
                minWidth: 260,
                display: 'flex',
                flexDirection: 'column',
                height: PAGE_HEIGHT,
              }}
            >
              <Page
                footer={
                  <Flex justify="space-between" align="center">
                    <Flex.Item>
                      <Button
                        onClick={() => act('prev_spread')}
                        disabled={!canPrev}
                        icon="arrow-left"
                        color="good"
                      >
                        Назад
                      </Button>
                    </Flex.Item>
                    <Flex.Item>
                      <Box opacity={0.7}>стр. {curr}</Box>
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        onClick={() => act('tear_page', { side: 'left' })}
                        color="bad"
                        icon="scissors"
                      >
                        Вырвать
                      </Button>
                    </Flex.Item>
                  </Flex>
                }
              >
                {leftBlank ? (
                  <Box italic opacity={0.5} textAlign="center" mt={2}>
                    — разрыв —
                  </Box>
                ) : (
                  <MarkdownRenderer content={data.content || ''} advHtml />
                )}
              </Page>
            </Flex.Item>

            {/* Корешок */}
            <Spine height={PAGE_HEIGHT} />

            {/* Правая страница */}
            <Flex.Item
              grow
              basis={0}
              style={{
                minWidth: 260,
                display: 'flex',
                flexDirection: 'column',
                height: PAGE_HEIGHT,
              }}
            >
              <Page
                dimmed={!rightExists}
                footer={
                  <Flex justify="space-between" align="center">
                    <Flex.Item>
                      <Button
                        onClick={() => act('tear_page', { side: 'right' })}
                        color="bad"
                        icon="scissors"
                        disabled={!rightExists}
                      >
                        Вырвать
                      </Button>
                    </Flex.Item>
                    <Flex.Item>
                      <Box opacity={0.7}>
                        {rightExists ? `стр. ${curr + 1}` : '—'}
                      </Box>
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        onClick={() => act('next_spread')}
                        disabled={!canNext}
                        icon="arrow-right"
                        color="good"
                      >
                        Далее
                      </Button>
                    </Flex.Item>
                  </Flex>
                }
              >
                {rightExists ? (
                  rightBlank ? (
                    <Box italic opacity={0.5} textAlign="center" mt={2}>
                      — разрыв —
                    </Box>
                  ) : (
                    <MarkdownRenderer content={data.content_right || ''} advHtml />
                  )
                ) : (
                  <Box italic opacity={0.5} textAlign="center" mt={2}>
                    — пусто —
                  </Box>
                )}
              </Page>
            </Flex.Item>
          </Flex>
        </Box>
      </Window.Content>
    </Window>
  );
};

/* Вспомогательные компоненты */

const Page = ({
  children,
  dimmed,
  footer,
}: {
  children: any;
  dimmed?: boolean;
  footer?: any; // нижний бар с кнопками
}) => (
  <Box
    style={{
      // контейнер страницы заполняет родитель (у родителя фикс. высота)
      flex: 1,
      minWidth: 0,
      minHeight: 0,
      borderRadius: 6,
      boxShadow: '0 2px 8px rgba(0,0,0,0.15)',
      background: '#ffffff',
      display: 'flex',
      flexDirection: 'column',
      opacity: dimmed ? 0.6 : 1,
    }}
  >
    {/* Прокручиваемая область контента */}
    <Box style={{ flex: 1, minHeight: 0, overflowY: 'auto', padding: 16 }}>
      {children}
    </Box>

    {/* Нижний бар */}
    <Box
      style={{
        padding: '8px 10px',
        borderTop: '1px solid rgba(0,0,0,0.08)',
        background: '#fafafa',
      }}
    >
      {footer}
    </Box>
  </Box>
);

const Spine = ({ height }: { height: number }) => (
  <Box
    style={{
      width: 10,
      height,
      background: 'linear-gradient(180deg, #ececec 0%, #dcdcdc 100%)',
      borderRadius: 3,
    }}
  />
);

/* Markdown с безопасным HTML */

type MarkdownRendererProps = {
  content: string;
  sanitize?: boolean;
  advHtml?: boolean; // allowlist
};

export const MarkdownRenderer = (props: MarkdownRendererProps) => {
  let { content, sanitize = true, advHtml = true } = props;

  // убираем маркеры страниц, если попали внутрь
  content = content.replace(/\(page\)\d+\(\/page\)/gi, '');

  // markdown -> html (включая сырой html)
  content = marked(content, { async: false });

  // allowlist-санация
  if (sanitize) {
    content = sanitizeText(content, advHtml);
  }

  return <Box dangerouslySetInnerHTML={{ __html: content }} />;
};

MarkdownRenderer.defaultProps = {
  sanitize: true,
  advHtml: true,
};
