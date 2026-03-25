# Roadmap: Social Scheduled Reports Backend Plumbing

## Overview

Wire `selected_social_content` end-to-end: expose it as a readable/writable attribute on the Graphiti resource, confirm report generation filters by it via `enabled_media_types`, and add specs proving both directions work. All foundational PRs are merged — this milestone is one focused delivery.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Wire selected_social_content** - Expose the attribute on the resource, confirm generation filtering, and add covering specs

## Phase Details

### Phase 1: Wire selected_social_content
**Goal**: `selected_social_content` is readable and writable on `ScheduledReportSpecificationRuleResource`, report generation correctly filters to selected platforms, and specs verify both directions
**Depends on**: Nothing (first phase)
**Requirements**: RES-01, RES-02, GEN-01, GEN-02, TST-01, TST-02, TST-03
**Success Criteria** (what must be TRUE):
  1. A GET request for a rule with specific social flags set returns `selected_social_content` as an array of the expected platform keys
  2. A PATCH/POST with `selected_social_content: ["twitter", "instagram"]` persists the correct bitflags and reads back the same platforms
  3. A report built for a rule with specific platforms selected only contains content matching those platforms (filtered via `enabled_media_types`)
  4. A rule with no platforms selected produces no social content in the generated report
  5. Resource specs for read and write pass; service spec for the `enabled_media_types` path passes with platform-specific selection
**Plans:** 1 plan

Plans:
- [ ] 01-01-PLAN.md — Add selected_social_content attribute to resource, add resource read/write specs and service platform-filtering specs

## Progress

**Execution Order:**
Phases execute in numeric order: 1

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Wire selected_social_content | 0/1 | Not started | - |
