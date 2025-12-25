resource "azurerm_cdn_frontdoor_rule_set" "this" {
  name                      = var.rule_set_name
  cdn_frontdoor_profile_id  = var.profile_id
}

resource "azurerm_cdn_frontdoor_rule" "jpg_cache" {
  count                      = var.enable_jpg ? 1 : 0
  name                       = var.jpg_rule_name
  cdn_frontdoor_rule_set_id  = azurerm_cdn_frontdoor_rule_set.this.id
  order                      = var.jpg_rule_order

  actions {
    response_header_action {
      header_action = "Overwrite"
      header_name   = "Cache-Control"
      value         = "public, max-age=${var.jpg_cache_seconds}"
    }
  }

  conditions {
    request_uri_condition {
      operator         = "EndsWith"
      match_values     = var.jpg_match_values
      negate_condition = false
      transforms       = ["Lowercase"]
    }
  }
}

resource "azurerm_cdn_frontdoor_rule" "css_cache" {
  count                      = var.enable_css ? 1 : 0
  name                       = var.css_rule_name
  cdn_frontdoor_rule_set_id  = azurerm_cdn_frontdoor_rule_set.this.id
  order                      = var.css_rule_order

  actions {
    response_header_action {
      header_action = "Overwrite"
      header_name   = "Cache-Control"
      value         = "public, max-age=${var.css_cache_seconds}"
    }
  }

  conditions {
    request_uri_condition {
      operator         = "EndsWith"
      match_values     = var.css_match_values
      negate_condition = false
      transforms       = ["Lowercase"]
    }
  }
}

resource "azurerm_cdn_frontdoor_rule" "no_cache" {
  count                      = var.enable_nocache ? 1 : 0
  name                       = var.nocache_rule_name
  cdn_frontdoor_rule_set_id  = azurerm_cdn_frontdoor_rule_set.this.id
  order                      = var.nocache_rule_order

  actions {
    response_header_action {
      header_action = "Overwrite"
      header_name   = "Cache-Control"
      value         = "no-store, no-cache, max-age=0"
    }
  }

  conditions {
    request_uri_condition {
      operator         = "BeginsWith"
      match_values     = var.nocache_match_values
      negate_condition = false
      transforms       = ["Lowercase"]
    }
  }
}

output "rule_set_id" { value = azurerm_cdn_frontdoor_rule_set.this.id }
