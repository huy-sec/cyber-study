// Supabase connection — credentials are injected at build time
// from environment variables (GitHub Secrets → Vite → bundle).
// Never commit real values here; use .env.local for local dev.

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || '';
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY || '';

export const isConfigured =
  SUPABASE_URL.startsWith('https://') && SUPABASE_ANON_KEY.length > 20;

/**
 * Minimal REST fetch helper — no SDK dependency.
 * @param {string} path  e.g. 'courses?select=*&order=sort_order.asc'
 */
export async function supaFetch(path) {
  if (!isConfigured) throw new Error('Supabase credentials not configured.');

  const res = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    headers: {
      apikey: SUPABASE_ANON_KEY,
      Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
      'Content-Type': 'application/json',
    },
  });

  if (!res.ok) {
    const body = await res.text().catch(() => '');
    throw new Error(`Supabase ${res.status}: ${body}`);
  }

  return res.json();
}

/**
 * Fetch and assemble the full course tree in one call batch.
 * Returns: Course[] with nested modules → sections → quiz
 */
export async function fetchAllCourseData() {
  const [courses, modules, sections, sectionItems, questions, options] =
    await Promise.all([
      supaFetch('courses?select=*&order=sort_order.asc'),
      supaFetch('modules?select=*&order=sort_order.asc'),
      supaFetch('sections?select=*&order=sort_order.asc'),
      supaFetch('section_items?select=*&order=sort_order.asc'),
      supaFetch('quiz_questions?select=*&order=sort_order.asc'),
      supaFetch('quiz_options?select=*&order=sort_order.asc'),
    ]);

  return courses.map((course) => ({
    ...course,
    modules: modules
      .filter((m) => m.course_id === course.id)
      .map((mod) => ({
        ...mod,
        sections: sections
          .filter((s) => s.module_id === mod.id)
          .map((s) => ({
            ...s,
            items:
              s.type === 'list'
                ? sectionItems
                    .filter((si) => si.section_id === s.id)
                    .map((si) => si.content)
                : undefined,
          })),
        quiz: questions
          .filter((q) => q.module_id === mod.id)
          .map((q) => ({
            ...q,
            options: options.filter((o) => o.question_id === q.id),
          })),
      })),
  }));
}
