-- LearnSphere starter schema for Supabase SQL Editor.
-- Review and test policies before inviting real users, especially minors.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  preferred_language text not null default 'English',
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
create policy "Users can read own profile" on public.profiles for select using (auth.uid() = id);
create policy "Users can insert own profile" on public.profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

create table if not exists public.resources (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 180),
  description text,
  subject text not null default 'Uncategorised',
  storage_path text not null,
  mime_type text,
  size_bytes bigint not null default 0 check (size_bytes >= 0 and size_bytes <= 10485760),
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  created_at timestamptz not null default now()
);
alter table public.resources enable row level security;
create policy "Approved resources are readable" on public.resources for select using (status = 'approved' or auth.uid() = owner_id);
create policy "Users submit own resources for review" on public.resources for insert with check (auth.uid() = owner_id and status = 'pending');
create policy "Owners can update own pending resources" on public.resources for update using (auth.uid() = owner_id and status = 'pending') with check (auth.uid() = owner_id and status = 'pending');
create policy "Owners can delete own resources" on public.resources for delete using (auth.uid() = owner_id);

create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 5 and 200),
  body text not null check (char_length(body) between 5 and 5000),
  subject text not null default 'General',
  status text not null default 'pending' check (status in ('pending','published','hidden')),
  created_at timestamptz not null default now()
);
alter table public.questions enable row level security;
create policy "Published questions readable, owners see own" on public.questions for select using (status = 'published' or auth.uid() = owner_id);
create policy "Signed-in users submit pending questions" on public.questions for insert with check (auth.uid() = owner_id and status = 'pending');
create policy "Owners can delete own questions" on public.questions for delete using (auth.uid() = owner_id);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.questions(id) on delete cascade,
  owner_id uuid not null references auth.users(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 3000),
  status text not null default 'pending' check (status in ('pending','published','hidden')),
  created_at timestamptz not null default now()
);
alter table public.comments enable row level security;
create policy "Published comments readable, owners see own" on public.comments for select using (status = 'published' or auth.uid() = owner_id);
create policy "Signed-in users submit pending comments" on public.comments for insert with check (auth.uid() = owner_id and status = 'pending');
create policy "Owners can delete own comments" on public.comments for delete using (auth.uid() = owner_id);

create table if not exists public.saved_resources (
  user_id uuid not null references auth.users(id) on delete cascade,
  resource_id uuid not null references public.resources(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(user_id, resource_id)
);
alter table public.saved_resources enable row level security;
create policy "Users manage own saved resources" on public.saved_resources for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Create a private storage bucket named student-notes with a 10 MB limit.
-- Storage object policies restrict each user's folder to their own auth UID.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('student-notes','student-notes',false,10485760,
  array['application/pdf','text/plain','image/png','image/jpeg','application/msword','application/vnd.openxmlformats-officedocument.wordprocessingml.document','application/vnd.ms-powerpoint','application/vnd.openxmlformats-officedocument.presentationml.presentation'])
on conflict (id) do nothing;

create policy "Users upload into own folder" on storage.objects for insert to authenticated
with check (bucket_id = 'student-notes' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "Users read own stored files" on storage.objects for select to authenticated
using (bucket_id = 'student-notes' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "Users delete own stored files" on storage.objects for delete to authenticated
using (bucket_id = 'student-notes' and (storage.foldername(name))[1] = auth.uid()::text);

-- Moderation: submissions default to pending. Only a trusted admin should approve
-- content using the Supabase dashboard or a separately secured admin tool.
