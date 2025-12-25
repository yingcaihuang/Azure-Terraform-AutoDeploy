output "record_id" {
  description = "The created DNS record ID."
  value       = tencentcloud_dnspod_record.this.id
}

output "fqdn" {
  description = "The fully-qualified domain name of the created record."
  value       = "${var.sub_domain}.${var.domain}"
}

output "record_value" {
  description = "The value stored in the DNS record."
  value       = var.value
  sensitive   = false
}
