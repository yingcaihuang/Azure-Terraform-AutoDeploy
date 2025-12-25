# Azure Login 与 Azure CLI 快速参考卡

## 工作流配置速查表

### 完整工作流模板

```yaml
name: Terraform Plan

on:
  push:
    branches: [main]

permissions:
  contents: read

env:
  TERRAFORM_VERSION: 1.6.0

jobs:
  terraform-plan:
    runs-on: ubuntu-latest
    steps:
      # ===== Azure 认证 =====
      - name: Checkout code
        uses: actions/checkout@v4

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
            az account show --query '{subscriptionId: id, name: name}' -o table

      # ===== Terraform 操作 =====
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: ${{ env.TERRAFORM_VERSION }}

      - name: Terraform Format Check
        run: terraform fmt -check -recursive .
        continue-on-error: true

      - name: Terraform Init
        run: terraform init -upgrade

      - name: Terraform Validate
        run: terraform validate -no-color

      - name: Terraform Plan
        run: |
          terraform plan \
            -var-file="env/dev.tfvars" \
            -no-color \
            -out=tfplan
```

## GitHub Secret 配置

### 生成凭证（⚠️ 必须单行格式）

```bash
# ✅ 推荐：直接输出单行 JSON
az ad sp create-for-rbac \
  --name "github-terraform-sp" \
  --role Contributor \
  --scopes /subscriptions/<your-id> \
  --json-auth | jq -c
```

**或者保存后转换**：
```bash
# 保存到文件
az ad sp create-for-rbac \
  --name "github-terraform-sp" \
  --role Contributor \
  --scopes /subscriptions/<your-id> \
  --json-auth > creds.json

# 转换为单行
cat creds.json | jq -c
```

**⚠️ 重要**：输出必须是单行格式，否则 GitHub Secrets 会报错！

### 添加到 GitHub

| 名称 | 值 |
|-----|-----|
| `AZURE_CREDENTIALS` | JSON 输出（单行） |

**可选**：
- `TENCENT_SECRET_ID` - Tencent Cloud 密钥 ID
- `TENCENT_SECRET_KEY` - Tencent Cloud 密钥
- `SLACK_WEBHOOK` - Slack 通知 URL

## 常用 Azure CLI 命令

### 账户信息

```bash
# 查看当前账户
az account show

# 查看当前账户（表格格式）
az account show -o table

# 设置默认订阅
az account set --subscription <subscription-id>
```

### 资源组

```bash
# 列出资源组
az group list

# 查看资源组中的资源
az resource list --resource-group <rg-name>

# 按类型筛选
az resource list --resource-group <rg-name> \
  --resource-type Microsoft.Network/virtualNetworks
```

### 存储账户

```bash
# 列出所有存储账户
az storage account list

# 列出容器
az storage container list --account-name <storage-account>

# 上传文件
az storage blob upload \
  --account-name <storage> \
  --container-name <container> \
  --name <blob-name> \
  --file <local-file>
```

### Azure Front Door

```bash
# 列出所有 Front Door
az afd profile list

# 获取特定 Front Door
az afd profile show \
  --name <name> \
  --resource-group <rg-name>
```

## 工作流中的 Azure CLI 示例

### 验证登录

```yaml
- name: Verify Login
  uses: azure/cli@v2
  with:
    azcliversion: latest
    inlineScript: |
      az account show
```

### 保存变量用于后续步骤

```yaml
- name: Save Variables
  uses: azure/cli@v2
  with:
    azcliversion: latest
    inlineScript: |
      SUBSCRIPTION_ID=$(az account show --query id -o tsv)
      echo "SUBSCRIPTION_ID=$SUBSCRIPTION_ID" >> $GITHUB_ENV

- name: Use Variables
  run: echo "Subscription: ${{ env.SUBSCRIPTION_ID }}"
```

### 循环处理多个资源组

```yaml
- name: Process Resource Groups
  uses: azure/cli@v2
  with:
    azcliversion: latest
    inlineScript: |
      for rg in $(az group list --query '[].name' -o tsv); do
        echo "Processing: $rg"
        az resource list --resource-group "$rg" --query 'length(@)' -o tsv
      done
```

## 输出格式

| 格式 | 命令 | 用途 |
|-----|-----|------|
| 表格 | `-o table` | 日志输出，易读 |
| JSON | `-o json` | 编程处理 |
| TSV | `-o tsv` | 脚本处理 |
| JSONC | `-o jsonc` | 美化 JSON |

## 故障排查

| 问题 | 原因 | 解决方案 |
|-----|-----|--------|
| 认证失败 | Secret 错误 | 检查 AZURE_CREDENTIALS 格式 |
| 找不到资源 | 资源不存在 | 验证资源组和订阅 |
| 权限被拒绝 | 权限不足 | 检查 Service Principal 角色 |
| CLI 命令失败 | 命令语法错误 | 查看完整日志输出 |

## 最佳实践

✅ 使用 `--query` 过滤输出
✅ 用有意义的变量名称
✅ 为复杂脚本添加注释
✅ 使用 `continue-on-error: true` 处理可选步骤
✅ 定期更新 Action 版本

## 相关文档链接

- [AZURE-LOGIN-SETUP.md](docs/AZURE-LOGIN-SETUP.md) - 详细配置指南
- [AZURE-CLI-GITHUB-ACTIONS.md](docs/AZURE-CLI-GITHUB-ACTIONS.md) - 完整 CLI 手册
- [AZURE-LOGIN-UPDATE.md](AZURE-LOGIN-UPDATE.md) - 升级总结
- [GITHUB-ACTIONS-SETUP.md](docs/GITHUB-ACTIONS-SETUP.md) - Secrets 配置

---

**快速参考** | azure/login@v2 | azure/cli@v2
