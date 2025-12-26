terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.65.0"
    }
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = ">= 1.81.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "tencentcloud" {
  # 优先使用环境变量 TENCENTCLOUD_SECRET_ID 和 TENCENTCLOUD_SECRET_KEY
  # 若环境变量未设置，则使用 Terraform 变量（来自 -var 参数或 tfvars 文件）
  secret_id  = var.tencent_secret_id != "" ? var.tencent_secret_id : null
  secret_key = var.tencent_secret_key != "" ? var.tencent_secret_key : null
}
