# GitHub Secrets 验证指南

## 问题根因

GitHub Actions 工作流中出现错误：
```
❌ ERROR: Tencent Cloud secrets are not configured!
   - TENCENT_SECRET_ID: NOT SET
   - TENCENT_SECRET_KEY: ✅ SET
```

这表明 `TENCENT_SECRET_ID` Secret 未正确配置。

## 解决步骤

### 1. 验证 GitHub Secrets 配置

访问你的 GitHub 仓库设置：
- 路径: Settings → Secrets and variables → Actions

### 2. 检查必需的 Secrets

确保以下 Secrets 已设置：

| Secret 名称 | 说明 | 来源 |
|----------|------|------|
| `AZURE_CREDENTIALS` | Azure Service Principal 凭证 (JSON 格式) | Azure 门户 |
| `TENCENT_SECRET_ID` | 腾讯云 API Secret ID | 腾讯云控制台 |
| `TENCENT_SECRET_KEY` | 腾讯云 API Secret Key | 腾讯云控制台 |

### 3. 获取腾讯云凭证

1. 登录 [腾讯云控制台](https://console.cloud.tencent.com/)
2. 进入 **访问管理** → **API密钥管理**
3. 创建新的 API 密钥或使用现有的：
   - **Secret ID** (等同于 Access Key ID)
   - **Secret Key** (等同于 Access Key Secret)

### 4. 添加到 GitHub Secrets

在仓库 Settings → Secrets 中：

1. 点击 "New repository secret"
2. Name: `TENCENT_SECRET_ID`
3. Value: `<你的腾讯云 API Secret ID>`
4. 点击 "Add secret"

重复相同步骤添加 `TENCENT_SECRET_KEY`

### 5. 验证配置

完成后，工作流中的调试步骤应该显示：
```
✅ Tencent Cloud secrets are properly configured
   - Secret ID length: 32
   - Secret Key length: 88
```

## 工作流执行

修复完成后：

1. 推送代码到 `feature/minimal-validation` 分支
2. GitHub Actions 会自动触发 `terraform validate` 和 `terraform plan`
3. 查看工作流日志，验证是否存在以下错误：
   - ✅ "Terraform format check passed"
   - ✅ "Terraform validate passed"  
   - ✅ "Tencent Cloud secrets are properly configured"
   - ✅ "Plan: 1 to add, 0 to change, 0 to destroy"

## 本地测试（可选）

如果想在本地验证，可以运行：

```bash
# 设置环境变量
export TENCENTCLOUD_SECRET_ID="<你的Secret ID>"
export TENCENTCLOUD_SECRET_KEY="<你的Secret Key>"

# 初始化 Terraform
terraform init

# 运行 plan
TIMESTAMP=$(date +%s)
terraform plan \
  -var-file="env/validation.tfvars" \
  -var="dns_subdomain=${TIMESTAMP}" \
  -lock=false
```

## 常见问题

### Q: 仍然收到 "Please set your `secret_id` and `secret_key`" 错误

A: 检查以下几点：
1. Secret 名称是否完全正确（区分大小写）
2. Secret 值是否为空或包含空格
3. 重新保存 Secret 以确保更改生效（GitHub 有缓存）

### Q: 如何重新设置 Secret？

A: 
1. 进入 Settings → Secrets
2. 找到要更新的 Secret
3. 点击右侧的铅笔图标编辑
4. 更新值
5. 点击 "Update secret"

### Q: 如何验证 Secret 值是否正确？

A: 在 GitHub Actions 工作流中添加调试步骤（类似我们工作流中的 Debug 步骤），会显示 Secret 长度以验证是否正确加载。

## 提交历史

最新修复 (commit: 6c86009):
- ✅ 添加缺失的 Azure Login 到 apply 和 destroy 步骤
- ✅ 确保所有步骤中都正确传递 TENCENTCLOUD_* 环境变量
- ✅ Terraform Init 步骤现在有环境变量上下文

