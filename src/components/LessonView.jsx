import { COLORS, MONO, SERIF, FAMILIES } from '../constants.js';
import { ProgressBar, Badge } from './ui.jsx';
import ContentSection from './ContentSection.jsx';

// ─── Lesson view ──────────────────────────────────────────────────────────────
export default function LessonView({ module, onBack, onStartQuiz }) {
  return (
    <div style={{ background: COLORS.bg, minHeight: '100vh' }}>
      <div style={{ padding: '16px 20px', borderBottom: `1px solid ${COLORS.border}`, background: COLORS.surface, position: 'sticky', top: 0, zIndex: 10 }}>
        <button onClick={onBack} style={{ background: 'none', border: 'none', color: COLORS.textSub, cursor: 'pointer', fontSize: '14px', padding: '4px 0', marginBottom: '10px', display: 'block', fontFamily: 'inherit' }}>
          ← Back
        </button>
        <div style={{ display: 'flex', gap: '10px', alignItems: 'baseline' }}>
          <span style={{ ...MONO, fontSize: '20px', fontWeight: 700, color: COLORS.accentBright }}>{module.number}</span>
          <div>
            <div style={{ ...SERIF, fontSize: '17px', fontWeight: 700, color: COLORS.text }}>{module.title}</div>
            <div style={{ fontSize: '12px', color: COLORS.textSub }}>{module.subtitle} · {module.duration}</div>
          </div>
        </div>
      </div>

      <div style={{ padding: '28px 20px 100px' }}>
        {module.sections.map((s, i) => <ContentSection key={s.id || i} section={s} />)}

        <div style={{ borderTop: `1px solid ${COLORS.border}`, paddingTop: '28px', marginTop: '8px' }}>
          <div style={{ ...SERIF, fontSize: '18px', fontWeight: 700, color: COLORS.text, marginBottom: '8px' }}>Knowledge Check</div>
          <div style={{ fontSize: '14px', color: COLORS.textSub, marginBottom: '20px', lineHeight: 1.6 }}>
            {module.quiz.length} questions covering this module. Score 70% or higher to mark it complete.
          </div>
          <button
            onClick={onStartQuiz}
            style={{ width: '100%', padding: '16px', background: COLORS.accent, border: 'none', borderRadius: '10px', color: COLORS.bg, fontSize: '15px', fontWeight: 700, cursor: 'pointer', letterSpacing: '0.02em', fontFamily: 'inherit' }}
          >
            Start Quiz →
          </button>
        </div>
      </div>
    </div>
  );
}
