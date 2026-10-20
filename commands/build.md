---
name: prodscope:build
description: "Run the full Builder → Breaker → Verify → Score loop in a single pass. Usage: /prodscope:build <task description>"
---

# /prodscope:build — Prodscope orchestrated workflow

You are running the **Prodscope Builder-Breaker loop**. Complete all four phases below **in this single response**. Do not stop after Phase 1 — continue through all phases automatically.

---

## Phase 1: Builder

Read and follow `skills/builder/SKILL.md`. For the user's task:

1. Implement or propose the smallest coherent diff.
2. Produce a `## HEALTH_CHECK` section with smoke steps, signals to watch, and rollback plan.
3. Mark the end of your Builder output with:

```
---
✅ BUILDER COMPLETE — entering Breaker review
---
```

Do **not** wait for user input. Immediately proceed to Phase 2.

---

## Phase 2: Breaker

Now switch roles. Read and follow `skills/breaker/SKILL.md`. Review **everything you just proposed in Phase 1** as a senior SRE:

1. Walk through the review checklist (async/concurrency, databases, long-running processes, security/ops).
2. Evaluate whether the HEALTH_CHECK is credible.
3. Produce a verdict:

**If material flaws exist**, output:

```
## REJECT

**Reasons:**
- (bullet list with file/symbol references)

**Required fixes:**
- (specific changes the Builder must make)
```

Then **immediately re-enter Phase 1** as Builder: apply the required fixes, update the HEALTH_CHECK, and run Phase 2 again. Repeat until the Breaker accepts. Maximum 3 cycles — if still rejected after 3, stop and present all outstanding issues to the user.

**If no material flaws** (or only minor nits), output:

```
## ACCEPT

**Nits (optional follow-ups):**
- (list, or "None")
```

Then proceed to Phase 3.

---

## Phase 3: Verification

Read and follow `skills/verification/SKILL.md`. Before scoring, **prove the change works**:

1. Re-read the HEALTH_CHECK smoke steps.
2. Run each step and capture output, or document why it cannot be run.
3. If any step fails, return to Builder (counts toward the 3-cycle limit).
4. Output the `## VERIFICATION` summary, then proceed to Phase 4.

---

## Phase 4: Reliability score

Read and follow `skills/reliability/SKILL.md`. Score the **final** accepted change set:

1. Rate 1–10 using the rubric (tests, observability, error handling, operational fit, security).
2. Output:

```
## RELIABILITY: <score>/10

**Justification:** (1–2 sentences)

**Top gaps:**
- (or "None — strong across dimensions")
```

3. If `.prodscope/logs/` exists, append a log line:
   `<ISO8601>\tprodscope\t<ACCEPT|REJECT>\t<one-line summary>`

---

## Rules

- Complete all phases in one response. Never stop after Phase 1 alone.
- If Breaker rejects, loop back to Builder silently — do not ask the user to intervene unless 3 cycles are exhausted.
- The user should see the full chain: Builder output → Breaker verdict → Verification evidence → Reliability score.
