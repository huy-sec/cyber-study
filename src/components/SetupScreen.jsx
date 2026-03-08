import { COLORS, MONO, SERIF, APP_STYLE } from '../constants.js';

export default function SetupScreen() {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', minHeight: '100vh', padding: '32px 24px' }}>
      <div style={{ ...MONO, fontSize: '10px', color: COLORS.accent, letterSpacing: '0.14em', marginBottom: '16px' }}>SETUP REQUIRED</div>
      <div style={{ ...SERIF, fontSize: '22px', fontWeight: 700, color: COLORS.text, marginBottom: '12px', lineHeight: 1.3 }}>Connect Supabase</div>
      <div style={{ fontSize: '14px', color: COLORS.textSub, lineHeight: 1.7, marginBottom: '24px' }}>
        Environment variables are missing. For local development, create a <code style={{ ...MONO, background: COLORS.surfaceHigh, padding: '1px 5px', borderRadius: '3px' }}>.env.local</code> file. For production, set GitHub Secrets and re-run the deployment workflow.
      </div>

      <div style={{ background: '#060c1a', border: `1px solid ${COLORS.border}`, borderRadius: '8px', padding: '16px', ...MONO, fontSize: '12px', color: COLORS.textSub, lineHeight: 2, marginBottom: '20px' }}>
        <span style={{ color: COLORS.textMuted }}># .env.local</span>{'\n'}
        <span style={{ color: COLORS.accentBright }}>VITE_SUPABASE_URL</span>=<span style={{ color: '#a8d8a8' }}>https://yourproject.supabase.co</span>{'\n'}
        <span style={{ color: COLORS.accentBright }}>VITE_SUPABASE_ANON_KEY</span>=<span style={{ color: '#a8d8a8' }}>eyJ...</span>
      </div>

      <div style={{ padding: '14px 16px', background: COLORS.accentDim, border: `1px solid rgba(200,146,42,0.3)`, borderLeft: `3px solid ${COLORS.accent}`, borderRadius: '6px' }}>
        <div style={{ ...MONO, fontSize: '10px', color: COLORS.accent, fontWeight: 700, letterSpacing: '0.12em', marginBottom: '6px' }}>NEXT STEP</div>
        <div style={{ fontSize: '13px', color: COLORS.text, lineHeight: 1.6 }}>
          Run <code style={{ ...MONO, background: COLORS.surfaceHigh, padding: '1px 5px', borderRadius: '3px' }}>nist-supabase-setup.sql</code> in your Supabase SQL Editor to create the schema and seed all course content.
        </div>
      </div>
    </div>
  );
}
