#!/bin/bash

# GitHub Actions Terraform 工作流诊断脚本

echo "=========================================="
echo "GitHub Actions Terraform 诊断"
echo "=========================================="
echo ""

# 检查 env 目录
echo "1. 检查 env 目录文件："
if [ -d "env" ]; then
    ls -lh env/*.tfvars 2>/dev/null || echo "❌ 没有找到 tfvars 文件"
else
    echo "❌ env 目录不存在"
fi
echo ""

# 检查 terraform 文件
echo "2. 检查 Terraform 文件："
echo "主配置文件："
ls -lh *.tf | head -5
echo ""

# 检查工作流文件
echo "3. 检查 GitHub Actions 工作流："
if [ -d ".github/workflows" ]; then
    ls -lh .github/workflows/*.yml
else
    echo "❌ .github/workflows 目录不存在"
fi
echo ""

# 验证 YAML 语法
echo "4. 验证 YAML 文件语法："
echo "检查 terraform-plan.yml..."
if command -v yq &> /dev/null; then
    yq eval '.jobs.terraform-plan.steps[] | .name' .github/workflows/terraform-plan.yml | head -5
    echo "✅ YAML 格式正确"
else
    echo "⚠️  yq 未安装，跳过详细 YAML 检查"
fi
echo ""

# 检查 git 配置
echo "5. 检查 Git 配置："
echo "当前分支: $(git branch --show-current 2>/dev/null || echo '未初始化')"
echo "远程: $(git remote -v 2>/dev/null | head -1 || echo '未配置')"
echo ""

# 检查 .gitignore
echo "6. 检查 .gitignore 规则："
if [ -f ".gitignore" ]; then
    echo "✅ .gitignore 存在"
    grep -E "tfstate|\.terraform" .gitignore || echo "⚠️  缺少状态文件忽略规则"
else
    echo "❌ .gitignore 不存在"
fi
echo ""

# 建议
echo "=========================================="
echo "故障排查建议："
echo "=========================================="
echo ""
echo "如果遇到 'env/dev.tfvars does not exist' 错误："
echo ""
echo "1. 确保所有 tfvars 文件都已提交到 GitHub"
echo "   $ git add env/*.tfvars"
echo "   $ git commit -m 'Add environment files'"
echo "   $ git push origin main"
echo ""
echo "2. 验证 GitHub Secrets 已配置："
echo "   进入 Settings → Secrets and variables → Actions"
echo "   检查以下 Secrets 是否存在："
echo "   - AZURE_SUBSCRIPTION_ID"
echo "   - AZURE_TENANT_ID"
echo "   - AZURE_CLIENT_ID"
echo "   - AZURE_CLIENT_SECRET"
echo ""
echo "3. 检查工作流是否成功检出代码："
echo "   在 Actions 日志中查看 'Checkout code' 步骤"
echo ""
echo "4. 确保 tfvars 文件不在 .gitignore 中被忽略"
echo "   (当前仓库中可以提交示例 tfvars 和占位符值)"
echo ""
