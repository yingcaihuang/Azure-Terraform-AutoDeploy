# Prod environment variables
resource_group_name = "rg-frontdoor-prod"
location            = "eastus"
afd_profile_name    = "afdprofile-prod"
domain_name         = "www.gslb.vip"
subscription_id     = "00000000-0000-0000-0000-000000000000"
dns_domain          = "gslb.vip"
dns_subdomain       = "www"
tencent_secret_id   = "your-tencent-secret-id"
tencent_secret_key  = "your-tencent-secret-key"

# Override origin configuration if needed
origin_group_name   = "origin-group"
origin_name         = "www2-gslb-vip"
origin_host_name    = "www2.gslb.vip"
origin_host_header  = "www2.gslb.vip"
origin_http_port    = 80
origin_https_port   = 443
