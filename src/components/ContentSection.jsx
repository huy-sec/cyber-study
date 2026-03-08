import { COLORS, MONO, SERIF, FAMILIES } from '../constants.js';

// ─── Families grid ─────────────────────────────────────────────────────────
function FamiliesPreview() {
  return (
    <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginTop: '4px' }}>
      {FAMILIES.slice(0, 6).map((f) => (
        <span key={f.id} style={{ ...MONO, fontSize: '11px', padding: '4px 8px', background: COLORS.surfaceHigh, border: `1px solid ${COLORS.border}`, borderRadius: '4px', color: COLORS.textSub }}>
          <span style={{ color: COLORS.accentBright }}>{f.id}</span> {f.name}
        </span>
      ))}
      <span style={{ ...MONO, fontSize: '11px', padding: '4px 8px', background: COLORS.surfaceHigh, border: `1px solid ${COLORS.border}`, borderRadius: '4px', color: COLORS.textMuted }}>
        +14 more →
      </span>
    </div>
  );
}

function FamiliesFull() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', marginTop: '4px' }}>
      {FAMILIES.map((f) => (
        <div key={f.id} style={{ display: 'flex', gap: '12px', padding: '10px 12px', background: COLORS.surfaceHigh, border: `1px solid ${COLORS.border}`, borderRadius: '6px', alignItems: 'flex-start' }}>
          <span style={{ ...MONO, fontSize: '12px', fontWeight: 700, color: COLORS.accentBright, minWidth: '28px', paddingTop: '1px' }}>{f.id}</span>
          <div>
            <div style={{ fontSize: '13px', fontWeight: 600, color: COLORS.text, marginBottom: '2px' }}>{f.name}</div>
            <div style={{ fontSize: '12px', color: COLORS.textSub, lineHeight: 1.4 }}>{f.desc}</div>
          </div>
        </div>
      ))}
    </div>
  );
}

function ControlExample({ controlId, controlName, content }) {
  return (
    <div style={{ background: '#060c1a', border: `1px solid ${COLORS.borderLight}`, borderRadius: '8px', overflow: 'hidden', marginTop: '4px' }}>
      <div style={{ padding: '10px 14px', borderBottom: `1px solid ${COLORS.border}`, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <span style={{ ...MONO, fontSize: '12px', color: COLORS.accentBright, fontWeight: 700 }}>{controlId}</span>
        <span style={{ ...MONO, fontSize: '11px', color: COLORS.textSub, letterSpacing: '0.05em' }}>{controlName}</span>
      </div>
      <div style={{ padding: '14px', ...MONO, fontSize: '12px', color: COLORS.textSub, lineHeight: 1.7, whiteSpace: 'pre-line' }}>{content}</div>
    </div>
  );
}

// ─── Main export ─────────────────────────────────────────────────────────────
export default function ContentSection({ section }) {
  const H = { fontSize: '16px', fontWeight: 700, color: COLORS.text, marginBottom: '10px', ...SERIF, lineHeight: 1.3 };
  const T = { fontSize: '15px', color: COLORS.textSub, lineHeight: 1.75 };

  if (section.type === 'families-preview')
    return <div style={{ marginBottom: '28px' }}><div style={H}>{section.heading}</div><FamiliesPreview /></div>;

  if (section.type === 'families-full')
    return <div style={{ marginBottom: '28px' }}><div style={H}>{section.heading}</div><FamiliesFull /></div>;

  if (section.type === 'control-example')
    return (
      <div style={{ marginBottom: '28px' }}>
        <div style={H}>{section.heading}</div>
        <ControlExample controlId={section.control_id} controlName={section.control_name} content={section.content} />
      </div>
    );

  if (section.type === 'callout')
    return (
      <div style={{ marginBottom: '28px' }}>
        {section.heading && <div style={H}>{section.heading}</div>}
        <div style={{ padding: '14px 16px', background: COLORS.accentDim, border: `1px solid rgba(200,146,42,0.3)`, borderLeft: `3px solid ${COLORS.accent}`, borderRadius: '6px' }}>
          <div style={{ ...MONO, fontSize: '10px', color: COLORS.accent, fontWeight: 700, letterSpacing: '0.12em', marginBottom: '8px' }}>{section.label}</div>
          <div style={{ ...T, color: COLORS.text, fontSize: '14px' }}>{section.content}</div>
        </div>
      </div>
    );

  if (section.type === 'list')
    return (
      <div style={{ marginBottom: '28px' }}>
        <div style={H}>{section.heading}</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
          {(section.items || []).map((item, i) => (
            <div key={i} style={{ display: 'flex', gap: '12px', alignItems: 'flex-start' }}>
              <span style={{ ...MONO, fontSize: '11px', color: COLORS.accent, minWidth: '20px', paddingTop: '3px' }}>
                {String(i + 1).padStart(2, '0')}
              </span>
              <span style={{ ...T, fontSize: '14px' }}>{item}</span>
            </div>
          ))}
        </div>
      </div>
    );

  // Default: plain text block
  return (
    <div style={{ marginBottom: '28px' }}>
      <div style={H}>{section.heading}</div>
      <p style={{ ...T, margin: 0 }}>{section.content}</p>
    </div>
  );
}
