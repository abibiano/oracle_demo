# PRD Quality Review — oracle_demo

## Overall verdict

This is a tight, self-aware PRD that knows exactly what it is — a single-developer teaching showcase for the `oracledb` driver — and refuses to inflate itself. The thesis ("can I use `oracledb` in a real Flutter app, the right way?") is stated plainly and every feature serves it; FR Consequences are unusually testable for a low-stakes doc; and the explicit split between PRD (capabilities) and addendum (implementation grade) is disciplined and correctly executed. The only real soft spots are minor: a couple of FR consequences lean on a human ("a reviewer recognizes…") rather than a checkable artifact, and the Assumptions Index roundtrip is loose (indexed assumptions lack matching inline tags). None of this is load-bearing at the agreed stakes. Green-light quality for a showcase app.

## 1. Decision-readiness — strong

A decision-maker — here, the author wearing the PM hat — can act on this directly. The hard choices are stated as choices, not smuggled in. Direct-connection-only, macOS-only, read-only, no data-grid dependency are all named in §5 Non-Goals with the thing-given-up attached ("Trina Grid / Syncfusion DataGrid rejected for v1", §5). The `shadcn_ui`-vs-`concurs`-Material divergence is surfaced honestly as "a deliberate, documented divergence" with a `[NOTE FOR PM]` at the real tension (FR-11 Notes, §4.4) rather than at a safe checkpoint.

Open Questions (§8) are genuinely open and correctly triaged — items 1 and 2 are flagged "dev-time," item 3 ("Should `idioma` / `filial` … be configurable later?") is explicitly "deferred, not a v1 blocker." No rhetorical questions-with-answers. The PRD avoids the "everything balances" red flag: the counter-metric SM-C1 openly states a tension the author will feel ("do **not** grow tables, sorting, writes … to look impressive").

No findings.

## 2. Substance over theater — strong

Almost no furniture. The Vision (§1) is product-specific — it could not swap into another PRD ("connects directly to a real Oracle database — no API backend, no Oracle Instant Client, no FFI"). The closing line "It is a teaching artifact, not a product. It stays small and exemplary on purpose" is doing real scope-discipline work, not decoration.

No persona theater: there are exactly two protagonists (Dana, Theo) and each maps to a distinct JTBD that drives distinct FRs. No NFR theater — in fact there is no NFR section at all, which is the correct call here (see §7 Shape fit). The one differentiation claim ("pure-Dart … no Oracle client libraries", §1/§2.1) is the actual product novelty, not template-driven.

### Findings
- **low** Builder's JTBD slightly redundant with author-as-PM framing (§2.1, "For the author (builder's JTBD)") — The "living reference I can link from the README, and a smoke-test" bullet is legitimate but overlaps the §0 framing that the author *is* the audience. Harmless. *Fix:* leave as-is; it earns its place by naming the smoke-test motivation that SM-1 later validates.

## 3. Strategic coherence — strong

The PRD has a clear thesis and bets on it: credibility-through-correctness ("mirrors the production-grade clean architecture of the author's `concurs` project, so it doubles as a **copy-pasteable blueprint**", §1). Feature prioritization follows the thesis, not ease — note that "Reference-Quality Architecture" (§4.4) is elevated to a *feature* with its own FRs (FR-10, FR-11) precisely because "the product *is* a teaching artifact, demonstrating best-practice structure is a requirement, not an implementation detail." That is the thesis made structural.

Success Metrics validate the thesis rather than measuring activity: SM-3 (configure-and-run without reading source) and SM-4 (a `concurs`-familiar reviewer recognizes the structure) are quality-of-teaching checks, not DAU/MAU theater. A counter-metric (SM-C1) is present and named — rare and correct. MVP scope kind is coherently "experience/blueprint," and the scope logic in §6 matches it.

No findings.

## 4. Done-ness clarity — strong (with two soft consequences)

This is the dimension the prompt asked me to be unforgiving on, and the PRD largely holds up. Every FR carries an explicit **Consequences (testable)** block, and most are genuinely verifiable:

- FR-3 is the standout: "The init block runs once per session creation/tag-change, **not** on every query" is a precise, falsifiable claim (observable via SQL trace / counting init executions).
- FR-7: "`N` equals `ceil(total rows / page size)`; `X` reflects the currently displayed page" — arithmetically checkable.
- FR-8: "Prev is disabled on page 1; Next is disabled on the last page" — directly assertable in a widget test.
- FR-4 / FR-9 avoid the "handles gracefully" trap by specifying the observable: "renders a human-readable error message in the UI; the app does not crash or hang on a blank screen" and "an empty state shows when `cliente` returns zero rows."
- FR-1, FR-2, FR-6 are all concrete (config-edit-only DB change; `withConnection` borrow; no cross-page accumulation in memory).

I scanned for the forbidden adjectives — "gracefully," "reasonable performance," "user-friendly." The only "graceful" is the FR-4 *heading* ("Graceful connection failure"), and the consequence underneath it is concrete, so the heading is fine.

Two consequences are softer than the rest and worth flagging because story creation will lean on them:

### Findings
- **medium** Reviewer-recognition consequences are subjective (FR-10 §4.4, "A reviewer familiar with `concurs` recognizes the layer boundaries and patterns without explanation"; mirrored in SM-4) — This is the only consequence with no checkable artifact: "recognizes … without explanation" depends on which reviewer. The *second* FR-10 consequence ("The driver is accessed only through the repository/data-source layer, never directly from a widget") is testable and largely carries the FR, so impact is limited. *Fix:* lean done-ness on the structural consequence (no widget-level driver access; named layer directories present: `data / domain / presentation` + application) and treat reviewer-recognition as a soft secondary signal, not the acceptance gate.
- **low** FR-5 ordering/columns deferred to addendum (§4.2, "The visible columns and ordering match the set defined in `addendum.md`") — Correct per the §0 PRD/addendum split, and the addendum does pin both (the dedup'd 16-column SELECT and `ORDER BY alta_cli DESC, potencial, nomb_cli`). But the column set is itself still provisional there (Open Question 2 + the `[ASSUMPTION]` on inferred types), so "done" for FR-5 is contingent on a dev-time confirmation. Acceptable at these stakes; just note that FR-5's testability inherits the addendum's open items. *Fix:* none required; flag so story creation knows the column list is "confirm during dev," not frozen.

## 5. Scope honesty — strong

Omissions are explicit and do real work. §5 Non-Goals is a proper section, not a token list, and §6.2 Out of Scope adds the *why* and the *when* ("Deferred to a future 'writes' tab"; "v2+"; "Could be a fast-follow; left out to keep v1 tight"). De-scoping of the third-party data grid is proposed honestly with rationale pointer, not done silently (§5, §6.2). §2.2 Non-Users complements this from the user angle.

Open-items density is appropriate: 3 Open Questions + 3 indexed assumptions + 2 `[NOTE FOR PM]` callouts. For a green-light-to-build PRD that would be borderline; for a low-stakes solo teaching app it is comfortably fine, and the items are all correctly marked deferred/dev-time rather than blocking.

### Findings
- **low** A couple of `[NON-GOAL for MVP]` callouts could sit inline at the FRs, not only in §5 (e.g. FR-5/FR-8 never say inline that in-table sort/filter is out) — Low impact because §5 covers it globally and §2.2 reinforces it; a reader is unlikely to silently assume sorting given how prominently it's excluded. *Fix:* optional; the centralized Non-Goals section already discharges the obligation.

## 6. Downstream usability — adequate

This PRD *is* chain-top (§0: "for downstream UX and architecture workflows"), so traceability matters. It mostly delivers. A Glossary (§3) is present and the domain nouns (`Cliente`, `OraclePool`, `sessionCallback`, `Page`, `Repository`, `AppFailure`) are used consistently across FRs, UJs, and SM definitions. FR/UJ/SM IDs are contiguous and unique (FR-1..11, UJ-1..2, SM-1..4 + SM-C1). Cross-references mostly resolve via Glossary terms rather than "see above," and the SM→FR backlinks ("Validates FR-1..FR-8") are a real asset for story creation.

Two friction points keep this from "strong":

### Findings
- **medium** Several FRs and SMs delegate the actually-testable detail to `addendum.md`, so a downstream workflow cannot source-extract cleanly from the PRD alone (FR-5 §4.2, FR-10/FR-11 §4.4, §6 "Exact package list and layering are in `addendum.md`") — This is a *deliberate* design per §0 and is the right call for keeping the PRD at capability altitude, but it means UX/architecture must read both files in tandem. Since §0 states this explicitly and the addendum is co-located, impact is contained. *Fix:* ensure the architecture stage is handed both artifacts as a pair (the PRD already says so in §0 — keep that link live).
- **low** "matching `concurs` conventions" / "the `concurs` pagination idiom" (FR-10, FR-11) assume the reader has the `concurs` codebase (§3 Glossary points to `pixcontest`) — Fine for the author, slightly opaque for any other downstream reader. The Glossary entry mitigates it. *Fix:* none required at these stakes.

## 7. Shape fit — strong

The PRD correctly identifies its own shape and resists over-formalization. This is a single-operator / solo-author technical capability spec, and the doc treats it that way: rigor is light where it should be (no NFR section, no scalability/SLA boilerplate, qualitative pass/fail SMs explicitly justified — §7: "Stakes are low (teaching artifact); metrics are qualitative pass/fail acceptance checks"), while the substance bar stays high (testable FR consequences, a real thesis).

On UJ density specifically — the prompt's worry: there are exactly **two** UJs, and both are load-bearing rather than theater. UJ-1 (Dana, evaluator) drives FR-1/4/5/6/7/8/9; UJ-2 (Theo, architecture-copier) drives FR-2/3/10/11. For a teaching app whose entire value proposition is "evaluate it" + "learn the structure," these two journeys *are* the two jobs, so even on a single-operator tool they are not overhead — they're the spec of who the showcase is for. Two is the right number; this is neither over- nor under-formalized. Both UJs have named protagonists carrying context inline (no floating UJs), and each has an explicit Climax/Resolution and (for UJ-1) an Edge case.

No findings.

## Mechanical notes

- **ID continuity:** FR-1..FR-11 contiguous, unique, no gaps or dupes. UJ-1, UJ-2 clean. SM-1..SM-4 plus counter-metric SM-C1 — clean. All SM→FR cross-references resolve to real FR IDs (FR-1..FR-11 all exist). No dangling references found.
- **Glossary drift:** Minor, low severity. The Glossary entry is **`Cliente`** (capitalized domain entity), but the PRD also refers to the lowercase table/sample-data **`cliente`** (§2.2, §4.2 description, §5, §6, FR-5, FR-9, SM-1). This is arguably *intentional* (entity vs. table name) and the Glossary even encodes the distinction ("A CRM client record from the Oracle `cliente` table"), but the two casings are not called out as deliberate, so a careless reader could read it as drift. No action needed; flag only.
- **Assumptions Index roundtrip — loose.** §9 indexes three assumptions. Only one of them has a matching **inline** `[ASSUMPTION]` tag in the body: SM-1 (§7) carries "_([ASSUMPTION] validated against the author's local/dev Oracle instance.)_". The other two index entries — macOS-only (§1/§6) and inferred column meanings/types (§3/addendum) — are **not** tagged inline at those sections; the index points to them but the body locations carry no `[ASSUMPTION]` marker. Reverse direction is clean (the one inline tag is indexed). Severity low for a low-stakes PRD, but worth a one-line fix. *Fix:* add inline `[ASSUMPTION]` tags at the §1/§6 macOS-only statement and the §3 `Cliente` Glossary entry (or the column-types mention) so the index roundtrips both ways.
- **`[NOTE FOR PM]` callouts:** two — FR-11 Notes (§4.4, `shadcn_ui` divergence) and §6.2 (multi-table browser / live query console deferral). Both sit at real deferred-decision tensions, not safe checkpoints. Good.
- **UJ protagonist naming:** both UJs name a protagonist (Dana, Theo) and carry their context inline. No floating UJs.
- **Required sections for shape/stakes:** all present and appropriately scoped — Vision, Target User (JTBD + Non-Users + UJs), Glossary, Features/FRs, Non-Goals, MVP Scope, Success Metrics (+ counter-metric), Open Questions, Assumptions Index. No NFR section, correctly omitted for this shape. §0 Document Purpose explicitly scopes the PRD/addendum split, which is a nice downstream affordance.
