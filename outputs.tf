output "resource_group_id" {
  description = "Resource Group ID"
  value       = azurerm_resource_group.validation.id
}

output "resource_group_name" {
  description = "Resource Group Name"
  value       = azurerm_resource_group.validation.name
}

output "resource_group_location" {
  description = "Resource Group Location"
  value       = azurerm_resource_group.validation.location
}

output "deployment_status" {
  description = "Deployment status message"
  value       = "✅ 最小化验证工作流成功部署 - 资源组 '${azurerm_resource_group.validation.name}' 已创建"
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
