locals {
  fqdn = "${var.sub_domain}.${var.domain}"
}

resource "tencentcloud_dnspod_record" "this" {
  domain      = var.domain
  sub_domain  = var.sub_domain
  record_type = var.record_type
  record_line = var.record_line
  value       = var.value
  ttl         = var.ttl
}

# Optional verification that the record resolves publicly to the expected value.
resource "null_resource" "verify" {
  count = var.enable_verify ? 1 : 0

  triggers = {
    record_id = tencentcloud_dnspod_record.this.id
    fqdn      = local.fqdn
    value     = var.value
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      fqdn="${local.fqdn}"
      expect="${var.value}"
      dns="${var.verify_dns_server}"
      retries=${var.verify_retries}
      interval=${var.verify_interval_sec}
      echo "Verifying TXT for ${local.fqdn} on ${var.verify_dns_server}..."
      for i in $(seq 1 "$retries"); do
        result=$(dig +short TXT "$fqdn" @"$dns" | tr -d '"') || true
        if echo "$result" | grep -q "$expect"; then
          echo "Verification succeeded: $result"; exit 0
        fi
        echo "Attempt $i/$retries: not found yet. Sleeping $interval sec..."
        sleep "$interval"
      done
      echo "Verification failed: TXT not matching expected value after $retries attempts." >&2
      exit 1
    EOT
  }
}
