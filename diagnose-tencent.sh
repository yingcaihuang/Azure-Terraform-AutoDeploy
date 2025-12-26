#!/bin/bash

# Tencent Cloud 腾讯云认证诊断脚本
# 用于验证本地和 GitHub Actions 环境中的凭证配置

set -e

echo "🔍 开始诊断 Tencent Cloud 凭证配置..."
echo ""

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查环境变量
echo "📋 检查环境变量..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -z "$TENCENTCLOUD_SECRET_ID" ]; then
    echo -e "${RED}✗ TENCENTCLOUD_SECRET_ID: 未设置${NC}"
    SECRET_ID_SET=0
else
    echo -e "${GREEN}✓ TENCENTCLOUD_SECRET_ID: 已设置${NC}"
    echo "  长度: ${#TENCENTCLOUD_SECRET_ID}"
    SECRET_ID_SET=1
fi

if [ -z "$TENCENTCLOUD_SECRET_KEY" ]; then
    echo -e "${RED}✗ TENCENTCLOUD_SECRET_KEY: 未设置${NC}"
    SECRET_KEY_SET=0
else
    echo -e "${GREEN}✓ TENCENTCLOUD_SECRET_KEY: 已设置${NC}"
    echo "  长度: ${#TENCENTCLOUD_SECRET_KEY}"
    SECRET_KEY_SET=1
fi

echo ""

# 检查 Terraform 配置文件
echo "📄 检查 Terraform 配置文件..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "providers.tf" ]; then
    echo -e "${GREEN}✓ providers.tf: 存在${NC}"
    if grep -q "tencentcloud" providers.tf; then
        echo "  - Tencent Cloud 提供商已配置"
    fi
else
    echo -e "${RED}✗ providers.tf: 不存在${NC}"
fi

if [ -f "variables.tf" ]; then
    echo -e "${GREEN}✓ variables.tf: 存在${NC}"
    if grep -q "tencent_secret_id" variables.tf; then
        echo "  - tencent_secret_id 变量已定义"
    fi
    if grep -q "tencent_secret_key" variables.tf; then
        echo "  - tencent_secret_key 变量已定义"
    fi
else
    echo -e "${RED}✗ variables.tf: 不存在${NC}"
fi

if [ -f "env/validation.tfvars" ]; then
    echo -e "${GREEN}✓ env/validation.tfvars: 存在${NC}"
else
    echo -e "${RED}✗ env/validation.tfvars: 不存在${NC}"
fi

echo ""

# 检查 GitHub 工作流
echo "🔄 检查 GitHub 工作流配置..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f ".github/workflows/terraform-validate-minimal.yml" ]; then
    echo -e "${GREEN}✓ 工作流文件存在${NC}"
    if grep -q "TENCENTCLOUD_SECRET_ID" .github/workflows/terraform-validate-minimal.yml; then
        echo "  - TENCENTCLOUD_SECRET_ID 环境变量已配置"
    fi
    if grep -q "secrets.TENCENT_SECRET_ID" .github/workflows/terraform-validate-minimal.yml; then
        echo "  - GitHub Secret TENCENT_SECRET_ID 已映射"
    fi
else
    echo -e "${RED}✗ 工作流文件不存在${NC}"
fi

echo ""

# 诊断结果
echo "📊 诊断结果..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $SECRET_ID_SET -eq 1 ] && [ $SECRET_KEY_SET -eq 1 ]; then
    echo -e "${GREEN}✅ 本地环境变量配置完整${NC}"
    echo ""
    echo "下一步:"
    echo "1. 运行 'terraform init' 初始化"
    echo "2. 运行 'terraform plan -var-file=env/validation.tfvars -var=\"dns_subdomain=\$(date +%s)\"' 测试"
else
    echo -e "${RED}❌ 环境变量配置不完整${NC}"
    echo ""
    echo "请按照以下步骤配置:"
    if [ $SECRET_ID_SET -eq 0 ]; then
        echo "1. 设置 TENCENTCLOUD_SECRET_ID 环境变量"
        echo "   export TENCENTCLOUD_SECRET_ID='你的-secret-id'"
    fi
    if [ $SECRET_KEY_SET -eq 0 ]; then
        echo "2. 设置 TENCENTCLOUD_SECRET_KEY 环境变量"
        echo "   export TENCENTCLOUD_SECRET_KEY='你的-secret-key'"
    fi
    echo ""
    echo "或者，在 GitHub 中配置 Secrets:"
    echo "1. 访问 https://github.com/yingcaihuang/Azure-Terraform-AutoDeploy/settings/secrets/actions"
    echo "2. 创建 TENCENT_SECRET_ID Secret"
    echo "3. 创建 TENCENT_SECRET_KEY Secret"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 详细信息请查看: TENCENT_SETUP_GUIDE.md"
