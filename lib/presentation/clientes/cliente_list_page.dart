import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../data/repository/cliente_repository.dart';
import '../../domain/cliente.dart';
import 'cliente_list_controllers.dart';

class ClienteListPage extends HookConsumerWidget {
  const ClienteListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageIndex = ref.watch(pageIndexProvider);
    final asyncPage = ref.watch(clientePageProvider(pageIndex));

    return Scaffold(
      backgroundColor: context.theme.colors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clientes', style: context.theme.typography.xl2),
            const SizedBox(height: 4),
            Text(
              'oracledb · paginación SQL directa sobre Oracle',
              style: context.theme.typography.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
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
                      : _ClienteTable(key: ValueKey(pageIndex), rows: rows),
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

final _euroFormat = NumberFormat.currency(
  locale: 'es_ES',
  symbol: '€',
  decimalDigits: 0,
);

String _euroText(num? value) => value == null ? '' : _euroFormat.format(value);

String _dateText(DateTime? value) =>
    value == null ? '' : value.toIso8601String().split('T').first;

List<PlutoColumn> _buildColumns() => [
      PlutoColumn(
        title: 'Alta',
        field: 'alta',
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
        type: PlutoColumnType.text(),
        width: 120,
        textAlign: PlutoColumnTextAlign.end,
        titleTextAlign: PlutoColumnTextAlign.end,
      ),
      PlutoColumn(
        title: 'Ventas año ant.',
        field: 'ventas_ant',
        type: PlutoColumnType.text(),
        width: 120,
        textAlign: PlutoColumnTextAlign.end,
        titleTextAlign: PlutoColumnTextAlign.end,
      ),
      PlutoColumn(
        title: 'Ventas -2 años',
        field: 'ventas_2',
        type: PlutoColumnType.text(),
        width: 120,
        textAlign: PlutoColumnTextAlign.end,
        titleTextAlign: PlutoColumnTextAlign.end,
      ),
      PlutoColumn(
        title: 'Ventas -3 años',
        field: 'ventas_3',
        type: PlutoColumnType.text(),
        width: 120,
        textAlign: PlutoColumnTextAlign.end,
        titleTextAlign: PlutoColumnTextAlign.end,
      ),
      PlutoColumn(
        title: 'Fecha alta',
        field: 'fecha_alta',
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

class _ClienteTable extends HookConsumerWidget {
  const _ClienteTable({super.key, required this.rows});
  final List<Cliente> rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = useMemoized(_buildColumns);
    final plutoRows = useMemoized(() => _buildRows(rows), [rows]);

    return PlutoGrid(
      columns: columns,
      rows: plutoRows,
      mode: PlutoGridMode.readOnly,
      configuration: const PlutoGridConfiguration(),
      onLoaded: (event) => event.stateManager.setShowColumnFilter(false),
    );
  }
}

class _PaginationBar extends HookConsumerWidget {
  const _PaginationBar({required this.pageIndex});

  final int pageIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref
        .watch(clienteCountProvider)
        .value
        ?.fold((_) => null, (n) => n);
    final pageCount = total == null
        ? pageIndex + 1
        : pageCountFor(total, ClienteRepository.pageSize);
    final canPrevious = pageIndex > 0;
    final canNext = pageIndex < pageCount - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FButton(
          variant: FButtonVariant.outline,
          onPress: canPrevious
              ? () => ref.read(pageIndexProvider.notifier).previous()
              : null,
          child: const Text('Anterior'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Página ${pageIndex + 1} de $pageCount',
            style: context.theme.typography.sm,
          ),
        ),
        FButton(
          variant: FButtonVariant.outline,
          onPress: canNext
              ? () => ref.read(pageIndexProvider.notifier).next()
              : null,
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
    return Center(
      child: Text(
        'No hay clientes para mostrar.',
        style: context.theme.typography.sm.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
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
