# ❌ TENCENT_SECRET_ID 未设置 - 解决方案

## 问题描述

GitHub Actions 工作流报错：
```
❌ ERROR: Tencent Cloud secrets are not configured!
   - TENCENT_SECRET_ID: NOT SET
   - TENCENT_SECRET_KEY: ✅ SET
```

这表明 `TENCENT_SECRET_ID` Secret 未在 GitHub 仓库中配置。

## 原因

GitHub Secrets 中缺少 `TENCENT_SECRET_ID`。虽然 `TENCENT_SECRET_KEY` 已配置，但 Secret ID 仍然缺失。

## 解决方案

### 步骤 1: 获取腾讯云 API 凭证

1. 访问 [腾讯云控制台](https://console.cloud.tencent.com/)
2. 点击右上角 **头像** → **访问管理**
3. 在左侧菜单中选择 **API 密钥管理**
4. 找到或创建一个 API 密钥对
5. 复制以下两个值：
   - **Secret ID** (32 个字符)
   - **Secret Key** (88 个字符左右)

### 步骤 2: 在 GitHub 中添加 Secret

1. 访问你的仓库: [Azure-Terraform-AutoDeploy Settings](https://github.com/yingcaihuang/Azure-Terraform-AutoDeploy/settings)
2. 在左侧菜单选择 **Secrets and variables** → **Actions**
3. 点击 **New repository secret** 按钮
4. 在 "Name" 字段输入: `TENCENT_SECRET_ID`
5. 在 "Secret" 字段粘贴你的腾讯云 API Secret ID
6. 点击 **Add secret** 按钮

### 步骤 3: 验证配置

一旦 Secret 添加完成（可能需要等待 1-5 分钟）：

1. 进入仓库的 **feature/minimal-validation** 分支
2. 进行一个小的改动（如编辑 README）并推送
3. 这会自动触发 GitHub Actions 工作流
4. 在 **Actions** 标签页查看工作流执行
5. 点击 **terraform-validate-minimal** 工作流
6. 展开 **plan** job
7. 找到 **Debug - Check Tencent Cloud Secrets** 步骤
8. 验证输出显示:
   ```
   ✅ Tencent Cloud secrets are properly configured
      - Secret ID length: 32
      - Secret Key length: 88
   ```

## 快速参考

### GitHub Secrets URL

- 直接链接: https://github.com/yingcaihuang/Azure-Terraform-AutoDeploy/settings/secrets/actions

### 需要配置的 Secrets 清单

| Name | Status | Source |
|------|--------|--------|
| `TENCENT_SECRET_ID` | ❌ **需要添加** | 腾讯云 API 密钥管理 |
| `TENCENT_SECRET_KEY` | ✅ 已配置 | 腾讯云 API 密钥管理 |
| `AZURE_CREDENTIALS` | ✅ 已配置 | Azure Service Principal |

## 工作流触发

Secret 添加后，以下任何操作都会触发工作流：

1. **自动触发（推荐）**: 推送代码到 `feature/minimal-validation` 分支
2. **手动触发**: 在 GitHub Actions 中点击 "Run workflow" 按钮
3. **Pull Request**: 创建 PR 到 main 分支

## 测试步骤

完成 Secrets 配置后：

### 第一次运行 - Plan 阶段（自动）
```
✅ Terraform format check: PASSED
✅ Terraform init: PASSED
✅ Terraform validate: PASSED
✅ Debug - Check Tencent Cloud Secrets: PASSED (两个 Secret 都已设置)
✅ Terraform Plan: PASSED (应该显示 "Plan: 1 to add, 0 to change, 0 to destroy")
```

### 第二次运行 - Apply 阶段（手动）
```
在 GitHub Actions 中：
1. 点击 "Run workflow" 按钮
2. 选择 "apply" 作为操作
3. 点击 "Run workflow"
```

### 第三次运行 - Destroy 阶段（清理）
```
在 GitHub Actions 中：
1. 点击 "Run workflow" 按钮
2. 选择 "destroy" 作为操作
3. 点击 "Run workflow"
```

## 常见问题

### Q: 添加 Secret 后立即运行工作流，仍然显示 NOT SET？

**A:** GitHub 有 Secret 缓存，需要等待 1-5 分钟。尝试：
1. 等待 5 分钟后重新运行工作流
2. 或进行一个新的代码推送以触发新的工作流运行

### Q: 如何验证 Secret 值是否正确？

**A:** 在工作流日志中查看：
- 如果显示 `Secret ID length: 32` 和 `Secret Key length: 88`，说明值已正确加载
- 实际的 Secret 值会被隐藏为 `***` 以保护安全

### Q: 两个 Secret 的长度通常是多少？

**A:** 
- **TENCENT_SECRET_ID**: 通常 32 个字符
- **TENCENT_SECRET_KEY**: 通常 88 个字符

### Q: 如何重新编辑已添加的 Secret？

**A:** 
1. 进入 Settings → Secrets and variables → Actions
2. 找到要编辑的 Secret
3. 点击右侧的 **铅笔** 图标
4. 修改值后点击 **Update secret**

### Q: 能否在工作流日志中看到 Secret 的真实值？

**A:** 不能。GitHub Actions 会自动隐藏所有 Secret 的值，即使在日志输出中也显示为 `***`。

## 后续步骤

1. ✅ 添加 `TENCENT_SECRET_ID` Secret
2. ⏳ 等待 GitHub Secrets 同步（1-5 分钟）
3. 推送代码或手动触发工作流
4. 验证 "Debug - Check Tencent Cloud Secrets" 步骤显示两个 Secret 都已设置
5. 查看完整的 Terraform plan 输出
6. 如果 plan 成功，手动触发 "apply" 操作来创建 DNS 记录
7. 验证 DNS 记录已在腾讯云中创建
8. 手动触发 "destroy" 操作来清理资源

## 相关文档

- [GitHub Secrets 官方文档](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
- [腾讯云 API 密钥管理](https://console.cloud.tencent.com/cam/capi)
- [工作流文件](../blob/feature/minimal-validation/.github/workflows/terraform-validate-minimal.yml)

