# Phase 1: Wire selected_social_content - Context

**Gathered:** 2026-03-24
**Status:** Ready for planning

<domain>
## Phase Boundary

Expose `selected_social_content` as a readable/writable `:array` attribute on `ScheduledReportSpecificationRuleResource`. Confirm that `ScheduledReportService` correctly filters social report content via `rule.enabled_media_types` (which reads from `selected_social_content` internally). Add resource specs for read/write and verify the existing service spec passes with platform-specific selection.

No new migration, no new model methods, no frontend changes in this phase.

</domain>

<decisions>
## Implementation Decisions

### Attribute Exposure
- **D-01:** Add `attribute :selected_social_content, :array` to `ScheduledReportSpecificationRuleResource` — same pattern as `StreamResource` (line 52)
- **D-02:** The attribute uses the model's existing `selected_social_content` getter/setter from `MediaExtensions` — no custom block needed

### social_content: :boolean Backward Compatibility
- **D-03:** Keep `social_content: :boolean` writable on the resource — no change to its current behavior. `selected_social_content` is additive alongside it. Existing monitoring report callers writing `social_content: true/false` must continue to work.
- **D-04:** The known issue (boolean writes all-or-none flags) is acceptable for now — do NOT change `social_content` write behavior as part of this phase

### Report Generation
- **D-05:** No service code changes needed — `ScheduledReportService` already calls `rule.enabled_media_types` (lines 351, 444) which reads `selected_social_content` internally via `MediaExtensions#enabled_media_types`
- **D-06:** GEN-02 (empty selection → no social content) is handled by the existing `MediaExtensions#enabled_media_types` implementation returning `[]` when `selected_social_content` is empty

### Array Value Format
- **D-07:** `selected_social_content` values are type keys matching `SocialMentionType` enum: `"tweet"`, `"facebook_post"`, `"instagram_post"`, etc. — NOT platform aliases like `"twitter"`, `"instagram"`. This matches what `MediaExtensions` getter returns and what the frontend `SocialMentionType` enum uses.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Core model concern
- `backend/shared/engines/core/app/models/concerns/media_extensions.rb` — Defines `selected_social_content` getter/setter, `enabled_media_types`, FlagShihTzu integration. All attribute behavior derives from here.

### Resource to modify
- `backend/api/app/resources/scheduled_report_specification_rule_resource.rb` — Only file to change for RES-01/RES-02

### Existing resource spec to extend
- `backend/api/spec/resources/scheduled_report_specification_rule_resource_spec.rb` — Add read/write contexts for TST-01/TST-02

### Report service (read-only reference)
- `backend/api/app/services/reporting/scheduled_report_service.rb` — Lines 351, 444 show `rule.enabled_media_types` usage. No changes needed.

### Existing service spec
- `backend/api/spec/services/reporting/scheduled_report_service_spec.rb` — Line 2062 context covers `enabled_media_types` path. TST-03 verifies this passes with platform-specific selection (may need a new context or factory setup, researcher to investigate).

### Pattern reference
- `backend/api/app/resources/stream_resource.rb` — Line 52: `attribute :selected_social_content, :array` — exact pattern to replicate

### Model
- `backend/shared/engines/core/app/models/scheduled_report_specification_rule.rb` — Confirms model includes `MediaExtensions`

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `MediaExtensions#selected_social_content` getter: returns array of type symbols (e.g., `[:tweet, :facebook_post]`) — already works on the rule model
- `MediaExtensions#selected_social_content=` setter: accepts Array — already works on the rule model
- `MediaExtensions#enabled_media_types`: called by `ScheduledReportService` — already correctly filters by `selected_social_content`

### Established Patterns
- `StreamResource` exposes `attribute :selected_social_content, :array` with no custom block — model getter handles serialization directly
- Other `*_content` attributes in the rule resource use `:boolean` for the legacy pattern; `:array` is the correct type for `selected_*` variants

### Integration Points
- `ScheduledReportSpecificationRuleResource` — sole change point
- `ScheduledReportService` — no changes, existing `enabled_media_types` calls already wire through correctly
- Frontend `ScheduledReportSpecificationRule.ts` (PR #17974) — will need `@Attr() selectedSocialContent: SocialMentionType[]` added after backend is live (out of scope for this phase but unlocks the frontend)

</code_context>

<specifics>
## Specific Ideas

- No specific UI/UX requirements — this is a pure backend attribute wiring phase
- Frontend PR #17974 is the downstream consumer — once `selected_social_content` is live on the resource, the frontend can add `@Attr() selectedSocialContent: SocialMentionType[]` and remove the `@TODO` comment

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-wire-selected-social-content*
*Context gathered: 2026-03-24*
