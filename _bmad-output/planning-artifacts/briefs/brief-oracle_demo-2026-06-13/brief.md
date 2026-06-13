---
title: "Product Brief: oracle_demo"
status: draft
created: 2026-06-13
updated: 2026-06-13
---

# Product Brief: oracle_demo

## Executive Summary

`oracle_demo` is a small macOS Flutter desktop app that serves as the **reference showcase** for the [`oracledb`](https://pub.dev/packages/oracledb) v1.0.0 pure-Dart Oracle driver. It connects directly to a real Oracle database — no API backend, no Oracle Instant Client, no FFI — and renders a **paginated data table** from a real table.

It answers one question convincingly: *"Can I use `oracledb` in a real Flutter app, the right way?"* Rather than a throwaway script, it mirrors the production-grade clean architecture from the author's `pixcontest/concurs` project, so it doubles as a **copy-pasteable blueprint** for best-practice driver integration.

Built by the package author for the package's users, its value is credibility and onboarding: a developer evaluating `oracledb` can clone it, point it at their database, and see live rows in a properly architected app within minutes.

## The Problem

`oracledb` is a newly stable (v1.0.0), independent pure-Dart driver. A developer discovering it on pub.dev faces predictable friction:

- **"Does it actually work end-to-end in a Flutter app?"** The README and `example.dart` show console usage, not how the driver lives inside a real UI app with state management, error handling, and async data flow.
- **"How do I wire it up *properly*?"** Naive examples (call `execute` in a widget `build`, dump rows in a `ListView`) teach bad habits. No canonical example shows the driver behind a repository, surfaced through providers, with paginated reads and graceful error states.
- **"Will it run on my desktop without Oracle client libraries?"** The headline claim (pure Dart, no Instant Client) deserves tangible, runnable proof on a real platform.

The alternative is for each developer to reinvent this integration, re-deriving architecture decisions the author already made well in other projects.

## The Solution

A focused macOS Flutter app with one screen: a **paginated table view** of rows from the `cliente` (CRM client) table, fetched directly from Oracle via `oracledb`.

The experience:
1. The app launches and reads connection settings (host/port/service/user/password) from `.env`.
2. It opens an `OraclePool` against `192.168.2.30:1521/CELO` as user `NIK`. A **`sessionCallback`** runs the mandatory per-session initialization block (setting the `filial`, `usuario_id`, and `idioma` session variables the database depends on) once per session, so every borrowed connection is correctly initialized.
3. It fetches the first page of `cliente` rows and renders them with **`shadcn_ui`**'s `ShadTable`, paired with pagination controls composed from `ShadButton` (next/prev, page indicator). Paging is done at the SQL level (`OFFSET … FETCH NEXT … ROWS ONLY` plus a `COUNT(*)` for totals), so only one small page is ever rendered — a clean fit for `ShadTable`, with no third-party data-grid needed.
4. Loading, error, and empty states are handled explicitly — no silent failures.

Architecturally, the non-UI layers deliberately mirror `pixcontest/concurs`:
- **Layered + feature-first**: `data / domain / presentation` with an `application` layer for providers.
- **Riverpod (code-gen)** for all state — `flutter_riverpod` + `hooks_riverpod` + `riverpod_annotation` + `riverpod_generator`.
- **Repository pattern**: a data source wraps `oracledb` calls → a repository maps results and handles errors → providers expose them.
- **Freezed** domain models; **`Result<T, AppFailure>`** error handling.
- **`FutureProvider.family`** for the paginated read, with a local `@Riverpod(keepAlive: true)` page-index provider — the exact pagination idiom from `concurs`.
- **`flutter_dotenv` + `String.fromEnvironment`** for connection config, mirroring `concurs` env handling.

The **presentation layer deliberately diverges** from `concurs`: instead of Material + `flex_color_scheme`, the UI is built with the **`shadcn_ui`** component library — a chance to evaluate shadcn-style components on a real desktop screen while keeping the proven architecture underneath.

## What Makes This Different

This is not a feature product; its differentiation is as a **teaching artifact**:

- **Real driver, real database, real architecture.** Most package examples cut corners on at least one. This cuts none.
- **Author-authored best practice.** Built by the driver's author against their own proven architecture, the patterns carry authority — this *is* the recommended way.
- **Adapted, not copied.** `concurs` paginates against a REST API that returns pagination metadata; with no API here, the demo shows the genuinely useful adaptation of **paginating in SQL** against Oracle directly.
- **Real-world session state.** The demo shows the *correct* place for the mandatory per-session init — the pool's `sessionCallback` — rather than re-running it on every query, exactly the kind of production concern most examples ignore.

## Who This Serves

**Primary: Dart/Flutter developers evaluating or adopting `oracledb`.** They need Oracle connectivity from Dart, are wary of an independent driver, and want to see it work in a real app before committing. Success = "I cloned it, pointed it at my DB, saw my rows paginated, and understood how to structure my own app."

**Secondary: the author.** A living reference to point users to, and a smoke-test that `oracledb` behaves correctly in a Flutter desktop runtime, not just under `dart run`.

## Success Criteria

- App launches on macOS, connects to a real Oracle DB, and displays real rows in a paginated table. `[ASSUMPTION]` Validated against the author's local/dev Oracle instance (e.g. Oracle 23ai/21c FREEPDB1).
- Pagination works: forward/back navigation fetches the correct page via SQL, and the total page count is accurate.
- Loading, error, and empty states each render correctly (e.g. wrong password → readable error, not a crash).
- The codebase visibly follows `concurs` conventions — a reviewer familiar with `concurs` recognizes the structure immediately.
- A developer unfamiliar with the project can configure connection settings and run it without reading source code.

## Scope

**In (v1):**
- Single macOS desktop target.
- The **`cliente`** table (CRM clients: name, fiscal data, multi-year sales) rendered with **`shadcn_ui`** `ShadTable` + `ShadButton` pagination controls, ordered `alta_cli DESC, potencial, nomb_cli`. No third-party data-grid package.
- Direct Oracle connection via `oracledb`, using **`OraclePool`** (`withConnection`) as the best-practice connection-management showcase, with a **`sessionCallback`** running the mandatory per-session init block. (Confirmed: pool over a single `OracleConnection`.)
- SQL-based pagination (`OFFSET … FETCH NEXT … ROWS ONLY` + `COUNT(*)`).
- Connection config via `.env` (dotenv) / dart-define, never hard-coded credentials.
- Clean-architecture layering + Riverpod code-gen mirroring `concurs`.
- **`shadcn_ui`** as the UI component library (deliberate divergence from `concurs`' Material/`flex_color_scheme`); table via `ShadTable`, pagination composed from `ShadButton` — no separate grid package.
- **go_router stubbed** for a single screen, to stay faithful to `concurs` conventions.
- Loading / error / empty UI states.

**Out (v1):**
- No API backend (explicit, by design).
- No web/Windows/Linux/mobile targets — **macOS only** for v1 (`oracledb` excludes web entirely).
- **Read-only**: no write operations (INSERT/UPDATE/DELETE), transactions UI, or PL/SQL demos.
- No authentication/login UI, no multi-table browser, no query editor.
- No column sorting/filtering UI. (Could be a fast-follow; left out to keep v1 tight.)

## Vision

If it succeeds, `oracle_demo` becomes the canonical "getting started with `oracledb` in Flutter" reference linked from the package README. Natural extensions — a multi-table browser, live query console, writes/transactions and PL/SQL demos, and additional desktop targets (Windows/Linux) — would each become a new tab in a growing, runnable gallery of the driver's capabilities. It stays small and exemplary; it never becomes a product, only an ever-clearer teaching tool.

---

### Resolved

_All decisions locked 2026-06-13:_ table = `cliente` · connection = `OraclePool` + `sessionCallback` init · target = `192.168.2.30:1521/CELO` as `NIK` (password in `.env`) · platform = macOS-only v1 · pagination = SQL `OFFSET/FETCH` + `COUNT(*)` · read-only · go_router stubbed · **UI = `shadcn_ui`** (diverges from concurs Material).

_Exact SQL, column-to-model mapping, and the session-init block are captured in [addendum.md](addendum.md) for the PRD/architecture stage. One dev-time item: confirm Dart types per column and dedupe the column list._
