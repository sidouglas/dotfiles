# Social Scheduled Reports — Backend Plumbing

## What This Is

Wiring the frontend social scheduled report builder (PR #17974) to the backend so that social platform content selection, filtering, and report generation work end-to-end. This milestone focuses on the remaining backend gap that lets users select which social platforms to include per report rule, and ensures those selections are persisted, returned, and used when building social reports.

## Core Value

A user creating a social scheduled report can select specific social platforms per stream rule, and the generated report only includes content from those platforms.

## Current Milestone: v1.0 Social Scheduled Reports Backend Plumbing

**Goal:** Complete backend wiring so `selectedSocialContent` on `ScheduledReportSpecificationRule` is persisted and used in report generation.

**Target features:**
- Expose `selected_social_content` on the rule resource (read/write)
- Wire platform selection into report generation via `enabled_media_types`
- Ensure frontend `@TODO` comment in `ScheduledReportSpecificationRule.ts` can be removed

## Requirements

### Validated

- ✓ `product_type` column on `scheduled_report_specifications` (social/monitoring enum) — PR #21378
- ✓ `engagement_count`, `like_count`, `comment_count`, `follower_count` indexed in ES — PR #21408
- ✓ Social mentions limit (100) and `mentions_count` in grouped results — PR #21437
- ✓ `enabled_media_types` and `content_type` used for social reports in service — PR #21485

### Active

- [ ] Expose `selected_social_content` as readable/writable attribute on `ScheduledReportSpecificationRuleResource`
- [ ] Frontend can persist and read back platform selections per rule
- [ ] Report generation filters social content by `selected_social_content` via `enabled_media_types`

### Out of Scope

- Social report email templates — separate design work, not blocking this milestone
- Social-specific sort order UI plumbing — sort fields already indexed in ES, sort_by already passed through service; no additional backend work needed
- Admin-side social report tooling — not needed to unblock frontend

## Context

- Backend: `/Users/simon.douglas/github/streem/backend/api`
- Frontend: `/Users/simon.douglas/github/streem/frontend`
- Frontend PR: `streemau/frontend#17974` ("feature: social scheduled reports")
- The `social_content` column on `scheduled_report_specification_rules` is already an **integer** (FlagShihTzu bitfield), not boolean — despite the resource exposing it as `:boolean`
- `MediaExtensions` concern already defines `selected_social_content` getter/setter via FlagShihTzu
- The service (`ScheduledReportService`) already calls `rule.enabled_media_types` which reads from `selected_social_content`
- The only missing piece is exposing `selected_social_content` in the Graphiti resource
- **Known issue flagged:** `ScheduledReportSpecificationRuleResource` exposes `social_content` as `:boolean` but the underlying column is an integer bitfield. The boolean getter works (returns `.any?`) but a write of `true`/`false` from the resource sets all-or-none flags. This should be understood when adding the new attribute.

## Constraints

- **Compatibility**: Must not break existing monitoring report behaviour — `social_content: boolean` still needs to function as before
- **Stack**: Ruby on Rails + Graphiti (JSON:API) backend; Vue 3 / Spraypaint frontend
- **Dependencies**: Frontend PR #17974 must be merged before this is fully testable end-to-end

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Reuse FlagShihTzu integer column for `selected_social_content` | Column already exists and FlagShihTzu already handles it via MediaExtensions | — Pending |
| No new migration needed | `social_content` integer column already supports bitflags for all social types | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-03-24 after milestone v1.0 initialized*
