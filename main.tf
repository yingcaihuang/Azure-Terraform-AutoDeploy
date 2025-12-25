# Resource Group (created if not exists)
resource "azurerm_resource_group" "this" {
  count    = var.enable_dns_test_only ? 0 : 1
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Azure Front Door profile (Standard/Premium)
resource "azurerm_cdn_frontdoor_profile" "this" {
  count               = var.enable_dns_test_only ? 0 : 1
  name                = var.afd_profile_name
  resource_group_name = azurerm_resource_group.this[0].name
  sku_name            = "Premium_AzureFrontDoor"
  tags                = var.tags
}

# Endpoint
resource "azurerm_cdn_frontdoor_endpoint" "this" {
  count                    = var.enable_dns_test_only ? 0 : 1
  name                     = "endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id
}

module "origins" {
  count               = var.enable_dns_test_only ? 0 : 1
  source              = "./modules/origins"
  profile_id          = azurerm_cdn_frontdoor_profile.this[0].id
  origin_group_name   = var.origin_group_name
  origin_name         = var.origin_name
  origin_host_name    = var.origin_host_name
  origin_host_header  = var.origin_host_header
  origin_http_port    = var.origin_http_port
  origin_https_port   = var.origin_https_port
}

module "caching" {
  count         = var.enable_dns_test_only ? 0 : 1
  source        = "./modules/caching"
  profile_id    = azurerm_cdn_frontdoor_profile.this[0].id
  rule_set_name = "cachingrules"
}

# Route with caching rules
resource "azurerm_cdn_frontdoor_route" "default_with_rules" {
  count                           = var.enable_dns_test_only ? 0 : 1
  name                            = "default-route-with-rules"
  cdn_frontdoor_endpoint_id       = azurerm_cdn_frontdoor_endpoint.this[0].id
  cdn_frontdoor_origin_group_id   = module.origins[0].origin_group_id
  cdn_frontdoor_origin_ids        = [module.origins[0].origin_id]
  cdn_frontdoor_rule_set_ids      = [module.caching[0].rule_set_id]
  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.custom[0].id]
  https_redirect_enabled          = true
  supported_protocols             = ["Http", "Https"]
  patterns_to_match               = ["/*"]
  forwarding_protocol             = "MatchRequest"

  link_to_default_domain = true

  depends_on = [module.origins, module.caching, azurerm_cdn_frontdoor_custom_domain.custom]
}

# WAF Policy
resource "azurerm_cdn_frontdoor_firewall_policy" "waf" {
  count               = var.enable_dns_test_only ? 0 : 1
  name                = "afdwafpolicy"
  resource_group_name = azurerm_resource_group.this[0].name
  sku_name            = azurerm_cdn_frontdoor_profile.this[0].sku_name

  enabled = true
  mode    = "Prevention"

  managed_rule {
    type    = "DefaultRuleSet"
    version = "1.0"
    action  = "Block"
  }
}

resource "azurerm_cdn_frontdoor_custom_domain" "custom" {
  count                    = var.enable_dns_test_only ? 0 : 1
  name                     = "fdcustomdomain01"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id
  host_name                = var.domain_name

  tls {
    certificate_type = "ManagedCertificate"
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "afd_security" {
  count                    = var.enable_dns_test_only ? 0 : 1
  name                     = "afdsecuritypolicy01"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this[0].id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.waf[0].id
      association {
        patterns_to_match = ["/*"]
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.custom[0].id
        }
      }
    }
  }
}
