-- ==========================================
-- 美食偏好管理 - 小组功能完整数据库迁移
-- 包含所有修复（递归 RLS + 邀请码查找）
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

-- 6) 安全函数（避免 RLS 递归）
create or replace function public.get_my_group_ids()
returns setof uuid
language sql
security definer
set search_path = ''
as $$
  select group_id from public.group_members where user_id = auth.uid();
$$;

-- 7) groups RLS 策略
create policy "groups_select" on public.groups for select using (
  auth.uid() = created_by or id in (select public.get_my_group_ids())
);
-- 额外：允许所有人查找邀请码
create policy "groups_find_by_invite" on public.groups for select using (true);
create policy "groups_insert" on public.groups for insert with check (auth.uid() = created_by);
create policy "groups_update" on public.groups for update using (auth.uid() = created_by);
create policy "groups_delete" on public.groups for delete using (auth.uid() = created_by);

-- 8) group_members RLS 策略
create policy "group_members_select" on public.group_members for select using (
  auth.uid() = user_id or group_id in (select public.get_my_group_ids())
);
create policy "group_members_insert" on public.group_members for insert with check (auth.uid() = user_id);
create policy "group_members_delete" on public.group_members for delete using (auth.uid() = user_id);

-- 9) edit_logs RLS 策略
create policy "edit_logs_select" on public.edit_logs for select using (
  auth.uid() = user_id or group_id in (select public.get_my_group_ids())
);
create policy "edit_logs_insert" on public.edit_logs for insert with check (auth.uid() = user_id);

-- 10) 更新 friends RLS（增加小组访问）
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

-- 11) 更新 food_items RLS（增加小组访问）
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
