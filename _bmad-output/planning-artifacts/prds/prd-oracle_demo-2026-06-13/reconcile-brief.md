---
title: "Reconciliation — brief/addendum vs PRD (oracle_demo)"
status: review
created: 2026-06-13
updated: 2026-06-13
---

# Reconciliation: Source (brief + addendum) vs Drafted PRD

**Scope:** Identify content meaningfully present in the brief or addendum that is **missing, weakened, or contradicted** in the PRD. Emphasis on qualitative ideas (tone, voice, intent, rationale) that a structured FR list tends to silently drop. Deep technical detail (exact SQL, column-type table, TNS descriptor, PL/SQL init block) is *correctly* deferred to the addendum and is flagged only where a requirement-level intent was lost.

---

## Verdict

The PRD faithfully carries the **structural and functional** substance of the source. Every scope item, every "Out", every Success Criterion, and the architecture-mirroring intent are present and well-mapped to FRs. Technical detail is correctly deferred to the addendum with explicit pointers. The gaps are almost entirely **qualitative/rationale erosion** — the "why this is credible / authoritative / different" voice that gives the artifact its purpose — plus two small concrete specifics (page size, env-key naming). No contradictions found. No blocker-level omissions.

---

## Gaps and Findings

### G1 — "Author-authored best practice → this *is* the recommended way" authority claim is weakened
- **Source (brief, "What Makes This Different"):** "**Author-authored best practice.** Built by the driver's author against their own proven architecture, the patterns carry authority — this *is* the recommended way." Also "the patterns carry authority."
- **PRD:** §0 notes the author acts as PM/dev; §4.4 says "demonstrating best-practice structure is a requirement." But the explicit, load-bearing claim — *because the author built it, it is THE canonical recommendation, not merely one example* — is diluted into a generic "best practice" requirement.
- **Assessment:** **Worth-adding (qualitative).** This is the brief's central differentiation and the source of the artifact's credibility. The FR list captures *what* (best-practice structure) but loses *why it has authority*. Recommend restoring the "this is the recommended way / author authority" framing in §1 Vision or §4.4 Description.

### G2 — "Adapted, not copied" — the SQL-pagination adaptation as a *teaching highlight* is weakened
- **Source (brief, "What Makes This Different"):** "**Adapted, not copied.** `concurs` paginates against a REST API that returns pagination metadata; with no API here, the demo shows the genuinely useful adaptation of **paginating in SQL** against Oracle directly." The brief frames this contrast (REST-metadata pagination → SQL pagination) as a deliberate teaching point.
- **PRD:** FR-11 captures the *mechanism* (FutureProvider.family + keepAlive page-index, adapted for direct SQL) and the Notes mention divergence. But the *narrative contrast* — concurs paginates via REST metadata, here there is no API so we paginate in SQL, and that adaptation is itself valuable to teach — is lost. The PRD states the idiom without the "why it's a meaningful adaptation rather than a copy" point.
- **Assessment:** **Worth-adding (qualitative/rationale).** The mechanics survive; the teaching rationale does not. One sentence in FR-11 or §4.4 would restore it.

### G3 — sessionCallback "correct place vs the wrong way most examples ignore" rationale is partially flattened
- **Source (brief, "What Makes This Different"):** "**Real-world session state.** The demo shows the *correct* place for the mandatory per-session init — the pool's `sessionCallback` — rather than re-running it on every query, exactly the kind of production concern most examples ignore." Addendum reinforces: "the canonical use of the pool's session-state feature and a key thing the demo teaches."
- **PRD:** FR-3 captures this **well** — "exactly once per session… **not** on every query" is an explicit, testable consequence, and the glossary defines sessionCallback precisely. The §4.1 Description calls it "a primary teaching point."
- **Assessment:** **Minor.** The functional intent is preserved strongly. What's softened is only the editorial sting — "the kind of production concern most examples ignore" / "teach the *correct* place vs the naive way." This is the same anti-pattern voice as in "The Problem" (naive examples teach bad habits). Optional to restore; functionally complete.

### G4 — "The Problem" anti-pattern framing (naive examples teach bad habits) is implied but not stated as motivation
- **Source (brief, "The Problem"):** Three vivid friction points — (a) "Does it actually work end-to-end in a Flutter app?" (README/example.dart show console usage, not a real UI app); (b) "How do I wire it up *properly*?" — "Naive examples (call `execute` in a widget `build`, dump rows in a `ListView`) teach bad habits"; (c) "Will it run on my desktop without Oracle client libraries?". Plus: "The alternative is for each developer to reinvent this integration, re-deriving architecture decisions the author already made well."
- **PRD:** §2.1 JTBD captures all three as positive jobs ("Prove it works end-to-end", "Show me how to wire it… so I don't… learn bad habits", "run it with no Oracle client libraries"). The "learn bad habits" phrase **does** survive in JTBD #2. The "reinvent / re-derive architecture" point is implicitly carried by UJ-2 and FR-10.
- **Assessment:** **Minor.** The problem substance is reframed into JTBD/journeys rather than dropped. The concrete anti-pattern examples (`execute` in `build`, dump rows in a `ListView`) are gone, but these are illustrative, not requirement-level. Acceptable; optionally cite one as color.

### G5 — Page size (~20–50 rows) is specified in source but absent from PRD
- **Source (addendum, "UI: table rendering"):** "meant for small tables (builds every child, no virtualization). Acceptable here because SQL-side paging means only one small page (**~20–50 rows**) renders at a time."
- **PRD:** FR-5/FR-6 say "only the current Page… is materialized" and "one small Page," but never quantify page size. FR-7's `N = ceil(total rows / page size)` references a page size that is never bounded.
- **Assessment:** **Worth-adding (minor concrete).** This is a soft requirement-level constraint, not just implementation detail: the choice of `ShadTable` (no virtualization) is *justified by* the small page size. If page size were large, the component choice would be wrong. The PRD should state the intended page-size range (or note it's bounded to keep `ShadTable` viable) rather than leave it fully open. Borderline between addendum-deferral and PRD intent; lean toward a one-line mention since it justifies a design decision the PRD does carry.

### G6 — Suggested `.env` keys / env-var naming intent
- **Source (addendum, "Connection"):** Explicit suggested keys: `ORACLE_HOST`, `ORACLE_PORT`, `ORACLE_SERVICE`, `ORACLE_USER`, `ORACLE_PASSWORD`; plus "`flutter_dotenv` + `String.fromEnvironment`" handling mirroring concurs (brief, Solution).
- **PRD:** FR-1 captures the *intent* fully (config via `.env`/dart-define, never hard-coded, example/template config shipped, real `.env` ignored). The exact key names live in the addendum.
- **Assessment:** **Correctly deferred.** Requirement intent (configurable, not hard-coded, example template) is fully preserved in FR-1. Exact key names are implementation detail. No action needed — listed only to confirm it was checked.

### G7 — "within minutes" / time-to-value promise
- **Source (brief, Executive Summary & Solution):** "see live rows in a properly architected app **within minutes**." Success: "I cloned it, pointed it at my DB, saw my rows paginated… within minutes."
- **PRD:** §1 Vision preserves "see live rows in a properly architected app within minutes" verbatim. SM-3 captures "configure and run without reading source."
- **Assessment:** **No gap.** Preserved. Listed to confirm.

### G8 — Vision "growing gallery of tabs" extension narrative
- **Source (brief, Vision):** Future extensions "would each become a new tab in a growing, runnable **gallery** of the driver's capabilities… an ever-clearer teaching tool"; "canonical 'getting started with `oracledb` in Flutter' reference linked from the package README."
- **PRD:** §6.2 explicitly references "the natural 'growing gallery' extensions named in the brief vision" via a `[NOTE FOR PM]`, and §2.1 author JTBD carries "link from the README." Non-goals (§5) defer writes/multi-table/query-console consistently.
- **Assessment:** **No gap / well-handled.** The PRD even cross-references the vision narrative explicitly.

### G9 — Confirmation that pool was chosen *over* a single OracleConnection
- **Source (brief, Scope In):** "using **`OraclePool`** … (Confirmed: pool over a single `OracleConnection`.)" — i.e. an explicit, resolved decision.
- **PRD:** FR-2 + glossary state the app uses `OraclePool` and borrows per operation (`withConnection`), with FR-2's testable consequence: "not a single long-lived connection." The *decision* (pool chosen over single connection) is thus encoded as a requirement consequence.
- **Assessment:** **No gap.** Decision intent preserved as a testable consequence.

### G10 — "smoke-test that oracledb behaves in a Flutter desktop runtime, not just under `dart run`"
- **Source (brief, Who This Serves — Secondary; Success):** The author's secondary value: a smoke-test that the driver works in a Flutter desktop runtime, "not just under `dart run`."
- **PRD:** §2.1 author JTBD preserves this verbatim ("a smoke-test that `oracledb` behaves correctly in a Flutter desktop runtime"). UJ wording echoes "not just under `dart run`."
- **Assessment:** **No gap.** Preserved.

---

## Items correctly deferred to addendum (no requirement-level loss)
These appear only in the addendum by design; the PRD points to them and preserves the requirement-level intent. **No action needed** — confirming they were checked:

- **Exact base SELECT and column list** → requirement intent ("visible columns and ordering match the set in addendum.md," ordered `alta_cli DESC, potencial, nomb_cli`) preserved in FR-5. Ordering even survives verbatim in the PRD.
- **Column→Freezed-model type table** → deferred; PRD §8 Open Questions + §9 Assumptions carry the "types provisional, confirm during dev" and "dedupe `nomb_fiscal_cli`" items intact.
- **TNS descriptor / EZ Connect string / target `192.168.2.30:1521/CELO` as `NIK`** → deferred; FR-1 carries the configurable-connection intent. (Note: the PRD deliberately genericizes the target — UJ-1 has Dana point at *her* DB — which is correct for a clonable showcase.)
- **Exact PL/SQL per-session init block** (`crm_set_filial`, `set_usuario_id`, `set_nik_idioma`, `set_cod_idioma_actual`) → deferred; FR-3 + glossary "Per-session init" carry the requirement intent (sets filial/usuario_id/idioma, must run once per session). No intent lost.
- **Paged-query wrapper SQL + COUNT(*)** → deferred; FR-6/FR-7 carry intent.
- **Rejected-alternatives rationale (Trina Grid, Syncfusion DataGrid, TableView fallback)** → §5 non-goals reference "Trina Grid / Syncfusion DataGrid rejected for v1; rationale in addendum.md." Intent + pointer preserved.
- **`idioma`/`filial` configurability question** → preserved verbatim as §8 Open Question #3.

---

## Contradictions
**None found.** Target genericization (specific host → "her own host/service/user/password") is an intentional, correct adaptation for a clonable reference, not a contradiction; the concrete target remains in the addendum.

---

## Recommended edits (priority order)
1. **(Worth-adding, qualitative)** Restore the **"author-authored → this *is* the recommended way" authority** framing — §1 Vision or §4.4 Description. (G1)
2. **(Worth-adding, qualitative)** Restore the **"adapted, not copied" SQL-pagination contrast** (concurs = REST metadata; here = SQL) as a teaching point — one sentence in FR-11/§4.4. (G2)
3. **(Worth-adding, minor concrete)** State the intended **page-size range (~20–50 rows)** or that it's bounded to keep `ShadTable` (non-virtualized) appropriate — FR-5 or §6.1. (G5)
4. **(Minor, optional)** Re-inject editorial voice on sessionCallback / naive-example anti-patterns ("the production concern most examples ignore," `execute`-in-`build` color). (G3, G4)
