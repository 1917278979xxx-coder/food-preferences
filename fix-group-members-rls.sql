-- ==========================================
-- 诊断 + 修复 group_members INSERT RLS 策略
-- 请在 Supabase SQL Editor 中运行
-- ==========================================

-- 第一步：诊断 — 查看 group_members 上现有的策略
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'group_members';

-- 第二步：查看 get_my_group_ids 函数是否存在
SELECT proname, prosrc FROM pg_proc WHERE proname = 'get_my_group_ids';

-- 第三步：修复 — 安全重建 group_members 的 INSERT 策略
DROP POLICY IF EXISTS "group_members_insert" ON public.group_members;
CREATE POLICY "group_members_insert" ON public.group_members
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 第四步：确认策略已创建
SELECT policyname, cmd, with_check
FROM pg_policies
WHERE tablename = 'group_members' AND cmd = 'INSERT';

-- 第五步（可选）：如果以上仍不生效，检查 RLS 是否真的开启了
SELECT tablename, rowsecurity FROM pg_tables
WHERE tablename = 'group_members' AND schemaname = 'public';
