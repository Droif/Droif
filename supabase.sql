-- GraphFlow: ตารางเดียวเก็บข้อมูลทั้งทีม
-- วิธีใช้: Supabase Dashboard → SQL Editor → New query → วางทั้งไฟล์ → Run

create table if not exists public.gf_items (
  kind       text        not null check (kind in ('members','tasks','broadcasts','activityLog')),
  id         text        not null,
  data       jsonb       not null,
  updated_at timestamptz not null default now(),
  primary key (kind, id)
);

-- แอปยังไม่มีระบบ login จริง ทุกคนที่มีลิงก์จึงอ่าน/เขียนได้ (anon)
alter table public.gf_items enable row level security;

drop policy if exists "gf read"   on public.gf_items;
drop policy if exists "gf insert" on public.gf_items;
drop policy if exists "gf update" on public.gf_items;
drop policy if exists "gf delete" on public.gf_items;

create policy "gf read"   on public.gf_items for select to anon using (true);
create policy "gf insert" on public.gf_items for insert to anon with check (true);
create policy "gf update" on public.gf_items for update to anon using (true) with check (true);
create policy "gf delete" on public.gf_items for delete to anon using (true);

-- เปิด Realtime ให้มือถือทุกเครื่องเห็นการเปลี่ยนแปลงทันที
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'gf_items'
  ) then
    alter publication supabase_realtime add table public.gf_items;
  end if;
end $$;
