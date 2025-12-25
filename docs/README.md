# 文档导航

欢迎！这里是 Azure Terraform 自动化部署项目的文档中心。

## 🎯 按需求快速查找

### 我想快速了解

👉 **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** （5分钟）
- 工作流配置速查表
- GitHub Secret 配置
- 常用 Azure CLI 命令
- 工作流模板

### 我要配置 Azure 登录

👉 **[AZURE-LOGIN-SETUP.md](AZURE-LOGIN-SETUP.md)** （10分钟）
- AZURE_CREDENTIALS 生成方法
- JSON 格式说明
- GitHub Secrets 配置步骤
- 故障排查

### 我要学习 Azure CLI 命令

👉 **[AZURE-CLI-GITHUB-ACTIONS.md](AZURE-CLI-GITHUB-ACTIONS.md)** （20分钟）
- 常用 Azure CLI 命令
- 工作流中的实际应用
- 高级用法
- 错误处理和最佳实践

### 我要配置 GitHub Secrets

👉 **[GITHUB-ACTIONS-SETUP.md](GITHUB-ACTIONS-SETUP.md)** （15分钟）
- 所有 Secrets 的详细配置
- 权限管理
- 安全最佳实践

### 我刚升级了工作流

👉 **[../AZURE-LOGIN-UPDATE.md](../AZURE-LOGIN-UPDATE.md)** （项目根目录）
- 升级内容总结
- 配置清单
- 下一步指南

## 📚 文档目录

| 文档 | 页数 | 用途 |
|-----|-----|------|
| QUICK-REFERENCE.md | 5 | 快速参考和模板 |
| AZURE-LOGIN-SETUP.md | 20 | 详细配置指南 |
| AZURE-CLI-GITHUB-ACTIONS.md | 25 | 完整命令参考 |
| GITHUB-ACTIONS-SETUP.md | 15 | Secrets 配置 |

**总计**：约 65 页精心整理的文档

## 🚀 推荐阅读顺序

1. **第一次使用** 
   - 先读 QUICK-REFERENCE.md
   - 然后读 AZURE-LOGIN-SETUP.md

2. **需要深入了解**
   - 阅读 AZURE-CLI-GITHUB-ACTIONS.md
   - 查看 GITHUB-ACTIONS-SETUP.md

3. **遇到问题**
   - 查找相关文档中的故障排查部分
   - 查看工作流日志

## 💡 核心概念

### azure/login@v2
最新的 Azure 身份验证方式，使用 AZURE_CREDENTIALS 进行登录。

### azure/cli@v2
在工作流中运行 Azure CLI 命令的 Action。

### Terraform
基础设施即代码（IaC）工具，用于管理 Azure 资源。

### GitHub Actions
CI/CD 自动化平台，自动执行部署任务。

## 🔗 快速链接

- [Azure 官方文档](https://docs.microsoft.com/azure)
- [Terraform 官方文档](https://www.terraform.io/docs)
- [GitHub Actions 文档](https://docs.github.com/actions)

## ⚡ 常见问题速答

**Q: 需要配置 4 个 Azure Secrets 吗？**
A: 不需要。现在只需 1 个 AZURE_CREDENTIALS。

**Q: 工作流多久运行一次？**
A: Plan 工作流在 push 时自动运行，Apply/Destroy 需手动触发。

**Q: 如何查看工作流日志？**
A: GitHub → Actions → 选择工作流 → 查看最新运行。

**Q: 删除了很多文档是为什么？**
A: 新的文档更新、更精准、无重复，便于维护和理解。

---

**有问题？** 查看相关文档的故障排查部分，或查看工作流日志获取错误详情。

**最后更新**：2025 年 12 月 25 日
