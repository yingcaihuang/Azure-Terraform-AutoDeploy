# ========================================
# 最小化验证工作流配置
# ========================================
# 仅用于验证 Terraform + GitHub Actions + Azure 完整工作流
# 此配置只创建一个简单的资源组，不包含任何生产资源

# Azure 基础配置
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

# 以下变量仅在完整工作流中使用，在最小化验证中不需要配置
afd_profile_name    = "afd-profile"          # 占位符
domain_name         = "example.com"          # 占位符
origin_group_name   = "origin-group"         # 占位符
origin_name         = "origin-001"           # 占位符
origin_host_name    = "example.com"          # 占位符
origin_host_header  = "example.com"          # 占位符
