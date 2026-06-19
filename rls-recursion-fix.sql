-- ==========================================
-- 修复 group_members RLS 无限递归
-- 在 Supabase SQL Editor 中执行:
-- https://supabase.com/dashboard/project/mbkdigtofgmdkepwsrve
-- ==========================================

-- 1) 创建安全函数（绕过 RLS，避免递归）
create or replace function public.get_my_group_ids()
returns setof uuid
language sql
security definer
set search_path = ''
as $$
  select group_id from public.group_members where user_id = auth.uid();
$$;

-- 2) 删除有问题的 group_members 策略
drop policy if exists "View members of own groups" on public.group_members;
drop policy if exists "Users can join groups" on public.group_members;
drop policy if exists "Users can leave groups" on public.group_members;

-- 3) 重建 group_members 策略（用安全函数避免递归）
create policy "View members of own groups" on public.group_members for select using (
  group_id in (select public.get_my_group_ids())
);
create policy "Users can join groups" on public.group_members for insert with check (auth.uid() = user_id);
create policy "Users can leave groups" on public.group_members for delete using (auth.uid() = user_id);

-- 4) 同样修复 groups 表的策略（也可能有递归）
drop policy if exists "Members can view their groups" on public.groups;

create policy "Members can view their groups" on public.groups for select using (
  id in (select public.get_my_group_ids())
);
