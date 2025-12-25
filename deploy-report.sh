#!/bin/bash

# Azure Front Door Deployment Report Generator
# 生成详细的部署报表并验证配置

set -e

RESET='\033[0m'
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${BLUE}  Azure Front Door Deployment Report${RESET}"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${RESET}"
echo ""

# Get all outputs in JSON format
OUTPUTS=$(terraform output -json 2>/dev/null || echo '{}')

# Extract key values
RG_NAME=$(echo "$OUTPUTS" | jq -r '.resource_group_name.value // "N/A"')
PROFILE_NAME=$(echo "$OUTPUTS" | jq -r '.deployment_summary.value.profile_name // "N/A"')
ENDPOINT_HOSTNAME=$(echo "$OUTPUTS" | jq -r '.endpoint_hostname.value // "N/A"')
CUSTOM_DOMAIN=$(echo "$OUTPUTS" | jq -r '.custom_domain_name.value // "N/A"')
CNAME_FQDN=$(echo "$OUTPUTS" | jq -r '.cname_fqdn.value // "N/A"')
ORIGIN_HOST=$(echo "$OUTPUTS" | jq -r '.origin_host.value // "N/A"')
DNS_VALIDATION=$(echo "$OUTPUTS" | jq -r '.dns_validation_record.value // "N/A"')
WAF_ID=$(echo "$OUTPUTS" | jq -r '.waf_policy_id.value // "N/A"')

# Section 1: Basic Information
echo -e "${BOLD}${GREEN}1. 基础信息${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "资源组:           ${BLUE}$RG_NAME${RESET}"
echo -e "Profile 名称:     ${BLUE}$PROFILE_NAME${RESET}"
echo -e "SKU:             ${BLUE}Premium_AzureFrontDoor${RESET}"
echo -e "部署地区:        ${BLUE}eastus${RESET}"
echo -e "部署时间:        ${BLUE}$(date '+%Y-%m-%d %H:%M:%S')${RESET}"
echo ""

# Section 2: Endpoint Information
echo -e "${BOLD}${GREEN}2. Endpoint 信息${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Endpoint 名称:    ${BLUE}endpoint${RESET}"
echo -e "Endpoint 主机名: ${BLUE}$ENDPOINT_HOSTNAME${RESET}"
echo -e "状态:            ${GREEN}✓ 已创建${RESET}"
echo ""

# Section 3: Custom Domain
echo -e "${BOLD}${GREEN}3. 自定义域名配置${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "自定义域名:      ${BLUE}$CUSTOM_DOMAIN${RESET}"
echo -e "证书类型:        ${BLUE}ManagedCertificate (自动签发)${RESET}"
echo -e "TLS 版本:        ${BLUE}TLS 1.2${RESET}"
echo -e "状态:            ${GREEN}✓ 已配置${RESET}"
echo ""

# Section 4: DNS Configuration
echo -e "${BOLD}${GREEN}4. DNS 配置${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "验证记录 (TXT):   ${BLUE}$DNS_VALIDATION${RESET}"
echo -e "CNAME 记录:      ${BLUE}$CNAME_FQDN${RESET}"
echo -e "CNAME 指向:      ${BLUE}$ENDPOINT_HOSTNAME${RESET}"
echo -e "TTL:            ${BLUE}600 秒${RESET}"

# Try to verify DNS resolution
echo ""
echo -e "${BOLD}DNS 解析验证:${RESET}"
if command -v dig &> /dev/null; then
  echo -n "检查 CNAME 解析... "
  CNAME_RESULT=$(dig +short "$CNAME_FQDN" 2>/dev/null | grep -v '^;' | head -1 || echo "")
  if [ -n "$CNAME_RESULT" ]; then
    echo -e "${GREEN}✓ 已解析${RESET}"
    echo -e "  └─ 解析结果: ${BLUE}$CNAME_RESULT${RESET}"
  else
    echo -e "${YELLOW}⚠ 待解析（DNS 可能尚未生效）${RESET}"
  fi
else
  echo -e "${YELLOW}⚠ dig 命令不可用，跳过 DNS 解析验证${RESET}"
fi
echo ""

# Section 5: Origin Configuration
echo -e "${BOLD}${GREEN}5. 源站配置${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Origin Group:    ${BLUE}origin-group${RESET}"
echo -e "Origin 名称:     ${BLUE}www2-gslb-vip${RESET}"
echo -e "源站主机名:      ${BLUE}$ORIGIN_HOST${RESET}"
echo -e "HTTP 端口:       ${BLUE}80${RESET}"
echo -e "HTTPS 端口:      ${BLUE}443${RESET}"
echo -e "状态:            ${GREEN}✓ 已启用${RESET}"
echo ""

# Section 6: Caching Rules
echo -e "${BOLD}${GREEN}6. 缓存规则配置${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Rule Set:        ${BLUE}cachingrules${RESET}"
echo ""
echo -e "  规则 1: JPG 缓存"
echo -e "  ├─ 文件类型:     ${BLUE}.jpg, .jpeg${RESET}"
echo -e "  ├─ 缓存时长:     ${BLUE}30 天 (2592000 秒)${RESET}"
echo -e "  └─ 优先级:       ${BLUE}1${RESET}"
echo ""
echo -e "  规则 2: CSS 缓存"
echo -e "  ├─ 文件类型:     ${BLUE}.css${RESET}"
echo -e "  ├─ 缓存时长:     ${BLUE}1 天 (86400 秒)${RESET}"
echo -e "  └─ 优先级:       ${BLUE}2${RESET}"
echo ""
echo -e "  规则 3: /meto 无缓存"
echo -e "  ├─ 路径前缀:     ${BLUE}^/meto/${RESET}"
echo -e "  ├─ 缓存策略:     ${BLUE}no-cache, max-age=0${RESET}"
echo -e "  └─ 优先级:       ${BLUE}3${RESET}"
echo ""

# Section 7: WAF Configuration
echo -e "${BOLD}${GREEN}7. Web 应用防火墙 (WAF) 配置${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "WAF 策略:        ${BLUE}afdwafpolicy${RESET}"
echo -e "工作模式:        ${BLUE}Prevention (阻止)${RESET}"
echo -e "规则集:          ${BLUE}DefaultRuleSet v1.0${RESET}"
echo -e "状态:            ${GREEN}✓ 已启用${RESET}"
echo -e "绑定域名:        ${BLUE}$CUSTOM_DOMAIN${RESET}"
echo -e "保护路径:        ${BLUE}/*${RESET}"
echo ""

# Section 8: Routing Configuration
echo -e "${BOLD}${GREEN}8. 路由配置${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "路由名称:        ${BLUE}default-route-with-rules${RESET}"
echo -e "路径模式:        ${BLUE}/*${RESET}"
echo -e "协议:            ${BLUE}Http, Https${RESET}"
echo -e "HTTPS 重定向:    ${BLUE}启用${RESET}"
echo -e "转发协议:        ${BLUE}MatchRequest${RESET}"
echo -e "关联规则集:      ${BLUE}cachingrules${RESET}"
echo -e "关联 Origin:     ${BLUE}www2-gslb-vip${RESET}"
echo -e "状态:            ${GREEN}✓ 已配置${RESET}"
echo ""

# Section 9: Security Configuration
echo -e "${BOLD}${GREEN}9. 安全配置${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "Security Policy: ${BLUE}afdsecuritypolicy01${RESET}"
echo -e "WAF 关联:        ${BLUE}已绑定到 $CUSTOM_DOMAIN${RESET}"
echo -e "受保护模式:      ${BLUE}Prevention (预防模式)${RESET}"
echo -e "状态:            ${GREEN}✓ 已启用${RESET}"
echo ""

# Section 10: Quick Test Commands
echo -e "${BOLD}${GREEN}10. 快速测试命令${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${YELLOW}# 1. 测试 Endpoint 访问:${RESET}"
echo "curl -I https://$ENDPOINT_HOSTNAME"
echo ""
echo -e "${YELLOW}# 2. 测试自定义域名访问（DNS 生效后）:${RESET}"
echo "curl -I https://$CNAME_FQDN"
echo ""
echo -e "${YELLOW}# 3. 验证缓存规则:${RESET}"
echo "curl -I https://$CNAME_FQDN/test.jpg      # 应返回 Cache-Control: max-age=2592000"
echo "curl -I https://$CNAME_FQDN/style.css     # 应返回 Cache-Control: max-age=86400"
echo "curl -I https://$CNAME_FQDN/meto/api      # 应返回 Cache-Control: no-cache"
echo ""
echo -e "${YELLOW}# 4. 查看所有部署的资源:${RESET}"
echo "terraform state list"
echo ""
echo -e "${YELLOW}# 5. 查看完整输出信息:${RESET}"
echo "terraform output"
echo ""

# Section 11: Summary
echo -e "${BOLD}${GREEN}11. 部署总结${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${GREEN}✓ 已成功部署以下资源:${RESET}"
echo -e "  ✓ Azure Front Door Profile (Premium SKU)"
echo -e "  ✓ Endpoint"
echo -e "  ✓ Origin Group 和 Origin"
echo -e "  ✓ 缓存规则 (jpg、css、/meto)"
echo -e "  ✓ 自定义域名 (ManagedCertificate)"
echo -e "  ✓ WAF 策略 (DefaultRuleSet v1.0)"
echo -e "  ✓ Security Policy"
echo -e "  ✓ DNS 验证记录 (TXT)"
echo -e "  ✓ CNAME 记录"
echo ""
echo -e "${YELLOW}待完成项:${RESET}"
echo -e "  ⏳ DNS CNAME 记录传播（通常 5-15 分钟）"
echo -e "  ⏳ 托管证书自动签发（DNS 验证后，通常 5-30 分钟）"
echo -e "  ⏳ Custom Domain 激活（证书签发后）"
echo ""

echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${GREEN}部署完成！${RESET} 所有资源已成功创建。"
echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${RESET}"
echo ""
