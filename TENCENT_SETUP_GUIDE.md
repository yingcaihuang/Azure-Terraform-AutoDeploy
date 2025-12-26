# Tencent Cloud 认证配置指南

## 问题诊断

GitHub Actions 工作流中出现 `Please set your 'secret_id' and 'secret_key'` 错误通常是由以下原因导致：

1. **GitHub Secrets 未配置** - TENCENT_SECRET_ID 或 TENCENT_SECRET_KEY 未在 GitHub 中设置
2. **Secrets 值为空** - Secrets 配置了但值为空字符串
3. **环境变量传递问题** - 工作流中环境变量未正确传递给 Terraform

## 解决方案

### 步骤 1: 配置 GitHub Secrets

1. 访问 GitHub 仓库: https://github.com/yingcaihuang/Azure-Terraform-AutoDeploy
2. 进入 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**，创建以下两个 secrets:

#### Secret 1: TENCENT_SECRET_ID
- **Name**: `TENCENT_SECRET_ID`
- **Value**: 你的腾讯云 API SecretId（从 [腾讯云控制台](https://console.cloud.tencent.com/cam/capi) 获取）

#### Secret 2: TENCENT_SECRET_KEY
- **Name**: `TENCENT_SECRET_KEY`  
- **Value**: 你的腾讯云 API SecretKey（从 [腾讯云控制台](https://console.cloud.tencent.com/cam/capi) 获取）

#### Secret 3: AZURE_CREDENTIALS (如果尚未配置)
- **Name**: `AZURE_CREDENTIALS`
- **Value**: Azure 服务主体凭证 (JSON 格式，使用 `jq -c` 压缩)

### 步骤 2: 验证 Secrets 配置

运行工作流并检查 "Debug - Check Tencent Cloud Secrets" 步骤的输出：

```
✅ Tencent Cloud secrets are properly configured
   - Secret ID length: 24
   - Secret Key length: 32
```

如果看到 `NOT SET` 错误，说明 Secrets 未正确配置。

### 步骤 3: 工作流触发

Secrets 配置完成后，工作流会在以下情况下自动运行：

1. **自动验证** (Validate 阶段):
   - 推送代码到 `feature/minimal-validation` 分支
   - 检查 Terraform 格式和有效性
   - 无需任何凭证

2. **手动计划** (Plan 阶段):
   - 代码验证通过后自动运行
   - 需要 AZURE_CREDENTIALS 和 TENCENT Secrets
   - 输出计划结果，不创建实际资源

3. **手动应用** (Apply 阶段):
   - 需要在 GitHub Actions 中手动触发 `workflow_dispatch`
   - 创建实际的 DNS 测试记录
   - 需要所有凭证都配置正确

4. **手动销毁** (Destroy 阶段):
   - 清理创建的 DNS 记录
   - 需要所有凭证都配置正确

## Terraform 配置说明

### 环境变量处理流程

```
GitHub Actions Secrets
    ↓
TENCENTCLOUD_SECRET_ID (env var)
TENCENTCLOUD_SECRET_KEY (env var)
    ↓
Terraform 提供商识别
    ↓
Tencent Cloud API 认证
```

### 关键配置文件

- **providers.tf**: 定义 Terraform 提供商，环境变量由 GitHub Actions 设置
- **variables.tf**: 定义 Terraform 变量，默认值为空字符串
- **env/validation.tfvars**: 验证环境配置，Tencent 凭证为空（由工作流覆盖）
- **.github/workflows/terraform-validate-minimal.yml**: 工作流定义，设置环境变量和运行 Terraform

## 常见问题

### Q: 错误 "Please set your `secret_id` and `secret_key`" 如何解决?

**A**: 
1. 检查 GitHub Secrets 是否已设置: Settings → Secrets and variables → Actions
2. 运行工作流并查看 "Debug - Check Tencent Cloud Secrets" 步骤
3. 确认 Secret 名称完全匹配: `TENCENT_SECRET_ID` 和 `TENCENT_SECRET_KEY`
4. 确认 Secret 值不为空

### Q: 如何获取腾讯云的 SecretId 和 SecretKey?

**A**:
1. 访问 [腾讯云访问管理](https://console.cloud.tencent.com/cam/capi)
2. 创建新的 API 密钥或使用现有的
3. 复制 SecretId 和 SecretKey
4. 粘贴到 GitHub Secrets 中

### Q: 工作流在哪个阶段需要 Tencent Cloud 凭证?

**A**: 在 **Plan 阶段** 及之后的所有阶段:
- Validate: ✅ 不需要（仅检查格式）
- Plan: ✅ **需要** TENCENT 凭证
- Apply: ✅ **需要** TENCENT 凭证  
- Destroy: ✅ **需要** TENCENT 凭证

### Q: 本地测试时如何配置环境变量?

**A**:
```bash
export TENCENTCLOUD_SECRET_ID="your-secret-id"
export TENCENTCLOUD_SECRET_KEY="your-secret-key"

terraform plan \
  -var-file="env/validation.tfvars" \
  -var="dns_subdomain=$(date +%s)"
```

## 验证清单

- [ ] TENCENT_SECRET_ID Secret 已在 GitHub 中配置
- [ ] TENCENT_SECRET_KEY Secret 已在 GitHub 中配置
- [ ] AZURE_CREDENTIALS Secret 已在 GitHub 中配置
- [ ] 所有 Secret 值非空
- [ ] 已推送代码到 feature/minimal-validation 分支
- [ ] 工作流已运行并通过 Validate 阶段
- [ ] "Debug - Check Tencent Cloud Secrets" 显示 ✅ 状态
- [ ] Plan 阶段成功完成，显示 DNS 记录输出

## 下一步

1. 如果 Debug 步骤显示 ✅，DNS 记录应该在 Plan 阶段显示
2. 在 GitHub Actions 中手动触发 "Apply" 操作来创建实际的 DNS 记录
3. 验证记录已在腾讯云 DNSPod 中创建
4. 运行 "Destroy" 清理测试记录

## 获取帮助

如需进一步调试，检查 GitHub Actions 工作流日志:
1. 进入仓库 → Actions
2. 选择最新的工作流运行
3. 展开 "Debug - Check Tencent Cloud Secrets" 步骤查看详细信息
4. 查看 "Terraform Plan" 步骤的完整错误信息
