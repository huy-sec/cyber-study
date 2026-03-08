import { useState, useEffect } from 'react';
import { COLORS, MONO, SERIF } from '../constants.js';
import { ProgressBar } from './ui.jsx';

function shuffle(arr) {
  const s = [...arr];
  for (let i = s.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [s[i], s[j]] = [s[j], s[i]];
  }
  return s;
}

// ─── Result screen ────────────────────────────────────────────────────────────
function ResultScreen({ answers, onComplete, onBack }) {
  const total  = answers.length;
  const score  = answers.filter((a) => a.selectedOpt?.is_correct).length;
  const pct    = Math.round((score / total) * 100);
  const passed = pct >= 70;

  return (
    <div style={{ padding: '24px 20px', minHeight: '100vh', background: COLORS.bg }}>
      <div style={{ textAlign: 'center', paddingTop: '40px' }}>
        <div style={{ fontSize: '56px', marginBottom: '16px' }}>{passed ? '✓' : '↺'}</div>
        <div style={{ ...SERIF, fontSize: '24px', fontWeight: 700, color: passed ? COLORS.green : COLORS.accent, marginBottom: '8px' }}>
          {passed ? 'Module Complete' : 'Keep Reviewing'}
        </div>
        <div style={{ ...MONO, fontSize: '36px', fontWeight: 700, color: COLORS.text, marginBottom: '4px' }}>{pct}%</div>
        <div style={{ fontSize: '14px', color: COLORS.textSub, marginBottom: '32px' }}>{score} of {total} correct</div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          {answers.map((a, i) => {
            const correct  = a.q.options.find((o) => o.is_correct);
            const wasRight = a.selectedOpt?.is_correct;
            return (
              <div key={i} style={{ padding: '12px 14px', background: COLORS.surface, border: `1px solid ${wasRight ? 'rgba(34,197,94,0.3)' : 'rgba(239,68,68,0.3)'}`, borderRadius: '8px', textAlign: 'left' }}>
                <div style={{ fontSize: '12px', color: COLORS.textSub, marginBottom: '4px' }}>{a.q.question}</div>
                <div style={{ fontSize: '12px', ...MONO, color: wasRight ? COLORS.green : COLORS.red }}>
                  {wasRight ? '✓ Correct' : `✗ ${correct?.text}`}
                </div>
                {!wasRight && (
                  <div style={{ fontSize: '12px', color: COLORS.textSub, marginTop: '6px', fontStyle: 'italic' }}>
                    {a.q.explanation}
                  </div>
                )}
              </div>
            );
          })}
        </div>

        <div style={{ display: 'flex', gap: '12px', marginTop: '28px' }}>
          <button onClick={onBack} style={{ flex: 1, padding: '14px', background: COLORS.surface, border: `1px solid ${COLORS.border}`, borderRadius: '8px', color: COLORS.textSub, fontSize: '14px', cursor: 'pointer', fontFamily: 'inherit' }}>
            ← Back
          </button>
          {passed && (
            <button onClick={onComplete} style={{ flex: 1, padding: '14px', background: COLORS.accent, border: 'none', borderRadius: '8px', color: COLORS.bg, fontSize: '14px', fontWeight: 700, cursor: 'pointer', fontFamily: 'inherit' }}>
              Complete →
            </button>
          )}
        </div>
      </div>
    </div>
  );
}

// ─── Quiz view ────────────────────────────────────────────────────────────────
export default function QuizView({ module, onComplete, onBack }) {
  const [current,         setCurrent]         = useState(0);
  const [selectedId,      setSelectedId]      = useState(null);
  const [answers,         setAnswers]         = useState([]);
  const [shuffledOptions, setShuffledOptions] = useState([]);
  const [showResult,      setShowResult]      = useState(false);

  const q     = module.quiz[current];
  const total = module.quiz.length;
  const isLast = current === total - 1;

  // Shuffle options whenever the question changes
  useEffect(() => {
    if (q?.options) setShuffledOptions(shuffle(q.options));
    setSelectedId(null);
  }, [current, q]);

  const handleSelect = (optId) => {
    if (selectedId) return;
    setSelectedId(optId);
  };

  const handleNext = () => {
    const selectedOpt = shuffledOptions.find((o) => o.id === selectedId);
    const newAnswers  = [...answers, { q, selectedOpt }];
    setAnswers(newAnswers);
    if (isLast) {
      setShowResult(true);
    } else {
      setCurrent((c) => c + 1);
    }
  };

  if (showResult)
    return <ResultScreen answers={answers} onComplete={onComplete} onBack={onBack} />;

  if (!q || shuffledOptions.length === 0) return null;

  return (
    <div style={{ background: COLORS.bg, minHeight: '100vh' }}>
      {/* Header */}
      <div style={{ padding: '16px 20px', borderBottom: `1px solid ${COLORS.border}`, display: 'flex', justifyContent: 'space-between', alignItems: 'center', background: COLORS.surface }}>
        <button onClick={onBack} style={{ background: 'none', border: 'none', color: COLORS.textSub, cursor: 'pointer', fontSize: '14px', padding: '4px 0', fontFamily: 'inherit' }}>
          ← Exit Quiz
        </button>
        <span style={{ ...MONO, fontSize: '12px', color: COLORS.textSub }}>{current + 1} / {total}</span>
      </div>

      {/* Progress */}
      <div style={{ padding: '8px 20px 4px' }}>
        <ProgressBar value={current + (selectedId ? 1 : 0)} max={total} color={COLORS.accentBright} />
      </div>

      {/* Question */}
      <div style={{ padding: '28px 20px' }}>
        <div style={{ ...MONO, fontSize: '11px', color: COLORS.accent, letterSpacing: '0.1em', marginBottom: '12px' }}>
          QUESTION {current + 1}
        </div>
        <div style={{ ...SERIF, fontSize: '18px', fontWeight: 600, color: COLORS.text, lineHeight: 1.5, marginBottom: '28px' }}>
          {q.question}
        </div>

        {/* Options */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
          {shuffledOptions.map((opt, i) => {
            let bg = COLORS.surface, border = COLORS.border, color = COLORS.text;
            if (selectedId) {
              if (opt.is_correct)            { bg = COLORS.greenDim; border = 'rgba(34,197,94,0.4)'; color = COLORS.green; }
              else if (opt.id === selectedId){ bg = 'rgba(239,68,68,0.1)'; border = 'rgba(239,68,68,0.4)'; color = COLORS.red; }
              else                           { color = COLORS.textMuted; }
            }
            return (
              <button
                key={opt.id}
                onClick={() => handleSelect(opt.id)}
                style={{ padding: '14px 16px', background: bg, border: `1px solid ${border}`, borderRadius: '8px', color, textAlign: 'left', cursor: selectedId ? 'default' : 'pointer', fontSize: '14px', lineHeight: 1.5, transition: 'all 0.2s', fontFamily: 'inherit' }}
              >
                <span style={{ ...MONO, fontSize: '11px', marginRight: '10px', opacity: 0.6 }}>
                  {String.fromCharCode(65 + i)}.
                </span>
                {opt.text}
              </button>
            );
          })}
        </div>

        {/* Explanation */}
        {selectedId && (
          <div style={{ marginTop: '20px', padding: '14px 16px', background: COLORS.blueDim, border: `1px solid rgba(61,127,232,0.3)`, borderRadius: '8px' }}>
            <div style={{ ...MONO, fontSize: '10px', color: COLORS.blue, marginBottom: '6px', letterSpacing: '0.1em' }}>EXPLANATION</div>
            <div style={{ fontSize: '13px', color: COLORS.text, lineHeight: 1.6 }}>{q.explanation}</div>
          </div>
        )}

        {selectedId && (
          <button
            onClick={handleNext}
            style={{ marginTop: '20px', width: '100%', padding: '15px', background: COLORS.accent, border: 'none', borderRadius: '8px', color: COLORS.bg, fontSize: '15px', fontWeight: 700, cursor: 'pointer', fontFamily: 'inherit' }}
          >
            {isLast ? 'See Results' : 'Next Question →'}
          </button>
        )}
      </div>
    </div>
  );
}
