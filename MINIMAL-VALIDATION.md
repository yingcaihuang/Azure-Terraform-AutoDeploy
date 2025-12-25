# 最小化验证工作流 (feature/minimal-validation)

## 📋 概述

这个分支用于验证 **Terraform + GitHub Actions + Azure** 完整工作流的基础设施。

- ✅ **不部署生产资源** - 只创建一个简单的资源组
- ✅ **快速验证流程** - 避免复杂配置，快速诊断问题
- ✅ **成本低廉** - 最小化 Azure 资源消耗
- ✅ **容易调试** - 清晰的日志输出，便于故障排查

## 🎯 最小化验证清单

### 验证项目

- [ ] Terraform 格式和语法检查
- [ ] Azure 服务主体（Service Principal）认证
- [ ] Terraform 执行计划（terraform plan）
- [ ] Terraform 应用部署（terraform apply）
- [ ] 资源组创建成功
- [ ] Terraform 输出正确显示
- [ ] Terraform 销毁清理（terraform destroy）

### 部署资源

| 资源 | 说明 |
|------|------|
| `azurerm_resource_group` | 名为 `rg-yingcai` 的资源组 |
| 标签 | Environment: validation, Purpose: Minimal workflow validation |

## 🚀 使用步骤

### 1️⃣ 初始化工作环境

```bash
# 切换到最小化验证分支
git checkout feature/minimal-validation

# 查看 Terraform 配置
cat main.tf              # 只有资源组定义
cat env/validation.tfvars  # 验证配置
```

### 2️⃣ 本地验证 (可选)

```bash
# 初始化 Terraform
terraform init

# 验证配置文件
terraform fmt -check -recursive
terraform validate

# 查看执行计划
terraform plan -var-file="env/validation.tfvars"
```

### 3️⃣ 通过 GitHub Actions 部署

#### 方式 A: 自动触发

推送代码到 `feature/minimal-validation` 分支：
```bash
git commit -m "feat: initialize minimal validation workflow"
git push origin feature/minimal-validation
```

自动触发工作流：
- 📊 **Validate** 阶段 (自动运行)
- 📋 **Plan** 阶段 (自动运行)
- ✅ **Apply** 阶段 (手动触发)
- 🗑️ **Destroy** 阶段 (手动触发)

#### 方式 B: 手动触发

1. 进入 GitHub 仓库 → Actions 标签
2. 选择 "Terraform Validate - Minimal RG" 工作流
3. 点击 "Run workflow" 下拉菜单
4. 选择操作：`plan` / `apply` / `destroy`
5. 点击 "Run workflow"

### 4️⃣ 验证部署结果

#### 查看 GitHub Actions 日志

```
✅ Terraform Format Check - PASS
✅ Terraform Validate - PASS
✅ Terraform Plan - SUCCESS
  Resources to be created:
  - azurerm_resource_group.validation

✅ Terraform Apply - SUCCESS
  Outputs:
  - resource_group_id: /subscriptions/.../resourceGroups/rg-yingcai
  - resource_group_name: rg-yingcai
  - resource_group_location: East US
  - deployment_status: ✅ 最小化验证工作流成功部署...
```

#### 在 Azure 门户中验证

1. 登录 [Azure 门户](https://portal.azure.com)
2. 搜索 "资源组"
3. 查看是否存在 `rg-yingcai` 资源组
4. 验证标签和位置信息

```
资源组名称: rg-yingcai
位置: East US
标签:
  - Environment: validation
  - Purpose: Minimal workflow validation
```

### 5️⃣ 清理资源

#### 使用 GitHub Actions

1. 进入 GitHub Actions
2. 选择 "Terraform Validate - Minimal RG"
3. 点击 "Run workflow"
4. 选择 `destroy` 操作
5. 点击 "Run workflow"

或通过 CLI：

```bash
terraform init
terraform destroy \
  -var-file="env/validation.tfvars" \
  -auto-approve
```

## 📊 工作流步骤详解

### Stage 1: Validate
```
验证 Terraform 配置的正确性
├─ 格式检查 (terraform fmt)
├─ 语法检查 (terraform validate)
└─ 结果: PASS/FAIL
```

### Stage 2: Plan
```
计划将要执行的 Terraform 操作
├─ Azure 认证
├─ Terraform 初始化
├─ 生成执行计划
└─ 结果: 显示将创建的资源
```

### Stage 3: Apply (手动触发)
```
应用 Terraform 计划，创建实际资源
├─ Azure 认证
├─ Terraform 初始化
├─ 执行计划
└─ 结果: 资源组已创建
```

### Stage 4: Destroy (手动触发)
```
删除创建的 Terraform 资源
├─ Azure 认证
├─ Terraform 初始化
├─ 销毁资源
└─ 结果: 资源组已删除
```

## 🔍 故障排查

### 问题: Azure 认证失败
```
Error: Failed to authenticate with Azure
```

**解决方案:**
1. 确认 `AZURE_CREDENTIALS` Secret 已正确配置
2. 验证 Secret 值是单行 JSON 格式（使用 `| jq -c`）
3. 参考 [Azure 登录设置指南](../docs/AZURE-LOGIN-SETUP.md)

### 问题: Terraform 格式检查失败
```
Error: File not properly formatted
```

**解决方案:**
```bash
# 自动修复格式
terraform fmt -recursive
git add .
git commit -m "fix: terraform formatting"
git push
```

### 问题: 资源创建超时
**解决方案:**
- 检查 Azure 订阅限额
- 验证区域可用性（East US）
- 检查网络连接

### 问题: 资源删除失败
**解决方案:**
```bash
# 手动删除
az group delete -n rg-yingcai --yes

# 或通过 Azure 门户删除
```

## 📝 配置文件说明

### `main.tf` - 资源定义
```hcl
resource "azurerm_resource_group" "validation" {
  name     = var.resource_group_name  # rg-yingcai
  location = var.location             # East US
  tags     = merge(...)               # 标签
}
```

### `env/validation.tfvars` - 最小化配置
```hcl
subscription_id     = "2884693e-..."
resource_group_name = "rg-yingcai"
location            = "East US"
```

### `.github/workflows/terraform-validate-minimal.yml` - 工作流定义
触发条件:
- ✅ 推送到 `feature/minimal-validation` 分支
- ✅ Pull Request 到 `main` 分支
- ✅ 手动触发 (workflow_dispatch)

## ✨ 最佳实践

### ✅ DO (推荐)

1. **定期验证** - 在推送生产分支前，先在此分支验证
2. **增量测试** - 先验证基础工作流，再添加复杂资源
3. **记录日志** - 保存 GitHub Actions 输出供故障排查
4. **及时清理** - 验证完成后立即删除资源

### ❌ DON'T (不推荐)

1. ❌ 不要直接在此分支修改生产配置
2. ❌ 不要留下未清理的资源（浪费成本）
3. ❌ 不要合并此分支到 main（仅用于验证）
4. ❌ 不要修改 Secret（使用既有的生产 Secret）

## 🔄 转向生产工作流

验证完成后，将改进合并回主分支：

```bash
# 切换到 main 分支
git checkout main

# 将验证分支的改进合并回来
git merge feature/minimal-validation

# 推送到 GitHub
git push origin main
```

## 📚 相关文档

- [Azure 登录设置指南](../docs/AZURE-LOGIN-SETUP.md)
- [GitHub Actions 设置](../docs/GITHUB-ACTIONS-SETUP.md)
- [快速参考](../docs/QUICK-REFERENCE.md)

---

**创建日期**: 2025-12-26  
**分支**: `feature/minimal-validation`  
**用途**: 最小化工作流验证
