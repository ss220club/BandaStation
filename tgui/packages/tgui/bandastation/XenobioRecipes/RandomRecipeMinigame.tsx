import { useCallback } from 'react';
import { Box, Button } from 'tgui-core/components';

type WordEntry = { word: string; line: number; start: number };

const TERMINAL_SCALE = 1.35;

type Props = {
  lines: string[];
  words: WordEntry[];
  lastLikeness: number | null;
  correctLength: number;
  attemptsLeft?: number;
  onGuess: (word: string) => void;
  onCancel: () => void;
};

export function RandomRecipeMinigame(props: Props) {
  const {
    lines,
    words,
    lastLikeness,
    correctLength,
    attemptsLeft = 4,
    onGuess,
    onCancel,
  } = props;
  const canGuess = attemptsLeft > 0;
  const optionFormulas = Array.from(new Set(words.map((w) => w.word))).sort();

  const renderLine = useCallback(
    (lineStr: string, lineIndex: number) => {
      const lineWords = words
        .filter((w) => w.line === lineIndex)
        .sort((a, b) => a.start - b.start);
      if (lineWords.length === 0) {
        return <span>{lineStr}</span>;
      }
      const segments: Array<{
        type: 'text' | 'word';
        value: string;
        word?: string;
      }> = [];
      let pos = 0;
      for (const w of lineWords) {
        if (w.start > pos) {
          segments.push({ type: 'text', value: lineStr.slice(pos, w.start) });
        }
        segments.push({ type: 'word', value: w.word, word: w.word });
        pos = w.start + w.word.length;
      }
      if (pos < lineStr.length) {
        segments.push({ type: 'text', value: lineStr.slice(pos) });
      }
      return (
        <span>
          {segments.map((seg, i) =>
            seg.type === 'word' && seg.word ? (
              <Box
                key={i}
                as="span"
                style={{
                  color: canGuess
                    ? 'rgba(140,200,255,1)'
                    : 'rgba(80,90,110,0.9)',
                  cursor: canGuess ? 'pointer' : 'default',
                  textDecoration: 'underline',
                  fontWeight: 'bold',
                  backgroundColor: canGuess
                    ? 'rgba(40,70,120,0.35)'
                    : 'rgba(30,35,50,0.4)',
                  padding: '0.1em 0.2em',
                  marginRight: '0.15em',
                  borderRadius: '3px',
                  border: canGuess
                    ? '1px solid rgba(100,160,220,0.5)'
                    : '1px solid rgba(60,70,90,0.4)',
                }}
                onClick={() => canGuess && onGuess(seg.word!)}
              >
                {seg.value}
              </Box>
            ) : (
              <span key={i}>{seg.value}</span>
            ),
          )}
        </span>
      );
    },
    [words, onGuess, canGuess],
  );

  return (
    <Box
      className="XenobioRecipes__Minigame XenobioRecipes__Terminal"
      style={{
        width: '100%',
        height: '100%',
        minHeight: 0,
        display: 'flex',
        flexDirection: 'column',
        padding: 'clamp(0.5rem, 2vw, 1rem)',
        backgroundColor: 'rgba(12,16,24,0.98)',
        boxSizing: 'border-box',
      }}
    >
      <Box
        style={{
          flexShrink: 0,
          fontSize: `clamp(${0.75 * TERMINAL_SCALE}rem, ${1.5 * TERMINAL_SCALE}vw, ${0.9 * TERMINAL_SCALE}rem)`,
          color: 'rgba(100,150,220,0.95)',
          marginBottom: '0.5rem',
          fontFamily: 'monospace',
        }}
      >
        Реконструктор рецептов - подберите подходящую химическую формулу в
        реконструированной цепочке химических соединений, основанной на других
        экспериментах и анализе.
      </Box>

      <Box
        style={{
          flexShrink: 0,
          fontSize: `clamp(${0.85 * TERMINAL_SCALE}rem, ${1.8 * TERMINAL_SCALE}vw, ${1.05 * TERMINAL_SCALE}rem)`,
          color:
            attemptsLeft <= 0
              ? 'rgba(200,100,80,0.95)'
              : 'rgba(140,170,230,0.95)',
          marginBottom: '0.35rem',
        }}
      >
        Попыток: {attemptsLeft} из 4
        {attemptsLeft <= 0 && ' - попытки исчерпаны'}
      </Box>

      <Box
        style={{
          flex: 1,
          minHeight: 0,
          overflow: 'auto',
          fontFamily: 'monospace',
          fontSize: `clamp(${1 * TERMINAL_SCALE}rem, ${2.4 * TERMINAL_SCALE}vw, ${1.35 * TERMINAL_SCALE}rem)`,
          lineHeight: 1.5,
          color: 'rgba(120,160,220,0.92)',
          backgroundColor: 'rgba(18,24,38,0.95)',
          border: '1px solid rgba(50,90,140,0.5)',
          borderRadius: '6px',
          padding: '0.9rem 1.1rem',
          letterSpacing: '0.02em',
        }}
      >
        {(lines || []).map((lineStr, i) => (
          <Box key={i} style={{ marginBottom: '0.15rem' }}>
            {renderLine(lineStr, i)}
          </Box>
        ))}
      </Box>

      {lastLikeness != null && (
        <Box
          style={{
            flexShrink: 0,
            marginTop: '0.5rem',
            fontSize: `clamp(${0.85 * TERMINAL_SCALE}rem, ${1.7 * TERMINAL_SCALE}vw, ${1.05 * TERMINAL_SCALE}rem)`,
            color: 'rgba(220,180,100,0.95)',
          }}
        >
          Совпадений символов: {lastLikeness} из {correctLength}
        </Box>
      )}

      {optionFormulas.length > 0 && (
        <Box
          style={{
            flexShrink: 0,
            marginTop: '0.5rem',
            fontFamily: 'monospace',
            fontSize: `clamp(${0.8 * TERMINAL_SCALE}rem, ${1.6 * TERMINAL_SCALE}vw, ${1 * TERMINAL_SCALE}rem)`,
            color: 'rgba(130,160,200,0.9)',
          }}
        >
          Варианты ответа:{' '}
          {optionFormulas.map((formula, i) => (
            <Box
              key={formula}
              as="span"
              style={{
                marginLeft: i > 0 ? '0.5rem' : 0,
                padding: '0.15em 0.35em',
                backgroundColor: 'rgba(40,70,120,0.3)',
                borderRadius: '3px',
                border: '1px solid rgba(100,160,220,0.4)',
              }}
            >
              {formula}
            </Box>
          ))}
        </Box>
      )}

      <Box
        style={{
          flexShrink: 0,
          marginTop: '0.75rem',
          display: 'flex',
          alignItems: 'center',
          gap: '0.5rem',
        }}
      >
        <Button icon="times" onClick={onCancel} color="bad">
          Отмена
        </Button>
        <Box
          style={{
            fontSize: `clamp(${0.7 * TERMINAL_SCALE}rem, ${1.3 * TERMINAL_SCALE}vw, ${0.85 * TERMINAL_SCALE}rem)`,
            color: 'rgba(100,110,130,0.8)',
          }}
        >
          При отмене очки исследования не возвращаются. Выберите формулу в
          цепочке соединений выше.
        </Box>
      </Box>
    </Box>
  );
}
