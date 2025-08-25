import { marked } from 'marked';
import { Box, Button, Stack } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

type MarkdownViewerData = {
  title: string;
  author?: string;
  content: string;
  content_right?: string;
  current_page: number;
  total_pages: number;
};

export function MarkdownViewer(_: any) {
  const { data, act } = useBackend<MarkdownViewerData>();

  const curr = data.current_page || 1;
  const total = data.total_pages || 1;
  const rightExists = curr + 1 <= total;

  const lastLeft = total % 2 === 0 ? total - 1 : total;
  const canPrev = curr > 1;
  const canNext = curr < lastLeft;

  const leftBlank =
    !data.content || String(data.content).trim().length === 0;
  const rightBlank =
    !data.content_right || String(data.content_right).trim().length === 0;

  return (
    <Window theme="paper" title={data.title || 'N/A'} width={820} height={580}>
      <Window.Content>
        <Stack align="start" justify="stretch" className="Paper__Spread">
          <Stack.Item grow basis={0} className="Paper__Column">
            <Page
              footer={
                <Stack justify="space-between" align="center">
                  <Stack.Item>
                    <Button
                      onClick={() => act('prev_spread')}
                      disabled={!canPrev}
                      icon="arrow-left"
                      color="good"
                    >
                      Назад
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Box opacity={0.7}>стр. {curr}</Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      onClick={() => act('tear_page', { side: 'left' })}
                      color="bad"
                      icon="scissors"
                    >
                      Вырвать
                    </Button>
                  </Stack.Item>
                </Stack>
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
          </Stack.Item>
          <Spine />
          <Stack.Item grow basis={0} className="Paper__Column">
            <Page
              dimmed={!rightExists}
              footer={
                <Stack justify="space-between" align="center">
                  <Stack.Item>
                    <Button
                      onClick={() => act('tear_page', { side: 'right' })}
                      color="bad"
                      icon="scissors"
                      disabled={!rightExists}
                    >
                      Вырвать
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Box opacity={0.7}>
                      {rightExists ? `стр. ${curr + 1}` : '—'}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      onClick={() => act('next_spread')}
                      disabled={!canNext}
                      icon="arrow-right"
                      color="good"
                    >
                      Далее
                    </Button>
                  </Stack.Item>
                </Stack>
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
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

type PageProps = {
  children: any;
  dimmed?: boolean;
  footer?: any;
};

function Page(props: PageProps) {
  const { children, dimmed, footer } = props;
  return (
    <Box className={`Paper__Sheet${dimmed ? ' Paper__Sheet--dimmed' : ''}`}>
      <Box className="Paper__Content">{children}</Box>
      <Box className="Paper__Footer">{footer}</Box>
    </Box>
  );
}

function Spine() {
  return <Box className="Paper__Spine" />;
}

type MarkdownRendererProps = {
  content: string;
  sanitize?: boolean;
  advHtml?: boolean;
};

function preCleanup(s: string) {
  return s
    .replace(/\r\n/g, '\n')
    .replace(/\(page\)\d+\(\/page\)/gi, '')
    .replace(/<[^>]*$/i, '')          // обломок тега в самом конце
    .replace(/(?:^|\n)\s*\/\s*$/i, ''); // одиночный "/" на последней строке
}

export function MarkdownRenderer(props: MarkdownRendererProps) {
  let { content, sanitize = true, advHtml = true } = props;
  content = preCleanup(content);
  content = marked(content, { async: false, gfm: true, breaks: true }) as string;
  if (sanitize) content = sanitizeText(content, advHtml);
  return <Box className="Paper__Page" dangerouslySetInnerHTML={{ __html: content }} />;
}

MarkdownRenderer.defaultProps = {
  sanitize: true,
  advHtml: true,
};
