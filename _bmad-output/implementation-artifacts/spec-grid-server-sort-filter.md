---
title: 'Server-side grid sort & filter (Oracle ORDER BY + WHERE)'
type: 'feature'
created: '2026-06-16'
status: 'done'
baseline_commit: '8e51375eb78aae3415c1eea43c97989d3d11fc74'
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Clicking a column header (or, eventually, filtering) only reorders the rows already prefetched into the infinite-scroll grid — not the whole Oracle `cliente` table — so results are wrong the moment there is more than one page. Filtering does not exist at all today (the column-filter UI is disabled).

**Approach:** Push sort and filter down to the database. Turn on pluto_grid's server-side mode (`fetchWithSorting`/`fetchWithFiltering` + a visible per-column filter row), thread the clicked sort column and active filters through `getPage`/`fetchPage`, and build a parameterized Oracle `ORDER BY` and `WHERE` from an allowlist that maps grid `field` → DB column, while keeping the existing SQL-level `OFFSET/FETCH` paging.

## Boundaries & Constraints

**Always:**
- Map grid `field` → DB column through a fixed allowlist in the data source; an unknown field is ignored, never interpolated into SQL.
- Pass every filter value as a bind parameter; only the column identifier and `ASC`/`DESC` come from code, never from user text.
- Append `cod_cli` as the final `ORDER BY` tiebreaker so `OFFSET/FETCH` never skips or duplicates rows. No active sort → keep the current default order.
- Keep the driver isolated to the data source (FR-2/FR-10): presentation maps pluto types → plain sort/filter params; no `pluto_grid` import in the data or repository layers.
- Combine multiple active filters with `AND`; text filters are case-insensitive.

**Ask First:**
- Adding any new `@riverpod` provider (forces a build_runner run) — prefer calling `getPage` with params.

**Never:**
- No client-side sort/filter fallback (`fetchWithSorting`/`fetchWithFiltering` stay `true`).
- No filtered total-count indicator or pagination bar — this grid is infinite-scroll only.
- Don't touch the session-init block, the pool, or the `Cliente` shape.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| No sort, no filter | initial load | default `ORDER BY alta_cli DESC, potencial, nomb_cli, cod_cli`, page 0 | N/A |
| Sort ascending | click 'Nombre' header | `ORDER BY nomb_cli ASC NULLS LAST, cod_cli`; grid resets to top, refetches offset 0 | N/A |
| Sort cleared | 3rd click on a header → none | revert to default order | N/A |
| Text filter | 'nombre' Contains "ace" | `WHERE UPPER(nomb_cli) LIKE UPPER('%'\|\|:f0\|\|'%')`, bind `f0`='ace' | N/A |
| Multiple filters | nombre + nif active | conditions `AND`-joined, each with its own bind | N/A |
| Filter on non-text col | sales / date / icon column | no DB filter produced (column not filterable) | ignored |
| Unknown field or blank value | field absent from allowlist, or empty value | clause omitted entirely | ignored |
| Scroll next page | `lastRow != null` under active sort/filter | same `WHERE`/`ORDER BY`, offset = loaded row count | N/A |

</frozen-after-approval>

## Code Map

- `lib/data/datasource/cliente_oracle_data_source.dart` -- core change: field→column allowlist, pure `ORDER BY`/`WHERE` builders with bind params, composed into `fetchPage`.
- `lib/data/repository/cliente_repository.dart` -- thread sort+filter params through `getPage`, keep the `Either` guard.
- `lib/presentation/clientes/cliente_list_page.dart` -- enable server-side sort/filter, show the filter row, map the pluto `fetch` request → plain params, mark non-text columns non-filterable.
- `test/cliente_query_builder_test.dart` (new) -- unit-test the SQL builders against the matrix.

## Tasks & Acceptance

**Execution:**
- [x] `lib/data/datasource/cliente_oracle_data_source.dart` -- define plain param types `ClienteSort` (`field`, `descending`) and `ClienteFilter` (`field`, `match`, `value`); add a `_fieldToColumn` allowlist plus its filterable subset; add pure `buildClienteOrderBy(sort)` and `buildClienteWhere(filters)` returning `(sql, binds)`; compose them into `fetchPage(pageIndex, pageSize, {sort, filters})` keeping `OFFSET/FETCH`.
- [x] `lib/data/repository/cliente_repository.dart` -- `getPage(pageIndex, {ClienteSort? sort, List<ClienteFilter> filters = const []})` forwarding to the data source under the existing guard; re-export the param types so presentation depends only on the repository.
- [x] `lib/presentation/clientes/cliente_list_page.dart` -- set `fetchWithSorting: true`, `fetchWithFiltering: true`; `setShowColumnFilter(true)`; in `fetch`, derive `ClienteSort` from `request.sortColumn` (`.field`, `.sort`) and `List<ClienteFilter>` from `request.filterRows` (read `FilterHelper.filterFieldColumn/Type/Value`); pass them to `getPage`; set `enableFilterMenuItem: false` on the icon (alta/pot), sales, and date columns.
- [x] `test/cliente_query_builder_test.dart` -- cover the matrix: default order; ASC/DESC; tiebreaker no-dup; Contains/Equals/StartsWith/EndsWith → SQL; multi-filter `AND`; unknown field ignored (injection guard); non-filterable field dropped; blank value omitted; malicious value bound not interpolated.

**Acceptance Criteria:**
- Given more than one page of clientes, when I click a column header, then rows reorder across the whole table (the first visible row changes), not just the loaded page.
- Given a value typed into a text column's filter, when it applies, then the grid shows only DB-matching rows and re-paginates from the top.
- Given a filter value or a field crafted to inject SQL, when `fetch` runs, then no column name is interpolated and every value is bound — the query stays safe.
- Given any sort or filter change, when `fetch` fires, then the grid clears and refetches from offset 0 with the new clause, and scrolling still loads further pages under that clause.

## Spec Change Log

- **2026-06-16, post-review (user-requested additions, review PASSED):**
  - **NULLS LAST** — `buildClienteOrderBy` now appends `NULLS LAST` to the active sort column for both directions (Oracle defaults NULLS FIRST on DESC), so NULLs never lead a sorted page. Tests updated. Frozen I/O matrix sort rows amended accordingly (human-authorized).
  - **Total count** — the unfiltered `count()` (previously orphaned) is wired into the page header as a pill beside the title via `useFuture`. Does not violate the "no filtered total-count" Never (this is the total, not a filter-scoped count, and no pagination bar is added).
  - **Visual polish** — added a forui-themed `PlutoGridConfiguration` (rounded border, zebra rows, no vertical grid lines, accented sort icons, roomier padding) and a header count badge. Presentation-only; no data/query changes.

## Design Notes

pluto_grid 8.1.0 hands state to the `fetch` callback on the request itself: `request.sortColumn` (`PlutoColumn?` → `.field`, `.sort` ∈ none/ascending/descending) and `request.filterRows` (`List<PlutoRow>`; read each via `FilterHelper.filterFieldColumn` / `filterFieldType` / `filterFieldValue`). The grid auto-resets on any sort/filter change — it clears rows and calls `fetch` with `lastRow == null` — so the existing offset logic (`lastRow == null ? 0 : loadedCount`) already re-paginates correctly; no manual reset needed.

Golden query under one text filter + sort:
```
... FROM cliente
 WHERE UPPER(nomb_cli) LIKE UPPER('%'||:f0||'%')
 ORDER BY nomb_cli ASC, cod_cli
 OFFSET :offset ROWS FETCH NEXT :pageSize ROWS ONLY
```
Filter type → SQL: Contains/StartsWith/EndsWith → matching `LIKE` shape; Equals → `UPPER(col) = UPPER(:fN)`; unknown type → Contains. LIKE wildcards inside user text match literally (acceptable for this demo — note only, not handled).

## Verification

**Commands:**
- `flutter analyze` -- expected: no new issues.
- `flutter test` -- expected: all pass, including the new query-builder tests.

**Manual checks:**
- Against a live DB: sort by Nombre, then NIF; confirm the top row reflects whole-table order, not page-local order. Type into a text filter; confirm the row set shrinks and scrolling still pages under the filter.
- Sort a column with NULLs; confirm NULL rows sink to the bottom in both ASC and DESC.
- Confirm the total-count pill beside the title shows the full `cliente` count, and the grid styling (zebra rows, rounded border, accented sort arrows) renders.

## Suggested Review Order

**Query building — the design heart + injection guard**

- Allowlist maps grid `field` → DB column; the sole source of column identifiers in SQL.
  [`cliente_oracle_data_source.dart:36`](../../lib/data/datasource/cliente_oracle_data_source.dart#L36)

- ORDER BY from the active sort, NULLS LAST + `cod_cli` tiebreaker; default order otherwise.
  [`cliente_oracle_data_source.dart:91`](../../lib/data/datasource/cliente_oracle_data_source.dart#L91)

- WHERE from filters: unknown/non-filterable/blank dropped, every value bound `:fN`.
  [`cliente_oracle_data_source.dart:104`](../../lib/data/datasource/cliente_oracle_data_source.dart#L104)

- Filter match → SQL shape; only the bind placeholder carries user text.
  [`cliente_oracle_data_source.dart:124`](../../lib/data/datasource/cliente_oracle_data_source.dart#L124)

- `fetchPage` composes SELECT + WHERE + ORDER BY + OFFSET/FETCH with merged binds.
  [`cliente_oracle_data_source.dart:182`](../../lib/data/datasource/cliente_oracle_data_source.dart#L182)

**Repository pass-through (driver stays isolated)**

- `getPage` forwards sort+filters under the Either guard; re-exports the plain param types.
  [`cliente_repository.dart:27`](../../lib/data/repository/cliente_repository.dart#L27)

**Grid → params mapping (presentation owns pluto)**

- Server-side mode on + fetch derives sort/filters from the pluto request.
  [`cliente_list_page.dart:353`](../../lib/presentation/clientes/cliente_list_page.dart#L353)

- pluto sort/filter state → plain `ClienteSort`/`ClienteFilter`; allowlist guards the rest.
  [`cliente_list_page.dart:305`](../../lib/presentation/clientes/cliente_list_page.dart#L305)

**Count + visual polish (presentation-only)**

- Total count read once via `useFuture`, shown as a header pill.
  [`cliente_list_page.dart:18`](../../lib/presentation/clientes/cliente_list_page.dart#L18)

- forui-themed grid styling: zebra, rounded border, accented sort icons, padding.
  [`cliente_list_page.dart:103`](../../lib/presentation/clientes/cliente_list_page.dart#L103)

**Tests**

- Pure builder coverage: order/tiebreaker/NULLS LAST, filter shapes, injection guard.
  [`cliente_query_builder_test.dart:4`](../../test/cliente_query_builder_test.dart#L4)
