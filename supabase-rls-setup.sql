-- ==========================================
-- 美食偏好管理 - 多用户数据隔离 SQL
-- 在 Supabase SQL Editor 中执行:
-- https://supabase.com/dashboard/project/mbkdigtofgmdkepwsrve
-- ==========================================

-- 1) 给两个表加 user_id 列
alter table public.friends add column if not exists user_id uuid references auth.users(id) on delete cascade;
alter table public.food_items add column if not exists user_id uuid references auth.users(id) on delete cascade;

-- 2) 开启 RLS
alter table public.friends enable row level security;
alter table public.food_items enable row level security;

-- 3) friends RLS 策略
create policy "Users can view own friends" on public.friends for select using (auth.uid() = user_id);
create policy "Users can insert own friends" on public.friends for insert with check (auth.uid() = user_id);
create policy "Users can update own friends" on public.friends for update using (auth.uid() = user_id);
create policy "Users can delete own friends" on public.friends for delete using (auth.uid() = user_id);

-- 4) food_items RLS 策略
create policy "Users can view own food_items" on public.food_items for select using (auth.uid() = user_id);
create policy "Users can insert own food_items" on public.food_items for insert with check (auth.uid() = user_id);
create policy "Users can update own food_items" on public.food_items for update using (auth.uid() = user_id);
create policy "Users can delete own food_items" on public.food_items for delete using (auth.uid() = user_id);
