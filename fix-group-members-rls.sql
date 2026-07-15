-- ==========================================
-- 诊断 + 修复 RLS 策略（加入小组 + 添加到我的列表）
-- 请在 Supabase SQL Editor 中运行
-- ==========================================

-- =====================
-- 第一步：诊断现有策略
-- =====================
SELECT '=== group_members policies ===' AS info;
SELECT policyname, cmd, qual, with_check
FROM pg_policies WHERE tablename = 'group_members';

SELECT '=== friends policies ===' AS info;
SELECT policyname, cmd, qual, with_check
FROM pg_policies WHERE tablename = 'friends';

SELECT '=== get_my_group_ids function ===' AS info;
SELECT proname, prosrc FROM pg_proc WHERE proname = 'get_my_group_ids';

-- =====================
-- 第二步：确保安全函数存在
-- =====================
CREATE OR REPLACE FUNCTION public.get_my_group_ids()
RETURNS SETOF uuid
LANGUAGE sql
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT group_id FROM public.group_members WHERE user_id = auth.uid();
$$;

-- =====================
-- 第三步：重建 group_members 策略
-- =====================
-- SELECT（查看小组成员）
DROP POLICY IF EXISTS "group_members_select" ON public.group_members;
CREATE POLICY "group_members_select" ON public.group_members
  FOR SELECT
  USING (
    auth.uid() = user_id
    OR group_id IN (SELECT public.get_my_group_ids())
  );

-- INSERT（加入小组）
DROP POLICY IF EXISTS "group_members_insert" ON public.group_members;
CREATE POLICY "group_members_insert" ON public.group_members
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- DELETE（退出小组）
DROP POLICY IF EXISTS "group_members_delete" ON public.group_members;
CREATE POLICY "group_members_delete" ON public.group_members
  FOR DELETE
  USING (auth.uid() = user_id);

-- =====================
-- 第四步：重建 friends SELECT 策略
-- （依赖 group_members 的 SELECT 策略，必须放在后面）
-- =====================
DROP POLICY IF EXISTS "View own or group friends" ON public.friends;
CREATE POLICY "View own or group friends" ON public.friends
  FOR SELECT
  USING (
    auth.uid() = user_id
    OR (
      group_id IS NOT NULL
      AND auth.uid() IN (
        SELECT gm.user_id FROM public.group_members gm
        WHERE gm.group_id = friends.group_id
      )
    )
  );

-- =====================
-- 第五步：确认修复结果
-- =====================
SELECT '=== After fix: group_members ===' AS info;
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'group_members';

SELECT '=== After fix: friends SELECT ===' AS info;
SELECT policyname, cmd, qual
FROM pg_policies WHERE tablename = 'friends' AND cmd = 'SELECT';

-- =====================
-- 第六步：测试
-- =====================
SELECT '=== Test get_my_group_ids ===' AS info;
SELECT * FROM public.get_my_group_ids();
