import { COLORS, MONO } from '../constants.js';

export function ProgressBar({ value, max, color = COLORS.accent }) {
  const pct = max > 0 ? Math.round((value / max) * 100) : 0;
  return (
    <div style={{ background: COLORS.border, borderRadius: '99px', height: '4px', overflow: 'hidden' }}>
      <div style={{ width: `${pct}%`, height: '100%', background: color, borderRadius: '99px', transition: 'width 0.5s ease' }} />
    </div>
  );
}

export function Badge({ children, color = COLORS.accent, bg }) {
  return (
    <span style={{
      ...MONO, fontSize: '10px', fontWeight: 700, letterSpacing: '0.1em',
      padding: '3px 8px', borderRadius: '4px',
      background: bg || COLORS.accentDim, color,
      textTransform: 'uppercase',
    }}>
      {children}
    </span>
  );
}
