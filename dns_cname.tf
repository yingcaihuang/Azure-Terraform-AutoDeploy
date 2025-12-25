# Tencent Cloud DNSPod CNAME record for custom domain
# Automatically points the custom domain to the Front Door endpoint

resource "tencentcloud_dnspod_record" "custom_domain_cname" {
  count       = var.enable_dns_test_only ? 0 : 1
  domain      = var.dns_domain          # e.g., "gslb.vip"
  sub_domain  = var.dns_subdomain       # e.g., "hrdev"
  record_type = "CNAME"
  record_line = "默认"
  value       = azurerm_cdn_frontdoor_endpoint.this[0].host_name
  ttl         = 600

  depends_on = [
    azurerm_cdn_frontdoor_endpoint.this,
    module.tencent_dns_validation
  ]
}

output "cname_record_fqdn" {
  description = "The FQDN of the CNAME record pointing to Front Door endpoint."
  value       = try("${var.dns_subdomain}.${var.dns_domain}", null)
}

output "cname_target" {
  description = "The Front Door endpoint hostname that the CNAME points to."
  value       = try(azurerm_cdn_frontdoor_endpoint.this[0].host_name, null)
}

output "cname_record_id" {
  description = "The ID of the created CNAME record in DNSPod."
  value       = try(tencentcloud_dnspod_record.custom_domain_cname[0].id, null)
}
