-- ==========================================
-- 美食偏好管理 - 小组功能数据库迁移
-- 在 Supabase SQL Editor 中执行:
-- https://supabase.com/dashboard/project/mbkdigtofgmdkepwsrve
-- ==========================================

-- 1) 新建 groups 表
create table if not exists public.groups (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  invite_code text not null unique,
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz default now()
);

-- 2) 新建 group_members 表
create table if not exists public.group_members (
  id uuid default gen_random_uuid() primary key,
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','member')),
  nickname text,
  joined_at timestamptz default now(),
  unique(group_id, user_id)
);

-- 3) 新建 edit_logs 表
create table if not exists public.edit_logs (
  id uuid default gen_random_uuid() primary key,
  action text not null check (action in ('add','delete')),
  food_name text not null,
  category text not null check (category in ('likes','dislikes','allergies')),
  friend_id uuid references public.friends(id) on delete cascade,
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  performed_at timestamptz default now()
);

-- 4) 修改现有表加 group_id
alter table public.friends add column if not exists group_id uuid references public.groups(id) on delete set null;
alter table public.food_items add column if not exists group_id uuid references public.groups(id) on delete set null;

-- 5) 开启 RLS
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.edit_logs enable row level security;

-- 6) groups RLS 策略
create policy "Members can view their groups" on public.groups for select using (
  auth.uid() in (select user_id from public.group_members where group_id = id)
);
create policy "Users can create groups" on public.groups for insert with check (auth.uid() = created_by);
create policy "Owner can update group" on public.groups for update using (auth.uid() = created_by);
create policy "Owner can delete group" on public.groups for delete using (auth.uid() = created_by);

-- 7) group_members RLS 策略
create policy "View members of own groups" on public.group_members for select using (
  auth.uid() in (select user_id from public.group_members gm where gm.group_id = group_id)
);
create policy "Users can join groups" on public.group_members for insert with check (auth.uid() = user_id);
create policy "Users can leave groups" on public.group_members for delete using (auth.uid() = user_id);

-- 8) edit_logs RLS 策略
create policy "Members can view edit logs" on public.edit_logs for select using (
  auth.uid() in (select user_id from public.group_members where group_id = edit_logs.group_id)
);
create policy "Members can insert edit logs" on public.edit_logs for insert with check (
  auth.uid() = user_id
);

-- 9) 更新 friends RLS（增加小组访问）
drop policy if exists "Users can view own friends" on public.friends;
drop policy if exists "Users can insert own friends" on public.friends;
drop policy if exists "Users can update own friends" on public.friends;
drop policy if exists "Users can delete own friends" on public.friends;

create policy "View own or group friends" on public.friends for select using (
  auth.uid() = user_id or (group_id is not null and auth.uid() in (
    select user_id from public.group_members where group_id = friends.group_id
  ))
);
create policy "Insert own friends" on public.friends for insert with check (auth.uid() = user_id);
create policy "Update own or group friends" on public.friends for update using (
  auth.uid() = user_id or (group_id is not null and auth.uid() in (
    select user_id from public.group_members where group_id = friends.group_id
  ))
);
create policy "Delete own friends" on public.friends for delete using (auth.uid() = user_id);

-- 10) 更新 food_items RLS（增加小组访问）
drop policy if exists "Users can view own food_items" on public.food_items;
drop policy if exists "Users can insert own food_items" on public.food_items;
drop policy if exists "Users can update own food_items" on public.food_items;
drop policy if exists "Users can delete own food_items" on public.food_items;

create policy "View own or group food_items" on public.food_items for select using (
  auth.uid() = user_id or auth.uid() in (
    select gm.user_id from public.group_members gm
    join public.friends f on f.group_id = gm.group_id
    where f.id = food_items.friend_id
  )
);
create policy "Insert food_items" on public.food_items for insert with check (auth.uid() = user_id);
create policy "Update own or group food_items" on public.food_items for update using (
  auth.uid() = user_id or auth.uid() in (
    select gm.user_id from public.group_members gm
    join public.friends f on f.group_id = gm.group_id
    where f.id = food_items.friend_id
  )
);
create policy "Delete own or group food_items" on public.food_items for delete using (
  auth.uid() = user_id or auth.uid() in (
    select gm.user_id from public.group_members gm
    join public.friends f on f.group_id = gm.group_id
    where f.id = food_items.friend_id
  )
);
