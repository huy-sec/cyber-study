// Static NIST 800-53 reference data — not stored in Supabase
// because it's stable spec data, not course content.

export const FAMILIES = [
  { id: 'AC', name: 'Access Control',                        desc: 'Account management, access enforcement, least privilege, remote access' },
  { id: 'AT', name: 'Awareness & Training',                  desc: 'Security literacy, role-based training, insider threat awareness' },
  { id: 'AU', name: 'Audit & Accountability',                desc: 'Event logging, log protection, audit review, timestamps' },
  { id: 'CA', name: 'Assessment, Authorization & Monitoring',desc: 'Control assessments, ATO, continuous monitoring, POA&M' },
  { id: 'CM', name: 'Configuration Management',              desc: 'Baseline configs, change control, least functionality, component inventory' },
  { id: 'CP', name: 'Contingency Planning',                  desc: 'Business continuity, backup, recovery objectives, testing' },
  { id: 'IA', name: 'Identification & Authentication',       desc: 'MFA, authenticator management, identity federation, phishing-resistant auth' },
  { id: 'IR', name: 'Incident Response',                     desc: 'Incident handling, monitoring, reporting, response plan, testing' },
  { id: 'MA', name: 'Maintenance',                           desc: 'Controlled maintenance, maintenance tools, remote maintenance' },
  { id: 'MP', name: 'Media Protection',                      desc: 'Media access, sanitization, transport, destruction' },
  { id: 'PE', name: 'Physical & Environmental Protection',   desc: 'Physical access, monitoring, visitor control, power, emergency' },
  { id: 'PL', name: 'Planning',                              desc: 'System security plan, rules of behavior, security architecture' },
  { id: 'PM', name: 'Program Management',                    desc: 'Risk strategy, enterprise architecture, critical infrastructure, insider threat' },
  { id: 'PS', name: 'Personnel Security',                    desc: 'Position risk, screening, termination, transfer, sanctions' },
  { id: 'PT', name: 'PII Processing & Transparency',         desc: 'Consent, privacy notice, data minimization, individual access (NEW Rev 5)' },
  { id: 'RA', name: 'Risk Assessment',                       desc: 'Risk assessment, vulnerability monitoring, threat hunting, supply chain risk' },
  { id: 'SA', name: 'System & Services Acquisition',         desc: 'Lifecycle planning, developer security, supply chain, external services' },
  { id: 'SC', name: 'System & Communications Protection',    desc: 'Boundary protection, cryptography, network segmentation, key management' },
  { id: 'SI', name: 'System & Information Integrity',        desc: 'Patch management, malware protection, monitoring, software integrity' },
  { id: 'SR', name: 'Supply Chain Risk Management',          desc: 'Supply chain controls, provenance, component authenticity (NEW Rev 5)' },
];

export const COLORS = {
  bg:           '#07090f',
  surface:      '#0d1220',
  surfaceUp:    '#131c30',
  surfaceHigh:  '#1a2540',
  border:       '#1e2e4a',
  borderLight:  '#253654',
  accent:       '#c8922a',
  accentBright: '#e8a830',
  accentDim:    'rgba(200,146,42,0.12)',
  blue:         '#3d7fe8',
  blueDim:      'rgba(61,127,232,0.12)',
  green:        '#22c55e',
  greenDim:     'rgba(34,197,94,0.1)',
  red:          '#ef4444',
  text:         '#dde4f0',
  textSub:      '#7a8eaa',
  textMuted:    '#3d4f6a',
};

export const MONO  = { fontFamily: "'IBM Plex Mono', 'Courier New', monospace" };
export const SERIF = { fontFamily: "'Playfair Display', Georgia, serif" };
export const APP_STYLE = {
  background:  COLORS.bg,
  minHeight:   '100vh',
  fontFamily:  "'Source Serif 4', Georgia, serif",
  color:       COLORS.text,
  maxWidth:    '480px',
  margin:      '0 auto',
};
