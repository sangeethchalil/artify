-- Run once in Supabase: SQL Editor -> New query -> paste -> Run

create table public.site (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz default now()
);

create table public.enquiries (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  name text not null check (char_length(name) <= 100),
  phone text not null check (char_length(phone) <= 25),
  email text check (char_length(email) <= 120),
  message text check (char_length(message) <= 2000),
  painting text,
  status text not null default 'New'
);

create table public.reviews (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  work_id int not null,
  name text not null check (char_length(name) between 1 and 60),
  rating int not null check (rating between 1 and 5),
  text text check (char_length(text) <= 600),
  photo text check (photo is null or (photo like 'data:image/jpeg;base64,%' and char_length(photo) < 60000))
);

alter table public.site enable row level security;
alter table public.enquiries enable row level security;
alter table public.reviews enable row level security;

-- Website content: everyone can read, only the logged-in admin can change
create policy "public read site" on public.site for select to anon, authenticated using (true);
create policy "admin writes site" on public.site for all to authenticated using (true) with check (true);

-- Enquiries: visitors can send, only admin can read/update/delete
create policy "visitors send enquiries" on public.enquiries for insert to anon, authenticated with check (status = 'New');
create policy "admin manages enquiries" on public.enquiries for all to authenticated using (true) with check (true);

-- Reviews: everyone can read and post, only admin can delete
create policy "public read reviews" on public.reviews for select to anon, authenticated using (true);
create policy "visitors post reviews" on public.reviews for insert to anon, authenticated with check (true);
create policy "admin deletes reviews" on public.reviews for delete to authenticated using (true);
