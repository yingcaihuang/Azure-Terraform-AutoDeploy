# DNS verification testing environment
# This file only enables the DNS test module.
# It inherits Tencent credentials from dev.tfvars or pass them via command line.

resource_group_name = "rg-frontdoor-dev"
location            = "eastus"
afd_profile_name    = "afdprofile-dev"
domain_name         = "hrdev.gslb.vip"
subscription_id     = "00000000-0000-0000-0000-000000000000"
dns_domain          = "gslb.vip"
dns_subdomain       = "hrdev"
tencent_secret_id   = "your-tencent-secret-id"
tencent_secret_key  = "your-tencent-secret-key"

# Enable DNS test only mode (no Front Door resources created)
enable_dns_test_only = true
