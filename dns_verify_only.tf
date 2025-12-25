# Standalone DNS verification module
# This file is OPTIONAL. When enabled, it creates ONLY a test DNS record WITHOUT Front Door.
# 
# To use this for DNS-only testing:
#   1. Temporarily comment out or remove the main Front Door resources (main.tf, origins.tf, caching_rules.tf, dns_tencent.tf)
#   2. terraform plan -var-file=env/dev.tfvars
#   3. terraform apply -var-file=env/dev.tfvars
#   4. Check DNS verification results in output
#   5. terraform destroy to clean up
#   6. Restore the main Front Door files

variable "enable_dns_test_only" {
  type        = bool
  description = "Set to true to create ONLY the DNS test record (Front Door resources will not be created if all their files are commented out)."
  default     = false
}

module "dns_verify_test" {
  count               = var.enable_dns_test_only ? 1 : 0
  source              = "./modules/tencent_dns"
  domain              = var.dns_domain     # e.g., "gslb.vip"
  sub_domain          = var.dns_subdomain # 使用工作流传入的 timestamp
  record_type         = "TXT"
  record_line         = "默认"
  value               = var.subscription_id # 使用 Azure 订阅 ID 作为记录值
  ttl                 = 600
  enable_verify       = true      # Enable DNS verification
  verify_dns_server   = "1.1.1.1" # Use Cloudflare DNS for public check
  verify_retries      = 15        # Number of retry attempts
  verify_interval_sec = 10        # Seconds between retries
}

output "dns_verify_record_id" {
  description = "The ID of the test DNS record (only if enable_dns_test_only=true)."
  value       = try(module.dns_verify_test[0].record_id, null)
}

output "dns_verify_fqdn" {
  description = "The FQDN of the test DNS record (only if enable_dns_test_only=true)."
  value       = try(module.dns_verify_test[0].fqdn, null)
}

output "dns_verify_value" {
  description = "The value of the test DNS record (only if enable_dns_test_only=true)."
  value       = try(module.dns_verify_test[0].record_value, null)
}
