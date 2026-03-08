# NIST SP 800-53 Rev 5 — Study App

A mobile-first study platform for GRC and cybersecurity practitioners. Built with React + Vite, backed by Supabase, deployed to Azure Static Web Apps via GitHub Actions.

---

## Architecture

```
GitHub repo
  └── GitHub Actions (CI/CD)
        ├── Injects secrets as VITE_ env vars at build time
        ├── Runs: npm ci → npm run build → uploads dist/
        └── Azure Static Web Apps
              └── Serves the static bundle globally
```

Content lives in **Supabase** (PostgreSQL). The app fetches it at runtime. Adding new courses, modules, or quiz questions requires only SQL — no code changes.

---

## Prerequisites

- Node.js 20+
- A [Supabase](https://supabase.com) project (free tier works)
- An [Azure Static Web Apps](https://azure.microsoft.com/en-us/products/app-service/static) resource
- A GitHub repository

---

## Local Development Setup

**1. Clone the repo**
```bash
git clone https://github.com/YOUR_ORG/nist-800-53-study.git
cd nist-800-53-study
npm install
```

**2. Set up Supabase**

Open your Supabase project → SQL Editor → paste and run `nist-supabase-setup.sql`. This creates all tables and seeds the full NIST 800-53 Rev 5 course content.

**3. Create your local environment file**
```bash
cp .env.example .env.local
```

Edit `.env.local` with your credentials (found in Supabase Dashboard → Project Settings → API):
```
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**4. Run the dev server**
```bash
npm run dev
```

App runs at `http://localhost:5173`.

---

## Production Deployment

### Step 1 — Create an Azure Static Web App

1. Go to [portal.azure.com](https://portal.azure.com)
2. Create a new **Static Web App** resource
3. Connect it to your GitHub repo during setup (or skip and use manual deployment)
4. Once created, go to **Overview → Manage deployment token** and copy the token

### Step 2 — Add GitHub Secrets

Go to your GitHub repo → **Settings → Secrets and variables → Actions → New repository secret**

Add these three secrets:

| Secret name | Where to find it |
|---|---|
| `AZURE_STATIC_WEB_APPS_API_TOKEN` | Azure Portal → your Static Web App → Overview → Manage deployment token |
| `VITE_SUPABASE_URL` | Supabase Dashboard → Project Settings → API → Project URL |
| `VITE_SUPABASE_ANON_KEY` | Supabase Dashboard → Project Settings → API → anon / public key |

> **Why `VITE_` prefix?** Vite only exposes env vars prefixed with `VITE_` to the client bundle. The secrets are injected during the GitHub Actions build step and baked into the static files — they never exist in your repository.

### Step 3 — Push to main

```bash
git add .
git commit -m "initial deploy"
git push origin main
```

The workflow in `.github/workflows/azure-static-web-apps.yml` runs automatically. It:
1. Installs dependencies
2. Builds with your secrets injected as env vars
3. Uploads `dist/` to Azure Static Web Apps

Monitor progress in your repo's **Actions** tab.

---

## Adding Content

All course content is stored in Supabase. No code changes needed to add new material.

### Add a new module to an existing course

```sql
-- 1. Insert the module
INSERT INTO modules (course_id, number, title, subtitle, duration, sort_order)
SELECT id, '08', 'Your New Module Title', 'Subtitle here', '45 min', 8
FROM courses WHERE slug = 'nist-800-53';

-- 2. Add sections (types: text, callout, list, control-example, families-preview, families-full)
INSERT INTO sections (module_id, type, heading, content, sort_order)
SELECT m.id, 'text', 'Section Heading', 'Section body text goes here.', 1
FROM modules m JOIN courses c ON m.course_id = c.id
WHERE c.slug = 'nist-800-53' AND m.number = '08';

-- 3. Add quiz questions
INSERT INTO quiz_questions (module_id, question, explanation, sort_order)
SELECT m.id, 'Your question text?', 'Explanation shown after answering.', 1
FROM modules m JOIN courses c ON m.course_id = c.id
WHERE c.slug = 'nist-800-53' AND m.number = '08';

-- 4. Add options (one row per option, is_correct = true for the right one)
INSERT INTO quiz_options (question_id, text, is_correct, sort_order)
SELECT q.id, opt.text, opt.correct, opt.ord
FROM quiz_questions q
JOIN modules m ON q.module_id = m.id
JOIN courses c ON m.course_id = c.id
CROSS JOIN (VALUES
  (1, 'Wrong answer', false),
  (2, 'Correct answer', true),
  (3, 'Wrong answer', false),
  (4, 'Wrong answer', false)
) AS opt(ord, text, correct)
WHERE c.slug = 'nist-800-53' AND m.number = '08' AND q.sort_order = 1;
```

### Add a new course

```sql
-- 1. Create the course (locked = true until ready)
INSERT INTO courses (slug, title, subtitle, tag, level, duration, prereq, description, locked, sort_order)
VALUES ('your-course-slug', 'Course Title', 'Subtitle', 'Tag Label', 'Intermediate', '4–5 hrs', 'Prereq here', 'Description.', true, 5);

-- 2. Add modules, sections, and quiz questions as above
-- 3. Set locked = false when ready to publish:
UPDATE courses SET locked = false WHERE slug = 'your-course-slug';
```

### Section types reference

| Type | Required fields | Notes |
|---|---|---|
| `text` | `heading`, `content` | Standard prose block |
| `callout` | `heading`, `content`, `label` | Highlighted box (PRO TIP, CRITICAL, etc.) |
| `list` | `heading` + rows in `section_items` | Numbered list |
| `control-example` | `heading`, `content`, `control_id`, `control_name` | Monospace control block |
| `families-preview` | `heading` | Renders first 6 NIST families (static) |
| `families-full` | `heading` | Renders all 20 NIST families (static) |

---

## Project Structure

```
nist-800-53-study/
├── .github/
│   └── workflows/
│       └── azure-static-web-apps.yml   # CI/CD pipeline
├── public/
│   ├── favicon.svg
│   └── staticwebapp.config.json        # Azure SWA routing + security headers
├── src/
│   ├── components/
│   │   ├── ContentSection.jsx          # Lesson content block renderer
│   │   ├── CourseView.jsx              # Module list for a course
│   │   ├── HomeView.jsx                # Course catalogue
│   │   ├── LessonView.jsx              # Module lesson reader
│   │   ├── QuizView.jsx                # Quiz with shuffled answers
│   │   ├── SetupScreen.jsx             # Shown when env vars are missing
│   │   └── ui.jsx                      # Shared: Badge, ProgressBar
│   ├── App.jsx                         # Root component + navigation state
│   ├── constants.js                    # Colors, fonts, NIST families reference
│   ├── main.jsx                        # React entry point
│   └── supabaseClient.js               # Supabase fetch + data assembly
├── .env.example                        # Template for local env vars
├── .gitignore
├── index.html
├── nist-supabase-setup.sql             # Schema + seed data (run once)
├── package.json
├── README.md
└── vite.config.js
```

---

## Security Notes

- **Supabase anon key** is safe to expose in the browser — it only allows what your Row Level Security (RLS) policies permit. For a read-only public app, this is fine. If you add user accounts or sensitive data, enable RLS policies on each table.
- **Secrets are never in the repo.** The `.env.local` file is git-ignored. GitHub Secrets are injected at build time only.
- **Security headers** are set in `staticwebapp.config.json`: `X-Frame-Options`, `X-Content-Type-Options`, and `Referrer-Policy`.

---

## License

MIT
