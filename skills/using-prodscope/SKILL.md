---
name: using-prodscope
description: Use when starting a session or before treating any implementation as complete — establishes whether the Builder-Breaker loop should run.
---

# Using Prodscope

Prodscope is a **production gate**, not a workflow framework. Before treating any code change as done, decide whether the Builder-Breaker loop applies.

## When the loop MUST run

- The user invokes `/prodscope:build`
- You are implementing, modifying, or deleting production code (not just reading or answering questions)
- The change touches error handling, data stores, authentication, external calls, or async logic
- The change would be deployed to users

## When the loop may be skipped

- The user explicitly opts out ("skip prodscope", "just make the change", etc.)
- The task is purely informational (explaining code, answering questions)
- The change is documentation-only with no behavioral impact
- The change is a trivial typo fix in a non-code file

## How to run it

Follow the three phases in order. Do not stop after Phase 1.

1. **Builder** — `skills/builder/SKILL.md`: implement the smallest coherent diff + `HEALTH_CHECK`
2. **Breaker** — `skills/breaker/SKILL.md`: SRE review; REJECT with fixes or ACCEPT
3. **Verification** — `skills/verification/SKILL.md`: confirm smoke steps pass with evidence
4. **Reliability** — `skills/reliability/SKILL.md`: score 1–10

## Priority

1. User's explicit instructions (always highest)
2. Prodscope skills (this gate)
3. Default agent behavior
