import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../data/repository/cliente_repository.dart';
import '../../domain/cliente.dart';

class ClienteListPage extends HookConsumerWidget {
  const ClienteListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetchError = useState<String?>(null);
    // Total cliente count (unfiltered), read once and shown next to the title.
    final countResult = useFuture(
      useMemoized(() => ref.read(clienteRepositoryProvider).count()),
    );
    final total = countResult.data?.fold((_) => null, (n) => n);

    // Server-side Sí/No filters for the flag columns, driven from the toolbar
    // (pluto's filter row is text-only). null = Todos.
    final gridManager = useRef<PlutoGridStateManager?>(null);
    final altaFilter = useState<String?>(null);
    final potFilter = useState<String?>(null);
    void applyFlags() {
      final sm = gridManager.value;
      if (sm != null) {
        _applyFlagFilters(sm, altaFilter.value, potFilter.value);
      }
    }

    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Clientes', style: typography.xl2),
                const SizedBox(width: 12),
                if (total != null) _CountBadge(total: total),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'oracledb · scroll infinito sobre Oracle',
              style: typography.sm.copyWith(color: colors.mutedForeground),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                _FlagFilter(
                  label: 'Alta',
                  value: altaFilter.value,
                  onChanged: (v) {
                    altaFilter.value = v;
                    applyFlags();
                  },
                ),
                _FlagFilter(
                  label: 'Potencial',
                  value: potFilter.value,
                  onChanged: (v) {
                    potFilter.value = v;
                    applyFlags();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: fetchError.value != null
                  ? _ErrorState(message: fetchError.value!)
                  : _ClienteTable(
                      onError: (msg) => fetchError.value = msg,
                      onGridLoaded: (sm) => gridManager.value = sm,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

final _euroFormat = NumberFormat.currency(
  locale: 'es_ES',
  symbol: '€',
  decimalDigits: 0,
);

String _euroText(num? value) => value == null ? '' : _euroFormat.format(value);

String _dateText(DateTime? value) =>
    value == null ? '' : value.toIso8601String().split('T').first;

final _countFormat = NumberFormat.decimalPattern('es_ES');

/// A pill showing the total cliente count beside the page title.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        '${_countFormat.format(total)} clientes',
        style: context.theme.typography.sm.copyWith(
          color: colors.mutedForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Rewrites pluto's filter rows for the `alta`/`pot` flag columns from the
/// toolbar selection (`'S'`, `'N'`, or null = Todos), preserving any other
/// column filters. `setFilterWithFilterRows` fires the filter-change event that
/// resets the infinite scroll and refetches from the database.
void _applyFlagFilters(
  PlutoGridStateManager stateManager,
  String? alta,
  String? pot,
) {
  final rows = stateManager.filterRows.where((row) {
    final field = row.cells[FilterHelper.filterFieldColumn]?.value;
    return field != 'alta' && field != 'pot';
  }).toList();
  void add(String field, String? value) {
    if (value == null) return;
    rows.add(FilterHelper.createFilterRow(
      columnField: field,
      filterType: const PlutoFilterTypeEquals(),
      filterValue: value,
    ));
  }

  add('alta', alta);
  add('pot', pot);
  stateManager.setFilterWithFilterRows(rows);
}

/// A compact `Todos · Sí · No` segmented control for a boolean flag column.
class _FlagFilter extends StatelessWidget {
  const _FlagFilter({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String? value; // null = Todos, 'S' = Sí, 'N' = No
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    Widget segment(String text, String? segValue) {
      final selected = value == segValue;
      return GestureDetector(
        onTap: () => onChanged(segValue),
        child: Container(
          color: selected ? colors.primary : colors.background,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            text,
            style: typography.sm.copyWith(
              color:
                  selected ? colors.primaryForeground : colors.mutedForeground,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: typography.sm.copyWith(color: colors.mutedForeground),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              segment('Todos', null),
              Container(width: 1, height: 30, color: colors.border),
              segment('Sí', 'S'),
              Container(width: 1, height: 30, color: colors.border),
              segment('No', 'N'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Themed pluto styling derived from the forui palette: rounded border, zebra
/// rows, no vertical grid lines, accented sort icons, roomier padding.
PlutoGridConfiguration _gridConfiguration(BuildContext context) {
  final colors = context.theme.colors;
  return PlutoGridConfiguration(
    style: PlutoGridStyleConfig(
      gridBackgroundColor: colors.background,
      rowColor: colors.background,
      evenRowColor: colors.background,
      oddRowColor: colors.muted,
      activatedColor: colors.muted,
      checkedColor: colors.muted,
      // Disabled filter cells (non-filterable columns) blend with the grid
      // instead of rendering as grey boxes.
      cellColorInReadOnlyState: colors.background,
      gridBorderColor: colors.border,
      borderColor: colors.border,
      activatedBorderColor: colors.primary,
      inactivatedBorderColor: colors.border,
      iconColor: colors.mutedForeground,
      enableColumnBorderVertical: false,
      enableCellBorderVertical: false,
      enableGridBorderShadow: false,
      iconSize: 16,
      rowHeight: 46,
      columnHeight: 48,
      columnFilterHeight: 44,
      gridBorderRadius: BorderRadius.circular(10),
      // Right padding keeps the title text clear of the context-menu icon,
      // which pluto overlays at the column's right edge (no overlap on narrow
      // columns).
      defaultColumnTitlePadding: const EdgeInsets.only(left: 14, right: 22),
      defaultColumnFilterPadding: const EdgeInsets.symmetric(horizontal: 10),
      defaultCellPadding: const EdgeInsets.symmetric(horizontal: 14),
      columnTextStyle: TextStyle(
        color: colors.foreground,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      cellTextStyle: TextStyle(color: colors.foreground, fontSize: 13),
      columnAscendingIcon:
          Icon(Icons.arrow_upward, size: 14, color: colors.primary),
      columnDescendingIcon:
          Icon(Icons.arrow_downward, size: 14, color: colors.primary),
    ),
  );
}

List<PlutoColumn> _buildColumns() => [
      PlutoColumn(
        title: 'Alta',
        field: 'alta',
        enableFilterMenuItem: false,
        type: PlutoColumnType.text(),
        width: 70,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (ctx) {
          final isYes =
              (ctx.cell.value?.toString() ?? '').trim().toUpperCase() == 'S';
          return Center(
            child: isYes
                ? const Icon(Icons.check_circle,
                    size: 18, color: Color(0xFF16A34A))
                : const Icon(Icons.remove, size: 18, color: Color(0xFF71717B)),
          );
        },
      ),
      PlutoColumn(
        title: 'Pot.',
        field: 'pot',
        enableFilterMenuItem: false,
        type: PlutoColumnType.text(),
        width: 60,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: (ctx) {
          final isYes =
              (ctx.cell.value?.toString() ?? '').trim().toUpperCase() == 'S';
          return Center(
            child: isYes
                ? const Icon(Icons.check_circle,
                    size: 18, color: Color(0xFF16A34A))
                : const Icon(Icons.remove, size: 18, color: Color(0xFF71717B)),
          );
        },
      ),
      PlutoColumn(
        title: 'Código',
        field: 'codigo',
        type: PlutoColumnType.text(),
        width: 90,
      ),
      PlutoColumn(
        title: 'Nombre',
        field: 'nombre',
        type: PlutoColumnType.text(),
        width: 200,
      ),
      PlutoColumn(
        title: 'Nombre fiscal',
        field: 'nombre_fiscal',
        type: PlutoColumnType.text(),
        width: 200,
      ),
      PlutoColumn(
        title: 'NIF',
        field: 'nif',
        type: PlutoColumnType.text(),
        width: 110,
      ),
      PlutoColumn(
        title: 'Dirección 1',
        field: 'dir1',
        type: PlutoColumnType.text(),
        width: 200,
      ),
      PlutoColumn(
        title: 'Dirección 2',
        field: 'dir2',
        type: PlutoColumnType.text(),
        width: 160,
      ),
      PlutoColumn(
        title: 'CP',
        field: 'cp',
        type: PlutoColumnType.text(),
        width: 80,
      ),
      PlutoColumn(
        title: 'Población',
        field: 'pobl',
        type: PlutoColumnType.text(),
        width: 160,
      ),
      PlutoColumn(
        title: 'Prov.',
        field: 'prov',
        type: PlutoColumnType.text(),
        width: 70,
      ),
      PlutoColumn(
        title: 'Ventas año act.',
        field: 'ventas_act',
        enableFilterMenuItem: false,
        type: PlutoColumnType.text(),
        width: 120,
        textAlign: PlutoColumnTextAlign.end,
        titleTextAlign: PlutoColumnTextAlign.end,
      ),
      PlutoColumn(
        title: 'Ventas año ant.',
        field: 'ventas_ant',
        enableFilterMenuItem: false,
        type: PlutoColumnType.text(),
        width: 120,
        textAlign: PlutoColumnTextAlign.end,
        titleTextAlign: PlutoColumnTextAlign.end,
      ),
      PlutoColumn(
        title: 'Ventas -2 años',
        field: 'ventas_2',
        enableFilterMenuItem: false,
        type: PlutoColumnType.text(),
        width: 120,
        textAlign: PlutoColumnTextAlign.end,
        titleTextAlign: PlutoColumnTextAlign.end,
      ),
      PlutoColumn(
        title: 'Ventas -3 años',
        field: 'ventas_3',
        enableFilterMenuItem: false,
        type: PlutoColumnType.text(),
        width: 120,
        textAlign: PlutoColumnTextAlign.end,
        titleTextAlign: PlutoColumnTextAlign.end,
      ),
      PlutoColumn(
        title: 'Fecha alta',
        field: 'fecha_alta',
        enableFilterMenuItem: false,
        type: PlutoColumnType.text(),
        width: 120,
      ),
    ];

List<PlutoRow> _buildRows(List<Cliente> clientes) => clientes
    .map(
      (c) => PlutoRow(cells: {
        'alta': PlutoCell(value: c.altaCli ?? ''),
        'pot': PlutoCell(value: c.potencial ?? ''),
        'codigo': PlutoCell(value: c.codCli ?? ''),
        'nombre': PlutoCell(value: c.nombCli ?? ''),
        'nombre_fiscal': PlutoCell(value: c.nombFiscalCli ?? ''),
        'nif': PlutoCell(value: c.nifCli ?? ''),
        'dir1': PlutoCell(value: c.dir1Fiscal ?? ''),
        'dir2': PlutoCell(value: c.dir2Fiscal ?? ''),
        'cp': PlutoCell(value: c.codPosFiscal ?? ''),
        'pobl': PlutoCell(value: c.poblFiscal ?? ''),
        'prov': PlutoCell(value: c.codProvFiscal ?? ''),
        'ventas_act': PlutoCell(value: _euroText(c.vtasAnyoAct)),
        'ventas_ant': PlutoCell(value: _euroText(c.vtasAnyoAnt)),
        'ventas_2': PlutoCell(value: _euroText(c.vtasHaceDosAnyos)),
        'ventas_3': PlutoCell(value: _euroText(c.vtasHaceTresAnyos)),
        'fecha_alta': PlutoCell(value: _dateText(c.fecAltaCli)),
      }),
    )
    .toList();

/// Maps pluto's current sort state to a plain [ClienteSort]. Null when no
/// column is sorted, so the data source applies its default order.
ClienteSort? _sortFrom(PlutoColumn? column) {
  if (column == null || column.sort.isNone) return null;
  return ClienteSort(field: column.field, descending: column.sort.isDescending);
}

/// Maps pluto's active filter rows to plain [ClienteFilter]s. Empty/sentinel
/// fields are passed through verbatim — the data source's allowlist drops any
/// that are not real, filterable columns.
List<ClienteFilter> _filtersFrom(List<PlutoRow> filterRows) {
  final filters = <ClienteFilter>[];
  for (final row in filterRows) {
    final field = row.cells[FilterHelper.filterFieldColumn]?.value;
    final value = row.cells[FilterHelper.filterFieldValue]?.value;
    if (field is! String || value is! String || value.isEmpty) continue;
    filters.add(ClienteFilter(
      field: field,
      match: _matchFrom(row.cells[FilterHelper.filterFieldType]?.value),
      value: value,
    ));
  }
  return filters;
}

ClienteFilterMatch _matchFrom(Object? type) => switch (type) {
      PlutoFilterTypeEquals() => ClienteFilterMatch.equals,
      PlutoFilterTypeStartsWith() => ClienteFilterMatch.startsWith,
      PlutoFilterTypeEndsWith() => ClienteFilterMatch.endsWith,
      _ => ClienteFilterMatch.contains,
    };

class _ClienteTable extends HookConsumerWidget {
  const _ClienteTable({required this.onError, required this.onGridLoaded});
  final void Function(String) onError;
  final void Function(PlutoGridStateManager) onGridLoaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = useMemoized(_buildColumns);

    return PlutoGrid(
      columns: columns,
      rows: <PlutoRow>[],
      mode: PlutoGridMode.readOnly,
      configuration: _gridConfiguration(context),
      onLoaded: (event) {
        event.stateManager.setShowColumnFilter(true);
        onGridLoaded(event.stateManager);
      },
      createFooter: (stateManager) => PlutoInfinityScrollRows(
        // Delegate sort/filter to the database instead of reordering the rows
        // already loaded. On any sort/filter change pluto resets (fetch with
        // lastRow == null), so the offset logic below re-paginates correctly.
        fetchWithSorting: true,
        fetchWithFiltering: true,
        stateManager: stateManager,
        fetch: (request) async {
          // Determine the Oracle page offset from the number of rows already
          // loaded. On initial fetch (lastRow == null) that count is 0.
          final loaded = request.lastRow == null
              ? 0
              : stateManager.refRows.originalList.length;
          final pageIndex = loaded ~/ ClienteRepository.pageSize;

          final result = await ref.read(clienteRepositoryProvider).getPage(
                pageIndex,
                sort: _sortFrom(request.sortColumn),
                filters: _filtersFrom(request.filterRows),
              );

          return result.fold(
            (failure) {
              onError(failure.message);
              return PlutoInfinityScrollRowsResponse(
                  isLast: true, rows: const []);
            },
            (rows) => PlutoInfinityScrollRowsResponse(
              isLast: rows.length < ClienteRepository.pageSize,
              rows: _buildRows(rows),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 420,
        child: FCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: context.theme.colors.destructive),
              const SizedBox(height: 8),
              Text(
                'No se pudieron cargar los clientes',
                style: context.theme.typography.lg,
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: context.theme.typography.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
