# Tencent Cloud DNS validation for Azure Front Door managed certificate
# Uses DNSPod API via tencentcloud provider

# Azure exposes a validation token for managed certificate validation.
# Create a TXT record at _dnsauth.<subdomain> to prove ownership.

locals {
  dnsauth_subdomain = "_dnsauth.${var.dns_subdomain}"
}

module "tencent_dns_validation" {
  count   = var.enable_dns_test_only ? 0 : 1
  source  = "./modules/tencent_dns"

  domain      = var.dns_domain
  sub_domain  = local.dnsauth_subdomain
  record_type = "TXT"
  record_line = "默认"
  value       = azurerm_cdn_frontdoor_custom_domain.custom[0].validation_token

  # Keep verification off for the integrated flow to avoid blocking AFD issuance.
  enable_verify = false
}
