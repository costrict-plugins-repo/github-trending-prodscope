---
name: verification
description: Use after Breaker ACCEPT and before Reliability scoring — gates completion on evidence that smoke steps actually pass.
---

# Verification (evidence gate)

Run this phase **after Breaker has accepted** and **before Reliability scoring**. No change is scored until there is evidence it works.

## Rule

Every claim of success requires **fresh output** from this session proving it. If a smoke step was not run, it did not pass.

## Process

1. Re-read the `HEALTH_CHECK` from the Builder's output.
2. For each smoke step, either:
   - **Run it** and include the output (command result, test output, build log).
   - **Document why it cannot be run** in the current environment (e.g., requires deployed infrastructure, CI-only step, needs credentials). Mark it as `SKIPPED — <reason>`.
3. Produce the verification summary.

## Output format

```
## VERIFICATION

### Passed
- [ ] `<command>` — <outcome summary>

### Skipped (with justification)
- [ ] `<step>` — SKIPPED: <reason it cannot be run here>

### Failed
- [ ] `<command>` — <failure output>
```

## On failure

If any smoke step **fails**, do not proceed to Reliability scoring. Return to Builder with the failure output as a new rejection item. This counts toward the 3-cycle rejection limit.

## On all-skipped

If every smoke step is skipped, the Reliability score must reflect this: a change with zero verified steps cannot score above **6/10** regardless of code quality.

## Shortcuts to avoid

| Shortcut | Why it's wrong |
|----------|---------------|
| "Tests should pass" without running them | Speculation is not evidence |
| Running a subset and claiming full pass | Untested paths are unknown paths |
| Marking steps as "verified" from prior context | Prior context may be stale; re-run in this session |
| Skipping verification because "the change is simple" | Simple changes break production too |
