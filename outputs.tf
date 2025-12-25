output "dns_verify_record_id" {
  description = "The ID of the DNS test record"
  value       = try(module.dns_verify_test[0].record_id, null)
}

output "dns_verify_fqdn" {
  description = "The FQDN of the DNS test record"
  value       = try(module.dns_verify_test[0].fqdn, null)
}

output "dns_verify_value" {
  description = "The value of the DNS test record"
  value       = try(module.dns_verify_test[0].record_value, null)
}

output "deployment_status" {
  description = "Deployment status message"
  value       = var.enable_dns_test_only ? "✅ DNS 验证工作流成功部署" : "⏭️ DNS 验证已禁用"
}

    meto_nocache = "no-cache (0 seconds)"
  }
}

output "deployment_summary" {
  description = "Deployment summary"
  value = {
    profile_name  = try(azurerm_cdn_frontdoor_profile.this[0].name, null)
    sku           = "Premium_AzureFrontDoor"
    endpoint_name = "endpoint"
    route_name    = "default-route-with-rules"
    waf_enabled   = true
    waf_mode      = "Prevention"
  }
}
