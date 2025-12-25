# Azure Terraform 自动化部署

用于在 GitHub Actions 上实现 Azure 资源的自动化部署、验证和销毁。

## 🚀 快速开始

### 1️⃣ 生成 Azure 凭证

```bash
az ad sp create-for-rbac \
  --name "github-terraform-sp" \
  --role Contributor \
  --scopes /subscriptions/<your-id> \
  --json-auth
```

### 2️⃣ 配置 GitHub Secret

GitHub → Settings → Secrets and variables → Actions → New Secret
- Name: `AZURE_CREDENTIALS`
- Value: 上面的 JSON 输出

### 3️⃣ 推送代码

```bash
git add .
git commit -m "Configure Azure deployment"
git push origin main
```

## 📖 文档

| 文档 | 用途 |
|-----|-----|
| [AZURE-LOGIN-UPDATE.md](AZURE-LOGIN-UPDATE.md) | 升级说明和下一步 |
| [docs/QUICK-REFERENCE.md](docs/QUICK-REFERENCE.md) | 快速参考和模板 |
| [docs/AZURE-LOGIN-SETUP.md](docs/AZURE-LOGIN-SETUP.md) | Azure 凭证配置 |
| [docs/AZURE-CLI-GITHUB-ACTIONS.md](docs/AZURE-CLI-GITHUB-ACTIONS.md) | Azure CLI 命令参考 |
| [docs/GITHUB-ACTIONS-SETUP.md](docs/GITHUB-ACTIONS-SETUP.md) | GitHub Secrets 配置 |

## 🔄 工作流

### Terraform Plan
- **触发**：Push 到 main/develop 分支
- **功能**：验证配置 + 生成部署计划
- **输出**：部署计划摘要

### Terraform Apply
- **触发**：手动运行
- **功能**：实际部署资源到 Azure
- **输出**：部署摘要

### Terraform Destroy
- **触发**：手动运行（需要确认）
- **功能**：销毁 Azure 资源
- **输出**：销毁摘要

## 📋 文件结构

```
.github/workflows/
├── terraform-plan.yml
├── terraform-apply.yml
└── terraform-destroy.yml

env/
├── dev.tfvars
├── prod.tfvars
└── dns_test.tfvars

docs/
├── QUICK-REFERENCE.md
├── AZURE-LOGIN-SETUP.md
├── AZURE-CLI-GITHUB-ACTIONS.md
└── GITHUB-ACTIONS-SETUP.md
```

## 🔑 环境变量

**必需**：
- `AZURE_CREDENTIALS` - Azure Service Principal 凭证

**可选**：
- `TENCENT_SECRET_ID` - Tencent Cloud 密钥
- `TENCENT_SECRET_KEY` - Tencent Cloud 密钥
- `SLACK_WEBHOOK` - Slack 通知

## 🛠️ 常见操作

### 验证 Terraform 配置
```bash
terraform validate
```

### 本地 Plan
```bash
terraform plan -var-file="env/dev.tfvars"
```

### 查看工作流日志
GitHub → Actions → 选择工作流 → 查看运行

## 📞 需要帮助？

查看相关文档：
- **快速上手** → [QUICK-REFERENCE.md](docs/QUICK-REFERENCE.md)
- **配置凭证** → [AZURE-LOGIN-SETUP.md](docs/AZURE-LOGIN-SETUP.md)
- **Azure CLI** → [AZURE-CLI-GITHUB-ACTIONS.md](docs/AZURE-CLI-GITHUB-ACTIONS.md)

---

**最后更新**：2025 年 12 月 25 日
