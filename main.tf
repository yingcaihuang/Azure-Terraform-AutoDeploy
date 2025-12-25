# ========================================
# 最小化验证工作流 - DNS 验证
# ========================================
# 用于验证 Terraform + GitHub Actions + Tencent Cloud 的完整工作流
# 使用 dns_verify_only 模块测试 DNS 配置，避免复杂资源部署

# 导入独立的 DNS 验证配置
# 参考: dns_verify_only.tf
