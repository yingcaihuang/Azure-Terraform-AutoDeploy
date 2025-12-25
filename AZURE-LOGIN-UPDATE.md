# Azure Login 集成升级总结

## ✅ 完成的更改

### 1. 升级 azure/login 版本

所有三个工作流都已升级到最新版本：

**之前**: `azure/login@v1`
**现在**: `azure/login@v2` ⬆️

三个受影响的工作流：
- `.github/workflows/terraform-plan.yml`
- `.github/workflows/terraform-apply.yml`
- `.github/workflows/terraform-destroy.yml`

### 2. 添加 azure/cli@v2 验证步骤

每个工作流现在都包含验证 Azure 登录的步骤：

```yaml
- name: Verify Azure Credentials
  uses: azure/cli@v2
  with:
    azcliversion: latest
    inlineScript: |
      echo "✅ Azure Login Successful"
      az account show --query '{"subscriptionId": id, "subscriptionName": name}' -o table
```

### 3. 创建新文档

#### AZURE-LOGIN-SETUP.md 更新
- ✅ 说明如何生成 `AZURE_CREDENTIALS` secret
- ✅ 详细的 JSON 凭证格式说明
- ✅ GitHub Secrets 配置步骤
- ✅ 升级到 @v2 的信息

#### 新文件：AZURE-CLI-GITHUB-ACTIONS.md
- 📖 完整的 Azure CLI 使用指南
- 📖 常用命令示例
- 📖 工作流中的应用案例
- 📖 高级用法和最佳实践

## 🔐 安全性改进

| 方面 | 改进 |
|-----|------|
| 认证方式 | 单一凭证 JSON（而不是四个单独变量） |
| 密钥管理 | 更集中的密钥管理 |
| 环境变量 | 自动设置，不需要手动配置 |
| Azure CLI | 验证步骤确保认证成功 |

## 📋 Secrets 配置清单

### 必需（1 个 Secret）

```
✅ AZURE_CREDENTIALS
   格式：JSON（单行）
   内容：{"clientId": "...", "clientSecret": "...", "subscriptionId": "...", "tenantId": "..."}
```

### 可选

```
⭕ TENCENT_SECRET_ID      (如使用 DNS 功能)
⭕ TENCENT_SECRET_KEY     (如使用 DNS 功能)
⭕ SLACK_WEBHOOK          (如需要通知)
```

## �� 工作流运行流程

```
1. 推送代码到 GitHub
   ↓
2. GitHub Actions 触发工作流
   ↓
3. Checkout 代码
   ↓
4. azure/login@v2 验证
   ├─ 读取 AZURE_CREDENTIALS secret
   ├─ 设置 Azure 认证上下文
   └─ 环境变量自动配置
   ↓
5. azure/cli@v2 验证步骤
   ├─ 显示 "✅ Azure Login Successful"
   ├─ 显示订阅信息
   └─ 验证认证成功
   ↓
6. Setup Terraform
   ↓
7. Terraform 操作（Plan/Apply/Destroy）
   ├─ 自动使用 Azure 认证
   ├─ 无需手动配置 ARM_* 变量
   └─ 部署/销毁资源
   ↓
8. 工作流完成
```

## 🔧 验证工作流

推送更新后：

1. 进入 GitHub → **Actions**
2. 选择 **Terraform Plan** 工作流
3. 查看日志：
   - ✅ "Verify Azure Credentials" 步骤
   - ✅ "✅ Azure Login Successful" 输出
   - ✅ 订阅 ID 和名称显示

## 📖 文档导航

| 文档 | 用途 |
|-----|------|
| [AZURE-LOGIN-SETUP.md](docs/AZURE-LOGIN-SETUP.md) | Azure Login 配置和 AZURE_CREDENTIALS 生成 |
| [AZURE-CLI-GITHUB-ACTIONS.md](docs/AZURE-CLI-GITHUB-ACTIONS.md) | Azure CLI 命令详解和工作流示例 |
| [GITHUB-ACTIONS-SETUP.md](docs/GITHUB-ACTIONS-SETUP.md) | GitHub Secrets 总体配置指南 |

## ⚠️ 重要注意事项

### 如果你已配置了旧的 Secrets（不需要删除）

旧配置：
```
AZURE_SUBSCRIPTION_ID
AZURE_TENANT_ID
AZURE_CLIENT_ID
AZURE_CLIENT_SECRET
```

新配置：
```
AZURE_CREDENTIALS    ← 新增，必需
```

旧的 Secrets 仍可保留（用于其他目的），但新工作流只使用 `AZURE_CREDENTIALS`。

### 生成 AZURE_CREDENTIALS 的正确方式

```bash
az ad sp create-for-rbac \
  --name "github-terraform-sp" \
  --role Contributor \
  --scopes /subscriptions/<subscription-id> \
  --json-auth
```

**关键**：使用 `--json-auth` 参数输出单行 JSON 格式，适合复制到 GitHub Secrets。

## 🎯 下一步

### 立即行动

1. ✅ 生成 `AZURE_CREDENTIALS` JSON
   ```bash
   az ad sp create-for-rbac --name "github-terraform-sp" --role Contributor --scopes /subscriptions/<your-id> --json-auth
   ```

2. ✅ 配置 GitHub Secret
   - 进入 Settings → Secrets and variables → Actions
   - 新建 Secret: `AZURE_CREDENTIALS`
   - 粘贴 JSON（单行格式）

3. ✅ 推送更新到 GitHub
   ```bash
   git add .github/workflows/ docs/
   git commit -m "upgrade: Azure login v2 with CLI verification"
   git push origin main
   ```

4. ✅ 验证工作流
   - GitHub → Actions
   - 查看 Terraform Plan 运行日志
   - 确认 "Verify Azure Credentials" 步骤成功

### 可选增强

- [ ] 添加更多 Azure CLI 验证步骤
- [ ] 配置 Slack 通知
- [ ] 添加资源检查脚本
- [ ] 设置工作流失败告警

## �� 常见问题

**Q: 需要删除旧的 Azure Secrets 吗？**
A: 不需要。可以保留旧 Secrets，新工作流只使用 `AZURE_CREDENTIALS`。

**Q: 能同时使用 @v1 和 @v2 吗？**
A: 可以。如果有其他工作流使用 @v1，可以单独保留。

**Q: Azure CLI 验证失败怎么办？**
A: 检查 AZURE_CREDENTIALS secret 是否正确，可参考 [AZURE-LOGIN-SETUP.md](docs/AZURE-LOGIN-SETUP.md) 故障排查部分。

---

**更新日期**：2025 年 12 月 25 日
**相关版本**：azure/login@v2, azure/cli@v2
