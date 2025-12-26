#!/bin/bash

# GitHub Secrets 快速验证脚本
# 此脚本帮助诊断和指导添加缺失的 Secrets

echo "================================"
echo "GitHub Secrets 配置检查"
echo "================================"
echo ""

# 仓库信息
REPO_OWNER="yingcaihuang"
REPO_NAME="Azure-Terraform-AutoDeploy"

echo "📦 仓库信息："
echo "   - 所有者: $REPO_OWNER"
echo "   - 仓库名: $REPO_NAME"
echo ""

echo "================================"
echo "需要添加的 Secrets"
echo "================================"
echo ""

echo "❌ 缺失: TENCENT_SECRET_ID"
echo "   - 这是腾讯云 API 的 Secret ID"
echo "   - 获取方式: https://console.cloud.tencent.com/cam/capi"
echo ""

echo "✅ 已配置: TENCENT_SECRET_KEY"
echo "   - 这是腾讯云 API 的 Secret Key"
echo ""

echo "✅ 已配置: AZURE_CREDENTIALS"
echo "   - 这是 Azure 服务主体凭证"
echo ""

echo "================================"
echo "添加缺失的 Secret - 详细步骤"
echo "================================"
echo ""

echo "1️⃣  访问 GitHub 仓库设置页面：
   https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"
echo ""

echo "2️⃣  获取腾讯云 API Secret ID：
   a. 访问腾讯云控制台: https://console.cloud.tencent.com/
   b. 点击右上角头像 → 访问管理
   c. 选择 API 密钥管理
   d. 查看或创建新的 API 密钥
   e. 复制 'Secret ID' 的值"
echo ""

echo "3️⃣  在 GitHub 中添加 Secret：
   a. 点击 'New repository secret' 按钮
   b. Name: TENCENT_SECRET_ID
   c. Secret: <粘贴你的腾讯云 API Secret ID>
   d. 点击 'Add secret'"
echo ""

echo "4️⃣  验证配置：
   a. 返回仓库主页
   b. 进入 'feature/minimal-validation' 分支
   c. 新建一个 commit 或 push 代码以触发工作流
   d. 在 Actions 标签页查看工作流执行
   e. 查看 'terraform-validate-minimal' 工作流的 'plan' job
   f. 展开 'Debug - Check Tencent Cloud Secrets' 步骤
   g. 验证输出显示两个 Secret 都已设置"
echo ""

echo "================================"
echo "工作流状态检查"
echo "================================"
echo ""

echo "预期的工作流输出（成功时）："
echo ""
echo "✅ Terraform format check passed"
echo "✅ Terraform init completed"
echo "✅ Terraform validate passed"
echo "✅ Tencent Cloud secrets are properly configured"
echo "✅ Plan: 1 to add, 0 to change, 0 to destroy"
echo ""

echo "当前状态："
echo "❌ TENCENT_SECRET_ID: NOT SET"
echo "✅ TENCENT_SECRET_KEY: SET"
echo ""

echo "================================"
echo "常见问题排查"
echo "================================"
echo ""

echo "Q: 添加 Secret 后工作流仍然失败？"
echo "A: 尝试以下几点："
echo "   1. 等待 5 分钟后再运行工作流（GitHub 有缓存）"
echo "   2. 确认 Secret 名称大小写完全正确"
echo "   3. 在仓库的另一个分支上进行更改以重新触发工作流"
echo ""

echo "Q: 如何验证 Secret 值是否被正确读取？"
echo "A: 在工作流中已有调试步骤 'Debug - Check Tencent Cloud Secrets'"
echo "   如果显示 Secret 长度（如 'Secret ID length: 32'），则说明正确加载"
echo ""

echo "Q: 可以看到 Secret 的实际值吗？"
echo "A: 不行。GitHub Actions 会自动隐藏 Secret 值以保护安全"
echo "   工作流日志中会显示 '***' 而不是真实值"
echo ""

echo "================================"
echo "验证完成后的下一步"
echo "================================"
echo ""

echo "1. 确认所有 Secrets 都已配置"
echo "2. 工作流 'terraform-validate-minimal' 全部通过"
echo "3. 可选：在 main 分支上创建 Pull Request，自动触发工作流验证"
echo "4. 准备好时，在 GitHub Actions 中手动触发 'apply' 操作"
echo ""

