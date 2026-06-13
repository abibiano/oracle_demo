import 'package:oracledb/oracledb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../config/oracle_config.dart';
import '../../domain/cliente.dart';

part 'cliente_oracle_data_source.g.dart';

/// Addendum base SELECT, wrapped for SQL-level paging. `cod_cli` (the client
/// key) is appended to the addendum ORDER BY as a deterministic tiebreaker, so
/// OFFSET/FETCH cannot skip or duplicate rows when the leading sort keys tie.
const _pagedClienteSql = '''
SELECT alta_cli, potencial, cod_cli, nomb_cli, nomb_fiscal_cli, nif_cli,
       dir1_fiscal, dir2_fiscal, cod_pos_fiscal, pobl_fiscal, cod_prov_fiscal,
       vtas_anyo_act, vtas_anyo_ant, vtas_hace_dos_anyos, vtas_hace_tres_anyos,
       fec_alta_cli
  FROM cliente
 ORDER BY alta_cli DESC, potencial, nomb_cli, cod_cli
 OFFSET :offset ROWS FETCH NEXT :pageSize ROWS ONLY''';

const _countClienteSql = 'SELECT COUNT(*) FROM cliente';

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

  /// Fetches a single page of rows via SQL paging. Only this page is
  /// materialized — no full-table load (FR-5, FR-6).
  Future<List<Cliente>> fetchPage(int pageIndex, int pageSize) async {
    final pool = await _ref.read(oraclePoolProvider.future);
    final result = await pool.withConnection(
      (connection) => connection.execute(
        _pagedClienteSql,
        {'offset': pageIndex * pageSize, 'pageSize': pageSize},
      ),
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
