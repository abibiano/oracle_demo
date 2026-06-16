---
title: 'Migrate shadcn_ui → forui + pluto_grid with hooks_riverpod'
type: 'refactor'
created: '2026-06-16'
status: 'done'
baseline_commit: '4529f1c333ba039a71ca373af8015b924a763d0c'
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** The app uses `shadcn_ui` for its app root widget, theming, and all UI components (table, buttons, card). The project's preferred pattern is `hooks_riverpod` + `flutter_hooks` (HookConsumerWidget) for pages, which the current code does not use.

**Approach:** Remove `shadcn_ui`; replace with `forui` (`FTheme` wrapping `MaterialApp.router`, `FButton`, `FCard`). Replace the manual `ShadTable` with `PlutoGrid` (`pluto_grid` ^8.1.0). Convert `ClienteListPage` and its nested stateful widget to `HookConsumerWidget` using `flutter_hooks`.

## Boundaries & Constraints

**Always:**
- Preserve all 16 columns with their existing labels, widths, and formatters (euro, date, bool icon).
- Preserve pagination, loading, error, and empty states.
- Use `HookConsumerWidget` from `hooks_riverpod` for every widget that currently uses `ConsumerWidget` or `StatefulWidget` in this page.
- Use `useScrollController()` (flutter_hooks) instead of manual `ScrollController` lifecycle management.

**Ask First:**
- If `PlutoGrid` custom cell `renderer` does not support arbitrary Flutter widgets (icon for bool, formatted text), halt and ask before choosing an alternative rendering approach.
- If forui `FTheme` + `MaterialApp.router` combination causes go_router to lose deep-link or back-button behaviour, halt and ask.

**Never:**
- Change business logic, data layer (`ClienteRepository`, `ClienteOracleDataSource`), routing config, or Oracle connectivity.
- Add any feature not present in the current app.
- Use `ConsumerStatefulWidget` / `StatefulWidget` — the hooks pattern eliminates them.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Normal load | `asyncPage` is `AsyncData(Right([...25 rows...]))` | PlutoGrid renders 25 rows, all 16 columns visible | — |
| Loading | `asyncPage` is `AsyncLoading` | `CircularProgressIndicator` centered | — |
| DB error | `asyncPage` is `AsyncError` OR `Left(failure)` | FCard error box (420 px wide) with message | error.toString() shown in muted text |
| Empty result | `AsyncData(Right([]))` | Centred muted text "No hay clientes para mostrar." | — |
| First page | `pageIndex == 0` | "Anterior" button is disabled | — |
| Last page | `pageIndex == pageCount - 1` | "Siguiente" button is disabled | — |

</frozen-after-approval>

## Code Map

- `pubspec.yaml` -- dependency manifest; remove `shadcn_ui`, add `forui`, `pluto_grid`, `flutter_hooks`, `hooks_riverpod`, `intl`
- `lib/main.dart` -- ProviderScope root; replace `flutter_riverpod` import with `hooks_riverpod` (re-exports it)
- `lib/presentation/app.dart` -- app root; replace `ShadApp.router` with `FTheme` + `MaterialApp.router`
- `lib/presentation/clientes/cliente_list_page.dart` -- only file using shadcn widgets + StatefulWidget; full rewrite to forui + PlutoGrid + HookConsumerWidget
- `lib/data/repository/cliente_repository.dart` -- remove stale comment referencing `ShadTable`

## Tasks & Acceptance

**Execution:**
- [x] `pubspec.yaml` -- remove `shadcn_ui ^0.54.0`; add `forui: ^0.22.3`, `pluto_grid: ^8.1.0`, `flutter_hooks: ^0.21.0`, `hooks_riverpod: ^3.1.0`, `intl: ^0.20.2` -- shadcn_ui re-exported `intl`; pluto_grid and hooks packages are net-new
- [x] `lib/main.dart` -- swap `import 'package:flutter_riverpod/flutter_riverpod.dart'` → `import 'package:hooks_riverpod/hooks_riverpod.dart'` -- hooks_riverpod re-exports ProviderScope
- [x] `lib/presentation/app.dart` -- replace `ShadApp.router(title:..., routerConfig: router)` with `FTheme(data: FThemes.zinc.light.desktop, child: MaterialApp.router(title:..., routerConfig: router, debugShowCheckedModeBanner: false))` -- forui has no dedicated FApp root widget; FThemes.zinc.light returns FPlatformThemeData, need .desktop
- [x] `lib/presentation/clientes/cliente_list_page.dart` -- rewrite: (1) `ClienteListPage` becomes `HookConsumerWidget`; (2) `_ClienteTable` becomes `HookConsumerWidget` using `useMemoized()` for column/row construction; (3) `ShadTable.list` → `PlutoGrid` with `PlutoColumn`/`PlutoRow` built from `_buildColumns()`/`_buildRows()`; (4) replace all `ShadTheme.of(context).*` with `context.theme.*` (forui extension); (5) `ShadButton.outline` → `FButton(variant: FButtonVariant.outline, ...)`; (6) `ShadCard` → `SizedBox(width: 420, child: FCard(child: ...))` -- shadcn_ui entirely removed
- [x] `lib/data/repository/cliente_repository.dart` -- remove stale ShadTable comment -- stale reference to removed widget

**Acceptance Criteria:**
- Given the app is running, when the clientes page loads, then all 16 columns are shown in PlutoGrid with correct labels and widths
- Given a row in PlutoGrid, when the `altaCli` or `potencial` field is `'S'`, then a green check icon is displayed; otherwise a muted dash icon
- Given a row, when euro columns (`vtasAnyoAct`, etc.) are rendered, then values are formatted as `1.234.567 €` (Spanish locale, 0 decimals)
- Given a row, when date columns (`fecAltaCli`) are rendered, then values are ISO date strings (YYYY-MM-DD)
- Given pageIndex is 0, when the page renders, then the "Anterior" FButton is disabled
- Given a DB error, when the page renders, then an FCard with the error message is visible and is 420 px wide
- Given the app starts, when rendered, then no `shadcn_ui` import exists in any `.dart` file

## Design Notes

**forui typography mapping (from shadcn_ui):**
- `theme.textTheme.h3` → `context.theme.typography.xl2`
- `theme.textTheme.muted` → `context.theme.typography.sm` (apply `color: context.theme.colors.mutedForeground` explicitly)
- `theme.textTheme.small` → `context.theme.typography.sm`
- `theme.textTheme.large` → `context.theme.typography.lg`

**forui color mapping:**
- `colorScheme.background` → `context.theme.colors.background`
- `colorScheme.mutedForeground` → `context.theme.colors.mutedForeground`
- `colorScheme.destructive` → `context.theme.colors.destructive`

**PlutoGrid read-only data setup:**
```dart
PlutoGrid(
  columns: _buildColumns(context),
  rows: _buildRows(rows),
  mode: PlutoGridMode.readOnly,
  onLoaded: (event) => event.stateManager.setShowColumnFilter(false),
)
```
Each `PlutoColumn` uses `renderer: (ctx) => ...` for custom cell widgets (bool icons, formatted text). Field names match `_Column.label` slugified.

**HookConsumerWidget pattern:**
```dart
class _ClienteTable extends HookConsumerWidget {
  const _ClienteTable({required this.rows});
  final List<Cliente> rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verticalCtrl = useScrollController();
    // PlutoGrid manages its own scroll; keep controllers only if scrollbars needed
    return PlutoGrid(...);
  }
}
```

## Verification

**Commands:**
- `flutter pub get` -- expected: resolves without conflicts
- `dart run build_runner build --delete-conflicting-outputs` -- expected: exits 0
- `flutter analyze` -- expected: 0 errors, 0 warnings
- `grep -r "shadcn_ui" lib/` -- expected: no output (all imports removed)

## Suggested Review Order

**App root & theme wiring**

- `FTheme` wraps `MaterialApp.router`; `FThemes.zinc.light.desktop` provides the theme data.
  [`app.dart:13`](../../lib/presentation/app.dart#L13)

**PlutoGrid integration**

- Entry point: `_ClienteTable` wires `PlutoGrid` with `readOnly` mode, `ValueKey`, and `onLoaded`.
  [`cliente_list_page.dart:224`](../../lib/presentation/clientes/cliente_list_page.dart#L224)

- Column definitions: 16 `PlutoColumn` entries with alignment, width, and bool icon renderers.
  [`cliente_list_page.dart:68`](../../lib/presentation/clientes/cliente_list_page.dart#L68)

- Row builder: maps `List<Cliente>` to `List<PlutoRow>`, pre-formatting euro/date strings.
  [`cliente_list_page.dart:198`](../../lib/presentation/clientes/cliente_list_page.dart#L198)

**Page shell & hooks pattern**

- `ClienteListPage` (HookConsumerWidget): drives async state and passes `ValueKey(pageIndex)`.
  [`cliente_list_page.dart:12`](../../lib/presentation/clientes/cliente_list_page.dart#L12)

- `_PaginationBar`: `FButton` disabled via `onPress: null`; no StatefulWidget lifecycle needed.
  [`cliente_list_page.dart:242`](../../lib/presentation/clientes/cliente_list_page.dart#L242)

- Error state: `SizedBox(width: 420)` + `FCard` replaces `ShadCard(width: 420)`.
  [`cliente_list_page.dart:289`](../../lib/presentation/clientes/cliente_list_page.dart#L289)

**Config & dependencies**

- New packages added, `shadcn_ui` removed, `hooks_riverpod` import replaces `flutter_riverpod`.
  [`pubspec.yaml:10`](../../pubspec.yaml#L10)

- `main.dart` import swap to `hooks_riverpod` (re-exports `ProviderScope`).
  [`main.dart:3`](../../lib/main.dart#L3)
