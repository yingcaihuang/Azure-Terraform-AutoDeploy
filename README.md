# Azure Front Door + WAF via Terraform

This module creates an Azure Front Door (Standard/Premium) profile with WAF, an origin pointing to `www2.myccdn.info`, and caching rules:
- `*.jpg`: cache 30 days
- `*.css`: cache 1 day
- `/meto/*`: no cache

## Prereqs
- Terraform >= 1.6
- AzureRM provider >= 3.65
- Logged in via `az login` or set `ARM_*` env vars

## Usage
```bash
terraform init
terraform plan -var "resource_group_name=rg-frontdoor" -var "location=eastus" -var "afd_profile_name=afd-profile" -var "domain_name=www.myccdn.info"
terraform apply
```

If Azure CLI login does not propagate the subscription in your environment, pass it explicitly:

```bash
terraform plan \
  -var "resource_group_name=rg-frontdoor" \
  -var "location=eastus" \
  -var "afd_profile_name=afdprofile01" \
  -var "domain_name=www.myccdn.info" \
  -var "subscription_id=<YOUR_SUBSCRIPTION_ID>"
```

## Use tfvars (local state)

- Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in values.
- Default backend is local state; no Azure Storage blob required.

Run:

```bash
terraform init
terraform plan
terraform apply
```

## Use -var-file for environments

- Dev:
```bash
terraform init
terraform plan -var-file=env/dev.tfvars
terraform apply -var-file=env/dev.tfvars
```

- Prod:
```bash
terraform init
terraform plan -var-file=env/prod.tfvars
terraform apply -var-file=env/prod.tfvars
```

Variables are defined in `variables.tf`. Adjust as needed.

### Standalone Tencent DNS verification (optional)

You can use the standalone module at `modules/tencent_dns` to create and verify a TXT record independently from Azure Front Door.

#### DNS-only mode (without creating Front Door)

Use the predefined environment file `env/dns_test.tfvars` which enables DNS-only mode:

```bash
terraform plan -var-file=env/dns_test.tfvars
terraform apply -var-file=env/dns_test.tfvars
```

This will:
1. Create a test TXT record at `dnstest.gslb.vip` with value `dns-verify-test-hr`
2. Verify the record resolves via public DNS (Cloudflare 1.1.1.1) with retries every 10 seconds for up to 15 attempts
3. Output the record ID and FQDN

After testing, clean up:

```bash
terraform destroy -var-file=env/dns_test.tfvars
```

#### Custom DNS record in code

You can also add a custom DNS record module to any `.tf` file:

```hcl
module "test_txt" {
  source              = "./modules/tencent_dns"
  domain              = "gslb.vip"
  sub_domain          = "mytest"
  value               = "my-test-value-123"
  enable_verify       = true          # Enable DNS verification
  verify_dns_server   = "1.1.1.1"     # optional
  verify_retries      = 15            # optional (default 15)
  verify_interval_sec = 10            # optional (default 10)
}
```

#### Notes

- The integrated Front Door flow still uses a managed certificate with DNS validation via `dns_tencent.tf`. The TXT record is created automatically, with verification disabled to avoid blocking the certificate issuance process.
- Use DNS-only mode when you want to test DNS setup independently before creating Front Door infrastructure.
- Verification uses `dig` to query public DNS; ensure the record has time to propagate before the tool timeout.
