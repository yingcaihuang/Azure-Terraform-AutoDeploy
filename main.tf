# ========================================
# 最小化验证工作流 - 仅创建资源组
# ========================================
# 用于验证 Terraform + GitHub Actions + Azure 的完整工作流
# 避免部署复杂的生产资源，便于快速测试和调试

resource "azurerm_resource_group" "validation" {
  name     = var.resource_group_name
  location = var.location
  tags = merge(
    var.tags,
    {
      Environment = "validation"
      Purpose     = "Minimal workflow validation"
    }
  )
}
