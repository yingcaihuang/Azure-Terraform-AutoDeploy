# Azure Login 配置指南

## 概述

GitHub Actions 工作流现已集成 `azure/login` action，用于安全地向 Azure 进行身份验证。这比使用单独的环境变量更加安全和可靠。

## 什么是 AZURE_CREDENTIALS？

`AZURE_CREDENTIALS` 是一个 JSON 格式的 secret，包含 Azure 服务主体的完整凭证信息。格式如下：

```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret",
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id"
}
```

## 生成 AZURE_CREDENTIALS

### 方法 1：使用 Azure CLI（推荐）

如果你已安装 Azure CLI，可以使用以下命令生成凭证 JSON：

```bash
az ad sp create-for-rbac --name "github-actions-sp" --role Contributor --scopes /subscriptions/<subscription-id> --json-auth
```

**注意**：将 `<subscription-id>` 替换为你的实际 Azure 订阅 ID。

输出示例：
```json
{
  "clientId": "1234abcd-5678-efgh-9012-ijklmnopqrst",
  "clientSecret": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
  "subscriptionId": "abcd1234-5678-efgh-9012-ijklmnopqrst",
  "tenantId": "9876abcd-5432-zyxw-vuts-rqponmlkjihg"
}
```

### 方法 2：使用 Azure 门户

1. 登录 [Azure 门户](https://portal.azure.com)
2. 导航到 **Azure Active Directory** → **应用注册**
3. 点击 **新建注册**
4. 输入应用名称（如 "github-actions-sp"）
5. 点击 **注册**
6. 在应用页面获取：
   - **Application (client) ID** → `clientId`
   - **Directory (tenant) ID** → `tenantId`
7. 导航到 **证书和密码** → **客户端密码**
8. 点击 **新客户端密码**
9. 复制密码值 → `clientSecret`
10. 获取你的订阅 ID → `subscriptionId`

## 在 GitHub 中配置 Secret

### 步骤 1：准备 JSON

将凭证信息整理成单行 JSON：

```json
{"clientId": "1234abcd-5678-efgh-9012-ijklmnopqrst", "clientSecret": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6", "subscriptionId": "abcd1234-5678-efgh-9012-ijklmnopqrst", "tenantId": "9876abcd-5432-zyxw-vuts-rqponmlkjihg"}
```

### 步骤 2：添加到 GitHub Secrets

1. 进入你的 GitHub 仓库
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**
4. 填写以下信息：
   - **Name**: `AZURE_CREDENTIALS`
   - **Value**: 粘贴上面的 JSON（单行格式）
5. 点击 **Add secret**

## 配置流程图

```
┌─────────────────────────────────────────┐
│  GitHub Actions 工作流启动               │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Checkout 代码                          │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  azure/login                            │
│  使用 AZURE_CREDENTIALS secret          │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Azure 登录成功                         │
│  环境变量自动设置：                     │
│  - AZURE_SUBSCRIPTION_ID               │
│  - AZURE_TENANT_ID                     │
│  - AZURE_CLIENT_ID                     │
│  - AZURE_CLIENT_SECRET                 │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Terraform 初始化和部署                 │
│  自动使用 Azure 凭证                    │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  任务完成                               │
└─────────────────────────────────────────┘
```

## 工作流中的 azure/login 配置

所有三个工作流（Plan、Apply、Destroy）都已配置了 `azure/login@v2`：

```yaml
- name: Azure Login
  uses: azure/login@v2
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}

- name: Verify Azure Credentials
  uses: azure/cli@v2
  with:
    azcliversion: latest
    inlineScript: |
      echo "✅ Azure Login Successful"
      az account show --query '{subscriptionId: id, subscriptionName: name}' -o table
```

这一步会：
1. 使用 `AZURE_CREDENTIALS` secret
2. 向 Azure 进行身份验证
3. 为后续步骤设置 Azure 环境
4. 使用 `azure/cli@v2` 验证登录成功
5. Terraform 会自动使用这些凭证

### azure/login@v2 vs azure/login@v1

| 功能 | v1 | v2 |
|------|-----|-----|
| 基础认证 | ✅ | ✅ |
| PowerShell 支持 | ✅ | ✅（可选） |
| 长期支持 | ⚠️ 维护中 | ✅ 推荐 |
| 性能 | 标准 | ⚡ 优化 |
| 安全性 | 良好 | ✅ 更新 |

**建议**：使用 `@v2` 获得最新的安全更新和性能改进。

## 验证 Azure 登录

可以在工作流中添加验证步骤：

```yaml
- name: Verify Azure Login
  uses: azure/cli@v2
  with:
    azcliversion: latest
    inlineScript: |
      echo "✅ Azure Authentication Successful"
      echo ""
      echo "Current Account:"
      az account show --query '{subscriptionId: id, name: name}' -o table
      
      echo ""
      echo "Available Resource Groups:"
      az group list --query '[].{name: name, location: location}' -o table -o tsv | head -10
```

### 输出示例

```
✅ Azure Authentication Successful

Current Account:
SubscriptionId                        Name
────────────────────────────────────  ──────────────────
abcd1234-5678-efgh-9012-ijklmnopqrst  My Azure Sub

Available Resource Groups:
rg-dev      eastus
rg-prod     eastus
rg-staging  westus
```

### azure/cli@v2 Action 参数

```yaml
- name: Run Azure CLI Commands
  uses: azure/cli@v2
  with:
    azcliversion: latest           # Azure CLI 版本（latest/specific version）
    inlineScript: |                # 要执行的 bash 脚本
      # 你的 Azure CLI 命令
    releasedVersion: true          # 使用已发布的版本
    environment: AzureCloud        # Azure 环境（默认）
```

**常用场景**：
- 验证 Azure 连接
- 检查资源状态
- 执行 Azure 管理任务
- 获取部署信息
- 配置 Azure 服务

👉 详细用法参考：[AZURE-CLI-GITHUB-ACTIONS.md](AZURE-CLI-GITHUB-ACTIONS.md)

## 故障排查

### 错误："AZURE_CREDENTIALS not found"

**原因**：Secret 未在 GitHub 中配置

**解决方案**：
1. 进入 **Settings** → **Secrets and variables** → **Actions**
2. 确认 `AZURE_CREDENTIALS` secret 存在
3. 如果不存在，按照上面的步骤创建

### 错误："Invalid JSON in creds"

**原因**：JSON 格式不正确

**解决方案**：
1. 验证 JSON 是否为有效格式
2. 检查是否使用了单行格式
3. 确认所有必需字段都存在

### 错误："Unable to authenticate"

**原因**：凭证已过期或权限不足

**解决方案**：
1. 重新生成服务主体凭证
2. 确保服务主体有足够权限
3. 更新 GitHub Secret

## 最佳实践

### 安全

✅ 使用 service principal（服务主体）而不是个人账户
✅ 定期轮换服务主体密钥
✅ 限制服务主体的 Azure 角色范围
✅ 使用 Contributor 角色或更细粒度的权限
✅ 定期审计工作流日志

### 权限

推荐为服务主体分配的权限：

```bash
# 仅在特定资源组
az role assignment create \
  --assignee <client-id> \
  --role Contributor \
  --resource-group <resource-group-name>

# 或仅在特定订阅
az role assignment create \
  --assignee <client-id> \
  --role Contributor \
  --scope /subscriptions/<subscription-id>
```

## 相关环境变量

`azure/login` action 会自动设置以下环境变量，Terraform 会自动使用：

| 环境变量 | 值 |
|---------|-----|
| `AZURE_SUBSCRIPTION_ID` | 你的订阅 ID |
| `AZURE_TENANT_ID` | 你的租户 ID |
| `AZURE_CLIENT_ID` | 服务主体的客户端 ID |
| `AZURE_CLIENT_SECRET` | 服务主体的客户端密码 |

无需在工作流中手动设置这些变量！

## 其他必需 Secrets

除了 `AZURE_CREDENTIALS` 外，还可能需要配置：

### 可选 - Tencent 云凭证（如果使用 DNS 功能）

```
TENCENT_SECRET_ID: your-tencent-secret-id
TENCENT_SECRET_KEY: your-tencent-secret-key
```

### 可选 - Slack 通知

```
SLACK_WEBHOOK: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

## 测试 Azure 登录

推送代码后，GitHub Actions 会自动运行工作流。你可以：

1. 进入 GitHub → **Actions**
2. 选择最新的 **Terraform Plan** 运行
3. 展开 **Azure Login** 步骤
4. 验证是否成功
5. 检查日志中没有身份验证错误

## 下一步

1. ✅ 生成 `AZURE_CREDENTIALS` JSON
2. ✅ 配置 GitHub Secret
3. ✅ 配置其他必需 Secrets（Tencent、Slack）
4. ✅ 推送工作流更新到 GitHub
5. ✅ 验证工作流成功运行

## 参考资源

- [Azure Login GitHub Action](https://github.com/Azure/login)
- [Azure Service Principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

---

**上次更新**：2025 年 12 月 25 日
