# Phase 1: Wire selected_social_content - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-24
**Mode:** Interactive (discuss)

---

## Gray Areas Presented

Three areas were identified:
1. `social_content: :boolean` behavior after `selected_social_content` is added
2. GEN-01/GEN-02 verification approach (code-read vs new spec)
3. TST-03 scope (extend existing service spec vs new context)

User selected area 1 only.

---

## Area: social_content: :boolean

**Question:** How should `social_content: :boolean` behave once `selected_social_content` is exposed on the rule resource?

**Options presented:**
- Keep writable (Recommended) — Leave as-is, monitoring reports writing true/false continue to work. `selected_social_content` is additive.
- Make read-only — Restrict to readable only, callers must use `selected_social_content` going forward. Breaking change.

**Selected:** Keep writable

**Decision logged:** D-03, D-04 in CONTEXT.md

---

## Areas Not Discussed

- GEN-01/GEN-02 verification — not selected. Researcher/planner to treat as code-verification (service already correct).
- TST-03 scope — not selected. Researcher/planner to investigate existing spec and determine if a new context is needed.
