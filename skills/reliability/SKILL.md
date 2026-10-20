---
name: reliability
description: Use after Breaker ACCEPT and Verification to score the final change 1-10 on reliability with an explicit rubric.
---

# Reliability score

Run this phase **after Breaker has accepted**. Rate the **final** change set on a **1–10** scale using the rubric below.

## Rubric (equal weight by default; adjust if the task is trivial)

| Dimension | What "good" looks like |
|-----------|-------------------------|
| **Tests** | Automated coverage for new logic; regression for fixed bugs; realistic integration where needed. |
| **Observability** | Logs/metrics/traces let operators detect failure and narrow blame. |
| **Error handling** | User-visible and internal errors are handled; no silent swallow of critical failures. |
| **Operational fit** | Config, migrations, rollbacks, and load characteristics are considered. |
| **Security** | AuthZ, secrets, and input validation appropriate to exposure. |

## Scoring guide

- **9–10** — Strong across dimensions; minor nits only.  
- **7–8** — Shippable with known follow-ups documented.  
- **5–6** — Significant gaps; risky without mitigation.  
- **1–4** — Not production-ready.

## Score anchoring examples

| Score | What the change looks like |
|-------|---------------------------|
| **4/10** | Feature works but has no tests, no error handling beyond happy path, no logging, and HEALTH_CHECK smoke steps were all skipped during verification. |
| **6/10** | Tests cover the happy path, errors are caught but logged generically, rollback plan exists but is manual. Some smoke steps passed, some skipped. |
| **8/10** | Tests cover happy path + key edge cases, structured logging for new failure modes, rollback is a config flag or revert. All runnable smoke steps passed. |
| **10/10** | Full test coverage including failure injection, metrics/alerts for new paths, automated rollback, migration tested both ways. Rare — reserve for genuinely thorough work. |

## Score inflation traps

| Trap | Correction |
|------|-----------|
| Defaulting to 7-8 because the code "looks clean" | Code quality is only one dimension; check tests, observability, ops, and security independently |
| Scoring 8+ when verification steps were all skipped | Zero verified steps caps the score at 6 regardless of code quality |
| Giving 9+ for trivial changes because "nothing can go wrong" | Trivial changes get trivially adjusted rubric weights, not inflated scores |
| Raising the score because the Builder "tried hard" across rejection cycles | Effort is not reliability; score the final artifact, not the process |

## Output format

```
## RELIABILITY: <score>/10

**Justification:** <1–2 sentences>

**Top gaps:**
- <gap, or "None — strong across dimensions">
```

## Logging (`.prodscope/logs/`)

After scoring, append one log line per significant event:

```text
ISO8601<TAB>agent<TAB>action<TAB>detail
```

Examples:

```text
2026-04-11T12:00:00Z	breaker	REJECT	missing index on users.email lookup
2026-04-11T12:05:00Z	builder	IMPROVE	added migration idx_users_email
2026-04-11T12:06:00Z	prodscope	ACCEPT	reliability 8/10 — shippable with follow-ups
```

`action` values: `REJECT`, `ACCEPT`, `IMPROVE`, `VERIFY`.
