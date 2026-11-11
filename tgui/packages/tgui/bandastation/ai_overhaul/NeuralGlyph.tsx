export function NeuralGlyph({ compact = false }: { compact?: boolean }) {
  return (
    <svg viewBox="0 0 100 80" fill="none" aria-hidden="true">
      {!compact && (
        <>
          <path
            className="AiOS__glyphFrame"
            d="M9 24V14h12M79 14h12v10M91 56v10H79M21 66H9V56"
          />
          <circle
            cx="50"
            cy="40"
            r="34"
            strokeDasharray="1 9"
            className="AiOS__orbit"
          />
          <path
            className="AiOS__glyphWire"
            d="M7 40h15M78 40h15M50 5v8M50 67v8"
          />
        </>
      )}
      <path
        className="AiOS__cortexFill"
        d="M47 18c-5-7-17-4-18 4-9-1-14 9-9 16-6 8-1 19 8 19 1 9 14 13 19 6V18ZM53 18c5-7 17-4 18 4 9-1 14 9 9 16 6 8 1 19-8 19-1 9-14 13-19 6V18Z"
      />
      <path
        className="AiOS__cortexOutline"
        d="M47 18c-5-7-17-4-18 4-9-1-14 9-9 16-6 8-1 19 8 19 1 9 14 13 19 6V18ZM53 18c5-7 17-4 18 4 9-1 14 9 9 16 6 8 1 19-8 19-1 9-14 13-19 6V18Z"
      />
      <path
        className="AiOS__glyphWire"
        d="M29 22v8l8 6v10l-9 11M20 38h10M47 24h-8v-5M47 54h-8v9M71 22v8l-8 6v10l9 11M80 38H70M53 24h8v-5M53 54h8v9"
      />
      <path className="AiOS__pulseTrace" d="M30 43h10l4-7 6 13 6-13 4 7h10" />
      <g className="AiOS__neuronNodes">
        <circle cx="29" cy="30" r="2.1" />
        <circle cx="71" cy="30" r="2.1" />
        <circle cx="37" cy="46" r="2.1" />
        <circle cx="63" cy="46" r="2.1" />
      </g>
    </svg>
  );
}
