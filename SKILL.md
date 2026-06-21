---
name: cloudflare-workers-d1-deploy
description: Deploy and troubleshoot Vite/React static or SPA websites on Cloudflare Workers/Pages with Wrangler, Worker Assets, D1 database bindings, GitHub repository publishing, custom domains, DNS nameservers, and Git Credential Manager. Use when a user wants to publish a frontend site so it stays online while their computer is off; connect GitHub to Cloudflare; configure wrangler.jsonc; create or bind a D1 database; fix Cloudflare build/deploy logs such as missing package.json, invalid wrangler config, D1 not configured, or GitHub credential errors; or prepare a repo/zip that can be uploaded to GitHub and deployed by Cloudflare.
---

# Cloudflare Workers D1 Deploy

Use this skill to take a local Vite/React web app from workspace to a public Cloudflare deployment with optional D1 persistence and a custom domain. Prefer concrete commands, checks, and deployment evidence over abstract hosting advice.

## Operating Model

Treat the flow as five layers:

1. **Local app**: source builds successfully with `npm run build`.
2. **Repository**: GitHub contains the project root, especially `package.json`, `src/`, `public/`, `worker/`, and `wrangler.jsonc`.
3. **Cloudflare build/deploy**: Wrangler deploys the Worker and serves built assets.
4. **Data**: D1 is created, bound, schema-applied, and visible through `/api/health`.
5. **Domain**: nameservers or DNS records point traffic to Cloudflare.

Do not skip layers. When a later layer fails, verify earlier layers first.

## Initial Inspection

Run these checks before changing anything:

```powershell
Get-ChildItem -Force
Get-Content -Raw package.json
Get-Content -Raw wrangler.jsonc
npm.cmd run build
```

If the project may already be a Git repo:

```powershell
git status --short
git remote -v
git branch --show-current
```

If `.git` is empty or invalid, do not assume local Git works. Use a temporary clone or prepare an upload zip.

For a repeatable local audit, use `scripts/check_project.ps1`.

## Deployment Decision Tree

### Standard path: GitHub plus Cloudflare auto-deploy

Use when the user has a normal GitHub repo connected to Cloudflare Pages/Workers.

1. Verify `package.json` is at the repository root.
2. Commit source files, not `node_modules`.
3. Push to the branch Cloudflare watches, usually `main`.
4. In Cloudflare, check `Workers & Pages -> project -> Deployments`.
5. If no deployment starts, use Wrangler direct deploy or check project connection.

### Direct path: Wrangler deploy

Use when GitHub auto-deploy is not configured, delayed, or the project is a Worker with assets.

```powershell
npm.cmd run build
npx wrangler deploy
```

If the browser asks for Cloudflare login, let the user complete login. Do not ask for API tokens unless necessary.

### Manual upload path: GitHub zip

Use when Git credentials are unavailable and the user can upload files in the GitHub UI.

1. Create a clean archive from a Git commit if possible:
   ```powershell
   git archive --format=zip --output=..\project-upload.zip HEAD
   ```
2. Otherwise package only deployable source files.
3. Tell the user to extract the zip and upload the extracted files, not the zip file itself.

## Wrangler Configuration

For Vite/React served from a Worker with assets and D1, use:

```jsonc
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "name": "your-worker-name",
  "compatibility_date": "2026-06-18",
  "main": "./worker/index.mjs",
  "assets": {
    "binding": "ASSETS",
    "directory": "./dist",
    "not_found_handling": "single-page-application"
  },
  "d1_databases": [
    {
      "binding": "DB",
      "database_name": "your-db-name",
      "database_id": "paste-d1-id-here"
    }
  ]
}
```

If no backend/API is needed, `main` and `d1_databases` may be omitted and Cloudflare can serve only static assets. If SPA routes must work, keep `not_found_handling`.

Read `references/cloudflare-config.md` before editing `wrangler.jsonc`.

## D1 Workflow

Use D1 only for data that must persist after refresh or across users, such as reports, users, orders, credits, or usage logs.

1. Create database in Cloudflare dashboard: `Storage & databases -> D1 SQL Database -> Create`.
2. Copy the database ID into `wrangler.jsonc`.
3. Add schema in `schema.sql`.
4. Apply schema:
   ```powershell
   npx wrangler d1 execute <database_name> --file=./schema.sql --remote
   ```
5. Confirm the Worker can see D1:
   ```text
   https://<worker-domain>/api/health
   ```

Expected healthy response:

```json
{
  "ok": true,
  "storage": "d1"
}
```

Read `references/d1.md` for schema and endpoint patterns.

## GitHub Credential Recovery

If `git push` fails with `SEC_E_NO_CREDENTIALS`, fix Windows GitHub login:

```powershell
git credential-manager github login
```

If stale credentials block login:

```powershell
git credential-manager erase
```

Then enter:

```text
protocol=https
host=github.com

```

Run login again and retry push. If Codex sandbox cannot access credentials, request escalated execution for `git push`, or fall back to the zip upload path.

Read `references/troubleshooting.md` for common failure signatures.

## Domain Workflow

For a custom domain bought from a registrar:

1. Add the domain to Cloudflare.
2. Cloudflare provides two nameservers.
3. In the registrar, replace existing nameservers with Cloudflare nameservers.
4. Wait for activation, usually minutes to 24 hours.
5. In Cloudflare Worker/Pages, add a custom domain route.

Do not confuse Web Analytics "Add site" with domain binding. DNS/Domain setup is under Cloudflare `Domains` or the specific Worker/Pages `Domains` tab.

Read `references/domain.md` before guiding DNS changes.

## Validation Checklist

A deployment is not done until these pass:

- `npm run build` passes locally.
- Cloudflare deployment status is successful.
- Main URL loads the app, not a blank page or source listing.
- SPA refresh works on non-root routes if applicable.
- `/api/health` returns JSON if a Worker API is present.
- D1-backed actions save and list data if the feature exists.
- Browser console has no asset 404s or framework overlays.
- Custom domain resolves after nameserver activation.

For frontend UI validation, pair this skill with a frontend testing/debugging skill when available.

## Safety and Account Boundaries

- Do not ask the user to paste passwords, OTPs, API tokens, or registrar secrets into chat.
- Before changing DNS, submitting account forms, or publishing live changes through browser automation, get explicit confirmation if the user did not already authorize that exact action.
- Prefer commands that use browser-based OAuth login for Wrangler and Git Credential Manager.

## Common User Requests

Examples this skill should handle:

```text
把我的 React/Vite 网站部署到 Cloudflare，电脑关机后也能访问。
```

```text
Cloudflare 构建报 package.json not found，帮我修。
```

```text
我创建了 D1 数据库，这个 database_id 填在哪里？
```

```text
GitHub 凭证没有打通，git push 报 SEC_E_NO_CREDENTIALS，怎么解决？
```

```text
我买了域名，怎么绑定到 Cloudflare Worker？
```
