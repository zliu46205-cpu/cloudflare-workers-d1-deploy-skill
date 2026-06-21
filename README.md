# cloudflare-workers-d1-deploy-skill
A Codex skill for deploying Vite/React apps to Cloudflare Workers with Wrangler, D1, GitHub, and custom dom用于指导 Codex 将 Vite / React 网站部署到 Cloudflare Workers，支持 Wrangler 部署、D1 数据库绑定、GitHub 推送、构建报错排查和自定义域名配置。ains.
SKILL.md：主工作流，覆盖本地构建、GitHub、Cloudflare、Wrangler、D1、域名、验证和安全边界
agents/openai.yaml：Codex UI 元数据
references/cloudflare-config.md：wrangler.jsonc 配置模板
references/d1.md：D1 建库、schema、健康检查、插入模式
references/domain.md：域名、nameserver、Worker 自定义域名流程
references/troubleshooting.md：常见报错排查
scripts/check_project.ps1：本地项目结构检查脚本
