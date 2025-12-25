variable "domain" {
  type        = string
  description = "The DNS root domain in Tencent Cloud DNSPod (e.g., gslb.vip)."
}

variable "sub_domain" {
  type        = string
  description = "The subdomain to create under the root domain (e.g., _dnsauth.www)."
}

variable "record_type" {
  type        = string
  description = "DNS record type. For validation use TXT."
  default     = "TXT"
}

variable "record_line" {
  type        = string
  description = "DNSPod line name. Usually use '默认'."
  default     = "默认"
}

variable "value" {
  type        = string
  description = "The record value (e.g., Azure Front Door validation token)."
}

variable "ttl" {
  type        = number
  description = "Record TTL in seconds."
  default     = 600
}

variable "enable_verify" {
  type        = bool
  description = "Whether to verify the record becomes visible via public DNS resolvers."
  default     = false
}

variable "verify_dns_server" {
  type        = string
  description = "Which DNS server to query for verification (e.g., 1.1.1.1 or 8.8.8.8)."
  default     = "1.1.1.1"
}

variable "verify_retries" {
  type        = number
  description = "How many times to retry DNS query during verification."
  default     = 15
}

variable "verify_interval_sec" {
  type        = number
  description = "Seconds between verification retries."
  default     = 10
}
