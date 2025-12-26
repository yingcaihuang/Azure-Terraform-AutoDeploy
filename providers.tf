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
  # 凭证获取优先级：
  # 1. -var 参数（非空时）
  # 2. 环境变量 TENCENTCLOUD_SECRET_ID / TENCENTCLOUD_SECRET_KEY
  # 当 var 为空时，Terraform 会自动使用同名的环境变量
  # 所以这里直接使用变量，让 Terraform SDK 处理环境变量降级
  secret_id  = var.tencent_secret_id != "" ? var.tencent_secret_id : null
  secret_key = var.tencent_secret_key != "" ? var.tencent_secret_key : null
}
