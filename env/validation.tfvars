# ========================================
# 最小化验证工作流配置 - DNS 验证模式
# ========================================
# 用于验证 Terraform + GitHub Actions + Tencent Cloud DNS 的完整工作流
# 此配置仅创建 DNS 测试记录，不部署任何 Azure 或 CDN 生产资源

# Azure 基础配置（必需但不使用）
subscription_id      = "2884693e-1b1f-4182-a931-38fce22157c4"
resource_group_name  = "rg-yingcai"
location             = "East US"

# 资源标签
tags = {
  Project      = "terraform-validation"
  Environment  = "validation"
  CreatedBy    = "Terraform"
  CreatedDate  = "2025-12-26"
}

# ========================================
# DNS 验证配置 (使用 dns_verify_only.tf)
# ========================================

# 启用 DNS 测试模式
enable_dns_test_only = true

# Tencent Cloud DNS 配置
tencent_secret_id  = "your-tencent-secret-id"    # 替换为实际值
tencent_secret_key = "your-tencent-secret-key"  # 替换为实际值

# DNS 域名配置
dns_domain    = "gslb.vip"     # 根域
dns_subdomain = "dnstest"      # 测试子域

# Front Door 占位符（在 DNS 测试模式下不使用）
afd_profile_name    = "afd-profile"          # 占位符
domain_name         = "example.com"          # 占位符
origin_group_name   = "origin-group"         # 占位符
origin_name         = "origin-001"           # 占位符
origin_host_name    = "example.com"          # 占位符
origin_host_header  = "example.com"          # 占位符
