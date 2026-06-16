import 'package:oracledb/oracledb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../config/oracle_config.dart';
import '../../domain/cliente.dart';

part 'cliente_oracle_data_source.g.dart';

/// How a text filter value is matched against its column.
enum ClienteFilterMatch { contains, equals, startsWith, endsWith }

/// A server-side sort request: a grid `field` and its direction.
class ClienteSort {
  const ClienteSort({required this.field, required this.descending});

  final String field;
  final bool descending;
}

/// A server-side filter request on one grid `field`.
class ClienteFilter {
  const ClienteFilter({
    required this.field,
    required this.match,
    required this.value,
  });

  final String field;
  final ClienteFilterMatch match;
  final String value;
}

/// Allowlist mapping a pluto grid `field` to its real `cliente` column. This is
/// the ONLY source of column identifiers that reach SQL — a field absent here is
/// ignored, so user input can never name a column (the injection guard).
const _fieldToColumn = <String, String>{
  'alta': 'alta_cli',
  'pot': 'potencial',
  'codigo': 'cod_cli',
  'nombre': 'nomb_cli',
  'nombre_fiscal': 'nomb_fiscal_cli',
  'nif': 'nif_cli',
  'dir1': 'dir1_fiscal',
  'dir2': 'dir2_fiscal',
  'cp': 'cod_pos_fiscal',
  'pobl': 'pobl_fiscal',
  'prov': 'cod_prov_fiscal',
  'ventas_act': 'vtas_anyo_act',
  'ventas_ant': 'vtas_anyo_ant',
  'ventas_2': 'vtas_hace_dos_anyos',
  'ventas_3': 'vtas_hace_tres_anyos',
  'fecha_alta': 'fec_alta_cli',
};

/// Columns that accept a `WHERE` filter. `alta`/`pot` are the raw `S` flags
/// (filter by typing `S`). Sales and date columns are excluded — their grid
/// cells are formatted, so a text match would not line up with the stored value.
const _filterableFields = <String>{
  'alta',
  'pot',
  'codigo',
  'nombre',
  'nombre_fiscal',
  'nif',
  'dir1',
  'dir2',
  'cp',
  'pobl',
  'prov',
};

/// Deterministic tiebreaker key appended to every ORDER BY so OFFSET/FETCH
/// paging cannot skip or duplicate rows when the leading sort keys tie.
const _tiebreaker = 'cod_cli';

/// Base SELECT (the addendum projection), wrapped per call for SQL-level paging.
const _selectClienteSql = '''
SELECT alta_cli, potencial, cod_cli, nomb_cli, nomb_fiscal_cli, nif_cli,
       dir1_fiscal, dir2_fiscal, cod_pos_fiscal, pobl_fiscal, cod_prov_fiscal,
       vtas_anyo_act, vtas_anyo_ant, vtas_hace_dos_anyos, vtas_hace_tres_anyos,
       fec_alta_cli
  FROM cliente''';

/// The addendum's default order, used when no column sort is active.
const _defaultOrderBy = 'ORDER BY alta_cli DESC, potencial, nomb_cli, cod_cli';

const _countClienteSql = 'SELECT COUNT(*) FROM cliente';

/// Builds the ORDER BY clause for a page query. An absent or unknown sort falls
/// back to [_defaultOrderBy]; a known sort orders by its column (NULLs always
/// last, regardless of direction) then the [_tiebreaker] (omitted when the sort
/// already is the tiebreaker column).
String buildClienteOrderBy(ClienteSort? sort) {
  if (sort == null) return _defaultOrderBy;
  final column = _fieldToColumn[sort.field];
  if (column == null) return _defaultOrderBy;
  final direction = sort.descending ? 'DESC' : 'ASC';
  if (column == _tiebreaker) return 'ORDER BY $column $direction NULLS LAST';
  return 'ORDER BY $column $direction NULLS LAST, $_tiebreaker';
}

/// Builds the WHERE clause and its bind parameters from [filters]. Filters on
/// non-filterable or unknown fields, or with a blank value, are dropped. Column
/// names come only from [_fieldToColumn]; values are always bound (`:f0`, `:f1`,
/// …), so user text can never be interpolated into SQL.
({String sql, Map<String, Object?> binds}) buildClienteWhere(
  List<ClienteFilter> filters,
) {
  final conditions = <String>[];
  final binds = <String, Object?>{};
  for (final filter in filters) {
    final column = _fieldToColumn[filter.field];
    if (column == null ||
        !_filterableFields.contains(filter.field) ||
        filter.value.trim().isEmpty) {
      continue;
    }
    final bind = 'f${binds.length}';
    conditions.add(_filterCondition(column, filter.match, bind));
    binds[bind] = filter.value;
  }
  if (conditions.isEmpty) return (sql: '', binds: const {});
  return (sql: 'WHERE ${conditions.join(' AND ')}', binds: binds);
}

String _filterCondition(String column, ClienteFilterMatch match, String bind) {
  final upper = 'UPPER($column)';
  return switch (match) {
    ClienteFilterMatch.equals => '$upper = UPPER(:$bind)',
    ClienteFilterMatch.startsWith => "$upper LIKE UPPER(:$bind || '%')",
    ClienteFilterMatch.endsWith => "$upper LIKE UPPER('%' || :$bind)",
    ClienteFilterMatch.contains => "$upper LIKE UPPER('%' || :$bind || '%')",
  };
}

/// The mandatory per-session init block (see addendum). It sets session
/// variables the database relies on and must run once per session before any
/// query — run here through the pool's `sessionCallback`, NOT per query.
const _sessionInitSql = '''
BEGIN
  crm.crm_set_filial(dbo.constants.filial_esp);
  crm.crm_conexion_pkg.set_usuario_id('NIK');
  crm.crm_conexion_pkg.set_nik_idioma('castellano');
  dbo.conexion_pkg.set_cod_idioma_actual('castellano');
END;''';

/// Owns the [OraclePool] for the app's lifetime (`keepAlive`).
///
/// The pool runs [_sessionInitSql] via its `sessionCallback` exactly once per
/// session creation/tag-change — the demo's primary teaching point (FR-3).
@Riverpod(keepAlive: true)
Future<OraclePool> oraclePool(Ref ref) async {
  final config = ref.watch(oracleConfigProvider);
  final pool = await OraclePool.create(
    config.connectionString,
    user: config.user,
    password: config.password,
    minConnections: 1,
    maxConnections: 4,
    sessionCallback: (connection, requestedTag) async {
      await connection.execute(_sessionInitSql);
      connection.tag = requestedTag;
    },
  );
  ref.onDispose(() => pool.close());
  return pool;
}

@riverpod
ClienteOracleDataSource clienteOracleDataSource(Ref ref) =>
    ClienteOracleDataSource(ref);

/// Reads `cliente` data directly from Oracle through the pooled connection.
/// The driver is touched ONLY here, never from a widget (FR-2, FR-10).
class ClienteOracleDataSource {
  ClienteOracleDataSource(this._ref);

  final Ref _ref;

  /// Fetches a single page of rows via SQL paging, ordered and filtered at the
  /// database (not over already-loaded rows). Only this page is materialized —
  /// no full-table load (FR-5, FR-6). [sort] and [filters] map to a bound
  /// `ORDER BY`/`WHERE` via the [_fieldToColumn] allowlist.
  Future<List<Cliente>> fetchPage(
    int pageIndex,
    int pageSize, {
    ClienteSort? sort,
    List<ClienteFilter> filters = const [],
  }) async {
    final pool = await _ref.read(oraclePoolProvider.future);
    final where = buildClienteWhere(filters);
    final sql = [
      _selectClienteSql,
      if (where.sql.isNotEmpty) where.sql,
      buildClienteOrderBy(sort),
      'OFFSET :offset ROWS FETCH NEXT :pageSize ROWS ONLY',
    ].join('\n');
    final result = await pool.withConnection(
      (connection) => connection.execute(sql, {
        'offset': pageIndex * pageSize,
        'pageSize': pageSize,
        ...where.binds,
      }),
    );
    return result.rows.map(_mapRow).toList();
  }

  /// Total `cliente` row count, used to derive the `page X of N` indicator
  /// (FR-7). Fetched once and cached by its provider — not per page.
  Future<int> count() async {
    final pool = await _ref.read(oraclePoolProvider.future);
    final result = await pool
        .withConnection((connection) => connection.execute(_countClienteSql));
    final value = result.rows.isEmpty ? null : result.rows.first[0];
    return value is num ? value.toInt() : 0;
  }

  /// Maps an Oracle row (columns read by UPPERCASE name) to a [Cliente],
  /// tolerant of provisional column types.
  Cliente _mapRow(OracleRow row) => Cliente(
        altaCli: _str(row['ALTA_CLI']),
        potencial: _str(row['POTENCIAL']),
        codCli: _str(row['COD_CLI']),
        nombCli: _str(row['NOMB_CLI']),
        nombFiscalCli: _str(row['NOMB_FISCAL_CLI']),
        nifCli: _str(row['NIF_CLI']),
        dir1Fiscal: _str(row['DIR1_FISCAL']),
        dir2Fiscal: _str(row['DIR2_FISCAL']),
        codPosFiscal: _str(row['COD_POS_FISCAL']),
        poblFiscal: _str(row['POBL_FISCAL']),
        codProvFiscal: _str(row['COD_PROV_FISCAL']),
        vtasAnyoAct: _num(row['VTAS_ANYO_ACT']),
        vtasAnyoAnt: _num(row['VTAS_ANYO_ANT']),
        vtasHaceDosAnyos: _num(row['VTAS_HACE_DOS_ANYOS']),
        vtasHaceTresAnyos: _num(row['VTAS_HACE_TRES_ANYOS']),
        fecAltaCli: _date(row['FEC_ALTA_CLI']),
      );
}

String? _str(Object? value) => value?.toString();

num? _num(Object? value) =>
    value is num ? value : (value is String ? num.tryParse(value) : null);

DateTime? _date(Object? value) => value is DateTime ? value : null;
