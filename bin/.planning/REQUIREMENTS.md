# Requirements: Social Scheduled Reports Backend Plumbing

**Defined:** 2026-03-24
**Core Value:** A user creating a social scheduled report can select specific social platforms per stream rule, and the generated report only includes content from those platforms.

## v1 Requirements

### Resource Layer

- [ ] **RES-01**: The `selected_social_content` attribute is exposed as a readable array on `ScheduledReportSpecificationRule` (frontend receives platform selections when loading a rule)
- [ ] **RES-02**: The `selected_social_content` attribute is writable on `ScheduledReportSpecificationRule` (frontend can persist platform selections via the existing create/update spec endpoint)

### Report Generation

- [ ] **GEN-01**: When building a social scheduled report, content is filtered to only the platforms selected per rule via `enabled_media_types`
- [ ] **GEN-02**: When no platforms are selected on a rule, the rule produces no content (not all social content)

### Validation & Tests

- [ ] **TST-01**: Resource spec covers reading `selected_social_content` returns correct array for a rule with specific flags set
- [ ] **TST-02**: Resource spec covers writing `selected_social_content` persists the correct bitflags
- [ ] **TST-03**: Service spec (already exists for `enabled_media_types` path) passes with platform-specific selection

## v2 Requirements

### Social Report Email Template

- **TMPL-01**: Social scheduled report emails use a social-specific template with platform-appropriate styling
- **TMPL-02**: Platform icons and engagement metrics shown in email output

## Out of Scope

| Feature | Reason |
|---------|--------|
| New DB migration for `selected_social_content` | Column already exists as integer bitfield via FlagShihTzu |
| Social sort order backend changes | Sort fields already indexed in ES (#21408); `sort_by` already passed through service |
| Admin social report tooling | Not blocking frontend feature delivery |
| Social email template redesign | Separate design work, not needed to unblock frontend |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| RES-01 | Phase 1 | Pending |
| RES-02 | Phase 1 | Pending |
| GEN-01 | Phase 1 | Pending |
| GEN-02 | Phase 1 | Pending |
| TST-01 | Phase 1 | Pending |
| TST-02 | Phase 1 | Pending |
| TST-03 | Phase 1 | Pending |

**Coverage:**
- v1 requirements: 7 total
- Mapped to phases: 7
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-24*
*Last updated: 2026-03-24 after roadmap created*
