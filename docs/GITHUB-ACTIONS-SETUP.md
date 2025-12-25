# GitHub Actions - Secrets 配置指南

## 概述

GitHub Actions 工作流需要以下敏感信息作为 **Repository Secrets** 进行配置。这些敏感信息不应该被提交到版本控制中。

## 必需的 Secrets

### Azure 认证信息

为了让 GitHub Actions 能够访问 Azure 资源，需要创建一个 Azure Service Principal（服务主体）。

#### 1. 创建 Azure Service Principal

```bash
# 登录 Azure
az login

# 获取你的订阅ID
az account show --query id --output tsv

# 创建 Service Principal（替换 <subscription-id> 和 <app-name>）
az ad sp create-for-rbac \
  --name "github-terraform-sp" \
  --role Contributor \
  --scopes /subscriptions/<subscription-id> \
  --sdk-auth
```

输出将包含以下信息：
```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

#### 2. 添加 Azure Secrets 到 GitHub

进入你的 GitHub 仓库 → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

添加以下 Secrets：

| Secret Name | 值 | 描述 |
|-------------|-----|------|
| `AZURE_SUBSCRIPTION_ID` | `subscriptionId` | Azure 订阅ID |
| `AZURE_TENANT_ID` | `tenantId` | Azure 租户ID |
| `AZURE_CLIENT_ID` | `clientId` | Service Principal 客户端ID |
| `AZURE_CLIENT_SECRET` | `clientSecret` | Service Principal 客户端密钥 |

### Tencent Cloud 认证信息（可选）

如果使用 Tencent DNS（DNSPod），需要添加以下 Secrets：

| Secret Name | 值 | 描述 |
|-------------|-----|------|
| `TENCENT_SECRET_ID` | 你的腾讯云 Secret ID | Tencent Cloud API 密钥 ID |
| `TENCENT_SECRET_KEY` | 你的腾讯云 Secret Key | Tencent Cloud API 密钥 |

#### 获取 Tencent Cloud 凭证

1. 登录 [Tencent Cloud Console](https://console.cloud.tencent.com/)
2. 进入 **访问管理** → **API 密钥管理**
3. 创建或查看现有的 API 密钥（SecretId 和 SecretKey）
4. 将它们添加到 GitHub Secrets

### 可选的通知 Secrets

| Secret Name | 值 | 描述 |
|-------------|-----|------|
| `SLACK_WEBHOOK` | Slack Webhook URL | Terraform 操作完成时发送通知（可选） |

#### 获取 Slack Webhook（可选）

1. 进入 [Slack App 目录](https://api.slack.com/apps)
2. 创建或选择应用
3. 启用 **Incoming Webhooks**
4. 创建新的 Webhook 并复制 URL
5. 将 URL 添加到 GitHub Secrets

## 环境变量映射

工作流使用以下环境变量与 Terraform 通信：

```yaml
# Azure 认证
ARM_SUBSCRIPTION_ID     -> AZURE_SUBSCRIPTION_ID
ARM_TENANT_ID           -> AZURE_TENANT_ID
ARM_CLIENT_ID           -> AZURE_CLIENT_ID
ARM_CLIENT_SECRET       -> AZURE_CLIENT_SECRET

# Terraform 变量
TF_VAR_tencent_secret_id    -> TENCENT_SECRET_ID
TF_VAR_tencent_secret_key   -> TENCENT_SECRET_KEY
```

## 工作流触发条件

### Terraform Plan 工作流 (`terraform-plan.yml`)

**触发条件：**
- 推送代码到 `main` 或 `develop` 分支
- 修改了 `*.tf` 文件、`env/` 目录或工作流文件
- 手动触发 (`workflow_dispatch`)

**作用：**
- 检查 Terraform 格式
- 验证 Terraform 配置
- 生成 Terraform 计划
- 在 GitHub Actions 日志中显示计划

### Terraform Apply 工作流 (`terraform-apply.yml`)

**触发条件：**
- 仅通过手动触发 (`workflow_dispatch`)
- 需要选择部署环境 (dev/prod)

**作用：**
- 执行 Terraform 应用
- 创建实际的 Azure 资源
- 输出资源信息
- 发送 Slack 通知（如配置）

### Terraform Destroy 工作流 (`terraform-destroy.yml`)

**触发条件：**
- 仅通过 `workflow_dispatch` 手动触发
- 需要选择环境并输入 "destroy" 确认

**作用：**
- 销毁已创建的 Azure 资源
- 需要手动确认以防止意外删除

## 使用工作流

### 1. 推送代码并查看 Plan

```bash
git add .
git commit -m "Update Terraform configuration"
git push origin main
```

GitHub Actions 将自动运行 **Terraform Plan**，可以在 Actions 标签页查看计划输出。

### 2. 手动触发 Apply 进行部署

进入 **Actions** → **Terraform Apply** → **Run workflow** → 选择环境 (dev/prod) → **Run workflow**

### 3. 手动触发 Destroy 销毁资源（谨慎！）

进入 **Actions** → **Terraform Destroy** → **Run workflow** → 选择环境 → 输入 "destroy" → **Run workflow**

## 安全最佳实践

✅ **必须做的事：**
- 定期轮换 Service Principal 凭证
- 使用最小权限原则（仅赋予必要权限）
- 启用 GitHub 仓库的分支保护规则
- 要求代码审查后才能合并 PR
- 监控 Actions 日志查看异常活动
- 定期审计 Secrets 的使用

❌ **不要做的事：**
- 不要在代码中硬编码敏感信息
- 不要在日志中输出敏感信息
- 不要与他人分享 Secrets
- 不要在公开的仓库中存储 Secrets（使用私有仓库）

## 故障排查

### 问题：Terraform Init 失败

**症状：** `Error: Failed to instantiate provider`

**解决方案：**
1. 验证 Azure Secrets 是否正确配置
2. 检查 Service Principal 是否有足够权限
3. 验证 `ARM_*` 环境变量是否正确传递

### 问题：Terraform Apply 失败

**症状：** `Error: creating Azure Front Door Profile`

**解决方案：**
1. 检查资源组是否已存在
2. 验证订阅配额是否充足
3. 查看详细错误日志
4. 在本地运行 `terraform plan` 验证配置

### 问题：Tencent DNS 操作失败

**症状：** `Error: DNS record creation failed`

**解决方案：**
1. 验证 Tencent Secrets 是否正确
2. 检查 Tencent Cloud API 权限
3. 确保域名已添加到 Tencent DNS 管理

## 相关文件

- [Terraform Plan 工作流](.github/workflows/terraform-plan.yml)
- [Terraform Apply 工作流](.github/workflows/terraform-apply.yml)
- [Terraform Destroy 工作流](.github/workflows/terraform-destroy.yml)
- [Terraform 配置](../README.md)
