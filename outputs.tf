output "frontdoor_profile_id" {
  description = "Azure Front Door Profile ID"
  value       = try(azurerm_cdn_frontdoor_profile.this[0].id, null)
}

output "endpoint_hostname" {
  description = "Front Door endpoint hostname"
  value       = try(azurerm_cdn_frontdoor_endpoint.this[0].host_name, null)
}

output "resource_group_name" {
  description = "Resource Group Name"
  value       = try(azurerm_resource_group.this[0].name, null)
}

output "custom_domain_name" {
  description = "Custom domain configured"
  value       = try(azurerm_cdn_frontdoor_custom_domain.custom[0].host_name, null)
}

output "custom_domain_validation_token" {
  description = "Custom domain validation token"
  value       = try(azurerm_cdn_frontdoor_custom_domain.custom[0].validation_token, null)
  sensitive   = true
}

output "origin_host" {
  description = "Origin server hostname"
  value       = try(module.origins[0].origin_host_name, null)
}

output "dns_validation_record" {
  description = "DNS validation record FQDN"
  value       = try("_dnsauth.${var.dns_subdomain}.${var.dns_domain}", null)
}

output "cname_fqdn" {
  description = "CNAME record FQDN (should point to endpoint_hostname)"
  value       = try("${var.dns_subdomain}.${var.dns_domain}", null)
}

output "waf_policy_id" {
  description = "WAF Policy ID"
  value       = try(azurerm_cdn_frontdoor_firewall_policy.waf[0].id, null)
}

output "caching_rules" {
  description = "Configured caching rules"
  value = {
    jpg_cache   = "30 days (2592000 seconds)"
    css_cache   = "1 day (86400 seconds)"
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
