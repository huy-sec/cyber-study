import { COLORS, MONO, SERIF, FAMILIES } from '../constants.js';
import { ProgressBar, Badge } from './ui.jsx';

export default function HomeView({ courses, completed, onSelectCourse }) {
  const mainCourse = courses.find((c) => c.slug === 'nist-800-53') || courses[0];
  if (!mainCourse) return null;

  const done   = mainCourse.modules.filter((m) => completed.has(m.id)).length;
  const total  = mainCourse.modules.length;
  const locked = courses.filter((c) => c.locked);

  return (
    <div style={{ background: COLORS.bg, minHeight: '100vh' }}>
      {/* Hero */}
      <div style={{ padding: '28px 20px 20px', background: COLORS.surface, borderBottom: `1px solid ${COLORS.border}` }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '4px' }}>
          <div style={{ ...MONO, fontSize: '10px', color: COLORS.accent, letterSpacing: '0.14em' }}>CYBERSECURITY EDUCATION</div>
          <div style={{ ...MONO, fontSize: '10px', color: COLORS.textMuted }}>SP 800-53 STUDY</div>
        </div>
        <div style={{ ...SERIF, fontSize: '28px', fontWeight: 700, color: COLORS.text, lineHeight: 1.2, marginBottom: '8px' }}>
          Control Your Controls
        </div>
        <div style={{ fontSize: '14px', color: COLORS.textSub, lineHeight: 1.6 }}>
          Practitioner-built courses for GRC professionals moving beyond the CSF.
        </div>
      </div>

      <div style={{ padding: '20px' }}>
        {/* Active course */}
        <div style={{ ...MONO, fontSize: '11px', color: COLORS.textMuted, letterSpacing: '0.1em', marginBottom: '14px' }}>ACTIVE COURSE</div>
        <button
          onClick={() => onSelectCourse(mainCourse)}
          style={{ width: '100%', padding: '20px', background: COLORS.surfaceUp, border: `1px solid ${COLORS.borderLight}`, borderRadius: '12px', textAlign: 'left', cursor: 'pointer', marginBottom: '24px', fontFamily: 'inherit' }}
        >
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '12px' }}>
            <Badge>{mainCourse.tag}</Badge>
            <span style={{ ...MONO, fontSize: '11px', color: COLORS.textMuted }}>{mainCourse.duration}</span>
          </div>
          <div style={{ ...SERIF, fontSize: '20px', fontWeight: 700, color: COLORS.text, marginBottom: '4px' }}>{mainCourse.title}</div>
          <div style={{ fontSize: '13px', color: COLORS.textSub, marginBottom: '16px' }}>{mainCourse.subtitle}</div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
            <span style={{ fontSize: '13px', color: COLORS.textSub }}>{done} of {total} modules</span>
            <span style={{ ...MONO, fontSize: '12px', color: COLORS.accent }}>{Math.round((done / total) * 100)}%</span>
          </div>
          <ProgressBar value={done} max={total} />
          <div style={{ marginTop: '16px', padding: '10px 14px', background: COLORS.accentDim, borderRadius: '8px', ...MONO, fontSize: '12px', color: COLORS.accent, textAlign: 'center' }}>
            {done === 0 ? 'Start Course →' : done === total ? 'Review Course ✓' : `Continue — Module ${done + 1} →`}
          </div>
        </button>

        {/* Locked courses */}
        {locked.length > 0 && (
          <>
            <div style={{ ...MONO, fontSize: '11px', color: COLORS.textMuted, letterSpacing: '0.1em', marginBottom: '14px' }}>COMING NEXT</div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', marginBottom: '28px' }}>
              {locked.map((course) => (
                <div key={course.id} style={{ padding: '16px', background: COLORS.surface, border: `1px solid ${COLORS.border}`, borderRadius: '10px', opacity: 0.6 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
                    <Badge color={COLORS.textSub} bg={COLORS.surfaceHigh}>{course.tag}</Badge>
                    <span style={{ ...MONO, fontSize: '10px', color: COLORS.textMuted }}>{course.level}</span>
                  </div>
                  <div style={{ ...SERIF, fontSize: '15px', fontWeight: 600, color: COLORS.textSub, marginBottom: '2px' }}>{course.title}</div>
                  <div style={{ fontSize: '12px', color: COLORS.textMuted }}>{course.subtitle}</div>
                </div>
              ))}
            </div>
          </>
        )}

        {/* Quick reference */}
        <div style={{ padding: '16px', background: COLORS.surfaceHigh, border: `1px solid ${COLORS.border}`, borderRadius: '10px' }}>
          <div style={{ ...MONO, fontSize: '10px', color: COLORS.textMuted, letterSpacing: '0.1em', marginBottom: '8px' }}>QUICK REFERENCE</div>
          <div style={{ ...SERIF, fontSize: '14px', color: COLORS.textSub, marginBottom: '12px' }}>NIST 800-53 Rev 5 — All 20 Families</div>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
            {FAMILIES.map((f) => (
              <span key={f.id} style={{ ...MONO, fontSize: '11px', padding: '3px 7px', background: COLORS.surface, border: `1px solid ${COLORS.border}`, borderRadius: '4px' }}>
                <span style={{ color: COLORS.accentBright }}>{f.id}</span>
              </span>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
