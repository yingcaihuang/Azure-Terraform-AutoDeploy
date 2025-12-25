# GitHub Actions CI/CD 快速开始

## 🎯 一句话总结

这是一套自动化部署系统：提交代码到 GitHub → 自动测试 → 自动部署到 Azure

## ⚡ 快速开始（5 分钟）

### 第 1 步：推送到 GitHub

```bash
cd /Users/betty/Azure-Terraform-AutoDeploy
git add .
git commit -m "Add GitHub Actions workflow"
git push origin main
```

### 第 2 步：配置 Azure (2 分钟)

在你的机器上运行：

```bash
# 登录 Azure
az login

# 获取订阅 ID
az account show --query id -o tsv

# 创建 Service Principal（复制整个 JSON 输出）
az ad sp create-for-rbac --name "github-terraform-sp" --role Contributor --sdk-auth
```

### 第 3 步：添加 Secrets 到 GitHub (3 分钟)

1. 打开仓库 → **Settings** → **Secrets and variables** → **Actions**
2. 点击 **New repository secret**，添加 4 个 Secrets：

```
AZURE_SUBSCRIPTION_ID  = 从上面的 JSON 中复制 subscriptionId
AZURE_TENANT_ID        = 从上面的 JSON 中复制 tenantId
AZURE_CLIENT_ID        = 从上面的 JSON 中复制 clientId
AZURE_CLIENT_SECRET    = 从上面的 JSON 中复制 clientSecret
```

### 第 4 步：更新 tfvars 文件

编辑 `env/dev.tfvars` 和 `env/prod.tfvars`，替换占位符：

```hcl
# 替换这些值为你的实际信息
subscription_id     = "你的-azure-subscription-id"  # 从第 2 步获取
domain_name         = "你的-实际-域名"
dns_domain          = "你的-dns-域"
```

---

## 🔄 工作流说明

### 什么会触发自动部署？

| 事件 | 工作流 | 作用 |
|------|-------|------|
| 推送代码到 main | Terraform Plan | ✅ 自动验证配置并预览变更 |
| 手动触发 | Terraform Apply | 🚀 手动部署资源到 Azure |
| 手动触发 | Terraform Destroy | 🎯 手动销毁资源 |

### 工作流详情

#### 🔵 Terraform Plan （Push 时自动运行）

```yaml
触发：推送代码到 main/develop 分支
步骤：
  1. 检查 Terraform 代码格式
  2. 验证 Terraform 配置
  3. 生成执行计划（不修改资源）
  4. 在 GitHub 日志中显示计划详情

结果：可以在 Actions 日志中查看计划预览
```

#### 🟢 Terraform Apply （手动运行）

```yaml
触发：从 Actions 页面手动运行
步骤：
  1. 执行 Terraform 初始化
  2. 生成执行计划
  3. 应用计划（创建/更新资源）
  4. 输出资源信息

结果：Azure 资源被创建或更新，在 Actions 中查看输出
```

#### 🔴 Terraform Destroy （手动运行）

```yaml
触发：从 Actions 页面手动运行
步骤：
  1. 需要输入 "destroy" 确认
  2. 执行销毁操作
  3. 删除所有 Terraform 管理的资源

注意：谨慎使用！这会删除所有资源
```

---

## 📝 使用示例

### 示例 1：修改配置并查看计划

```bash
# 1. 创建功能分支
git checkout -b feature/update-domain

# 2. 修改生产环境配置
# 编辑 env/prod.tfvars，更新 domain_name

# 3. 提交并推送
git add env/prod.tfvars
git commit -m "Update production domain"
git push origin feature/update-domain

# 4. 在 GitHub Actions 中查看自动运行的 Plan
# 进入仓库 → Actions → 查看最新的 Terraform Plan 运行

# 5. 确认计划无误后，在本地合并到 main
git checkout main
git merge feature/update-domain
git push origin main

# 6. Push 自动触发另一个 Plan 运行
```

### 示例 2：手动部署开发环境

```bash
# 1. 进入 GitHub Actions 标签页
# 2. 点击左侧 "Terraform Apply"
# 3. 点击 "Run workflow"
# 4. 选择 environment: "dev"
# 5. 点击 "Run workflow" 按钮
# 6. 在日志中查看部署进度
```

### 示例 3：删除测试资源

```bash
# 1. 进入 GitHub Actions 标签页
# 2. 点击左侧 "Terraform Destroy"
# 3. 点击 "Run workflow"
# 4. 选择 environment: "dev"
# 5. 输入 "destroy" 进行确认
# 6. 点击 "Run workflow" 按钮
# 注意：所有资源将被删除！
```

---

## 🔍 监控工作流

### 方式 1：GitHub UI

```
仓库首页 → Actions 标签页 → 选择工作流 → 查看运行历史
```

### 方式 2：实时日志

```
Actions → Terraform Apply (运行中) → 查看实时日志
```

### 方式 3：PR 评论

```
Pull Request → 下滑查看 GitHub Actions 生成的评论
```

---

## ❌ 故障排查

### 问题 1: "Error: authenticating using credentials"

**原因：** Azure Secrets 配置不正确

**解决方案：**
1. 检查 GitHub Secrets 中的值是否正确
2. 确保没有多余的空格或换行符
3. 重新生成 Service Principal 并更新 Secrets

### 问题 2: "Error: creating Azure Front Door Profile"

**原因：** Azure 配额不足或权限不够

**解决方案：**
1. 检查 Service Principal 是否有 Contributor 角色
2. 检查订阅配额
3. 查看 Azure Portal 中的活动日志了解详细错误

### 问题 3: 工作流没有运行

**原因：** 没有修改相关文件或分支不是 main

**解决方案：**
1. 确保修改的是 `*.tf` 文件或 `env/` 目录
2. 确保推送到的是 `main` 或 `develop` 分支
3. 手动触发工作流进行测试

### 问题 4: "terraform.tfstate not found"

**原因：** 第一次运行时没有后端存储配置

**解决方案：**
- 正常现象，第一次会创建本地状态文件
- 建议配置远程后端（Azure Storage）
- 参见 [远程后端配置](#远程后端配置)

---

## 🔐 安全检查清单

部署前确保：

- [ ] 所有敏感信息已从代码中删除
- [ ] `.gitignore` 包含 `*.tfstate` 规则
- [ ] GitHub Secrets 已添加
- [ ] Service Principal 权限已最小化
- [ ] 分支保护规则已启用
- [ ] 代码审查流程已建立

---

## 📚 文件导航

```
项目根目录/
├── .github/workflows/               # GitHub Actions 工作流
│   ├── terraform-plan.yml           # Plan 工作流
│   ├── terraform-apply.yml          # Apply 工作流
│   └── terraform-destroy.yml        # Destroy 工作流
├── env/                             # 环境配置
│   ├── dev.tfvars                   # 开发环境（需编辑）
│   └── prod.tfvars                  # 生产环境（需编辑）
├── docs/                            # 文档
│   ├── GITHUB-ACTIONS-SETUP.md      # 详细配置指南
│   └── ENVIRONMENT-SETUP.md         # 环境配置指南
├── *.tf                             # Terraform 配置
└── README.md                        # 项目说明
```

---

## 🚀 下一步

1. ✅ 完成 [第 3 步：添加 Secrets](#第-3-步添加-secrets-到-github-3-分钟)
2. ✅ 编辑 `env/dev.tfvars` 和 `env/prod.tfvars`
3. ✅ 创建测试 PR 验证 Plan 工作流
4. ✅ 合并 PR 验证 Apply 工作流
5. ✅ 在 Azure Portal 中验证资源已创建

---

## 💬 获取帮助

- 📖 查看 [GITHUB-ACTIONS-SETUP.md](GITHUB-ACTIONS-SETUP.md) 获取详细配置
- 📖 查看 [ENVIRONMENT-SETUP.md](ENVIRONMENT-SETUP.md) 了解环境设置
- 🔍 查看 Actions 日志了解具体错误
- 📞 查看 [README.md](../README.md) 获取项目信息

---

## 🎓 学习资源

- [Terraform 官方文档](https://www.terraform.io/docs)
- [Azure Provider 文档](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub Actions 官方指南](https://docs.github.com/en/actions)
- [Azure CLI 文档](https://learn.microsoft.com/en-us/cli/azure/)
