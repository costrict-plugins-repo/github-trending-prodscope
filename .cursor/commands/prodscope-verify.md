---
name: prodscope:verify
description: Run after Builder proposes changes — structured verification using MCP when configured (Sentry, Datadog, Cloudflare, Stripe, AWS, etc.).
---

# /prodscope:verify — Prodscope verification pass

Use this command (`/prodscope:verify`) **after** the Builder has proposed a diff and attached `HEALTH_CHECK`, and **before** treating work as merge-ready.

## Steps

1. **Re-read** `HEALTH_CHECK` from the Builder output (or `HEALTH_CHECK.md`). Execute smoke steps locally or in CI if available.
2. **Telemetry** — If `mcp-config.json` lists MCP servers (Sentry, Datadog, …), invoke the relevant MCP tools to confirm no new critical issues for the touched surface. If no servers are configured, **skip** with a one-line note—do not block.
3. **Third-party** — Extend this flow by adding MCP server entries for Cloudflare, Stripe, AWS, or others next to Sentry/Datadog; operators merge config per vendor docs and keep secrets in env only.
4. **Breaker** — Run Breaker review (`skills/breaker/SKILL.md`). If **REJECT**, return to Builder; do not merge.

## Copy-paste operator template (Sentry / Datadog)

Add entries under `mcpServers` in `mcp-config.json` using the **exact** command and args from your vendor’s current MCP documentation. Example shape only—**do not** commit tokens:

```json
{
  "mcpServers": {
    "sentry": {
      "command": "npx",
      "args": ["-y", "<package-from-sentry-docs>"],
      "env": {
        "SENTRY_AUTH_TOKEN": "${SENTRY_AUTH_TOKEN}"
      }
    },
    "datadog": {
      "command": "npx",
      "args": ["-y", "<package-from-datadog-docs>"],
      "env": {
        "DD_API_KEY": "${DD_API_KEY}",
        "DD_SITE": "${DD_SITE}"
      }
    }
  }
}
```

## Optional: strict mode

If your team requires telemetry checks before merge, set policy in your runner or Breaker skill; the default Prodscope template allows skip when MCP is unset.
