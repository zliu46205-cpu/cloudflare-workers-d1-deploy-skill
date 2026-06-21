# Cloudflare Configuration Reference

## Worker With Assets

Use this when a Vite/React app needs API routes and static asset serving from the same Cloudflare Worker.

```jsonc
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "name": "my-worker",
  "compatibility_date": "2026-06-18",
  "main": "./worker/index.mjs",
  "assets": {
    "binding": "ASSETS",
    "directory": "./dist",
    "not_found_handling": "single-page-application"
  }
}
```

`assets.binding` must match the Worker code:

```js
const assetResponse = await env.ASSETS.fetch(request);
```

## Static Only

Use this when there is no API or D1:

```jsonc
{
  "$schema": "node_modules/wrangler/config-schema.json",
  "name": "my-static-site",
  "compatibility_date": "2026-06-18",
  "assets": {
    "directory": "./dist",
    "not_found_handling": "single-page-application"
  }
}
```

## D1 Binding

Add this block only after the database exists:

```jsonc
"d1_databases": [
  {
    "binding": "DB",
    "database_name": "xuanxue",
    "database_id": "7ad4c265-d678-4467-8cf3-7d191fcc0596"
  }
]
```

In Worker code, access it as `env.DB`.

## Common Mistakes

- `After creating a Cloudflare D1 database...` appears inside `wrangler.jsonc` without `//`: JSONC parser reports `InvalidSymbol`.
- `name` does not match the intended Worker: deployment creates or updates the wrong Worker.
- `main` is missing while API endpoints are expected: `/api/*` cannot work.
- `assets.directory` is not `./dist` for a Vite app: deployed site has no built assets.
- Uploading the repo with app files inside a nested folder: Cloudflare cannot find `package.json`.
