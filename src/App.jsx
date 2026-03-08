import { useState, useEffect } from 'react';
import { fetchAllCourseData, isConfigured } from './supabaseClient.js';
import { APP_STYLE, COLORS, MONO, SERIF } from './constants.js';
import HomeView    from './components/HomeView.jsx';
import CourseView  from './components/CourseView.jsx';
import LessonView  from './components/LessonView.jsx';
import QuizView    from './components/QuizView.jsx';
import SetupScreen from './components/SetupScreen.jsx';

// ─── Loading skeleton ─────────────────────────────────────────────────────────
function LoadingScreen() {
  return (
    <div style={{ ...APP_STYLE, padding: '28px 20px' }}>
      {[100, 80, 60].map((w, i) => (
        <div key={i} style={{ background: COLORS.surface, borderRadius: '8px', height: i === 0 ? '28px' : '18px', width: `${w}%`, marginBottom: '14px', opacity: 0.4 - i * 0.05 }} />
      ))}
      {[1, 2, 3].map((i) => (
        <div key={i} style={{ background: COLORS.surface, borderRadius: '10px', height: '80px', marginBottom: '12px', opacity: 0.15 + i * 0.05 }} />
      ))}
      <div style={{ ...MONO, fontSize: '12px', color: COLORS.textMuted, textAlign: 'center', marginTop: '24px' }}>
        Loading from Supabase...
      </div>
    </div>
  );
}

// ─── Error screen ─────────────────────────────────────────────────────────────
function ErrorScreen({ error, onRetry }) {
  return (
    <div style={{ ...APP_STYLE, display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: '32px 24px', minHeight: '100vh' }}>
      <div style={{ ...MONO, fontSize: '10px', color: COLORS.red, letterSpacing: '0.14em', marginBottom: '16px' }}>
        CONNECTION ERROR
      </div>
      <div style={{ ...SERIF, fontSize: '20px', fontWeight: 700, color: COLORS.text, marginBottom: '12px' }}>
        Couldn't reach Supabase
      </div>
      <div style={{ fontSize: '13px', color: COLORS.textSub, lineHeight: 1.7, marginBottom: '16px' }}>
        Check that your environment variables are correct and your Supabase project is running.
      </div>
      <div style={{ background: '#060c1a', border: `1px solid rgba(239,68,68,0.3)`, borderRadius: '8px', padding: '12px 14px', ...MONO, fontSize: '11px', color: COLORS.red, marginBottom: '24px', wordBreak: 'break-word' }}>
        {error?.message || 'Unknown error'}
      </div>
      <button
        onClick={onRetry}
        style={{ padding: '14px', background: COLORS.surface, border: `1px solid ${COLORS.border}`, borderRadius: '8px', color: COLORS.textSub, fontSize: '14px', cursor: 'pointer', fontFamily: 'inherit' }}
      >
        Retry →
      </button>
    </div>
  );
}

// ─── Root ─────────────────────────────────────────────────────────────────────
export default function App() {
  const [courses,      setCourses]      = useState([]);
  const [loading,      setLoading]      = useState(true);
  const [error,        setError]        = useState(null);
  const [view,         setView]         = useState('home');   // home | course | lesson
  const [activeCourse, setActiveCourse] = useState(null);
  const [activeModule, setActiveModule] = useState(null);
  const [inQuiz,       setInQuiz]       = useState(false);
  const [completed,    setCompleted]    = useState(new Set());

  // Inject Google Fonts once
  useEffect(() => {
    const style = document.createElement('style');
    style.textContent = `
      @import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Source+Serif+4:ital,wght@0,400;0,500;1,400&family=IBM+Plex+Mono:wght@400;500;700&display=swap');
      * { box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
      body { margin: 0; background: #07090f; }
      ::-webkit-scrollbar { width: 4px; }
      ::-webkit-scrollbar-track { background: #0d1220; }
      ::-webkit-scrollbar-thumb { background: #1e2e4a; border-radius: 2px; }
    `;
    document.head.appendChild(style);
    return () => document.head.removeChild(style);
  }, []);

  const load = () => {
    setLoading(true);
    setError(null);
    fetchAllCourseData()
      .then((data) => { setCourses(data); setLoading(false); })
      .catch((err)  => { setError(err);   setLoading(false); });
  };

  useEffect(() => {
    if (isConfigured) load();
    else setLoading(false);
  }, []);

  // ── Navigation helpers ────────────────────────────────────────────────────
  const openCourse = (course) => { setActiveCourse(course); setView('course'); };
  const openModule = (mod)    => { setActiveModule(mod);    setView('lesson'); };
  const backHome   = ()       => setView('home');
  const backCourse = ()       => setView('course');

  const completeModule = () => {
    setCompleted((prev) => new Set([...prev, activeModule.id]));
    setInQuiz(false);
    setView('course');
  };

  // ── Render ────────────────────────────────────────────────────────────────
  if (!isConfigured)           return <div style={APP_STYLE}><SetupScreen /></div>;
  if (loading)                 return <div style={APP_STYLE}><LoadingScreen /></div>;
  if (error)                   return <div style={APP_STYLE}><ErrorScreen error={error} onRetry={load} /></div>;

  if (inQuiz && activeModule)
    return (
      <div style={APP_STYLE}>
        <QuizView module={activeModule} onComplete={completeModule} onBack={() => setInQuiz(false)} />
      </div>
    );

  if (view === 'lesson' && activeModule)
    return (
      <div style={APP_STYLE}>
        <LessonView module={activeModule} onBack={backCourse} onStartQuiz={() => setInQuiz(true)} />
      </div>
    );

  if (view === 'course' && activeCourse)
    return (
      <div style={APP_STYLE}>
        <CourseView course={activeCourse} completed={completed} onSelectModule={openModule} onBack={backHome} />
      </div>
    );

  return (
    <div style={APP_STYLE}>
      <HomeView courses={courses} completed={completed} onSelectCourse={openCourse} />
    </div>
  );
}
