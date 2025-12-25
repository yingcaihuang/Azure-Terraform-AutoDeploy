output "deployment_status" {
  description = "Deployment status message"
  value       = var.enable_dns_test_only ? "✅ DNS 验证工作流成功部署" : "⏭️ DNS 验证已禁用"
}
