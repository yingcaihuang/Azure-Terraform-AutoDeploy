# Azure CLI 与 GitHub Actions 集成指南

## 概述

本指南说明如何在 GitHub Actions 工作流中使用 `azure/cli@v2` action 运行 Azure CLI 命令，配合 `azure/login@v2` 进行 Azure 认证。

## 工作流集成架构

```
┌──────────────────────────────────────┐
│  GitHub Actions 工作流开始            │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  Checkout 代码                       │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  azure/login@v2                      │
│  读取 AZURE_CREDENTIALS secret       │
│  设置 Azure 认证上下文               │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  azure/cli@v2                        │
│  使用已认证的 Azure 会话             │
│  运行 Azure CLI 命令                 │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  后续步骤（Terraform 等）            │
└──────────────────────────────────────┘
```

## 基础配置

### 最小配置

```yaml
- name: Azure Login
  uses: azure/login@v2
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}

- name: Run Azure CLI
  uses: azure/cli@v2
  with:
    azcliversion: latest
    inlineScript: |
      az account show
```

### 完整配置

```yaml
- name: Azure Login
  uses: azure/login@v2
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}
    enable-AzPSSession: false  # 不启用 PowerShell 会话（可选）
    environment: AzureCloud    # 指定 Azure 环境（默认）

- name: Run Azure CLI
  uses: azure/cli@v2
  with:
    azcliversion: latest       # Azure CLI 版本
    inlineScript: |            # 内联脚本命令
      # 你的 Azure CLI 命令
```

## 常用 Azure CLI 命令

### 1. 账户信息查询

```bash
# 查看当前账户信息
az account show

# 查看当前账户信息（表格格式）
az account show -o table

# 查看特定字段
az account show --query '{subscriptionId: id, name: name}' -o table

# 列出所有订阅
az list

# 设置默认订阅
az account set --subscription <subscription-id>
```

### 2. 资源组管理

```bash
# 列出所有资源组
az group list

# 列出资源组中的所有资源
az resource list --resource-group <rg-name>

# 列出特定类型的资源
az resource list --resource-group <rg-name> --resource-type Microsoft.Compute/virtualMachines

# 显示资源组详情
az group show --name <rg-name>
```

### 3. 存储账户管理

```bash
# 列出所有存储账户
az storage account list

# 列出存储账户中的容器
az storage container list --account-name <storage-account-name>

# 列出特定容器中的 Blob
az storage blob list --account-name <storage-account-name> --container-name <container-name>

# 上传文件到存储账户
az storage blob upload \
  --account-name <storage-account-name> \
  --container-name <container-name> \
  --name <blob-name> \
  --file <local-file-path>
```

### 4. 网络资源管理

```bash
# 列出所有虚拟网络
az network vnet list

# 列出所有公共 IP
az network public-ip list

# 列出所有负载均衡器
az network lb list

# 列出 Azure Front Door
az afd profile list
```

### 5. 应用服务管理

```bash
# 列出所有 App Service
az appservice plan list

# 列出所有 Web Apps
az webapp list

# 获取 Web App 详情
az webapp show --name <app-name> --resource-group <rg-name>
```

### 6. 键值库管理

```bash
# 列出所有 Key Vault
az keyvault list

# 列出 Key Vault 中的密钥
az keyvault key list --vault-name <vault-name>

# 列出 Key Vault 中的密钥
az keyvault secret list --vault-name <vault-name>
```

## 工作流中的实际应用

### 示例 1：验证 Azure 登录并显示订阅信息

```yaml
- name: Verify Azure Credentials
  uses: azure/cli@v2
  with:
    azcliversion: latest
    inlineScript: |
      echo "✅ Azure Login Successful"
      echo ""
      echo "Current Subscription:"
      az account show --query '{subscriptionId: id, name: name}' -o table
      echo ""
      echo "Available Storage Accounts:"
      az storage account list --query '[].{name: name, resourceGroup: resourceGroup}' -o table
```

### 示例 2：检查资源部署状态

```yaml
- name: Check Deployment Status
  uses: azure/cli@v2
  with:
    azcliversion: latest
    inlineScript: |
      RESOURCE_GROUP="my-resource-group"
      echo "Resources in $RESOURCE_GROUP:"
      az resource list \
        --resource-group "$RESOURCE_GROUP" \
        --query '[].{name: name, type: type, status: properties.provisioningState}' \
        -o table
```

### 示例 3：Azure Front Door 信息获取

```yaml
- name: Get Azure Front Door Info
  uses: azure/cli@v2
  with:
    azcliversion: latest
    inlineScript: |
      echo "Azure Front Door Profiles:"
      az afd profile list \
        --query '[].{name: name, resourceGroup: resourceGroup}' \
        -o table
      
      # 如果有特定的 Front Door，获取其详情
      FRONT_DOOR_NAME="my-front-door"
      RESOURCE_GROUP="my-resource-group"
      echo ""
      echo "Front Door '$FRONT_DOOR_NAME' Details:"
      az afd profile show \
        --name "$FRONT_DOOR_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query '{name: name, hostName: properties.hostName}' \
        -o json
```

### 示例 4：保存 CLI 输出用于后续步骤

```yaml
- name: Get Resource Info and Save
  uses: azure/cli@v2
  with:
    azcliversion: latest
    inlineScript: |
      # 获取信息并保存到环境变量
      STORAGE_ACCOUNTS=$(az storage account list --query '[].name' -o tsv)
      echo "STORAGE_ACCOUNTS<<EOF" >> $GITHUB_ENV
      echo "$STORAGE_ACCOUNTS" >> $GITHUB_ENV
      echo "EOF" >> $GITHUB_ENV
      
      # 获取当前订阅 ID
      SUBSCRIPTION_ID=$(az account show --query id -o tsv)
      echo "SUBSCRIPTION_ID=$SUBSCRIPTION_ID" >> $GITHUB_ENV

- name: Use Saved Variables
  run: |
    echo "Storage Accounts: ${{ env.STORAGE_ACCOUNTS }}"
    echo "Subscription ID: ${{ env.SUBSCRIPTION_ID }}"
```

## 当前工作流中的 Azure CLI 使用

所有三个工作流都已配置 `azure/cli@v2` 用于验证 Azure 登录：

```yaml
- name: Verify Azure Credentials
  uses: azure/cli@v2
  with:
    azcliversion: latest
    inlineScript: |
      echo "✅ Azure Login Successful"
      az account show --query '{subscriptionId: id, subscriptionName: name}' -o table
```

### 获取验证结果

在工作流运行日志中可以看到类似输出：

```
✅ Azure Login Successful
SubscriptionId                        SubscriptionName
────────────────────────────────────  ──────────────────
abcd1234-5678-efgh-9012-ijklmnopqrst  My Subscription
```

## 高级用法

### 条件执行

```yaml
- name: Run Azure CLI (条件执行)
  uses: azure/cli@v2
  if: github.event_name == 'workflow_dispatch'
  with:
    azcliversion: latest
    inlineScript: |
      az group list
```

### 错误处理

```yaml
- name: Safe Azure CLI Execution
  uses: azure/cli@v2
  continue-on-error: true
  with:
    azcliversion: latest
    inlineScript: |
      # 这个命令可能失败，但工作流继续执行
      az resource list --resource-group "non-existent-group" || echo "Resource group not found"
```

### 循环执行

```yaml
- name: Run Azure CLI for Multiple Resources
  uses: azure/cli@v2
  with:
    azcliversion: latest
    inlineScript: |
      RESOURCE_GROUPS=("rg-dev" "rg-prod" "rg-test")
      
      for rg in "${RESOURCE_GROUPS[@]}"; do
        echo "Processing resource group: $rg"
        az resource list --resource-group "$rg" --query 'length(@)' -o tsv
      done
```

## 输出格式

Azure CLI 支持多种输出格式，在工作流中常用：

```bash
# 表格格式（推荐用于日志）
az resource list -o table

# JSON 格式（适合程序处理）
az resource list -o json

# 仅值（适合脚本）
az resource list -o tsv

# 美化 JSON
az resource list -o jsonc
```

## 常见问题排查

### 问题：认证失败

**症状**：`ERROR: AADSTS error`

**解决方案**：
1. 检查 `AZURE_CREDENTIALS` secret 是否正确配置
2. 验证 Service Principal 凭证未过期
3. 检查 Service Principal 是否有必要权限

### 问题：找不到资源

**症状**：`ResourceNotFound: The resource you are looking for does not exist`

**解决方案**：
1. 检查资源组名称拼写
2. 确认资源存在于指定的订阅
3. 验证 Service Principal 有读取权限

### 问题：命令输出不可见

**症状**：工作流日志中看不到 CLI 输出

**解决方案**：
1. 确保在 `inlineScript` 中使用 `echo` 输出
2. 检查脚本中是否有重定向（`> /dev/null`）
3. 查看完整的工作流日志（展开所有步骤）

## 最佳实践

### 安全性

✅ 不要在脚本中硬编码敏感信息
✅ 使用 GitHub Secrets 存储凭证
✅ 限制 Service Principal 权限范围
✅ 定期轮换凭证
✅ 审计工作流日志

### 性能

✅ 使用 `--query` 过滤输出而不是在 CLI 后面处理
✅ 使用 `-o tsv` 或 `-o json` 以获得更快的处理
✅ 避免重复调用相同的命令
✅ 使用环境变量缓存结果

### 可维护性

✅ 为复杂脚本添加注释
✅ 使用有意义的变量名称
✅ 将长脚本分解为多个步骤
✅ 添加错误消息帮助调试

## 参考资源

- [Azure CLI 官方文档](https://docs.microsoft.com/cli/azure/)
- [azure/cli GitHub Action](https://github.com/Azure/cli)
- [azure/login GitHub Action](https://github.com/Azure/login)
- [Azure CLI 命令参考](https://docs.microsoft.com/cli/azure/reference-index)

---

**上次更新**：2025 年 12 月 25 日
