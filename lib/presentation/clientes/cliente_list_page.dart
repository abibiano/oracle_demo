import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Column definition: header label, pixel width, and cell-text extractor.
class _Column {
  const _Column(this.label, this.width, this.value);
  final String label;
  final double width;
  final String Function(Cliente) value;
}

String _numberText(num? value) => value?.toString() ?? '';

String _dateText(DateTime? value) =>
    value == null ? '' : value.toIso8601String().split('T').first;

final _columns = <_Column>[
  _Column('Alta', 70, (c) => c.altaCli ?? ''),
  _Column('Pot.', 60, (c) => c.potencial ?? ''),
  _Column('Código', 90, (c) => c.codCli ?? ''),
  _Column('Nombre', 200, (c) => c.nombCli ?? ''),
  _Column('Nombre fiscal', 200, (c) => c.nombFiscalCli ?? ''),
  _Column('NIF', 110, (c) => c.nifCli ?? ''),
  _Column('Dirección 1', 200, (c) => c.dir1Fiscal ?? ''),
  _Column('Dirección 2', 160, (c) => c.dir2Fiscal ?? ''),
  _Column('CP', 80, (c) => c.codPosFiscal ?? ''),
  _Column('Población', 160, (c) => c.poblFiscal ?? ''),
  _Column('Prov.', 70, (c) => c.codProvFiscal ?? ''),
  _Column('Ventas año act.', 120, (c) => _numberText(c.vtasAnyoAct)),
  _Column('Ventas año ant.', 120, (c) => _numberText(c.vtasAnyoAnt)),
  _Column('Ventas -2 años', 120, (c) => _numberText(c.vtasHaceDosAnyos)),
  _Column('Ventas -3 años', 120, (c) => _numberText(c.vtasHaceTresAnyos)),
  _Column('Fecha alta', 120, (c) => _dateText(c.fecAltaCli)),
];

class _ClienteTable extends StatelessWidget {
  const _ClienteTable({required this.rows});
  final List<Cliente> rows;

  @override
  Widget build(BuildContext context) {
    return ShadTable.list(
      columnSpanExtent: (index) => FixedTableSpanExtent(_columns[index].width),
      header: _columns
          .map((column) => ShadTableCell.header(child: Text(column.label)))
          .toList(),
      children: rows
          .map(
            (cliente) => _columns
                .map((column) => ShadTableCell(child: Text(column.value(cliente))))
                .toList(),
          )
          .toList(),
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
