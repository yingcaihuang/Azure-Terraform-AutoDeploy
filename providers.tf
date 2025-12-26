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
  # 凭证来源优先级：
  # 1. TF_VAR_tencent_secret_id / TF_VAR_tencent_secret_key (GitHub Actions 设置)
  # 2. TENCENTCLOUD_SECRET_ID / TENCENTCLOUD_SECRET_KEY (环境变量)
  # 3. 本地 -var 参数
  # 直接使用变量值，SDK 会自动处理环保变量降级
  secret_id  = var.tencent_secret_id
  secret_key = var.tencent_secret_key
}
