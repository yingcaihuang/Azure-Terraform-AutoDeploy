## 🔧 故障排查指南

### 错误：env/dev.tfvars does not exist

如果在 GitHub Actions 工作流中遇到这个错误：

```
Error: Failed to read variables file
Given variables file env/dev.tfvars does not exist.
Error: Terraform exited with code 1.
```

**原因：** env 目录中的 tfvars 文件没有被提交到 GitHub 仓库。

---

## ✅ 解决方案

### 第 1 步：检查 Git 状态

```bash
cd /Users/betty/Azure-Terraform-AutoDeploy
git status env/
```

应该显示 env 文件为"Untracked files"。

### 第 2 步：添加 env 文件到 Git

```bash
# 添加所有 env 文件
git add env/

# 查看即将提交的文件
git status
```

### 第 3 步：提交文件

```bash
git commit -m "Add environment configuration files with placeholder values"
```

### 第 4 步：推送到 GitHub

```bash
git push origin main
```

### 第 5 步：验证 GitHub Actions

1. 进入 GitHub 仓库
2. 查看 **Actions** 标签页
3. 查看 Terraform Plan 工作流是否成功运行

---

## 📋 .gitignore 配置说明

项目中的 `.gitignore` 文件已配置为：

```gitignore
# 排除所有 .tfvars 文件（保护敏感信息）
*.tfvars
*.tfvars.json

# 但允许 env/ 目录中的文件（包含占位符值）
!env/*.tfvars
```

**说明：**
- `*.tfvars` 排除所有 tfvars 文件
- `!env/*.tfvars` 例外允许 env 目录中的文件

这样可以保护根目录的 `terraform.tfvars` 文件（如果有），同时允许 env 目录中的示例配置提交。

---

## 🔐 安全实践

### env 目录中的文件

env 目录中的 tfvars 文件：
- ✅ **可以提交** - 包含占位符值（如 `your-tencent-secret-id`）
- ✅ **应该提交** - 工作流需要这些文件存在
- ✅ **不包含真实密钥** - 所有敏感值已替换为占位符

### 根目录的 terraform.tfvars

根目录的 `terraform.tfvars` 文件：
- ❌ **不能提交** - 如果存在包含真实值
- ✅ **应该忽略** - .gitignore 已配置忽略

---

## 验证文件内容

### 查看 env/dev.tfvars

```bash
cat env/dev.tfvars
```

示例输出：
```hcl
resource_group_name = "rg-frontdoor-dev"
location            = "eastus"
afd_profile_name    = "afdprofile-dev"
domain_name         = "hrdev.gslb.vip"
subscription_id     = "00000000-0000-0000-0000-000000000000"  # 占位符
dns_domain          = "gslb.vip"
dns_subdomain       = "hrdev"
tencent_secret_id   = "your-tencent-secret-id"  # 占位符
tencent_secret_key  = "your-tencent-secret-key"  # 占位符
```

所有真实的敏感值都已替换为占位符。

---

## 完整的步骤

### 如果是第一次设置

```bash
# 1. 进入项目目录
cd /Users/betty/Azure-Terraform-AutoDeploy

# 2. 检查 env 文件是否存在
ls -la env/

# 3. 如果文件不存在，创建它们
# (已在早期步骤中创建)

# 4. 添加所有文件
git add env/
git add .gitignore

# 5. 提交
git commit -m "Add environment files and update gitignore"

# 6. 推送
git push origin main

# 7. 检查 GitHub Actions 运行
# 进入 GitHub → Actions 查看
```

### 如果已经提交过

```bash
# 检查文件是否已在 Git 中
git ls-files | grep env/

# 如果没有，需要强制添加
git add -f env/*.tfvars
git commit -m "Force add environment files"
git push origin main
```

---

## GitHub Actions 工作流日志检查

### 查看 Plan 工作流日志

1. 进入 GitHub 仓库
2. 点击 **Actions** 标签
3. 选择 **Terraform Plan** 工作流
4. 查看最新运行
5. 展开 **Determine Environment** 步骤，查看：
   ```
   Environment file: env/dev.tfvars
   ```
6. 展开 **Terraform Plan** 步骤，检查：
   - 是否成功读取 tfvars 文件
   - 是否生成了执行计划

---

## 常见问题

### Q: 为什么 env/dev.tfvars 被忽略？

A: 因为 .gitignore 中的 `*.tfvars` 规则。现在已添加 `!env/*.tfvars` 例外规则。

### Q: 可以提交真实的敏感信息吗？

A: **不可以**！只有占位符值可以提交。真实的敏感信息应该通过 GitHub Secrets 提供。

### Q: 如何更新敏感值？

A: 
1. 不要编辑提交到 GitHub 的 env 文件中的占位符
2. 在 GitHub Secrets 中配置真实值
3. 工作流会从 Secrets 中读取真实值

### Q: 为什么 Plan 工作流仍然失败？

A: 可能的原因：
1. 文件尚未推送到 GitHub → 推送文件
2. GitHub Secrets 未配置 → 配置 Secrets
3. 工作流文件有语法错误 → 检查 YAML 格式

---

## 诊断脚本

项目中包含诊断脚本 `diagnose.sh`，可以快速检查配置：

```bash
./diagnose.sh
```

输出会显示：
- ✅ env 文件是否存在
- ✅ 工作流文件是否存在
- ✅ .gitignore 配置
- ✅ Git 配置

---

## 下一步

1. ✅ 确认 env 文件已提交到 GitHub
2. ✅ 推送变更
3. ✅ 查看 GitHub Actions 日志
4. ✅ 验证 Terraform Plan 成功运行
5. ✅ 配置 GitHub Secrets
6. ✅ 手动触发 Terraform Apply

---

**如果问题仍未解决，请检查：**
- [ ] env 文件是否存在于本地
- [ ] 是否已提交到 GitHub
- [ ] GitHub Secrets 是否已配置
- [ ] GitHub Actions 日志中的错误信息
