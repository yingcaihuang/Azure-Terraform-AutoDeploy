#!/bin/bash

# 本地测试脚本 - 验证 Terraform 配置和环境变量

set -e

echo "================================"
echo "本地 Terraform 验证测试"
echo "================================"
echo ""

# 检查 Terraform 是否已安装
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform 未安装"
    echo "请先安装 Terraform: https://www.terraform.io/downloads"
    exit 1
fi

TERRAFORM_VERSION=$(terraform version | head -n 1 | grep -oP '(?<=v)\d+\.\d+\.\d+')
echo "✅ Terraform 版本: $TERRAFORM_VERSION"
echo ""

# 检查必要的 Secrets 环境变量
echo "================================"
echo "检查环境变量"
echo "================================"
echo ""

check_env_var() {
    local var_name=$1
    local var_value=${!var_name}
    
    if [ -z "$var_value" ]; then
        echo "❌ $var_name: NOT SET"
        return 1
    else
        local length=${#var_value}
        echo "✅ $var_name: SET (长度: $length 字符)"
        return 0
    fi
}

# 检查所有必要的环境变量
all_set=true

if ! check_env_var "TENCENTCLOUD_SECRET_ID"; then
    all_set=false
fi

if ! check_env_var "TENCENTCLOUD_SECRET_KEY"; then
    all_set=false
fi

if ! check_env_var "AZURE_CLIENT_ID"; then
    all_set=false
fi

if ! check_env_var "AZURE_CLIENT_SECRET"; then
    all_set=false
fi

echo ""

if [ "$all_set" = false ]; then
    echo "⚠️  一些环境变量未设置"
    echo ""
    echo "请在运行本脚本前设置环境变量:"
    echo ""
    echo "export TENCENTCLOUD_SECRET_ID=\"<your-secret-id>\""
    echo "export TENCENTCLOUD_SECRET_KEY=\"<your-secret-key>\""
    echo "export AZURE_CLIENT_ID=\"<your-client-id>\""
    echo "export AZURE_CLIENT_SECRET=\"<your-client-secret>\""
    echo ""
    exit 1
fi

echo "✅ 所有环境变量已设置"
echo ""

# 初始化 Terraform
echo "================================"
echo "初始化 Terraform"
echo "================================"
echo ""

terraform init

echo ""
echo "✅ Terraform init 完成"
echo ""

# 验证配置
echo "================================"
echo "验证 Terraform 配置"
echo "================================"
echo ""

terraform validate

echo ""
echo "✅ Terraform validate 完成"
echo ""

# 生成动态值
TIMESTAMP=$(date +%s)
SUBSCRIPTION_ID=$(az account show --query 'id' -o tsv 2>/dev/null || echo "UNKNOWN")

echo "================================"
echo "生成动态值"
echo "================================"
echo ""
echo "Timestamp (DNS Subdomain): $TIMESTAMP"
echo "Subscription ID (DNS Value): $SUBSCRIPTION_ID"
echo ""

# 运行 plan
echo "================================"
echo "运行 Terraform Plan"
echo "================================"
echo ""

terraform plan \
    -var-file="env/validation.tfvars" \
    -var="dns_subdomain=${TIMESTAMP}" \
    -out=tfplan \
    -lock=false

echo ""
echo "✅ Terraform plan 完成"
echo ""
echo "计划已保存到: tfplan"
echo ""
echo "运行 'terraform apply tfplan' 来应用计划"
echo ""

