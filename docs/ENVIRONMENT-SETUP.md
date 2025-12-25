# 环境配置规划与实现指南

## 📋 配置清单

### 必需的 GitHub Secrets

在将此项目推送到 GitHub 后，需要在仓库中配置以下 Secrets。

```
仓库 → Settings → Secrets and variables → Actions → New repository secret
```

#### Azure 认证 Secrets（必需）

| Secret 名称 | 类型 | 获取方法 | 优先级 |
|-------------|------|--------|--------|
| `AZURE_SUBSCRIPTION_ID` | UUID | `az account show --query id -o tsv` | 🔴 必需 |
| `AZURE_TENANT_ID` | UUID | Service Principal 信息 | 🔴 必需 |
| `AZURE_CLIENT_ID` | UUID | Service Principal 信息 | 🔴 必需 |
| `AZURE_CLIENT_SECRET` | 密钥 | Service Principal 信息 | 🔴 必需 |

#### Tencent Cloud Secrets（可选，仅当使用 Tencent DNS 时需要）

| Secret 名称 | 类型 | 获取方法 | 优先级 |
|-------------|------|--------|--------|
| `TENCENT_SECRET_ID` | API Key | Tencent Cloud Console | 🟡 可选 |
| `TENCENT_SECRET_KEY` | API Key | Tencent Cloud Console | 🟡 可选 |

#### 通知 Secrets（可选）

| Secret 名称 | 类型 | 获取方法 | 优先级 |
|-------------|------|--------|--------|
| `SLACK_WEBHOOK` | URL | Slack App | 🟡 可选 |

---

## 🔧 分步配置指南

### 第 1 步：创建 Azure Service Principal

```bash
# 1. 登录 Azure
az login

# 2. 获取订阅 ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Subscription ID: $SUBSCRIPTION_ID"

# 3. 创建 Service Principal
az ad sp create-for-rbac \
  --name "github-terraform-sp" \
  --role Contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID \
  --sdk-auth
```

**保存输出内容：**
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

### 第 2 步：添加 Azure Secrets 到 GitHub

1. 进入 GitHub 仓库 → **Settings**
2. 左侧菜单 → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**
4. 分别添加以下 Secrets：

**Secret 1: AZURE_SUBSCRIPTION_ID**
- Name: `AZURE_SUBSCRIPTION_ID`
- Value: `subscriptionId` 的值

**Secret 2: AZURE_TENANT_ID**
- Name: `AZURE_TENANT_ID`
- Value: `tenantId` 的值

**Secret 3: AZURE_CLIENT_ID**
- Name: `AZURE_CLIENT_ID`
- Value: `clientId` 的值

**Secret 4: AZURE_CLIENT_SECRET**
- Name: `AZURE_CLIENT_SECRET`
- Value: `clientSecret` 的值

### 第 3 步：（可选）添加 Tencent Cloud Secrets

如果使用 Tencent DNS 功能：

1. 登录 [Tencent Cloud Console](https://console.cloud.tencent.com/)
2. 进入 **访问管理** → **API 密钥管理**
3. 获取 SecretId 和 SecretKey
4. 在 GitHub 中添加 Secrets：
   - Name: `TENCENT_SECRET_ID`, Value: `SecretId`
   - Name: `TENCENT_SECRET_KEY`, Value: `SecretKey`

### 第 4 步：（可选）添加 Slack Webhook

如果要启用 Slack 通知：

1. 进入 [Slack App 目录](https://api.slack.com/apps)
2. 创建新应用或选择现有应用
3. 启用 **Incoming Webhooks**
4. 创建新的 Webhook，选择通知频道
5. 复制 Webhook URL
6. 在 GitHub 中添加 Secret：
   - Name: `SLACK_WEBHOOK`, Value: `Webhook URL`

---

## 📦 Terraform 环境配置

### 现有环境文件

| 文件 | 用途 | 触发条件 |
|------|------|--------|
| `env/dev.tfvars` | 开发环境 | PR 或手动触发 |
| `env/prod.tfvars` | 生产环境 | 主分支 Push 或手动触发 |
| `env/dns_test.tfvars` | DNS 测试 | 手动触发 |

### 环境变量说明

#### 开发环境 (`dev.tfvars`)

```hcl
resource_group_name = "rg-frontdoor-dev"
location            = "eastus"
afd_profile_name    = "afdprofile-dev"
domain_name         = "hrdev.gslb.vip"
subscription_id     = "00000000-0000-0000-0000-000000000000"
dns_domain          = "gslb.vip"
dns_subdomain       = "hrdev"
tencent_secret_id   = "your-tencent-secret-id"
tencent_secret_key  = "your-tencent-secret-key"
```

**修改说明：**
1. 将 `subscription_id` 替换为实际的 Azure 订阅 ID
2. 将 `domain_name` 更新为你的实际域名
3. 如使用 Tencent DNS，更新 Tencent 凭证

#### 生产环境 (`prod.tfvars`)

```hcl
resource_group_name = "rg-frontdoor-prod"
location            = "eastus"
afd_profile_name    = "afdprofile-prod"
domain_name         = "www.gslb.vip"
subscription_id     = "00000000-0000-0000-0000-000000000000"
dns_domain          = "gslb.vip"
dns_subdomain       = "www"
tencent_secret_id   = "your-tencent-secret-id"
tencent_secret_key  = "your-tencent-secret-key"
```

**修改说明：**
1. 将 `subscription_id` 替换为实际的 Azure 订阅 ID
2. 确保域名与生产环境一致
3. 生产环境应该使用不同的资源组和名称

---

## 🚀 工作流执行流程

### 流程图

```
┌─────────────────────────────────────────────────────────────────┐
│                     GitHub Actions 工作流                        │
└─────────────────────────────────────────────────────────────────┘

1️⃣  Modify Terraform Configuration
    │
    ├─ Edit .tf files or env/ files
    └─ Make changes to infrastructure

2️⃣  Push to GitHub
    │
    ├─ git add .
    ├─ git commit -m "message"
    ├─ git push origin main
    └─ 🔵 Terraform Plan 工作流自动运行

3️⃣  Review Plan Output
    │
    ├─ Check Actions tab for plan details
    ├─ Review the infrastructure changes
    └─ Verify plan is correct

4️⃣  Manual Trigger Apply (手动)
    │
    ├─ Go to Actions → Terraform Apply
    ├─ Click "Run workflow"
    ├─ Select environment (dev/prod)
    └─ 🟢 Terraform Apply 工作流手动运行

5️⃣  Resources Created/Updated
    │
    ├─ Azure resources deployed
    ├─ Outputs displayed in Actions tab
    └─ ✅ Deployment complete
```
    └─ 📧 Slack notification (if configured)
```

### 手动触发工作流

#### 手动运行 Plan

```
Actions → Terraform Plan → Run workflow → Select branch → Run
```

#### 手动运行 Apply

```
Actions → Terraform Apply → Run workflow
  → Select environment (dev/prod)
  → Run workflow
```

#### 销毁资源（谨慎！）

```
Actions → Terraform Destroy → Run workflow
  → Select environment (dev/prod)
  → Input confirmation "destroy"
  → Run workflow
```

---

## ✅ 验证清单

在推送到 GitHub 前，确保完成以下操作：

- [ ] `.gitignore` 已创建，包含敏感文件规则
- [ ] `*.tfvars` 中的敏感信息已替换为占位符
- [ ] `terraform.tfstate*` 文件已删除
- [ ] `.terraform/` 目录已删除
- [ ] GitHub Secrets 已配置（至少 Azure 4 个）
- [ ] Terraform 配置在本地已验证：`terraform validate`
- [ ] 仓库分支保护规则已启用
- [ ] 代码审查要求已设置

---

## 📊 监控和日志

### 查看工作流执行

1. 进入仓库 → **Actions** 标签页
2. 选择工作流查看执行历史
3. 点击特定运行查看详细日志

### 常见日志位置

```
Actions tab
  ├─ Terraform Plan 日志
  ├─ Terraform Apply 日志
  └─ Terraform Destroy 日志
```

### 调试技巧

- 启用 `TFDEBUG: true` 获取更详细的日志
- 查看 `terraform plan` 输出了解将做的变更
- 检查环境变量是否正确传递
- 验证 Secrets 是否在工作流中可见

---

## 🔒 安全建议

### 权限最小化

创建 Service Principal 时，仅赋予必要权限：

```bash
# 仅赋予特定资源组的权限
az ad sp create-for-rbac \
  --name "github-terraform-sp" \
  --role Contributor \
  --scopes /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}
```

### 定期轮换凭证

- 每 90 天轮换一次 Service Principal 密钥
- 立即更新 GitHub Secrets
- 删除旧凭证

### 启用审计日志

- 启用 GitHub 仓库的审计日志
- 监控 Secrets 的访问情况
- 设置异常活动告警

### 分支保护

在 GitHub 仓库设置中启用：
- ✅ Require pull request reviews before merging
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- ✅ Dismiss stale pull request approvals

---

## 📚 相关资源

- [Azure 认证文档](https://learn.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)
- [GitHub Secrets 文档](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub Actions 文档](https://docs.github.com/en/actions)

---

## 🆘 常见问题

### Q: 如果 Secrets 过期了怎么办？

A: 
1. 重新创建 Service Principal
2. 更新 GitHub Secrets
3. 运行新的 workflow

### Q: 可以手动修改 Azure 资源吗？

A: 不建议。Terraform 状态会不同步。建议通过 Git 和工作流管理所有变更。

### Q: 如何恢复之前的资源版本？

A: 
1. 在 Git 历史中找到之前的提交
2. Revert 到该提交
3. Push 到 main，工作流会自动同步资源

### Q: 工作流运行失败了怎么办？

A: 
1. 查看 Actions 日志找出错误
2. 在本地使用相同环境变量重现问题
3. 修复问题并重新提交
