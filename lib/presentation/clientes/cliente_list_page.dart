import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// NumberFormat (intl) is re-exported by shadcn_ui, so no separate intl import.
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../data/repository/cliente_repository.dart';
import '../../domain/cliente.dart';
import 'cliente_list_controllers.dart';

/// The single showcase screen: a SQL-paginated `cliente` table with explicit
/// loading / error / empty states (FR-5..FR-9).
class ClienteListPage extends ConsumerWidget {
  const ClienteListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    final pageIndex = ref.watch(pageIndexProvider);
    final asyncPage = ref.watch(clientePageProvider(pageIndex));

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clientes', style: theme.textTheme.h3),
            const SizedBox(height: 4),
            Text(
              'oracledb · paginación SQL directa sobre Oracle',
              style: theme.textTheme.muted,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: asyncPage.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _ErrorState(message: error.toString()),
                data: (result) => result.fold(
                  (failure) => _ErrorState(message: failure.message),
                  (rows) => rows.isEmpty
                      ? const _EmptyState()
                      : _ClienteTable(rows: rows),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _PaginationBar(pageIndex: pageIndex),
          ],
        ),
      ),
    );
  }
}

/// Column definition: header label, pixel width, in-cell alignment, and a
/// builder that renders the cell widget for a given row.
class _Column {
  const _Column({
    required this.label,
    required this.width,
    required this.cell,
    this.alignment = AlignmentDirectional.centerStart,
  });
  final String label;
  final double width;
  final AlignmentGeometry alignment;
  final Widget Function(BuildContext, Cliente) cell;
}

/// Spanish euro format with no decimals, e.g. `1.234.567 €`.
final _euroFormat = NumberFormat.currency(
  locale: 'es_ES',
  symbol: '€',
  decimalDigits: 0,
);

/// Single-line text cell; truncates with an ellipsis instead of wrapping.
Widget _textCell(String value) =>
    Text(value, maxLines: 1, overflow: TextOverflow.ellipsis);

String _euroText(num? value) => value == null ? '' : _euroFormat.format(value);

String _dateText(DateTime? value) =>
    value == null ? '' : value.toIso8601String().split('T').first;

/// Boolean indicator for `S`/`N` flags: a green check for yes, a muted dash
/// for no.
Widget _boolCell(BuildContext context, String? raw) {
  final isYes = (raw ?? '').trim().toUpperCase() == 'S';
  return isYes
      ? const Icon(Icons.check_circle, size: 18, color: Color(0xFF16A34A))
      : Icon(
          Icons.remove,
          size: 18,
          color: ShadTheme.of(context).colorScheme.mutedForeground,
        );
}

final _columns = <_Column>[
  _Column(
    label: 'Alta',
    width: 70,
    alignment: Alignment.center,
    cell: (context, c) => _boolCell(context, c.altaCli),
  ),
  _Column(
    label: 'Pot.',
    width: 60,
    alignment: Alignment.center,
    cell: (context, c) => _boolCell(context, c.potencial),
  ),
  _Column(label: 'Código', width: 90, cell: (_, c) => _textCell(c.codCli ?? '')),
  _Column(label: 'Nombre', width: 200, cell: (_, c) => _textCell(c.nombCli ?? '')),
  _Column(
    label: 'Nombre fiscal',
    width: 200,
    cell: (_, c) => _textCell(c.nombFiscalCli ?? ''),
  ),
  _Column(label: 'NIF', width: 110, cell: (_, c) => _textCell(c.nifCli ?? '')),
  _Column(
    label: 'Dirección 1',
    width: 200,
    cell: (_, c) => _textCell(c.dir1Fiscal ?? ''),
  ),
  _Column(
    label: 'Dirección 2',
    width: 160,
    cell: (_, c) => _textCell(c.dir2Fiscal ?? ''),
  ),
  _Column(label: 'CP', width: 80, cell: (_, c) => _textCell(c.codPosFiscal ?? '')),
  _Column(
    label: 'Población',
    width: 160,
    cell: (_, c) => _textCell(c.poblFiscal ?? ''),
  ),
  _Column(
    label: 'Prov.',
    width: 70,
    cell: (_, c) => _textCell(c.codProvFiscal ?? ''),
  ),
  _Column(
    label: 'Ventas año act.',
    width: 120,
    alignment: AlignmentDirectional.centerEnd,
    cell: (_, c) => _textCell(_euroText(c.vtasAnyoAct)),
  ),
  _Column(
    label: 'Ventas año ant.',
    width: 120,
    alignment: AlignmentDirectional.centerEnd,
    cell: (_, c) => _textCell(_euroText(c.vtasAnyoAnt)),
  ),
  _Column(
    label: 'Ventas -2 años',
    width: 120,
    alignment: AlignmentDirectional.centerEnd,
    cell: (_, c) => _textCell(_euroText(c.vtasHaceDosAnyos)),
  ),
  _Column(
    label: 'Ventas -3 años',
    width: 120,
    alignment: AlignmentDirectional.centerEnd,
    cell: (_, c) => _textCell(_euroText(c.vtasHaceTresAnyos)),
  ),
  _Column(
    label: 'Fecha alta',
    width: 120,
    cell: (_, c) => _textCell(_dateText(c.fecAltaCli)),
  ),
];

class _ClienteTable extends StatefulWidget {
  const _ClienteTable({required this.rows});
  final List<Cliente> rows;

  @override
  State<_ClienteTable> createState() => _ClienteTableState();
}

class _ClienteTableState extends State<_ClienteTable> {
  // ShadTable wraps a 2D TableView that scrolls both axes but shows no
  // scrollbar affordance. We own both controllers so we can drive a Scrollbar
  // per axis and keep the thumbs visible.
  final _verticalController = ScrollController();
  final _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ShadTable renders a single TableView (one shared 2D viewport), so both
    // axes emit scroll notifications at depth 0. Each Scrollbar paints only its
    // own axis because it filters by its controller's position axis, not by
    // notification depth — so no notificationPredicate override is needed.
    return Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      child: Scrollbar(
        controller: _horizontalController,
        thumbVisibility: true,
        child: ShadTable.list(
          verticalScrollController: _verticalController,
          horizontalScrollController: _horizontalController,
          columnSpanExtent: (index) =>
              FixedTableSpanExtent(_columns[index].width),
          header: _columns
              .map(
                (column) => ShadTableCell.header(
                  alignment: column.alignment,
                  child: Text(
                    column.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          children: widget.rows
              .map(
                (cliente) => _columns
                    .map(
                      (column) => ShadTableCell(
                        alignment: column.alignment,
                        child: column.cell(context, cliente),
                      ),
                    )
                    .toList(),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _PaginationBar extends ConsumerWidget {
  const _PaginationBar({required this.pageIndex});

  final int pageIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ShadTheme.of(context);
    // Total comes from the cached count provider, so it stays stable while a
    // page loads — no flicker and Next is not spuriously disabled.
    final total = ref.watch(clienteCountProvider).value?.fold((_) => null, (n) => n);
    final pageCount = total == null
        ? pageIndex + 1
        : pageCountFor(total, ClienteRepository.pageSize);
    final canPrevious = pageIndex > 0;
    final canNext = pageIndex < pageCount - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShadButton.outline(
          enabled: canPrevious,
          onPressed: () => ref.read(pageIndexProvider.notifier).previous(),
          child: const Text('Anterior'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Página ${pageIndex + 1} de $pageCount',
            style: theme.textTheme.small,
          ),
        ),
        ShadButton.outline(
          enabled: canNext,
          onPressed: () => ref.read(pageIndexProvider.notifier).next(),
          child: const Text('Siguiente'),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: Text(
        'No hay clientes para mostrar.',
        style: theme.textTheme.muted,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: ShadCard(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.destructive),
            const SizedBox(height: 8),
            Text(
              'No se pudieron cargar los clientes',
              style: theme.textTheme.large,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: theme.textTheme.muted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
