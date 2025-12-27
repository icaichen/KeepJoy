# Edge Functions 部署指南

## 账户删除功能所需的Edge Function

账户删除功能需要部署`delete-user` Edge Function，因为删除Supabase Auth用户需要service_role权限，客户端无法直接调用。

## 前置要求

1. 安装Supabase CLI
```bash
brew install supabase/tap/supabase
```

2. 登录Supabase
```bash
supabase login
```

## 部署步骤

### 方法1：部署到Supabase Cloud（推荐）

```bash
# 1. 确保你已经link到你的Supabase项目
supabase link --project-ref YOUR_PROJECT_REF

# 2. 部署delete-user函数
supabase functions deploy delete-user

# 3. 验证部署
supabase functions list
```

### 方法2：本地测试

```bash
# 1. 启动本地Supabase
supabase start

# 2. 在本地serve函数
supabase functions serve delete-user --env-file supabase/.env.local

# 3. 测试函数
curl -i --location --request POST 'http://localhost:54321/functions/v1/delete-user' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"userId":"test-user-id"}'
```

## 环境变量

Edge Function会自动获取以下环境变量（由Supabase提供）：
- `SUPABASE_URL` - 你的Supabase项目URL
- `SUPABASE_ANON_KEY` - 匿名公钥
- `SUPABASE_SERVICE_ROLE_KEY` - 服务角色密钥（仅在服务端可用）

无需手动配置。

## 验证部署成功

部署后，在Supabase Dashboard中：
1. 进入 **Edge Functions** 页面
2. 确认看到 `delete-user` 函数
3. 查看函数日志，确保没有错误

## App中的调用

部署完成后，你的Flutter app中的账户删除功能会自动工作：

```dart
// lib/services/auth_service.dart:358-385
await client!.functions.invoke(
  'delete-user',
  body: {'userId': userId},
  headers: {'Authorization': 'Bearer $accessToken'},
);
```

## 故障排除

### 错误: "function not found"
- 确认函数已部署: `supabase functions list`
- 重新部署: `supabase functions deploy delete-user`

### 错误: "service_role key not found"
- 这是Supabase自动提供的，无需手动配置
- 确保在Supabase Cloud上部署（本地测试需要`supabase start`）

### 权限错误
- Edge Function会验证请求用户只能删除自己的账户
- 确保传递了正确的Authorization header

## 安全说明

✅ **安全特性**：
1. 需要用户的access token（用户必须已登录）
2. 验证请求用户ID与要删除的用户ID一致
3. service_role key只在服务端使用，不暴露给客户端

## 相关文件

- Edge Function代码: `supabase/functions/delete-user/index.ts`
- 调用代码: `lib/services/auth_service.dart`
- Supabase配置: `supabase/config.toml`
