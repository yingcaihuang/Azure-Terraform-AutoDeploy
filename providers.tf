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
  # Tencent Cloud 提供商会自动从以下来源读取凭证（按优先级）：
  # 1. TENCENTCLOUD_SECRET_ID 和 TENCENTCLOUD_SECRET_KEY 环境变量
  # 2. 如果省略 secret_id/secret_key，提供商会自动使用环境变量
  # 
  # GitHub Actions 工作流设置这两个环境变量：
  #   env:
  #     TENCENTCLOUD_SECRET_ID: ${{ secrets.TENCENT_SECRET_ID }}
  #     TENCENTCLOUD_SECRET_KEY: ${{ secrets.TENCENT_SECRET_KEY }}
}
