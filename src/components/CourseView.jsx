import { COLORS, MONO, SERIF } from '../constants.js';
import { ProgressBar, Badge } from './ui.jsx';

export default function CourseView({ course, completed, onSelectModule, onBack }) {
  const total = course.modules.length;
  const done  = course.modules.filter((m) => completed.has(m.id)).length;

  return (
    <div style={{ background: COLORS.bg, minHeight: '100vh' }}>
      {/* Course header */}
      <div style={{ background: COLORS.surface, borderBottom: `1px solid ${COLORS.border}`, padding: '20px 20px 24px' }}>
        <button onClick={onBack} style={{ background: 'none', border: 'none', color: COLORS.textSub, cursor: 'pointer', fontSize: '14px', padding: '4px 0', marginBottom: '16px', display: 'block', fontFamily: 'inherit' }}>
          ← All Courses
        </button>
        <Badge>{course.tag}</Badge>
        <div style={{ ...SERIF, fontSize: '22px', fontWeight: 700, color: COLORS.text, marginTop: '10px', marginBottom: '4px' }}>{course.title}</div>
        <div style={{ fontSize: '14px', color: COLORS.textSub, marginBottom: '16px' }}>{course.description}</div>

        <div style={{ display: 'flex', gap: '16px', marginBottom: '16px' }}>
          {[['Level', course.level], ['Duration', course.duration], course.prereq && ['Prereq', course.prereq]]
            .filter(Boolean)
            .map(([k, v]) => (
              <div key={k}>
                <div style={{ ...MONO, fontSize: '10px', color: COLORS.textMuted, letterSpacing: '0.08em' }}>{k}</div>
                <div style={{ fontSize: '12px', color: COLORS.textSub }}>{v}</div>
              </div>
            ))}
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
          <span style={{ ...MONO, fontSize: '11px', color: COLORS.textSub }}>{done} of {total} complete</span>
          <span style={{ ...MONO, fontSize: '11px', color: COLORS.accent }}>{Math.round((done / total) * 100)}%</span>
        </div>
        <ProgressBar value={done} max={total} />
      </div>

      {/* Module list */}
      <div style={{ padding: '20px' }}>
        <div style={{ ...MONO, fontSize: '11px', color: COLORS.textMuted, letterSpacing: '0.1em', marginBottom: '14px' }}>MODULES</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
          {course.modules.map((mod, i) => {
            const isDone = completed.has(mod.id);
            const isNext = !isDone && (i === 0 || completed.has(course.modules[i - 1]?.id));
            return (
              <button
                key={mod.id}
                onClick={() => onSelectModule(mod)}
                style={{ padding: '16px', background: isDone ? COLORS.greenDim : COLORS.surface, border: `1px solid ${isDone ? 'rgba(34,197,94,0.25)' : isNext ? COLORS.borderLight : COLORS.border}`, borderRadius: '10px', textAlign: 'left', cursor: 'pointer', transition: 'all 0.2s', fontFamily: 'inherit' }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
                  <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
                    <span style={{ ...MONO, fontSize: '14px', fontWeight: 700, color: isDone ? COLORS.green : COLORS.accentBright }}>
                      {isDone ? '✓' : mod.number}
                    </span>
                    <div style={{ ...SERIF, fontSize: '15px', fontWeight: 600, color: COLORS.text }}>{mod.title}</div>
                  </div>
                  {isNext && <Badge color={COLORS.blue} bg={COLORS.blueDim}>Next</Badge>}
                </div>
                <div style={{ paddingLeft: '26px', fontSize: '13px', color: COLORS.textSub }}>{mod.subtitle}</div>
                <div style={{ paddingLeft: '26px', ...MONO, fontSize: '11px', color: COLORS.textMuted, marginTop: '4px' }}>
                  {mod.duration} · {mod.quiz.length} questions
                </div>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
