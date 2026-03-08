-- ============================================================
-- NIST 800-53 Study App — Supabase Schema & Seed Data
-- Run this in your Supabase SQL Editor
-- ============================================================

-- ============================================================
-- SCHEMA
-- ============================================================

create table if not exists courses (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text not null,
  subtitle text,
  tag text,
  level text,
  duration text,
  prereq text,
  description text,
  locked boolean default false,
  sort_order int default 0,
  created_at timestamptz default now()
);

create table if not exists modules (
  id uuid primary key default gen_random_uuid(),
  course_id uuid references courses(id) on delete cascade not null,
  number text not null,
  title text not null,
  subtitle text,
  duration text,
  sort_order int default 0
);

create table if not exists sections (
  id uuid primary key default gen_random_uuid(),
  module_id uuid references modules(id) on delete cascade not null,
  -- types: text | callout | list | control-example | families-preview | families-full
  type text not null,
  heading text,
  content text,
  label text,          -- callout label (e.g. 'PRO TIP')
  control_id text,     -- for control-example type
  control_name text,   -- for control-example type
  sort_order int default 0
);

create table if not exists section_items (
  id uuid primary key default gen_random_uuid(),
  section_id uuid references sections(id) on delete cascade not null,
  content text not null,
  sort_order int default 0
);

create table if not exists quiz_questions (
  id uuid primary key default gen_random_uuid(),
  module_id uuid references modules(id) on delete cascade not null,
  question text not null,
  explanation text,
  sort_order int default 0
);

create table if not exists quiz_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid references quiz_questions(id) on delete cascade not null,
  text text not null,
  is_correct boolean default false,
  sort_order int default 0
);

-- ============================================================
-- ROW LEVEL SECURITY (optional — enable if needed)
-- ============================================================
-- alter table courses enable row level security;
-- create policy "Public read" on courses for select using (true);
-- (repeat for other tables)

-- ============================================================
-- SEED DATA
-- ============================================================

-- Courses
insert into courses (slug, title, subtitle, tag, level, duration, prereq, description, locked, sort_order) values
('nist-800-53',  'NIST SP 800-53 Rev 5',    'Security and Privacy Controls',     'Core Curriculum', 'Intermediate', '6–8 hrs',  'NIST CSF familiarity',     'A practitioner-focused course on implementing and assessing NIST 800-53 Rev 5 controls. Built for GRC professionals already familiar with the CSF framework.',  false, 1),
('csf-advanced', 'NIST CSF 2.0 Advanced',   'Governance and Tiers in Depth',     'Coming Soon',     'Intermediate', '4–5 hrs',  null,                       'A deep dive into the new Govern function, implementation tiers, and organizational profiles. Covers building and using profiles for gap analysis.',            true,  2),
('cti-fundamentals','Cyber Threat Intelligence','From Feeds to Finished Intel',  'Coming Soon',     'Intermediate', '5–6 hrs',  null,                       'The intelligence cycle applied to cybersecurity. ATT&CK, STIX/TAXII, pivot analysis, and producing actionable finished intelligence products.',               true,  3),
('fedramp',      'FedRAMP Authorization',    'CSPs, AOs, and the Auth Path',      'Coming Soon',     'Advanced',     '6–8 hrs',  null,                       'How FedRAMP works, the Rev 5 transition, continuous monitoring requirements, and common authorization failures.',                                            true,  4);

-- ============================================================
-- MODULE 01 — From CSF to 800-53
-- ============================================================

insert into modules (course_id, number, title, subtitle, duration, sort_order)
select id, '01', 'From CSF to 800-53', 'Bridging the frameworks', '45 min', 1
from courses where slug = 'nist-800-53';

-- Sections for Module 01
insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'Two Different Questions',
$cnt$NIST CSF answers "what should we do?" NIST SP 800-53 answers "how do we do it?" If you're already comfortable with the CSF's five functions—Identify, Protect, Detect, Respond, Recover—you already have the conceptual scaffolding for 800-53. The difference is resolution. The CSF gives you categories and subcategories. 800-53 gives you 1,000+ specific controls with implementation guidance, assessment procedures, and defined parameters.$cnt$,
1
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '01';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'The RMF Connection',
$cnt$800-53 lives inside the Risk Management Framework (RMF). Step 3 (Select) is where you pick your controls from 800-53. Step 4 (Implement) is where you put them in place. Step 5 (Assess) is where you prove they work. Most federal agencies and many regulated industries follow the RMF, making 800-53 the de facto control catalog for serious compliance programs.$cnt$,
2
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '01';

insert into sections (module_id, type, heading, content, label, sort_order)
select m.id, 'callout', 'CSF ↔ 800-53 Mapping',
$cnt$NIST publishes an official crosswalk between CSF 2.0 subcategories and 800-53 controls. Every CSF subcategory maps to one or more 800-53 controls. For example, CSF GV.OC-01 maps to PM-1, PM-11, PM-18, and SA-2. This mapping is your best tool when a client asks how 800-53 relates to their existing CSF work. Find it at csrc.nist.gov/Projects/olir.$cnt$,
'PRO TIP', 3
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '01';

insert into sections (module_id, type, heading, sort_order)
select m.id, 'list', 'What Changed in Rev 5', 4
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '01';

insert into section_items (section_id, content, sort_order)
select s.id, item.content, item.ord
from sections s
join modules m on s.module_id = m.id
join courses c on m.course_id = c.id
cross join (values
  (1, 'Controls are now outcome-based—they apply to any entity, not just federal agencies'),
  (2, 'Two new families: PT (PII Processing & Transparency) and SR (Supply Chain Risk Management)'),
  (3, 'Privacy controls fully integrated (previously in a separate appendix)'),
  (4, 'Removed prescriptive federal-only language throughout'),
  (5, 'Program Management (PM) family elevated and significantly expanded'),
  (6, 'Control enhancements numbered separately for cleaner referencing')
) as item(ord, content)
where c.slug = 'nist-800-53' and m.number = '01' and s.type = 'list' and s.sort_order = 4;

insert into sections (module_id, type, heading, sort_order)
select m.id, 'families-preview', 'Control Families at a Glance', 5
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '01';

-- Quiz for Module 01
insert into quiz_questions (module_id, question, explanation, sort_order)
select m.id, 'What is the primary difference between NIST CSF and NIST 800-53?',
'The CSF provides high-level outcomes and categories. 800-53 provides the specific, detailed controls that help achieve those outcomes. They''re complementary, not competing.',
1
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '01';

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q
join modules m on q.module_id = m.id
join courses c on m.course_id = c.id
cross join (values
  (1, 'CSF is for federal agencies; 800-53 is for private companies', false),
  (2, 'CSF defines what to achieve; 800-53 specifies how to achieve it', true),
  (3, '800-53 is newer and replaces the CSF', false),
  (4, 'CSF covers technical controls; 800-53 covers administrative controls', false)
) as opt(ord, text, correct)
where c.slug = 'nist-800-53' and m.number = '01' and q.sort_order = 1;

insert into quiz_questions (module_id, question, explanation, sort_order)
select m.id, 'Which step of the RMF involves selecting controls from NIST 800-53?',
'Step 3 (Select) is where you choose appropriate 800-53 controls based on system categorization and any applicable overlays.',
2
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '01';

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q
join modules m on q.module_id = m.id
join courses c on m.course_id = c.id
cross join (values
  (1, 'Step 1 – Prepare', false),
  (2, 'Step 2 – Categorize', false),
  (3, 'Step 3 – Select', true),
  (4, 'Step 4 – Implement', false)
) as opt(ord, text, correct)
where c.slug = 'nist-800-53' and m.number = '01' and q.sort_order = 2;

insert into quiz_questions (module_id, question, explanation, sort_order)
select m.id, 'Which two control families are NEW in Rev 5?',
'PT (PII Processing and Transparency) and SR (Supply Chain Risk Management) are the two new families. PT integrates privacy controls previously in a separate appendix.',
3
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '01';

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q
join modules m on q.module_id = m.id
join courses c on m.course_id = c.id
cross join (values
  (1, 'SA and SR', false),
  (2, 'PT and SR', true),
  (3, 'PM and PT', false),
  (4, 'CM and IR', false)
) as opt(ord, text, correct)
where c.slug = 'nist-800-53' and m.number = '01' and q.sort_order = 3;

-- ============================================================
-- MODULE 02 — Anatomy of a Control
-- ============================================================

insert into modules (course_id, number, title, subtitle, duration, sort_order)
select id, '02', 'Anatomy of a Control', 'Reading and parsing controls correctly', '40 min', 2
from courses where slug = 'nist-800-53';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'Control Structure',
$cnt$Every 800-53 control follows a consistent structure. The control identifier (e.g., AC-2) tells you the family (Access Control) and sequence number. The control statement is the actual requirement—what the organization or system must do. The Discussion section provides context, rationale, and implementation considerations (this replaced "Supplemental Guidance" from Rev 4). Related Controls point to dependencies and complements.$cnt$,
1
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '02';

insert into sections (module_id, type, heading, content, control_id, control_name, sort_order)
select m.id, 'control-example', 'Reading a Real Control',
$cnt$a. Define and document the types of accounts allowed for use within the system
b. Assign account managers for information system accounts
c. Require [Assignment: organization-defined prerequisites] for group and role membership
d. Specify authorized users of the system, group and role membership, and access authorizations
e. Require approvals for account creation
f. Create, enable, modify, disable, and remove accounts per organization policy
g. Monitor use of system accounts
h. Notify account managers within [Assignment: time period] when accounts are no longer required or user transfers/terminates$cnt$,
'AC-2', 'ACCOUNT MANAGEMENT', 2
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '02';

insert into sections (module_id, type, heading, content, label, sort_order)
select m.id, 'callout', 'Organization-Defined Parameters (ODPs)',
$cnt$The brackets in control statements are ODPs—places where you must fill in organization-specific values. For AC-2, you define account types, time periods, and approval roles. ODPs are what auditors check first. If your SSP doesn''t document ODP values, the control is effectively unimplemented in their eyes.$cnt$,
'CRITICAL', 3
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '02';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'Control Enhancements',
$cnt$Enhancements are numbered extensions to a base control: AC-2(1), AC-2(2), etc. They add capability or specificity. Enhancements appear in higher baselines (Moderate, High) when the base control alone isn''t sufficient. AC-2(1) requires automated account management. AC-2(7) requires role-based scheme management for privileged users. When scoping, you''re deciding which enhancements apply.$cnt$,
4
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '02';

insert into sections (module_id, type, heading, sort_order)
select m.id, 'list', 'The Five Control Components', 5
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '02';

insert into section_items (section_id, content, sort_order)
select s.id, item.content, item.ord
from sections s
join modules m on s.module_id = m.id
join courses c on m.course_id = c.id
cross join (values
  (1, 'Control Statement: The actual requirement (what must be done)'),
  (2, 'Discussion: Intent, rationale, and implementation context'),
  (3, 'Related Controls: Dependencies and complements in other families'),
  (4, 'Control Enhancements: Stronger versions of the base control'),
  (5, 'References: Relevant NIST publications and external standards')
) as item(ord, content)
where c.slug = 'nist-800-53' and m.number = '02' and s.type = 'list' and s.sort_order = 5;

-- Quiz for Module 02
insert into quiz_questions (module_id, question, explanation, sort_order)
select m.id, q.question, q.explanation, q.ord
from modules m join courses c on m.course_id = c.id
cross join (values
  (1, 'What does "ODP" stand for in 800-53 controls?', 'ODPs are the bracketed fields where organizations specify their own values—account types, time periods, roles, thresholds. Documented ODP values are what assessors look for in the SSP.'),
  (2, 'Control AC-2(7) is an example of what?', 'The parenthetical number (7) indicates this is the 7th enhancement to base control AC-2. Enhancements add specificity and typically appear in Moderate or High baselines.'),
  (3, 'Where in a Rev 5 control do you find implementation guidance and rationale?', 'The Discussion section (formerly "Supplemental Guidance" in Rev 4) provides implementation context and rationale. The control statement is the requirement itself.')
) as q(ord, question, explanation)
where c.slug = 'nist-800-53' and m.number = '02';

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values
  (1, 'Organizational Data Policy', false),
  (2, 'Organization-Defined Parameter', true),
  (3, 'Operational Deployment Procedure', false),
  (4, 'Output Definition Protocol', false)
) as opt(ord, text, correct)
where c.slug = 'nist-800-53' and m.number = '02' and q.sort_order = 1;

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values
  (1, 'A base control', false),
  (2, 'A control enhancement', true),
  (3, 'An ODP value', false),
  (4, 'A control overlay', false)
) as opt(ord, text, correct)
where c.slug = 'nist-800-53' and m.number = '02' and q.sort_order = 2;

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values
  (1, 'The control statement', false),
  (2, 'The control identifier', false),
  (3, 'The Discussion section', true),
  (4, 'The Related Controls section', false)
) as opt(ord, text, correct)
where c.slug = 'nist-800-53' and m.number = '02' and q.sort_order = 3;

-- ============================================================
-- MODULE 03 — The 20 Control Families
-- ============================================================

insert into modules (course_id, number, title, subtitle, duration, sort_order)
select id, '03', 'The 20 Control Families', 'Full catalog overview', '60 min', 3
from courses where slug = 'nist-800-53';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'Why 20 Families',
$cnt$Rev 5 has 20 control families, up from 18 in Rev 4. The families are organized alphabetically by two-letter identifier. Knowing what lives in each family lets you quickly locate relevant controls during assessments. Ask yourself for any security requirement: "which family does this logically belong to?" and you''ll narrow it down fast.$cnt$,
1
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '03';

insert into sections (module_id, type, heading, sort_order)
select m.id, 'families-full', 'All 20 Families', 2
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '03';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'The Five Highest-Volume Families',
$cnt$AC, IA, SI, CM, and AU tend to have the most controls and generate the most findings. AC covers account management through remote access. IA covers authentication including phishing-resistant MFA. SI is patch management, malware protection, and monitoring. CM is configuration baselines and change control. AU is your logging and audit trail. Master these five and you''ll handle 60% of most assessments.$cnt$,
3
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '03';

insert into sections (module_id, type, heading, content, label, sort_order)
select m.id, 'callout', 'The Two New Families',
$cnt$PT (PII Processing and Transparency) integrates privacy controls previously scattered across an appendix. Key controls: PT-2 (Authority to Process PII), PT-5 (Privacy Notice), PT-7 (Specific Categories of PII). SR (Supply Chain Risk Management) was elevated due to growing third-party risks. SR-3 (Supply Chain Controls and Plans), SR-11 (Component Authenticity), and SR-12 (Component Disposal) are worth knowing in depth.$cnt$,
'REV 5 FOCUS', 4
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '03';

-- Quiz for Module 03
insert into quiz_questions (module_id, question, explanation, sort_order)
select m.id, q.question, q.explanation, q.ord
from modules m join courses c on m.course_id = c.id
cross join (values
  (1, 'How many control families are in NIST 800-53 Rev 5?', 'Rev 5 has 20 control families. Rev 4 had 18; the additions are PT (PII Processing & Transparency) and SR (Supply Chain Risk Management).'),
  (2, 'Which control family contains patch management requirements?', 'SI-2 (Flaw Remediation) is the patch management control. CM covers configuration baselines and change control, but flaw remediation is in SI.'),
  (3, 'The SR family was added in Rev 5 to address what growing concern?', 'SR was elevated to address increased risks from third-party software, hardware, and service providers—especially following high-profile supply chain attacks.')
) as q(ord, question, explanation)
where c.slug = 'nist-800-53' and m.number = '03';

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values (1,'16',false),(2,'18',false),(3,'20',true),(4,'22',false)) as opt(ord,text,correct)
where c.slug = 'nist-800-53' and m.number = '03' and q.sort_order = 1;

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values
  (1,'CM – Configuration Management',false),
  (2,'SI – System and Information Integrity',true),
  (3,'SA – System and Services Acquisition',false),
  (4,'RA – Risk Assessment',false)
) as opt(ord,text,correct)
where c.slug = 'nist-800-53' and m.number = '03' and q.sort_order = 2;

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values
  (1,'Social engineering attacks',false),
  (2,'Cloud computing risks',false),
  (3,'Supply chain threats from third-party components',true),
  (4,'Insider threat programs',false)
) as opt(ord,text,correct)
where c.slug = 'nist-800-53' and m.number = '03' and q.sort_order = 3;

-- ============================================================
-- MODULE 04 — Baselines and Tailoring
-- ============================================================

insert into modules (course_id, number, title, subtitle, duration, sort_order)
select id, '04', 'Baselines and Tailoring', 'Selecting the right controls for your system', '55 min', 4
from courses where slug = 'nist-800-53';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'The Three Baselines',
$cnt$800-53 provides three control baselines: Low, Moderate, and High. The baseline depends on your system''s impact level, determined through FIPS 199 categorization. Low-impact systems have limited adverse effects if compromised. Moderate systems have serious adverse effects. High-impact systems—critical infrastructure, national security—have severe or catastrophic consequences if confidentiality, integrity, or availability fails.$cnt$,
1
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '04';

insert into sections (module_id, type, heading, content, label, sort_order)
select m.id, 'callout', 'FIPS 199: The Gateway to Baseline Selection',
$cnt$Before picking a baseline, categorize the system using FIPS 199. Assess three security objectives—Confidentiality, Integrity, and Availability—each rated Low, Moderate, or High. The overall system categorization is the high-water mark: if any objective is High, the system is High-impact. This drives your entire control selection.$cnt$,
'KEY CONCEPT', 2
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '04';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'The Tailoring Process',
$cnt$You rarely implement a baseline exactly as-is. Tailoring lets you adjust through four mechanisms: (1) Scoping—removing controls that genuinely don''t apply based on technology or operational requirements. (2) Parameterization—filling in ODPs with organization-specific values. (3) Compensating controls—substituting alternative controls when standard ones aren''t feasible. (4) Overlays—adding controls for specific technologies or sectors (FedRAMP, CMMC, HIPAA). Document every tailoring decision. Assessors will ask why you excluded anything.$cnt$,
3
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '04';

insert into sections (module_id, type, heading, sort_order)
select m.id, 'list', 'Tailoring Considerations', 4
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '04';

insert into section_items (section_id, content, sort_order)
select s.id, item.content, item.ord
from sections s join modules m on s.module_id = m.id join courses c on m.course_id = c.id
cross join (values
  (1,'Common controls: Inherited from shared infrastructure (a shared SIEM) don''t need re-implementation at system level'),
  (2,'Applicability: Wireless controls don''t apply to an air-gapped system—document the scoping decision'),
  (3,'Technology overlays: NIST publishes overlays for cloud (SP 800-210), IoT, and industrial control systems'),
  (4,'Sector overlays: FedRAMP, CMMC, and HIPAA Security Rule each map to 800-53 with specific tailoring'),
  (5,'High-water mark rule: System categorization equals the highest individual C-I-A rating')
) as item(ord, content)
where c.slug = 'nist-800-53' and m.number = '04' and s.type = 'list' and s.sort_order = 4;

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'Inherited vs System-Specific Controls',
$cnt$Common controls (inherited controls) are implemented at the organization level and shared across multiple systems. Physical security (PE family) is often common—managed by facilities, not individual system teams. Identifying common controls early reduces duplicated effort and clarifies ownership. The SSP must still document inherited controls—just indicate the provider and reference their implementation.$cnt$,
5
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '04';

-- Quiz for Module 04
insert into quiz_questions (module_id, question, explanation, sort_order)
select m.id, q.question, q.explanation, q.ord
from modules m join courses c on m.course_id = c.id
cross join (values
  (1,'What publication determines a system''s impact level before selecting a baseline?','FIPS 199 (Standards for Security Categorization) is used to categorize systems as Low, Moderate, or High. NIST SP 800-60 provides guidance on mapping information types to impact levels.'),
  (2,'A system has Confidentiality=Low, Integrity=Moderate, Availability=High. What is its overall impact level?','The high-water mark rule applies: the overall categorization equals the highest individual rating. Availability=High means the system is categorized as High-impact.'),
  (3,'What is the term for removing a control from your baseline because it genuinely doesn''t apply?','Scoping allows exclusion of controls that aren''t applicable based on technology, environment, or operational requirements. Every scoping decision must be documented and justified in the SSP.')
) as q(ord, question, explanation)
where c.slug = 'nist-800-53' and m.number = '04';

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values (1,'NIST SP 800-37',false),(2,'FIPS 200',false),(3,'FIPS 199',true),(4,'NIST SP 800-60',false)) as opt(ord,text,correct)
where c.slug = 'nist-800-53' and m.number = '04' and q.sort_order = 1;

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values (1,'Low',false),(2,'Moderate',false),(3,'High',true),(4,'It averages to Moderate',false)) as opt(ord,text,correct)
where c.slug = 'nist-800-53' and m.number = '04' and q.sort_order = 2;

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values (1,'Parameterization',false),(2,'Compensating control',false),(3,'Scoping',true),(4,'Overlay',false)) as opt(ord,text,correct)
where c.slug = 'nist-800-53' and m.number = '04' and q.sort_order = 3;

-- ============================================================
-- MODULE 05 — High-Priority Families
-- ============================================================

insert into modules (course_id, number, title, subtitle, duration, sort_order)
select id, '05', 'High-Priority Families', 'AC, IA, SI, IR — the controls that matter most', '70 min', 5
from courses where slug = 'nist-800-53';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'Access Control (AC)',
$cnt$AC is the largest family by control count and generates more findings than almost any other. Key controls: AC-2 (Account Management)—defines account types, requires automated provisioning/deprovisioning, and periodic review. AC-3 (Access Enforcement)—technical enforcement via RBAC or ABAC. AC-6 (Least Privilege)—authorize only what''s necessary; AC-6(5) requires privileged accounts used only for privileged functions. AC-17 (Remote Access)—authorization, encryption, and monitoring for all remote sessions.$cnt$,
1
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '05';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'Identification & Authentication (IA)',
$cnt$IA is where MFA and identity assurance live. IA-2 is the lynchpin—multi-factor authentication for privileged and (at Moderate/High) non-privileged accounts. IA-2(1) specifies MFA for privileged local and network access. IA-5 (Authenticator Management) governs password complexity, rotation, and storage. IA-8 addresses federation and authenticator assurance levels aligned with NIST SP 800-63.$cnt$,
2
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '05';

insert into sections (module_id, type, heading, content, label, sort_order)
select m.id, 'callout', 'IA-2(6): Phishing-Resistant MFA',
$cnt$IA-2(6) requires phishing-resistant MFA (FIDO2/WebAuthn or PIV/CAC) for privileged accounts. SMS and TOTP are not phishing-resistant and no longer satisfy this control at High baseline. If your org still uses TOTP for admin accounts on a High-impact system, that''s a finding.$cnt$,
'REV 5 CHANGE', 3
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '05';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'System & Information Integrity (SI)',
$cnt$SI covers controls that keep systems clean. SI-2 (Flaw Remediation)—patch management; requires identifying and remediating flaws in defined timeframes. SI-3 (Malicious Code Protection)—anti-malware requirements. SI-4 (System Monitoring)—where your SIEM and SOC tooling gets documented. SI-7 (Software and Firmware Integrity)—integrity verification, code signing, and supply chain integrity.$cnt$,
4
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '05';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'Incident Response (IR)',
$cnt$IR defines how you detect, respond to, and recover. IR-4 (Incident Handling)—covering preparation, detection, containment, eradication, and recovery. IR-5 (Incident Monitoring)—tracks and documents incidents. IR-6 (Incident Reporting)—specifies reporting timelines to organizational officials. IR-8 (Incident Response Plan)—documented, maintained, and tested. IR-10 (Integrated Information Security Analysis Team)—new in Rev 5; cross-functional team for coordinated response.$cnt$,
5
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '05';

insert into sections (module_id, type, heading, sort_order)
select m.id, 'list', 'Most Common Findings in These Four Families', 6
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '05';

insert into section_items (section_id, content, sort_order)
select s.id, item.content, item.ord
from sections s join modules m on s.module_id = m.id join courses c on m.course_id = c.id
cross join (values
  (1,'AC-2: No automated deprovisioning; no documented periodic account reviews'),
  (2,'AC-6: Admin accounts used for day-to-day tasks (least privilege violation)'),
  (3,'IA-2: MFA not enforced for all privileged access; TOTP used on High baseline systems'),
  (4,'SI-2: Patch windows exceed defined timeframes; no formal flaw remediation tracking'),
  (5,'SI-4: SIEM alerts not reviewed; monitoring coverage gaps on cloud workloads'),
  (6,'IR-8: IRP exists but hasn''t been tested or updated in over 12 months')
) as item(ord, content)
where c.slug = 'nist-800-53' and m.number = '05' and s.type = 'list' and s.sort_order = 6;

-- Quiz for Module 05
insert into quiz_questions (module_id, question, explanation, sort_order)
select m.id, q.question, q.explanation, q.ord
from modules m join courses c on m.course_id = c.id
cross join (values
  (1,'Which AC control requires that privileged accounts only be used for privileged functions?','AC-6(5) specifically restricts privileged accounts to only be used for privileged functions—not for browsing, email, or other day-to-day tasks.'),
  (2,'A High-baseline system uses TOTP for admin accounts. Which Rev 5 control is likely failing?','IA-2(6) requires phishing-resistant MFA (FIDO2 or PIV/CAC) for privileged access at High baseline. TOTP is not phishing-resistant.'),
  (3,'Which SI control governs patch management and flaw remediation?','SI-2 (Flaw Remediation) requires identifying, reporting, correcting, and testing information system flaws within organization-defined time periods.')
) as q(ord, question, explanation)
where c.slug = 'nist-800-53' and m.number = '05';

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values (1,'AC-2',false),(2,'AC-3',false),(3,'AC-6(5)',true),(4,'AC-17',false)) as opt(ord,text,correct)
where c.slug = 'nist-800-53' and m.number = '05' and q.sort_order = 1;

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values (1,'IA-2',false),(2,'IA-2(1)',false),(3,'IA-2(6)',true),(4,'IA-5',false)) as opt(ord,text,correct)
where c.slug = 'nist-800-53' and m.number = '05' and q.sort_order = 2;

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values (1,'SI-1',false),(2,'SI-2',true),(3,'SI-3',false),(4,'SI-4',false)) as opt(ord,text,correct)
where c.slug = 'nist-800-53' and m.number = '05' and q.sort_order = 3;

-- ============================================================
-- MODULE 06 — Assessment & Authorization
-- ============================================================

insert into modules (course_id, number, title, subtitle, duration, sort_order)
select id, '06', 'Assessment & Authorization', 'The A&A process from a controls perspective', '50 min', 6
from courses where slug = 'nist-800-53';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'The CA Family',
$cnt$CA (Assessment, Authorization, and Monitoring) governs the authorization process itself. CA-2 (Control Assessments)—requires assessing controls at defined frequencies using 800-53A procedures. CA-3 (Information Exchange)—system interconnection agreements. CA-5 (POA&M)—the plan of action and milestones for tracking findings. CA-6 (Authorization)—the ATO itself. CA-7 (Continuous Monitoring)—arguably the most important CA control for modern programs.$cnt$,
1
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '06';

insert into sections (module_id, type, heading, content, label, sort_order)
select m.id, 'callout', 'Writing a Good SSP',
$cnt$PL-2 requires a documented SSP. Each control section needs: implementation status, how it''s implemented, responsible parties, and ODP values. Vague language like "the system uses encryption" will generate findings. Write it as if the assessor has never seen your system—because they haven''t.$cnt$,
'PRACTITIONER NOTE', 2
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '06';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'Assessment vs Authorization',
$cnt$These are separate activities. Assessors test controls against 800-53A procedures and produce a Security Assessment Report (SAR) with findings. The Authorizing Official (AO) reviews the SAR plus the POA&M and decides whether to accept residual risk and grant an ATO. The AO is accepting risk on behalf of the organization—not the ISSO, not the assessor. This distinction matters when explaining findings to leadership.$cnt$,
3
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '06';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'Continuous Monitoring (CA-7)',
$cnt$CA-7 moved authorization from a point-in-time event to an ongoing process. A ConMon program must define assessment frequencies for each control, collect and analyze security metrics, report status to leadership, and feed results back into risk decisions. The goal: situational awareness so the AO can make ongoing authorization decisions rather than waiting years for a full assessment cycle.$cnt$,
4
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '06';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'POA&M Management (CA-5)',
$cnt$The POA&M documents every assessment finding with remediation plans and milestones. A well-managed POA&M is evidence of a mature program. Items open for years with no progress signal dysfunction to AOs and oversight bodies. Risk acceptance entries require AO signature and defined review periods—a POA&M item isn''t a permanent pass.$cnt$,
5
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '06';

-- Quiz for Module 06
insert into quiz_questions (module_id, question, explanation, sort_order)
select m.id, q.question, q.explanation, q.ord
from modules m join courses c on m.course_id = c.id
cross join (values
  (1,'Who formally accepts residual risk and grants an ATO?','The AO formally accepts residual risk on behalf of the organization and grants the Authority to Operate. This is a named individual with accountability for that decision.'),
  (2,'What is the central artifact describing a system''s authorization boundary and control implementations?','The SSP (required by PL-2) is the central authorization package artifact. It describes the system, its boundary, its environment, and how each selected control is implemented.'),
  (3,'CA-7 changed the authorization model from what to what?','CA-7 shifts authorization from a periodic event (every 3 years) to an ongoing program with continuous control monitoring and real-time risk management.')
) as q(ord, question, explanation)
where c.slug = 'nist-800-53' and m.number = '06';

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values
  (1,'The ISSO',false),(2,'The Security Assessor',false),(3,'The Authorizing Official (AO)',true),(4,'The System Owner',false)
) as opt(ord,text,correct)
where c.slug = 'nist-800-53' and m.number = '06' and q.sort_order = 1;

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values
  (1,'Security Assessment Report (SAR)',false),(2,'System Security Plan (SSP)',true),(3,'Plan of Action & Milestones (POA&M)',false),(4,'Security Impact Analysis (SIA)',false)
) as opt(ord,text,correct)
where c.slug = 'nist-800-53' and m.number = '06' and q.sort_order = 2;

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values
  (1,'Manual to automated',false),(2,'Technical to administrative',false),(3,'Point-in-time to ongoing',true),(4,'System-level to enterprise-level',false)
) as opt(ord,text,correct)
where c.slug = 'nist-800-53' and m.number = '06' and q.sort_order = 3;

-- ============================================================
-- MODULE 07 — Practical Implementation
-- ============================================================

insert into modules (course_id, number, title, subtitle, duration, sort_order)
select id, '07', 'Practical Implementation', 'Building a real control program', '60 min', 7
from courses where slug = 'nist-800-53';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'Start With the Boundary',
$cnt$Before selecting or implementing a single control, define your authorization boundary. Everything inside is subject to your control requirements. Everything outside is either inherited or requires CA-3 interconnection agreements. Boundary mistakes—systems accidentally inside or outside—cause more re-work than almost any other scoping decision. Get this right first.$cnt$,
1
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '07';

insert into sections (module_id, type, heading, content, label, sort_order)
select m.id, 'callout', 'A Practical Sequencing Approach',
$cnt$There''s no mandated sequence, but experienced practitioners typically start with: (1) IA and AC—identity and access are foundational prerequisites for other controls. (2) AU—get logging working early; you''ll need it to demonstrate other controls. (3) CM—establish baselines before the system matures. (4) SI—patching and malware protection from day one. Everything else builds on this foundation.$cnt$,
'IMPLEMENTATION ORDER', 2
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '07';

insert into sections (module_id, type, heading, content, sort_order)
select m.id, 'text', 'Evidence Collection',
$cnt$Assessors collect evidence against 800-53A procedures. For each control, three evidence types: Examine (documents, configurations), Interview (personnel), and Test (technical verification). Build evidence packages before assessments rather than scrambling during them. Screenshot configurations, export logs, document procedures. The SRTM (Security Requirements Traceability Matrix) maps controls to evidence locations.$cnt$,
3
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '07';

insert into sections (module_id, type, heading, sort_order)
select m.id, 'list', 'Common Implementation Pitfalls', 4
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '07';

insert into section_items (section_id, content, sort_order)
select s.id, item.content, item.ord
from sections s join modules m on s.module_id = m.id join courses c on m.course_id = c.id
cross join (values
  (1,'Implementing controls in isolation without considering dependencies (AU-9 protects AU-2 log data)'),
  (2,'Documenting planned controls as implemented in the SSP—this is a significant integrity issue'),
  (3,'Using vendor documentation as evidence without testing the actual implementation'),
  (4,'Forgetting cloud shared responsibility—provider controls don''t automatically satisfy your requirements'),
  (5,'Not updating the SSP when the system changes—stale documentation is a finding in itself'),
  (6,'Treating POA&M items as permanent—risk acceptance has a defined expiration, not a permanent pass')
) as item(ord, content)
where c.slug = 'nist-800-53' and m.number = '07' and s.type = 'list' and s.sort_order = 4;

insert into sections (module_id, type, heading, sort_order)
select m.id, 'list', 'Your Study Roadmap from Here', 5
from modules m join courses c on m.course_id = c.id
where c.slug = 'nist-800-53' and m.number = '07';

insert into section_items (section_id, content, sort_order)
select s.id, item.content, item.ord
from sections s join modules m on s.module_id = m.id join courses c on m.course_id = c.id
cross join (values
  (1,'NIST SP 800-53 Rev 5 — full catalog at csrc.nist.gov (also available as a searchable spreadsheet)'),
  (2,'NIST SP 800-53A Rev 5 — the assessment procedures for every control'),
  (3,'FIPS 199 and NIST SP 800-60 — for system categorization practice'),
  (4,'NIST SP 800-37 Rev 2 — the RMF guideline that ties it all together'),
  (5,'NIST NCCoE community — free resources, use cases, and practice guides at nccoe.nist.gov')
) as item(ord, content)
where c.slug = 'nist-800-53' and m.number = '07' and s.type = 'list' and s.sort_order = 5;

-- Quiz for Module 07
insert into quiz_questions (module_id, question, explanation, sort_order)
select m.id, q.question, q.explanation, q.ord
from modules m join courses c on m.course_id = c.id
cross join (values
  (1,'What is the first step before selecting any controls for a new system?','Defining the authorization boundary determines scope. Boundary mistakes cascade into every subsequent RMF activity.'),
  (2,'In 800-53A, what are the three types of assessment methods?','NIST SP 800-53A defines: Examine (documentation, configurations), Interview (personnel), and Test (technical mechanisms). Each control has defined assessment procedures using these methods.'),
  (3,'A cloud provider implements encryption in transit. Does this automatically satisfy your SC-8 requirement?','Cloud shared responsibility means you verify the provider''s implementation actually satisfies your requirements. Check the Customer Responsibility Matrix—even FedRAMP authorized providers have controls you still own.')
) as q(ord, question, explanation)
where c.slug = 'nist-800-53' and m.number = '07';

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values
  (1,'Choose the control baseline',false),(2,'Define the authorization boundary',true),(3,'Select the Authorizing Official',false),(4,'Write the System Security Plan',false)
) as opt(ord,text,correct)
where c.slug = 'nist-800-53' and m.number = '07' and q.sort_order = 1;

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values
  (1,'Review, Test, Verify',false),(2,'Document, Interview, Observe',false),(3,'Examine, Interview, Test',true),(4,'Audit, Scan, Interview',false)
) as opt(ord,text,correct)
where c.slug = 'nist-800-53' and m.number = '07' and q.sort_order = 2;

insert into quiz_options (question_id, text, is_correct, sort_order)
select q.id, opt.text, opt.correct, opt.ord
from quiz_questions q join modules m on q.module_id = m.id join courses c on m.course_id = c.id
cross join (values
  (1,'Yes, if documented in the SSP',false),(2,'Yes, if the provider is FedRAMP authorized',false),(3,'No, you must verify the implementation meets your specific requirements',true),(4,'No, cloud controls never satisfy 800-53',false)
) as opt(ord,text,correct)
where c.slug = 'nist-800-53' and m.number = '07' and q.sort_order = 3;

-- ============================================================
-- ADDING NEW CONTENT GUIDE
-- ============================================================
-- To add a new module to an existing course:
--   1. INSERT into modules (course_id = select from courses where slug = '...')
--   2. INSERT sections referencing the new module
--   3. INSERT section_items for any 'list' sections
--   4. INSERT quiz_questions + quiz_options
--
-- To add a new course:
--   1. INSERT into courses with a new slug and locked = true
--   2. Add modules, sections, questions as above
--   3. Set locked = false when ready to publish
-- ============================================================
