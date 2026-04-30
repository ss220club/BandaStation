export const bodyModStyles = {
  contentRoot: {
    display: 'flex',
    flex: 1,
    overflow: 'hidden',
    flexDirection: 'column' as const,
    gap: '0.45rem',
    padding: '0.45rem',
  },
  row: {
    display: 'flex',
    flex: 1,
    overflow: 'hidden',
    gap: '0.45rem',
  },
  categoriesPanel: {
    width: '190px',
    minWidth: '190px',
    background:
      'linear-gradient(180deg, rgba(6,18,24,0.78) 0%, rgba(10,10,18,0.45) 55%, rgba(34,10,22,0.52) 100%)',
    border: '1px solid rgba(0, 240, 255, 0.22)',
    borderRadius: '6px',
    display: 'flex',
    flexDirection: 'column' as const,
    overflowY: 'auto' as const,
    boxShadow:
      'inset 0 0 0 1px rgba(255,42,109,0.08), 0 8px 20px rgba(0,0,0,0.25)',
  },
  previewPanel: {
    width: '280px',
    minWidth: '280px',
    display: 'flex',
    flexDirection: 'column' as const,
    alignItems: 'stretch',
    padding: '0.55rem',
    background:
      'linear-gradient(180deg, rgba(8,20,26,0.72) 0%, rgba(9,9,16,0.55) 48%, rgba(28,10,20,0.55) 100%)',
    border: '1px solid rgba(0, 240, 255, 0.24)',
    borderRadius: '6px',
    boxShadow:
      'inset 0 0 0 1px rgba(255,42,109,0.1), 0 8px 20px rgba(0,0,0,0.24)',
  },
  listPanel: {
    flex: 1,
    minWidth: '340px',
    background:
      'linear-gradient(180deg, rgba(5,17,23,0.62) 0%, rgba(10,10,18,0.4) 50%, rgba(30,10,22,0.44) 100%)',
    border: '1px solid rgba(0, 240, 255, 0.2)',
    borderRadius: '6px',
    display: 'flex',
    flexDirection: 'column' as const,
    overflow: 'hidden',
    boxShadow:
      'inset 0 0 0 1px rgba(255,42,109,0.08), 0 8px 20px rgba(0,0,0,0.24)',
  },
  previewViewport: {
    border: '1px solid rgba(0,240,255,0.34)',
    borderRadius: '6px',
    overflow: 'hidden',
    background:
      'radial-gradient(circle at 50% 30%, rgba(0,240,255,0.16), rgba(0,0,0,0.58) 62%)',
    marginBottom: '0.5rem',
    display: 'flex',
    justifyContent: 'center' as const,
    alignItems: 'center' as const,
    animation: 'rd-frame-pulse 3.6s ease-in-out infinite',
    boxShadow: 'inset 0 0 22px rgba(0,0,0,0.5)',
    padding: '0.25rem 0.35rem',
  },
  previewInner: {
    width: '220px',
    height: '270px',
    borderRadius: '4px',
    overflow: 'hidden',
    border: '1px solid rgba(0,240,255,0.18)',
    boxShadow: '0 0 0 1px rgba(0,0,0,0.35), 0 0 16px rgba(0,240,255,0.12)',
  },
};
