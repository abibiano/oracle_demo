---
title: oracle_demo
status: final
created: 2026-06-13
updated: 2026-06-13
---

# PRD: oracle_demo

## 0. Document Purpose

This PRD is for the author of the [`oracledb`](https://pub.dev/packages/oracledb) Dart driver (acting as PM and developer) and for downstream UX and architecture workflows. It builds on the existing **product brief** and **addendum** at `_bmad-output/planning-artifacts/briefs/brief-oracle_demo-2026-06-13/` — it does not duplicate them. Capabilities and behavior live here; implementation-grade detail (TNS descriptor, exact SQL, column→model mapping, the per-session init block, package selections) lives in `addendum.md` and feeds the architecture stage. Features are grouped with globally-numbered FRs nested under them; assumptions are tagged inline and indexed in §9.

## 1. Vision

`oracle_demo` is a small macOS Flutter desktop app that serves as the **reference showcase** for the `oracledb` v1.0.0 pure-Dart Oracle driver. It connects directly to a real Oracle database — no API backend, no Oracle Instant Client, no FFI — and renders a paginated data table from a real `cliente` table.

It exists to answer one question convincingly: *"Can I use `oracledb` in a real Flutter app, the right way?"* Rather than a throwaway script, it mirrors the production-grade clean architecture of the author's `concurs` project, so it doubles as a **copy-pasteable blueprint** for best-practice driver integration. Because it is built by the driver's author against their own proven architecture, the patterns carry authority — this is *the recommended way* to use `oracledb`, not merely one way. Its value is credibility and onboarding: a developer evaluating `oracledb` can clone it, point it at their database, and see live rows in a properly architected app within minutes.

It is a teaching artifact, not a product. It stays small and exemplary on purpose.

## 2. Target User

### 2.1 Jobs To Be Done

- **Evaluate the driver** — "Prove to me `oracledb` works end-to-end inside a real Flutter app, not just under `dart run`, before I commit to it."
- **Learn the right structure** — "Show me how to wire the driver behind a repository, surfaced through providers, with paginated reads and explicit error states — so I don't reinvent the architecture or learn bad habits."
- **See the pure-Dart claim made tangible** — "Let me run it on my desktop with no Oracle client libraries installed."
- **For the author (builder's JTBD)** — "Give me a living reference I can link from the README, and a smoke-test that `oracledb` behaves correctly in a Flutter desktop runtime."

### 2.2 Non-Users (v1)

- End users of a CRM — this is not a client-management product; `cliente` is sample data.
- Developers on Windows / Linux / web / mobile — those targets are out of scope for v1 (`oracledb` excludes web entirely).
- Developers wanting write operations, query editing, or multi-table browsing — this is a read-only, single-screen showcase.

### 2.3 Key User Journeys

- **UJ-1. Dana evaluates `oracledb` before adopting it.**
  Dana, a Dart/Flutter dev who needs Oracle connectivity and is wary of an independent driver, clones the repo, copies `.env.example` to `.env`, and fills in her own host/service/user/password. She runs the app on macOS. It opens a pool, initializes the session, and renders the first page of her rows in a styled table with `page 1 of N` and prev/next controls. **Climax:** she sees her real rows, paginated, in a properly architected app — without installing any Oracle client. **Resolution:** convinced it works, she moves on to study how it's built. **Edge case:** a wrong password yields a readable error message on screen, not a crash or a blank window.

- **UJ-2. Theo copies the architecture into his own app.**
  Theo, already sold on the driver, opens the source to learn the *right* structure. He recognizes the `data / domain / presentation` layering, the Riverpod code-gen providers, the repository wrapping the driver, the `Result<T, AppFailure>` error handling, and the `sessionCallback` that runs per-session init exactly once. He lifts the patterns into his own project. **Resolution:** he structures his app the recommended way on the first try.

## 3. Glossary

- **oracle_demo** — This app; the reference showcase being specified here.
- **`oracledb`** — The pure-Dart Oracle driver this app showcases (v1.0.0).
- **`concurs`** — The author's existing `pixcontest` project whose non-UI architecture this app mirrors.
- **Cliente** — A CRM client record from the Oracle `cliente` table; the domain entity rendered in the table. The exact column set and field mapping are defined in `addendum.md`; per-column Dart types are provisional `[ASSUMPTION]` pending column-metadata confirmation (see Open Question 1).
- **OraclePool** — The `oracledb` connection pool used for connection management; connections are borrowed per operation (`withConnection`).
- **sessionCallback** — The `OraclePool` hook that runs the mandatory per-session initialization once per session (on creation/tag-change), not per query.
- **Per-session init** — A required PL/SQL block (sets `filial`, `usuario_id`, `idioma` session variables) the database depends on; defined in `addendum.md`.
- **Page** — One SQL-level slice of `Cliente` rows (`OFFSET … FETCH NEXT … ROWS ONLY`); the only set of rows materialized and rendered at a time.
- **Repository** — The layer that wraps `oracledb` calls, maps results to domain models, and converts errors into `AppFailure`.
- **AppFailure** — The typed error value returned (via `Result<T, AppFailure>`) when an operation fails, instead of throwing into the UI.

## 4. Features

### 4.1 Database Connection & Session Management

**Description:** The app connects directly to a real Oracle database using `oracledb`'s `OraclePool` as the best-practice connection-management showcase. Connection settings come from configuration, never source. Every borrowed session is correctly initialized via the pool's `sessionCallback` — this is a primary teaching point. Re-running that init on every query instead — the production concern most examples quietly skip — is exactly the anti-pattern this demo avoids. Realizes UJ-1, UJ-2.

#### FR-1: Configuration-driven connection

The developer can provide connection settings (host, port, service, user, password) via `.env` / dart-define without editing source. Realizes UJ-1.

**Consequences (testable):**
- Credentials are never hard-coded; the repo ships an example/template config and ignores the real `.env`.
- Changing the target database requires only a config edit, no code change.

#### FR-2: Pooled connection via OraclePool

The app opens an `OraclePool` against the configured database and borrows connections per operation. Realizes UJ-2.

**Consequences (testable):**
- Queries run through a borrowed pooled connection (`withConnection`), not a single long-lived connection.

#### FR-3: Mandatory per-session initialization via sessionCallback

Each pooled session runs the per-session init block exactly once per session through `sessionCallback`, before any query uses it. Realizes UJ-2.

**Consequences (testable):**
- The init block runs once per session creation/tag-change, **not** on every query.
- Every borrowed connection is correctly initialized regardless of which session is reused.

#### FR-4: Graceful connection failure

Connection and authentication failures surface as readable error states, not crashes. Realizes UJ-1.

**Consequences (testable):**
- A wrong password (or unreachable host) renders a human-readable error message in the UI; the app does not crash or hang on a blank screen.

### 4.2 Paginated Cliente Table

**Description:** A single screen renders a `Page` of `Cliente` rows in a `shadcn_ui` `ShadTable`, with pagination controls composed from `ShadButton`. Paging is done at the SQL level so only one small `Page` — fixed size `[ASSUMPTION: 25 rows]` — is ever fetched and rendered, small enough that the non-virtualized `ShadTable` renders comfortably with no data-grid dependency. This is a deliberately *adapted* idiom, not a copy: `concurs` paginates against a REST API that returns pagination metadata, but with no API here the demo teaches the genuinely useful adaptation — paginating in SQL directly against Oracle. Realizes UJ-1.

#### FR-5: Render a page of clients

The user sees a `Page` of `Cliente` rows in a styled table, ordered `alta_cli DESC, potencial, nomb_cli`. Realizes UJ-1.

**Consequences (testable):**
- The visible columns and ordering match the set defined in `addendum.md`.
- Only the current `Page` of rows is materialized and rendered at any time (no full-table load).

#### FR-6: SQL-level pagination

Forward/back navigation fetches the correct `Page` via SQL (`OFFSET … FETCH NEXT … ROWS ONLY`). Realizes UJ-1.

**Consequences (testable):**
- Each navigation issues a paged query for that page only; previously fetched pages are not accumulated in memory.

#### FR-7: Accurate total and page indicator

The total page count is derived from a `COUNT(*)` and shown as a `page X of N` indicator. Realizes UJ-1.

**Consequences (testable):**
- `N` equals `ceil(total rows / page size)`; `X` reflects the currently displayed page.

#### FR-8: Pagination controls

Prev/Next controls let the user move between pages and are disabled at the boundaries. Realizes UJ-1.

**Consequences (testable):**
- Prev is disabled on page 1; Next is disabled on the last page.

### 4.3 Explicit UI States

**Description:** Loading, error, and empty states each render explicitly — no silent failures or indefinite blank screens. Realizes UJ-1.

#### FR-9: Loading / error / empty states

While a `Page` loads, on failure, and when the result set is empty, the screen shows a distinct, explicit state.

**Consequences (testable):**
- A loading indicator shows during fetch; an error state shows a readable message on failure; an empty state shows when `cliente` returns zero rows.

### 4.4 Reference-Quality Architecture

**Description:** Because the product *is* a teaching artifact, demonstrating best-practice structure is a requirement, not an implementation detail. The non-UI layers deliberately mirror `concurs`; the presentation layer deliberately diverges to use `shadcn_ui`. A reviewer familiar with `concurs` should recognize the structure immediately. Exact package list and layering are in `addendum.md` and the architecture doc. Realizes UJ-2.

#### FR-10: Layered, concurs-faithful structure

The implementation demonstrates `data / domain / presentation` layering with an application layer for providers, the repository pattern wrapping the driver, `Result<T, AppFailure>` error handling, Freezed domain models, and Riverpod code-gen state — matching `concurs` conventions.

**Consequences (testable):**
- A reviewer familiar with `concurs` recognizes the layer boundaries and patterns without explanation.
- The driver is accessed only through the repository/data-source layer, never directly from a widget.

#### FR-11: SQL-paginated read idiom

The paginated read uses the `concurs` pagination idiom adapted for direct SQL: a `FutureProvider.family` for the paged read, with a local `@Riverpod(keepAlive: true)` page-index provider.

**Consequences (testable):**
- Changing the page index drives a new family read; the page-index provider survives rebuilds.

**Notes:** The presentation layer's use of `shadcn_ui` (instead of `concurs`' Material + `flex_color_scheme`) is a deliberate, documented divergence — `[NOTE FOR PM]` if architecture review wants this called out explicitly as an evaluation goal.

## 5. Non-Goals (Explicit)

- **Not an API-backed app** — direct Oracle connection only, by design.
- **Not multi-platform** — macOS only for v1 (no Windows/Linux/web/mobile).
- **Not a CRM / data product** — `cliente` is sample data; this is a driver showcase.
- **Not read-write** — no INSERT/UPDATE/DELETE, transactions UI, or PL/SQL demos in v1.
- **No auth/login UI, no multi-table browser, no query editor.**
- **No in-table sort/filter UI** — and no third-party data-grid dependency (Trina Grid / Syncfusion DataGrid rejected for v1; rationale in `addendum.md`).

## 6. MVP Scope

### 6.1 In Scope

- Single macOS desktop target. `[ASSUMPTION]` v1 is macOS-only (`oracledb` has no web support).
- Direct Oracle connection via `oracledb` using `OraclePool` + `sessionCallback` per-session init.
- One screen: paginated `cliente` table via `ShadTable` + `ShadButton` pagination controls.
- SQL-based pagination (`OFFSET … FETCH NEXT` + `COUNT(*)`), default page size `[ASSUMPTION: 25]`.
- Connection config via `.env` / dart-define.
- Loading / error / empty states.
- Clean-architecture layering + Riverpod code-gen mirroring `concurs`; `go_router` stubbed for the single screen.

### 6.2 Out of Scope for MVP

- Write operations, transactions, PL/SQL demos. _Deferred to a future "writes" tab._
- Additional desktop targets (Windows/Linux). _v2+._
- Multi-table browser, live query console. _v2+ — `[NOTE FOR PM]`: these are the natural "growing gallery" extensions named in the brief vision; revisit once v1 lands._
- In-table sort/filter and any data-grid dependency. _Could be a fast-follow; left out to keep v1 tight._

## 7. Success Metrics

Stakes are low (teaching artifact); metrics are qualitative pass/fail acceptance checks.

**Primary**
- **SM-1**: App launches on macOS, connects to a real Oracle DB, and displays real `cliente` rows paginated. Validates FR-1..FR-8. _([ASSUMPTION] validated against the author's local/dev Oracle instance.)_
- **SM-2**: Pagination is correct — forward/back fetches the right `Page` via SQL and the total page count is accurate. Validates FR-5..FR-8.

**Secondary**
- **SM-3**: A developer unfamiliar with the project can configure connection settings and run it without reading source. Validates FR-1, FR-4, FR-9.
- **SM-4**: A reviewer familiar with `concurs` recognizes the structure immediately. Validates FR-10, FR-11.

**Counter-metrics (do not optimize)**
- **SM-C1**: Feature breadth / UI polish — do **not** grow tables, sorting, writes, or add a data-grid dependency to look impressive. Doing so dilutes the teaching focus and breaks the "small and exemplary" vision. Counterbalances the temptation behind SM-1/SM-2.

## 8. Open Questions

1. Exact Dart type per `cliente` column (inspect column metadata / sample rows) — dev-time.
2. Final deduplicated column list (`nomb_fiscal_cli` appeared twice in the source list) — dev-time.
3. Should `idioma` / `filial` (currently hard-set in the init block) be configurable later? — deferred, not a v1 blocker.

## 9. Assumptions Index

- §1 / §6 — v1 is **macOS-only** (rationale: `oracledb` has no web support; user requested macOS). `[ASSUMPTION]`
- §4.2 / §6.1 — **page size = 25 rows** is a provisional default, chosen to keep the non-virtualized `ShadTable` comfortable; confirm during dev. `[ASSUMPTION]`
- §7 SM-1 — success is validated against the **author's local/dev Oracle instance** (e.g. Oracle 23ai/21c), not a public dataset. `[ASSUMPTION]`
- §3 / addendum — inferred per-column meanings and Dart types for `Cliente` (e.g. `alta_cli` as a flag, sales columns as numerics, `fec_alta_cli` as DateTime) are **provisional** pending column-metadata confirmation. `[ASSUMPTION]`
