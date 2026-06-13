---
title: 'oracle_demo v1 — paginated cliente showcase'
type: 'feature'
created: '2026-06-13'
status: 'done'
baseline_commit: 'NO_VCS'
context:
  - '{project-root}/_bmad-output/planning-artifacts/prds/prd-oracle_demo-2026-06-13/prd.md'
  - '{project-root}/_bmad-output/planning-artifacts/briefs/brief-oracle_demo-2026-06-13/addendum.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** There is no living, properly-architected Flutter app proving the published `oracledb` v1.0.0 pure-Dart driver works end-to-end against a real Oracle DB. `oracle_demo` is currently an empty scaffold (only `main.dart`).

**Approach:** Build a single-screen macOS app that opens an `OraclePool`, runs the mandatory per-session init via `sessionCallback`, and renders a SQL-paginated `cliente` table in `shadcn_ui`. Mirror the author's `concurs`/blueocean clean architecture (data/domain/presentation, `fpdart` `Either<AppException,T>`, Riverpod code-gen, Freezed) so it doubles as a copy-pasteable blueprint.

## Boundaries & Constraints

**Always:**
- Credentials come only from `.env` (never hard-coded). Ship a committed `.env.example`; gitignore the real `.env`.
- The per-session init PL/SQL block runs through `OraclePool.sessionCallback` exactly once per session creation/tag-change — never per query.
- The driver is reached only through the data-source/repository layer — never from a widget.
- Repositories return `Either<AppException, T>`; domain models are Freezed; state is Riverpod code-gen. Layering must be recognizable to a `concurs` reader.
- Pagination is SQL-level only (`OFFSET … FETCH NEXT … ROWS ONLY` + `COUNT(*)`); only the current page is ever materialized.

**Ask First:**
- If live `cliente` column metadata contradicts the assumed Dart types (addendum table), confirm the mapping before finalizing the Freezed model.
- If the real `ShadTable` constructor cannot cleanly render this table, halt before substituting any other table widget.
- Page size other than the assumed **25**.
- Treating the abstract PRD "`Result<T, AppFailure>`" as the concrete `fpdart` `Either<AppException, T>` (the actual `concurs` idiom).

**Never:** No writes (INSERT/UPDATE/DELETE), transactions UI, or PL/SQL demos. No third-party data-grid (Trina/Syncfusion) and no in-table sort/filter. No API backend. No non-macOS / web targets.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| First page | Valid `.env`, `cliente` has rows | Page 1 (≤25 rows) renders in `ShadTable`; `page 1 of N`; Prev disabled | N/A |
| Navigate | On page X, tap Next/Prev | Fetches only page X±1 via OFFSET/FETCH; prior pages not accumulated | N/A |
| Last page | On page N | Next disabled | N/A |
| Loading | Page fetch in flight | Explicit loading indicator | N/A |
| Empty set | `cliente` returns 0 rows | Explicit empty state; no crash | N/A |
| Wrong password | Bad `ORACLE_PASSWORD` | Readable error state on screen; no crash/blank window | `OracleException`(oraInvalidCredentials/Locked/Expired) → `AppException.auth` |
| Unreachable host | Bad host/port | Readable error state | `OracleException`(connectTimeout/hostUnreachable/connectionRefused/networkError) → `AppException.connection` |
| Other DB error | SQL/runtime failure | Readable error state | other `OracleException` → `AppException.query`; non-Oracle → `AppException.unexpected` |

</frozen-after-approval>

## Code Map

- `pubspec.yaml` -- add deps + register `.env` asset
- `.env.example` -- committed connection template; real `.env` gitignored
- `analysis_options.yaml` -- lints + exclude generated files
- `lib/config/oracle_config.dart` -- reads dotenv → EZ-Connect string, user, password
- `lib/exceptions/app_exception.dart` -- Freezed sealed `AppException` (auth/connection/query/unexpected)
- `lib/domain/cliente.dart` -- Freezed `Cliente` (16 cols)
- `lib/data/datasource/cliente_oracle_data_source.dart` -- `OraclePool` lifecycle, `sessionCallback` init, `fetchPage` (paged SELECT, deterministic ORDER BY) + `count` (`COUNT(*)`), row→`Cliente` mapping; pool via `@Riverpod(keepAlive:true)` with dispose
- `lib/data/repository/cliente_repository.dart` -- wraps data source, `getPage`→`Either<AppException, List<Cliente>>` and `count`→`Either<AppException, int>`, maps `OracleException`; `@riverpod` provider
- `lib/presentation/clientes/cliente_list_controllers.dart` -- `pageIndexProvider` `@Riverpod(keepAlive:true)` + `clientePageProvider` family(page) + cached `clienteCountProvider`
- `lib/presentation/clientes/cliente_list_page.dart` -- `ShadTable` + `ShadButton` prev/next + `page X of N` + loading/error/empty states
- `lib/presentation/app.dart` -- `ShadApp.router` + go_router
- `lib/presentation/routing/app_router.dart` -- single-route go_router stub
- `lib/main.dart` -- `WidgetsFlutterBinding`, `dotenv.load()`, `ProviderScope`, run `App`

## Tasks & Acceptance

**Execution:**
- [x] `pubspec.yaml` -- add `oracledb: ^1.0.0`, `flutter_riverpod: ^3.2.1`, `riverpod_annotation: ^4.0.2`, `fpdart: ^1.2.0`, `freezed_annotation: ^3.1.0`, `flutter_dotenv: ^6.0.0`, `go_router`, `shadcn_ui`; dev: `build_runner: ^2.11.1`, `riverpod_generator: ^4.0.3`, `freezed: ^3.2.5`, `riverpod_lint`, `custom_lint`, `flutter_lints: ^6.0.0`; register `.env` under `flutter: assets:`. Verify resolved `shadcn_ui`/`go_router` versions support SDK `^3.12`.
- [x] `.env.example` -- `ORACLE_HOST=192.168.2.30`, `ORACLE_PORT=1521`, `ORACLE_SERVICE=CELO`, `ORACLE_USER=NIK`, `ORACLE_PASSWORD=`; add `.env` to `.gitignore`
- [x] `lib/config/oracle_config.dart` -- build `${host}:${port}/${service}` + user/password from dotenv
- [x] `lib/exceptions/app_exception.dart` -- Freezed sealed `AppException` with `auth/connection/query/unexpected` + a `message` accessor
- [x] `lib/domain/cliente.dart` -- Freezed `Cliente` (cols per addendum) + `ClientePage`; types provisional pending column metadata
- [x] `lib/data/datasource/cliente_oracle_data_source.dart` -- pool provider (keepAlive, disposed via `pool.close`); `sessionCallback` runs the init block + sets `conn.tag`; `fetchPage(offset,size)` runs paged SELECT; `count()` runs `COUNT(*)`; map rows by UPPERCASE name → `Cliente`
- [x] `lib/data/repository/cliente_repository.dart` -- `getPage(pageIndex)` returns `Either<AppException, ClientePage>`; try/catch maps `OracleException`→`AppException`
- [x] `lib/presentation/clientes/cliente_list_controllers.dart` -- keepAlive `pageIndexProvider`; `clientePageProvider` family reads repository for the page
- [x] `lib/presentation/clientes/cliente_list_page.dart` -- render `ShadTable`, `ShadButton` prev/next (disabled at boundaries), `page X of N`, loading/error/empty via `AsyncValue`
- [x] `lib/presentation/app.dart` + `lib/presentation/routing/app_router.dart` -- `ShadApp.router` over a single-route go_router
- [x] `lib/main.dart` -- bootstrap: ensureInitialized, `dotenv.load()`, `ProviderScope`, run `App`
- [ ] Unit-test the `OracleException`→`AppException` mapping and offset/page-count math (`N = ceil(total/size)`); no live DB required

**Acceptance Criteria:**
- Given valid `.env`, when the app boots, then the `OraclePool` opens and the init block runs once per session via `sessionCallback` (verified not re-run per query).
- Given a `concurs`-familiar reviewer reads `lib/`, then they recognize data/domain/presentation layering, `Either<AppException,T>` repositories, Riverpod code-gen, and Freezed models without explanation.
- Given any page navigation, when the page changes, then exactly one paged SQL query runs for that page and no prior page is retained.
- Given `flutter analyze`, then it reports no errors after code-gen.

## Design Notes

**sessionCallback (primary teaching point)** — runs the mandatory init exactly once per physical session:
```dart
sessionCallback: (conn, requestedTag) async {
  await conn.execute('''BEGIN
    crm.crm_set_filial(dbo.constants.filial_esp);
    crm.crm_conexion_pkg.set_usuario_id('NIK');
    crm.crm_conexion_pkg.set_nik_idioma('castellano');
    dbo.conexion_pkg.set_cod_idioma_actual('castellano');
  END;''');
  conn.tag = requestedTag;
}
```
Reads run through `pool.withConnection((conn) => conn.execute(sql, {'offset': o, 'pageSize': s}))`; rows read by UPPERCASE column name (`row['NOMB_CLI']`). Paged SQL is the addendum's base SELECT + `ORDER BY alta_cli DESC, potencial, nomb_cli OFFSET :offset ROWS FETCH NEXT :pageSize ROWS ONLY`. `Either`/`AppException` are the concrete form of the PRD's abstract `Result<T,AppFailure>`. `ShadTable`'s exact constructor is unverified (package not yet fetched) — verify against the resolved source before coding the table.

## Verification

**Commands:**
- `flutter pub get` -- expected: resolves, no version conflicts
- `dart run build_runner build --delete-conflicting-outputs` -- expected: generates `.g.dart`/`.freezed.dart` with no errors
- `flutter analyze` -- expected: no errors
- `flutter run -d macos` -- expected: app launches (needs live Oracle + real `.env`)

**Manual checks:**
- With a valid `.env`, page 1 of `cliente` renders in `ShadTable`; Next/Prev paginate correctly; Prev disabled on page 1, Next on last page.
- A wrong `ORACLE_PASSWORD` shows a readable on-screen error, not a crash or blank window.

## Suggested Review Order

**Connection & session (the teaching centerpiece)**

- Start here: the pooled `OraclePool` opened once for the app, disposed on shutdown.
  [`cliente_oracle_data_source.dart:39`](../../lib/data/datasource/cliente_oracle_data_source.dart#L39)

- The mandatory per-session init block — runs via `sessionCallback`, once per session, not per query.
  [`cliente_oracle_data_source.dart:47`](../../lib/data/datasource/cliente_oracle_data_source.dart#L47)

- Connection settings come only from `.env` → EZ-Connect string.
  [`oracle_config.dart:27`](../../lib/config/oracle_config.dart#L27)

**Data access & typed errors**

- SQL-paged read; `cod_cli` appended to ORDER BY for deterministic paging.
  [`cliente_oracle_data_source.dart:69`](../../lib/data/datasource/cliente_oracle_data_source.dart#L69)

- `COUNT(*)` lives behind its own method so the total is fetched once, not per page.
  [`cliente_oracle_data_source.dart:82`](../../lib/data/datasource/cliente_oracle_data_source.dart#L82)

- Repository wraps the driver, returning `Either<AppException, T>` instead of throwing.
  [`cliente_repository.dart:26`](../../lib/data/repository/cliente_repository.dart#L26)

- Driver `OracleException` → typed `AppException` (auth / connection / query / unexpected).
  [`app_exception.dart:30`](../../lib/exceptions/app_exception.dart#L30)

**Pagination state & UI**

- keepAlive page index + paged family + cached count provider (the `concurs` idiom).
  [`cliente_list_controllers.dart:13`](../../lib/presentation/clientes/cliente_list_controllers.dart#L13)

- `ShadTable.list` render + loading/error/empty branches off `AsyncValue` + `Either`.
  [`cliente_list_page.dart:35`](../../lib/presentation/clientes/cliente_list_page.dart#L35)

- Prev/Next disabled at boundaries; `page X of N` from the stable count.
  [`cliente_list_page.dart:109`](../../lib/presentation/clientes/cliente_list_page.dart#L109)

**App shell**

- `ShadApp.router` over a single-route go_router; bootstrap loads `.env` before providers read it.
  [`app.dart:16`](../../lib/presentation/app.dart#L16)

- [`main.dart:10`](../../lib/main.dart#L10)

**Tests (no live DB)**

- Error-mapping + `N = ceil(total/size)` math.
  [`cliente_mapping_test.dart:7`](../../test/cliente_mapping_test.dart#L7)
