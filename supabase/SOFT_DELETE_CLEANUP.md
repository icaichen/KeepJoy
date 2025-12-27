# 软删除自动清理系统

## 概述

这个系统会自动清理超过30天的软删除记录，包括：
- memories（记忆）
- declutter_items（整理物品）
- deep_cleaning_sessions（深度清理会话）
- resell_items（转卖物品）
- planned_sessions（计划会话）

**清理策略**：
- ⏰ 每天凌晨2点（UTC时间）自动运行
- 🗑️ 删除`deleted_at`字段超过30天的记录
- 📊 记录每次清理删除的记录数量

## 部署步骤

### 方法1：通过Supabase Dashboard（推荐）

#### 步骤1：启用pg_cron扩展

1. 打开 Supabase Dashboard
2. 进入你的KeepJoy项目
3. 点击左侧菜单 **Database** > **Extensions**
4. 搜索 `pg_cron`
5. 点击右侧开关启用

#### 步骤2：运行Migration SQL

1. 点击左侧菜单 **SQL Editor**
2. 点击 **New Query**
3. 复制粘贴文件内容：`supabase/migrations/20231227000000_soft_delete_cleanup.sql`
4. 点击 **Run** 运行

如果看到错误"extension pg_cron does not exist"，返回步骤1先启用扩展。

#### 步骤3：验证部署

运行以下SQL检查定时任务：

```sql
-- 查看已安排的任务
SELECT * FROM cron.job;
```

你应该看到一个名为 `clean-soft-deleted-records` 的任务。

### 方法2：通过Supabase CLI

```bash
# 1. 确保已link到项目
supabase link --project-ref YOUR_PROJECT_REF

# 2. 推送migration
supabase db push

# 3. 验证
supabase db execute "SELECT * FROM cron.job;"
```

## 测试

### 手动运行清理

在Supabase SQL Editor中运行：

```sql
SELECT * FROM clean_soft_deleted_records();
```

这会返回每个表删除的记录数：

```
table_name              | deleted_count
------------------------+--------------
memories                | 5
declutter_items         | 12
deep_cleaning_sessions  | 3
resell_items           | 8
planned_sessions       | 2
```

### 查看执行历史

```sql
-- 查看最近10次运行记录
SELECT * FROM cron.job_run_details
ORDER BY start_time DESC
LIMIT 10;
```

## 管理

### 暂停自动清理

```sql
SELECT cron.unschedule('clean-soft-deleted-records');
```

### 恢复自动清理

```sql
SELECT cron.schedule(
  'clean-soft-deleted-records',
  '0 2 * * *',
  $$SELECT * FROM clean_soft_deleted_records()$$
);
```

### 修改清理周期

如果你想改成60天或90天：

1. 打开 SQL Editor
2. 修改函数定义：

```sql
CREATE OR REPLACE FUNCTION clean_soft_deleted_records()
...
  -- 修改这一行，把30改成你想要的天数
  cutoff_date := NOW() - INTERVAL '60 days';  -- 改成60天
...
```

### 修改运行时间

```sql
-- 删除旧任务
SELECT cron.unschedule('clean-soft-deleted-records');

-- 创建新任务（例如每天凌晨4点）
SELECT cron.schedule(
  'clean-soft-deleted-records',
  '0 4 * * *',  -- 4 AM UTC
  $$SELECT * FROM clean_soft_deleted_records()$$
);
```

## 监控

### 设置通知（可选）

你可以在Supabase Dashboard中设置数据库日志通知：

1. 进入 **Settings** > **Integrations**
2. 配置Slack/Email通知
3. 当清理运行时会收到通知

### 检查清理效果

```sql
-- 查看当前有多少软删除记录等待清理
SELECT
  'memories' as table_name,
  COUNT(*) as pending_deletion
FROM memories
WHERE deleted_at IS NOT NULL
  AND deleted_at > NOW() - INTERVAL '30 days'

UNION ALL

SELECT
  'declutter_items',
  COUNT(*)
FROM declutter_items
WHERE deleted_at IS NOT NULL
  AND deleted_at > NOW() - INTERVAL '30 days'

-- ... (可以为每个表添加类似查询)
```

## 注意事项

⚠️ **重要提醒**：

1. **不可恢复**：清理后的记录无法恢复，确保30天足够用户反悔
2. **照片清理**：这个SQL只删除数据库记录，不会自动删除Supabase Storage中的照片
   - 照片已在账户删除时通过`auth_service.dart`清理
   - 或者你可以添加Storage清理逻辑
3. **免费计划限制**：Supabase免费计划对pg_cron可能有限制
   - 如果遇到问题，可以改用Edge Function + HTTP定时触发
4. **时区**：定时任务使用UTC时间，注意时区转换

## 故障排除

### 错误："extension pg_cron does not exist"

**解决方案**：在Dashboard > Database > Extensions中启用pg_cron

### 错误："permission denied"

**解决方案**：这个函数使用`SECURITY DEFINER`，应该可以正常运行。如果仍有问题，检查数据库角色权限。

### 定时任务没有运行

**检查步骤**：

1. 确认任务已创建：`SELECT * FROM cron.job;`
2. 查看错误日志：`SELECT * FROM cron.job_run_details WHERE status = 'failed';`
3. 手动测试函数：`SELECT * FROM clean_soft_deleted_records();`

### 想要立即清理所有软删除记录

```sql
-- 修改cutoff_date为未来日期
CREATE OR REPLACE FUNCTION clean_all_soft_deleted_records()
RETURNS TABLE (table_name TEXT, deleted_count INTEGER)
LANGUAGE plpgsql AS $$
DECLARE
  cutoff_date TIMESTAMP := NOW() + INTERVAL '1 day';  -- 所有记录
  -- ... (rest of function)
$$;

-- 运行一次
SELECT * FROM clean_all_soft_deleted_records();
```

## 相关文件

- Migration SQL: `supabase/migrations/20231227000000_soft_delete_cleanup.sql`
- 软删除逻辑: `lib/services/hive_service.dart`
- 数据仓库: `lib/services/data_repository.dart`

## 下一步

部署成功后：

1. ✅ 检查`cron.job`表确认任务已创建
2. ✅ 手动运行一次测试
3. ✅ 等待第一次自动运行（第二天凌晨2点UTC）
4. ✅ 检查`cron.job_run_details`确认执行成功

---

**部署日期**: _待填写_
**部署者**: _待填写_
**首次运行时间**: _待填写_
