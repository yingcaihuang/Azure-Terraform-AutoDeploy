variable "resource_group_name" {
  type        = string
  description = "Resource group to deploy Front Door"
}

variable "location" {
  type        = string
  description = "Azure location for RG and supporting resources"
}

variable "afd_profile_name" {
  type        = string
  description = "Azure Front Door profile name"
}

variable "domain_name" {
  type        = string
  description = "Custom domain to route (e.g., www.myccdn.info)"
}

variable "tags" {
  type        = map(string)
  description = "Common resource tags"
  default     = {}
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID to use with the azurerm provider"
}

variable "tencent_secret_id" {
  type        = string
  description = "Tencent Cloud SecretId for DNSPod API"
  default     = null
}

variable "tencent_secret_key" {
  type        = string
  description = "Tencent Cloud SecretKey for DNSPod API"
  default     = null
}

variable "dns_domain" {
  type        = string
  description = "Root DNS domain managed in Tencent Cloud (e.g., gslb.vip)"
  default     = "gslb.vip"
}

variable "dns_subdomain" {
  type        = string
  description = "Subdomain part for Azure FD custom domain (e.g., www)"
  default     = "www"
}

# Origin configuration (can be overridden via tfvars)
variable "origin_group_name" {
  type        = string
  description = "Front Door origin group name"
  default     = "origin-group"
}

variable "origin_name" {
  type        = string
  description = "Front Door origin name"
  default     = "www2-gslb-vip"
}

variable "origin_host_name" {
  type        = string
  description = "Origin host name"
  default     = "www2.gslb.vip"
}

variable "origin_host_header" {
  type        = string
  description = "Origin host header"
  default     = "www2.gslb.vip"
}

variable "origin_http_port" {
  type        = number
  description = "Origin HTTP port"
  default     = 80
}

variable "origin_https_port" {
  type        = number
  description = "Origin HTTPS port"
  default     = 443
}
