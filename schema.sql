-- Super Oxford Web Version: run this entire file in Supabase SQL Editor.
-- All tables are restricted to signed-in users. Create the admin account in Supabase Authentication first.
create extension if not exists pgcrypto;

create table if not exists public.courses (
 id uuid primary key default gen_random_uuid(), course_name text not null, duration text, fee_amount numeric(12,2), description text, created_at timestamptz not null default now()
);
create table if not exists public.students (
 id uuid primary key default gen_random_uuid(), admission_no text not null unique, full_name text not null, father_name text, mobile text, email text, course_id text, admission_date date, status text default 'Active', created_at timestamptz not null default now()
);
create table if not exists public.fees (
 id uuid primary key default gen_random_uuid(), student_name text not null, admission_no text, amount numeric(12,2) not null, payment_date date, payment_mode text, receipt_no text, remarks text, created_at timestamptz not null default now()
);
create table if not exists public.attendance (
 id uuid primary key default gen_random_uuid(), student_name text not null, admission_no text, attendance_date date not null, status text not null, remarks text, created_at timestamptz not null default now()
);
create table if not exists public.enquiries (
 id uuid primary key default gen_random_uuid(), person_name text not null, mobile text not null, course_interested text, enquiry_date date, status text default 'New', follow_up_date date, notes text, created_at timestamptz not null default now()
);
create table if not exists public.library_books (
 id uuid primary key default gen_random_uuid(), book_title text not null, author text, category text, book_code text, total_copies integer default 0, available_copies integer default 0, created_at timestamptz not null default now()
);
create table if not exists public.exams (
 id uuid primary key default gen_random_uuid(), exam_name text not null, course_name text, exam_date date, total_marks numeric(10,2), passing_marks numeric(10,2), description text, created_at timestamptz not null default now()
);
create table if not exists public.certificates (
 id uuid primary key default gen_random_uuid(), student_name text not null, admission_no text, certificate_no text not null unique, course_name text, issue_date date, status text default 'Pending', created_at timestamptz not null default now()
);
create table if not exists public.staff (
 id uuid primary key default gen_random_uuid(), full_name text not null, mobile text, email text, designation text, joining_date date, salary numeric(12,2), status text default 'Active', created_at timestamptz not null default now()
);
create table if not exists public.transactions (
 id uuid primary key default gen_random_uuid(), entry_type text not null check(entry_type in ('Income','Expense')), category text not null, amount numeric(12,2) not null, entry_date date not null, payment_mode text, description text, created_at timestamptz not null default now()
);
create table if not exists public.tests (
 id uuid primary key default gen_random_uuid(), test_name text not null, course_name text, total_questions integer default 0, duration_minutes integer default 30, is_published boolean default false, max_attempts integer default 1, created_at timestamptz not null default now()
);
create table if not exists public.test_questions (
 id uuid primary key default gen_random_uuid(), test_id text not null, question_text text not null, option_a text, option_b text, option_c text, option_d text, correct_option text not null check(correct_option in ('A','B','C','D')), marks numeric(8,2) default 1, created_at timestamptz not null default now()
);
create table if not exists public.exam_results (
 id uuid primary key default gen_random_uuid(), student_name text not null, admission_no text, exam_name text, marks_obtained numeric(10,2), total_marks numeric(10,2), result_date date, created_at timestamptz not null default now()
);

-- Enable Row Level Security and allow authenticated admins to manage institute records.
do $$ declare t text; begin
 foreach t in array array['courses','students','fees','attendance','enquiries','library_books','exams','certificates','staff','transactions','tests','test_questions','exam_results'] loop
  execute format('alter table public.%I enable row level security',t);
  execute format('drop policy if exists "Authenticated users manage %I" on public.%I',t,t);
  execute format('create policy "Authenticated users manage %I" on public.%I for all to authenticated using (true) with check (true)',t,t);
 end loop;
end $$;
