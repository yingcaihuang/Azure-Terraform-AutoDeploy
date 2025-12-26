# GitHub Secrets 配置问题排查

## 🔴 当前状态

工作流报告错误：
```
❌ ERROR: Tencent Cloud secrets are not configured!
   - TENCENT_SECRET_ID: NOT SET
   - TENCENT_SECRET_KEY: ✅ SET
```

## 🎯 问题诊断

| 项目 | 状态 | 说明 |
|------|------|------|
| `TENCENT_SECRET_ID` | ❌ **未配置** | 需要立即添加 |
| `TENCENT_SECRET_KEY` | ✅ 已配置 | 正常工作 |
| `AZURE_CREDENTIALS` | ✅ 已配置 | 正常工作 |
| Terraform 配置 | ✅ 正确 | 所有工作流步骤都已修复 |

## 📋 立即需要做的事

### 第 1 步: 获取腾讯云 API Secret ID

访问: https://console.cloud.tencent.com/cam/capi

1. 登录腾讯云控制台
2. 在左侧菜单选择"访问管理"
3. 选择"API 密钥管理"
4. 找到或创建一个 API 密钥
5. **复制 "Secret ID"** 的值（32 个字符）

### 第 2 步: 在 GitHub 中添加 Secret

访问: https://github.com/yingcaihuang/Azure-Terraform-AutoDeploy/settings/secrets/actions

1. 点击 **"New repository secret"** 按钮
2. **Name**: `TENCENT_SECRET_ID`（完全匹配，区分大小写）
3. **Secret**: 粘贴你从腾讯云复制的 Secret ID
4. 点击 **"Add secret"** 保存

### 第 3 步: 验证

等待 1-5 分钟后，执行以下操作之一：

**选项 A - 推送代码**（推荐）
```bash
# 在本地进行一个小改动
echo "# Update" >> README.md
git add README.md
git commit -m "test: trigger workflow"
git push origin feature/minimal-validation
```

**选项 B - 手动触发**
1. 访问仓库的 Actions 标签页
2. 选择 "terraform-validate-minimal" 工作流
3. 点击 "Run workflow" 按钮
4. 选择分支 "feature/minimal-validation"
5. 点击 "Run workflow"

## ✅ 验证成功标志

在 GitHub Actions 日志中，"Debug - Check Tencent Cloud Secrets" 步骤应该显示：

```
✅ Tencent Cloud secrets are properly configured
   - Secret ID length: 32
   - Secret Key length: 88
```

## 📚 详细文档

- [完整的 Secrets 设置指南](TENCENT_SECRET_ID_MISSING.md)
- [本地测试脚本使用](test-locally.sh)
- [GitHub Secrets 快速设置](setup-github-secrets.sh)
- [工作流验证指南](verify-secrets.md)

## 🔧 工作流修复历史

最新修复 (commit: 84dad9f):
- ✅ 添加 Azure Login 到 apply 和 destroy 步骤
- ✅ 所有 Terraform Init 步骤都有环境变量上下文
- ✅ 环境变量在所有必要步骤中被正确传递
- ✅ 添加诊断脚本和文档

## 🚀 下一步

1. **立即**: 在 GitHub 中添加 `TENCENT_SECRET_ID` Secret
2. **等待**: 1-5 分钟 GitHub Secret 同步
3. **验证**: 触发工作流，检查 "Debug - Check Tencent Cloud Secrets" 步骤
4. **如果成功**:
   - Plan 阶段自动运行 ✅
   - 手动触发 Apply 来创建 DNS 记录
   - 手动触发 Destroy 来清理资源

## ⚠️ 常见问题

**Q: Secret 添加后仍然显示 NOT SET？**
- A: GitHub 有缓存，等待 5 分钟或进行新的 push 来触发新的工作流运行

**Q: 能看到 Secret 的实际值吗？**
- A: 不能，GitHub 自动隐藏 Secret 值。只能看到长度信息来验证是否正确加载

**Q: 如何编辑已添加的 Secret？**
- A: 进入 Settings → Secrets，点击 Secret 右侧的铅笔图标，更新值

## 📞 获取帮助

如果问题仍未解决，请检查：

1. Secret 名称是否完全正确（包括大小写）
2. Secret 值是否包含多余的空格
3. GitHub 界面是否显示 Secret 已存在
4. 工作流日志中 "Debug" 步骤的完整输出

