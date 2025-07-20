import { marked } from 'marked';
import { Box, Button, Flex, Section } from 'tgui-core/components'; // BANDASTATION - Multipages

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';

type MarkdownViewerData = {
  title: string;
  content: string;
  author: string;
  current_page?: number;
  total_pages?: number;
};

export const MarkdownViewer = (_: any) => {
  const { data, act } = useBackend<MarkdownViewerData>();
  return (
    <Window theme="paper" title={data.title} width={300} height={350}>
      <Window.Content scrollable backgroundColor={'#FFFFFF'}>
        {data.current_page && data.total_pages && (
          <Section>
            <Box textAlign="center" mb={1}>
              <b>
                Страница {data.current_page} / {data.total_pages}
              </b>
            </Box>

            <Flex justify="space-between" mb={1}>
              <Flex.Item>
                <Button
                  onClick={() => act('prev_page')}
                  disabled={data.current_page <= 1}
                  color="good"
                >
                  ← Назад
                </Button>
              </Flex.Item>
              <Flex.Item>
                <Button onClick={() => act('tear_page')} color="bad">
                  Вырвать
                </Button>
              </Flex.Item>
              <Flex.Item>
                <Button
                  onClick={() => act('next_page')}
                  disabled={data.current_page >= data.total_pages}
                  color="good"
                >
                  Вперёд →
                </Button>
              </Flex.Item>
            </Flex>
          </Section>
        )}

        <MarkdownRenderer content={data.content} />
      </Window.Content>
    </Window>
  );
};

type MarkdownRendererProps = {
  content: string;
  sanitize?: boolean;
};

export const MarkdownRenderer = (props: MarkdownRendererProps) => {
  let { content, sanitize } = props;

  content = content.replace(/\(page\)\d+\(\/page\)/gi, '');

  content = marked(content, { async: false });
  if (sanitize) {
    content = sanitizeText(content, /* advHtml = */ false);
  }

  // eslint-disable-next-line react/no-danger
  return <div dangerouslySetInnerHTML={{ __html: content }} />;
};

MarkdownRenderer.defaultProps = {
  sanitize: true,
};
