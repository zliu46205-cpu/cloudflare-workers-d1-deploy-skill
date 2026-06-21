# Troubleshooting Reference

## `Could not read package.json`

Log:

```text
npm error enoent Could not read package.json
path /opt/buildhome/repo/package.json
```

Cause: Cloudflare is building from a repository root that does not contain `package.json`.

Fix:

- Upload the project contents, not the parent folder.
- Set Cloudflare root directory to the subfolder containing `package.json`.
- Make sure `package.json` is committed at repo root if root directory is `/`.

## `InvalidSymbol` in `wrangler.jsonc`

Cause: plain English or Chinese text was left inside JSONC without comment markers.

Fix:

- Remove prose.
- Or prefix comments with `//`.
- Validate that `wrangler.jsonc` is valid JSONC.

## `D1_NOT_CONFIGURED`

Cause: Worker code expects `env.DB`, but `wrangler.jsonc` has no `d1_databases` block or the deployed Worker was not updated.

Fix:

1. Create D1 database.
2. Paste database ID into `wrangler.jsonc`.
3. Redeploy with `npx wrangler deploy`.
4. Check `/api/health`.

## `SEC_E_NO_CREDENTIALS` During Git Push

Log:

```text
schannel: AcquireCredentialsHandle failed: SEC_E_NO_CREDENTIALS
```

Cause: Windows Git credential layer has no usable GitHub credential.

Fix:

```powershell
git credential-manager github login
```

If still failing:

```powershell
git credential-manager erase
```

Input:

```text
protocol=https
host=github.com

```

Then:

```powershell
git credential-manager github login
git push origin main
```

In restricted Codex environments, rerun `git push` with escalated execution so it can access Windows credential UI/state.

## No `Retry build` Button

Workers deployments do not always show Pages-style `Retry build`.

Use direct deploy:

```powershell
npm.cmd run build
npx wrangler deploy
```

If the project is Cloudflare Pages connected to GitHub, look at the Pages build details page. Workers version history is different from Pages build logs.

## workers.dev Opens On Phone But Not PC

Likely causes:

- PC DNS cache
- firewall/proxy
- browser cache
- local network issue

Try:

```powershell
ipconfig /flushdns
nslookup <worker>.workers.dev
curl.exe -I https://<worker>.workers.dev/
```
