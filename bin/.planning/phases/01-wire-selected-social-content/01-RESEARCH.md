# Phase 1: Wire selected_social_content - Research

**Researched:** 2026-03-26
**Domain:** Graphiti resource attribute exposure, FlagShihTzu bitfield serialization, RSpec resource/service specs
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Add `attribute :selected_social_content, :array` to `ScheduledReportSpecificationRuleResource` — same pattern as `StreamResource` (line 52)
- **D-02:** The attribute uses the model's existing `selected_social_content` getter/setter from `MediaExtensions` — no custom block needed
- **D-03:** Keep `social_content: :boolean` writable on the resource — no change to its current behavior. `selected_social_content` is additive alongside it. Existing monitoring report callers writing `social_content: true/false` must continue to work.
- **D-04:** The known issue (boolean writes all-or-none flags) is acceptable for now — do NOT change `social_content` write behavior as part of this phase
- **D-05:** No service code changes needed — `ScheduledReportService` already calls `rule.enabled_media_types` (lines 351, 444) which reads `selected_social_content` internally via `MediaExtensions#enabled_media_types`
- **D-06:** GEN-02 (empty selection → no social content) is handled by the existing `MediaExtensions#enabled_media_types` implementation returning `[]` when `selected_social_content` is empty
- **D-07:** `selected_social_content` values are type keys matching `SocialMentionType` enum: `"tweet"`, `"facebook_post"`, `"instagram_post"`, etc. — NOT platform aliases like `"twitter"`, `"instagram"`. This matches what `MediaExtensions` getter returns and what the frontend `SocialMentionType` enum uses.

### Claude's Discretion
None documented — all choices locked.

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| RES-01 | `selected_social_content` is readable as an array on the rule resource | Single attribute declaration in resource file; model getter already returns array of symbols |
| RES-02 | `selected_social_content` is writable on the rule resource | Same attribute declaration makes it writable by default in Graphiti; model setter from FlagShihTzu handles array input |
| GEN-01 | Report generation filters to selected platforms via `enabled_media_types` | `ScheduledReportService` line 351 already passes `rule.enabled_media_types` as `:types` — no service change needed |
| GEN-02 | No platforms selected → no social content in report | `MediaExtensions#enabled_media_types` returns `[]` when no flags set; service passes empty `:types` which returns no mentions |
| TST-01 | Resource spec covers read of `selected_social_content` returns correct array | New context in existing spec; factory supports setting specific social flags via array |
| TST-02 | Resource spec covers write of `selected_social_content` persists correct bitflags | New context using `Resource.find(params).update_attributes` pattern; verify with `.reload.selected_social_content` |
| TST-03 | Service spec passes with platform-specific selection | Existing "when specification is social" context uses `social_content: true` (all types); new context needed using specific `selected_social_content` array on rule factory |
</phase_requirements>

---

## Summary

This phase has a single code change: add one line to `ScheduledReportSpecificationRuleResource`. The model concern (`MediaExtensions`) and service (`ScheduledReportService`) already provide all the behavior required. The work is almost entirely spec-writing.

`ScheduledReportSpecificationRule` includes `MediaExtensions`, which dynamically defines `selected_social_content` getter (returns array of type symbols), `selected_social_content=` setter (FlagShihTzu-generated, accepts Array of symbols/strings), and `enabled_media_types` (reads from `selected_social_content`, filtered by feature flags). The service already consumes `rule.enabled_media_types` at lines 351 and 444. No service changes are needed.

The spec work has two parts: (1) extend the existing resource spec with read and write contexts for `selected_social_content`, following the `StreamNotificationResource` `update_attributes` pattern; (2) add a new context to the existing service spec "when specification is social" that creates a rule with a specific `selected_social_content` array rather than `social_content: true`.

**Primary recommendation:** Add `attribute :selected_social_content, :array` at line 12 of the resource file (after `social_content`). Then add three spec contexts: read, write, and service.

---

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Graphiti | project version | JSON:API resource layer — `attribute :name, :type` macro | Project-standard resource framework; `:array` type is supported natively |
| FlagShihTzu | project version | Bitfield flag management on ActiveRecord models | Already in use via `MediaExtensions`; provides `has_flags`, `select_all_*`, `all_*` methods |
| RSpec | project version | Test framework | Project-standard |

No new dependencies. All required libraries are already in the project.

**Installation:** No installation required — all dependencies already present.

---

## Architecture Patterns

### Recommended Project Structure
No structural changes. Changes are isolated to:
```
backend/api/app/resources/
└── scheduled_report_specification_rule_resource.rb   # +1 line

backend/api/spec/resources/
└── scheduled_report_specification_rule_resource_spec.rb  # +2 contexts

backend/api/spec/services/reporting/
└── scheduled_report_service_spec.rb  # +1 context inside existing "when specification is social"
```

### Pattern 1: Graphiti Array Attribute Declaration
**What:** Declares an attribute as readable and writable without a custom block when the model already exposes the correct getter/setter.
**When to use:** When the model's getter returns the correct serializable value and the setter accepts what the resource receives.
**Example:**
```ruby
# Source: backend/api/app/resources/stream_resource.rb lines 46–52
attribute :selected_tv_content, :array
attribute :selected_radio_content, :array
attribute :selected_online_content, :array
attribute :selected_print_content, :array
attribute :selected_magazine_content, :array
attribute :selected_podcast_content, :array
attribute :selected_social_content, :array
```

The exact line to add to `ScheduledReportSpecificationRuleResource` (after line 11, `attribute :social_content, :boolean`):
```ruby
attribute :selected_social_content, :array
```

### Pattern 2: Resource Write Test Using `update_attributes`
**What:** Tests that a PATCH payload persists correctly by calling `Resource.find(params).update_attributes` in a `Graphiti.with_context` block, then reloading the record.
**When to use:** Testing writable attributes on any Graphiti resource.
**Example (from stream_notification_resource_spec.rb):**
```ruby
result = StreamNotificationResource.find(params).update_attributes
expect(result).to be true
```

For the rule write test, the `params` payload shape is:
```ruby
{
  data: {
    id: rule.id,
    type: "scheduled_report_specification_rules",
    attributes: {
      selected_social_content: ["tweet", "instagram_post"]
    }
  }
}
```

After `update_attributes`, verify with:
```ruby
expect(rule.reload.selected_social_content).to eq [:tweet, :instagram_post]
```

Note: the model getter returns symbols; the factory/setter accepts strings or symbols interchangeably.

### Pattern 3: Resource Read Test
**What:** Creates a record with specific flags set via the factory, serializes via `Resource.all.to_jsonapi`, and asserts the array attribute value.
**When to use:** Testing readable `:array` attributes.
**Example (from instant_insights_report_resource_spec.rb line 241):**
```ruby
expect(data.attributes.selected_social_content).to eq(
  first_stream.selected_social_content.map(&:to_s)
)
```

The serialized form is strings (`:to_s` on symbols). A rule created with:
```ruby
create(:scheduled_report_specification_rule,
  stream: stream,
  social_content: [:tweet, :instagram_post])
```
...will have `selected_social_content` return `[:tweet, :instagram_post]` as symbols from the model, but `["tweet", "instagram_post"]` as strings in the JSON:API response.

### Pattern 4: Factory with Specific Social Flags
**What:** The rule factory accepts `social_content:` with an Array to set specific FlagShihTzu bits.
**When to use:** Creating a rule with specific platforms selected in specs.
**Example:**
```ruby
create(
  :scheduled_report_specification_rule,
  stream: social_stream,
  social_content: [:tweet, :instagram_post]
)
```
This works because `MediaExtensions` setter delegates array values to `selected_social_content=` (line 200 of media_extensions.rb).

Alternatively, pass `selected_social_content:` directly — both routes hit the same setter.

### Pattern 5: Service Spec for Platform-Specific Selection (TST-03)
**What:** Add a nested context inside the existing "when specification is social" context that overrides the rule's `social_content` to a specific subset.
**When to use:** Verifying `enabled_media_types` filtering behaviour in the report service.
**Example structure:**
```ruby
context "when rule has platform-specific selection" do
  # Override the rule to only have :tweet selected
  let(:scheduled_report_specification) do
    create(
      :scheduled_report_specification,
      :user => user,
      :sections => [
        create(
          :scheduled_report_specification_section,
          :rules => [
            create(
              :scheduled_report_specification_rule,
              :stream => social_stream,
              :social_content => [:tweet]   # only tweet
            )
          ]
        )
      ],
      :media_order => media_order,
      :group_by_media => true,
      :product_type => "social"
    )
  end

  it "only includes tweet content, not facebook_post", :indexed_content do
    grouped_mentions = subject
    items = grouped_mentions[0]["items"]
    expect(items.size).to eq(1)
    expect(items[0][:type]).to eq "tweet"
  end
end
```

### Anti-Patterns to Avoid
- **Adding a custom block to the attribute declaration:** `MediaExtensions` getter already returns the right value. No custom block is needed — this would duplicate logic.
- **Changing `social_content: :boolean` behavior:** D-03 is locked. Do not touch the boolean attribute or its setter behavior.
- **Using platform alias strings in specs:** The values are `"tweet"`, `"facebook_post"`, `"instagram_post"` etc. — NOT `"twitter"`, `"instagram"`, `"facebook"` (those are the `TYPE_SOCIAL_PLATFORM_LOOKUP` values, not what `selected_social_content` returns).
- **Checking `selected_social_content` on a rule with no `DEFAULT_MEDIA`:** Unlike `Stream`, `ScheduledReportSpecificationRule` has no `DEFAULT_MEDIA` constant. `default_types_for_medium` returns `0` for it. So a newly created rule with `social_content: true` (boolean) calls `select_all_social_content` setting all bits. A rule with no content attributes set has `selected_social_content` returning `[]`.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Bitfield serialization to/from array | Custom attribute with encode/decode block | `attribute :selected_social_content, :array` + model getter/setter | `MediaExtensions` already handles FlagShihTzu bit manipulation |
| Type-to-platform name translation | Custom mapping in resource | `TYPE_SOCIAL_PLATFORM_LOOKUP` constant in `MediaExtensions` | Already exists; not needed for this phase |
| Media type filtering in service | New service method | `rule.enabled_media_types` | Already called by service at lines 351, 444 |

---

## Common Pitfalls

### Pitfall 1: Symbol vs String in Test Assertions
**What goes wrong:** Model getter returns symbols (e.g., `[:tweet, :instagram_post]`). The JSON:API serializer converts them to strings. Tests asserting on the resource output must use strings; tests asserting on `rule.reload.selected_social_content` must use symbols.
**Why it happens:** `MediaExtensions` uses FlagShihTzu which works in symbols; Graphiti serializes them as strings via `.to_s`.
**How to avoid:** For resource read tests: `eq ["tweet", "instagram_post"]`. For model reload assertions: `eq [:tweet, :instagram_post]`.
**Warning signs:** Test failure with `expected [:tweet] but got ["tweet"]` or vice versa.

### Pitfall 2: Missing `Graphiti.with_context` for Write Tests
**What goes wrong:** Resource `update_attributes` may require an authorized context depending on the resource's authorization setup.
**Why it happens:** `InsecureApplicationResource` typically does not enforce auth, but `Graphiti.with_context` is idiomatic for resource specs.
**How to avoid:** Follow the existing pattern in the resource spec — `authorized_context` is already defined as `double(:current_user => user)`.
**Warning signs:** Write test works without context but behaves oddly in CI.

### Pitfall 3: TST-03 Service Spec Needs Feature Flags
**What goes wrong:** `enabled_media_types` filters by `organisation.feature_enabled?` for both the medium (`has_social_platform`) and individual type (`view_tweet`, `view_instagram_post`, etc.). If features aren't enabled, `enabled_media_types` returns `[]` regardless of what flags are set.
**Why it happens:** `MediaExtensions#enabled_media_types` checks feature flags at two levels.
**How to avoid:** The existing "when specification is social" context already calls `enable_features([:social_mentions, :has_social_platform, :view_tweet, :view_facebook_post], ...)`. The new platform-specific context needs to enable only the features for the selected platforms (e.g., for `:tweet` only: `:social_mentions`, `:has_social_platform`, `:view_tweet`).
**Warning signs:** `grouped_mentions[0]["items"]` is empty when expecting content.

### Pitfall 4: Rule Has No DEFAULT_MEDIA
**What goes wrong:** Unlike `Stream` or `SocialStream`, `ScheduledReportSpecificationRule` has no `DEFAULT_MEDIA` constant. The `default_types_for_medium` method returns `0` for it. This means a rule created with no `social_content` argument has `social_content_before_type_cast` as `0` and `selected_social_content` returns `[]`.
**Why it happens:** `ScheduledReportSpecificationRule` is a rule/config record, not a stream. It has no default media preset.
**How to avoid:** Always set `social_content:` explicitly in test factories when you need specific content to be enabled.
**Warning signs:** Read test for an "empty" rule returns `[]` unexpectedly — this is correct behaviour.

### Pitfall 5: `social_content: true` vs `social_content: [:tweet]`
**What goes wrong:** `social_content: true` calls `select_all_social_content` which sets ALL social type bits (tweet, facebook_post, youtube_video, instagram_post, instagram_comment, reddit_post, reddit_post_comment, blog_post, forum_post, bluesky_post, linkedin_post, linkedin_comment, tiktok_video, tiktok_comment). This is what the existing service spec uses. The new TST-03 context needs a rule with a SUBSET.
**Why it happens:** The `=` setter in `MediaExtensions` dispatches on value type — `TrueClass` → `select_all`, `Array` → `selected_social_content=`.
**How to avoid:** Use `social_content: [:tweet, :instagram_post]` (or any subset) when testing platform-specific filtering. The setter handles both forms.

---

## Code Examples

Verified patterns from source files:

### Resource: One-Line Change
```ruby
# File: backend/api/app/resources/scheduled_report_specification_rule_resource.rb
# Insert after line 11 (attribute :social_content, :boolean)

attribute :selected_social_content, :array
```

### Resource Spec: Read Context
```ruby
# Source pattern: instant_insights_report_resource_spec.rb line 241
context "reading selected_social_content" do
  let!(:rule_with_platforms) do
    create(
      :scheduled_report_specification_rule,
      :scheduled_report_specification_section_id => scheduled_report_specification_section.id,
      :stream_id => stream.id,
      :social_content => [:tweet, :instagram_post]
    )
  end

  it "returns the selected social content as strings" do
    json_data = jsonapi_data(
      ScheduledReportSpecificationRuleResource.all({}).to_jsonapi
    )

    rule_data = json_data.find { |d| d.id == rule_with_platforms.id.to_s }
    expect(rule_data.attributes.selected_social_content).to eq ["tweet", "instagram_post"]
  end
end
```

### Resource Spec: Write Context
```ruby
# Source pattern: stream_notification_resource_spec.rb line 192
context "writing selected_social_content" do
  let(:rule) do
    create(
      :scheduled_report_specification_rule,
      :scheduled_report_specification_section_id => scheduled_report_specification_section.id,
      :stream_id => stream.id,
      :social_content => false
    )
  end

  let(:params) do
    {
      :data => {
        :id => rule.id,
        :type => "scheduled_report_specification_rules",
        :attributes => {
          :selected_social_content => ["tweet", "instagram_post"]
        }
      }
    }
  end

  it "persists the correct bitflags" do
    Graphiti.with_context authorized_context do
      result = ScheduledReportSpecificationRuleResource.find(params).update_attributes
      expect(result).to be true
      expect(rule.reload.selected_social_content).to eq [:tweet, :instagram_post]
    end
  end
end
```

### Service Spec: Platform-Specific Context (TST-03)
```ruby
# Source pattern: scheduled_report_service_spec.rb "when specification is social" context
# Add as nested context inside the existing "when specification is social" block

context "when rule has platform-specific selection (only tweet)" do
  let(:scheduled_report_specification) do
    create(
      :scheduled_report_specification,
      :user => user,
      :sections => [
        create(
          :scheduled_report_specification_section,
          :rules => [
            create(
              :scheduled_report_specification_rule,
              :stream => social_stream,
              :social_content => [:tweet]
            )
          ]
        )
      ],
      :media_order => ["tweet"],
      :group_by_media => true,
      :product_type => "social"
    )
  end

  it "only includes tweet content", :indexed_content do
    grouped_mentions = subject
    items = grouped_mentions[0]["items"]
    expect(items.size).to eq(1)
    expect(items[0][:type]).to eq "tweet"
    expect(items[0]).to have_attributes(:object => have_attributes(:id => tweet.id))
  end
end
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `social_content: :boolean` (all-or-none) | `selected_social_content: :array` (per-type selection) | This phase | Frontend can now select individual platforms; service already handles it |

**In-use pattern `StreamResource` already has:**
`StreamResource` (line 52) already exposes `selected_social_content` as `:array`. This phase replicates that same one-line declaration on `ScheduledReportSpecificationRuleResource`. The implementation is identical.

---

## Open Questions

1. **TST-03 placement — new nested context vs standalone context**
   - What we know: The existing "when specification is social" context has `tweet` and `facebook_post` mentions indexed. These fixtures can be reused.
   - What's unclear: Whether the new context should be nested inside the existing one (inheriting `tweet` and `facebook_post` fixtures) or be a sibling context with its own fixture set.
   - Recommendation: Nest inside "when specification is social" to reuse the existing `tweet` and `facebook_post` mentions. Override only the specification/rule to select just `[:tweet]`. The `facebook_post` fixture will be present but not returned — that's the assertion.

2. **`update_attributes` authorization on `InsecureApplicationResource`**
   - What we know: `ScheduledReportSpecificationRuleResource < InsecureApplicationResource`. The existing spec uses `authorized_context` for sideloading tests.
   - What's unclear: Whether write operations in the resource spec require `Graphiti.with_context`.
   - Recommendation: Use `Graphiti.with_context authorized_context` for write tests to match the existing sideloading pattern and avoid any context-dependent surprises.

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | RSpec (project standard) |
| Config file | `backend/api/.rspec` / `spec/rails_helper.rb` |
| Quick run command | `bundle exec rspec backend/api/spec/resources/scheduled_report_specification_rule_resource_spec.rb` |
| Full suite command | `bundle exec rspec backend/api/spec/resources/scheduled_report_specification_rule_resource_spec.rb backend/api/spec/services/reporting/scheduled_report_service_spec.rb` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| RES-01 | Read `selected_social_content` returns array of type strings | unit | `bundle exec rspec .../scheduled_report_specification_rule_resource_spec.rb` | ✅ (extend existing) |
| RES-02 | Write `selected_social_content` persists bitflags | unit | `bundle exec rspec .../scheduled_report_specification_rule_resource_spec.rb` | ✅ (extend existing) |
| GEN-01 | Service passes `enabled_media_types` to mentions query | integration | `bundle exec rspec .../scheduled_report_service_spec.rb` | ✅ (extend existing) |
| GEN-02 | Empty selection → empty `enabled_media_types` → no results | integration | `bundle exec rspec .../scheduled_report_service_spec.rb` | ❌ Wave 0 (new context needed) |
| TST-01 | Resource read spec passes | unit | `bundle exec rspec .../scheduled_report_specification_rule_resource_spec.rb` | ❌ Wave 0 |
| TST-02 | Resource write spec passes | unit | `bundle exec rspec .../scheduled_report_specification_rule_resource_spec.rb` | ❌ Wave 0 |
| TST-03 | Service spec passes with platform-specific selection | integration | `bundle exec rspec .../scheduled_report_service_spec.rb` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `bundle exec rspec backend/api/spec/resources/scheduled_report_specification_rule_resource_spec.rb`
- **Per wave merge:** `bundle exec rspec backend/api/spec/resources/scheduled_report_specification_rule_resource_spec.rb backend/api/spec/services/reporting/scheduled_report_service_spec.rb`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `backend/api/spec/resources/scheduled_report_specification_rule_resource_spec.rb` — add read context (TST-01/RES-01)
- [ ] `backend/api/spec/resources/scheduled_report_specification_rule_resource_spec.rb` — add write context (TST-02/RES-02)
- [ ] `backend/api/spec/services/reporting/scheduled_report_service_spec.rb` — add platform-specific selection context (TST-03/GEN-01)
- [ ] `backend/api/spec/services/reporting/scheduled_report_service_spec.rb` — add empty selection context (GEN-02)

*(Framework infrastructure exists — no new config or shared fixtures needed.)*

---

## Sources

### Primary (HIGH confidence)
- `backend/shared/engines/core/app/models/concerns/media_extensions.rb` — full getter/setter/enabled_media_types implementation, verified directly
- `backend/api/app/resources/stream_resource.rb` lines 46–52 — exact pattern being replicated, verified directly
- `backend/api/app/resources/scheduled_report_specification_rule_resource.rb` — current state of file to modify, verified directly
- `backend/api/app/services/reporting/scheduled_report_service.rb` lines 351, 444 — `enabled_media_types` call sites, verified directly
- `backend/api/spec/resources/scheduled_report_specification_rule_resource_spec.rb` — existing spec to extend, verified directly
- `backend/api/spec/services/reporting/scheduled_report_service_spec.rb` line 2009–2100 — existing "when specification is social" context, verified directly
- `backend/shared/engines/core/app/models/scheduled_report_specification_rule.rb` — confirms `include MediaExtensions`, verified directly

### Secondary (MEDIUM confidence)
- `backend/api/spec/resources/stream_notification_resource_spec.rb` — `update_attributes` write pattern reference, verified directly
- `backend/api/spec/resources/instant_insights_report_resource_spec.rb` lines 207–243 — `selected_social_content.map(&:to_s)` read assertion pattern, verified directly
- `backend/shared/engines/core/spec/models/concerns/media_extensions_spec.rb` lines 388–465 — symbol return type from getter, verified directly

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all code verified directly from source files; no external dependencies
- Architecture: HIGH — exact pattern replicated from `StreamResource`; source files read
- Pitfalls: HIGH — derived from reading the actual `MediaExtensions` implementation and existing spec patterns

**Research date:** 2026-03-26
**Valid until:** 2026-06-26 (stable domain — no external dependencies, all internal code)
