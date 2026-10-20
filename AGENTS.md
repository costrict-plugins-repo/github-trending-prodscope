# Prodscope — project agents (Codex / OpenAI)

This repository defines **Prodscope**, an operational-first agentic plugin: a **Builder** proposes changes with explicit verification plans, and a **Breaker** (senior SRE mindset) reviews for production risks before anything is treated as done.

## Orchestration (how to run the loop)

For **every implementation task**, execute these four phases in order within a single response. Do not stop after Phase 1.

### Phase 1 — Builder

Read and follow [`skills/builder/SKILL.md`](skills/builder/SKILL.md):
1. Implement the smallest coherent diff.
2. Attach a `## HEALTH_CHECK` (smoke steps, signals to watch, rollback).

### Phase 2 — Breaker

Read and follow [`skills/breaker/SKILL.md`](skills/breaker/SKILL.md):
1. Review the Builder's proposal for production risks.
2. **REJECT** with specific fixes → loop back to Phase 1 (max 3 cycles).
3. **ACCEPT** (with optional nits) → proceed to Phase 3.

### Phase 3 — Verification

Read and follow [`skills/verification/SKILL.md`](skills/verification/SKILL.md):
1. Run HEALTH_CHECK smoke steps and capture evidence.
2. If any step fails, return to Builder (counts toward 3-cycle limit).
3. Document skipped steps with justification.

### Phase 4 — Reliability score

Read and follow [`skills/reliability/SKILL.md`](skills/reliability/SKILL.md):
1. Score the final change 1–10.
2. List top gaps.

If Breaker **REJECT**s, return to Builder with the listed fixes — do not silently patch around Breaker findings. After 3 rejected cycles, stop and present outstanding issues.

## Instruction sets (source of truth)

| Role | Path |
|------|------|
| Session bootstrap — when the loop runs | [`skills/using-prodscope/SKILL.md`](skills/using-prodscope/SKILL.md) |
| Builder — feature delivery + `HEALTH_CHECK` | [`skills/builder/SKILL.md`](skills/builder/SKILL.md) |
| Breaker — SRE review + REJECT / loop-back | [`skills/breaker/SKILL.md`](skills/breaker/SKILL.md) |
| Verification — evidence gate | [`skills/verification/SKILL.md`](skills/verification/SKILL.md) |
| Reliability score (1–10) | [`skills/reliability/SKILL.md`](skills/reliability/SKILL.md) |

## MCP and verification

- **Config placeholder:** [`mcp-config.json`](mcp-config.json) — starts with an empty `mcpServers` object; add Sentry/Datadog (or other) entries per vendor MCP docs and env vars only; **never** commit secrets. See `/prodscope:verify` template in [`commands/verify.md`](commands/verify.md).
- **Pre-merge hook:** [`hooks/pre-merge.js`](hooks/pre-merge.js) runs on task completion when using Claude Code with this plugin; it logs a gate and skips gracefully if Sentry/MCP is unavailable.

## Logging

Structured rejection and improvement lines under [`.prodscope/logs/`](.prodscope/logs/) — see format in `skills/reliability/SKILL.md`. Log files are gitignored.

## Cursor

Composer should still load [`.cursor/rules/prodscope.md`](.cursor/rules/prodscope.md) for Breaker-aligned skepticism when skills are not loaded the same way as in Claude Code.
