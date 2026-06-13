import 'package:fpdart/fpdart.dart';
import 'package:oracledb/oracledb.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/cliente.dart';
import '../../exceptions/app_exception.dart';
import '../datasource/cliente_oracle_data_source.dart';

part 'cliente_repository.g.dart';

@riverpod
ClienteRepository clienteRepository(Ref ref) =>
    ClienteRepository(ref.watch(clienteOracleDataSourceProvider));

/// Wraps the Oracle data source, mapping driver errors into a typed
/// [AppException] returned via `Either` instead of thrown into the UI (FR-4).
class ClienteRepository {
  ClienteRepository(this._dataSource);

  final ClienteOracleDataSource _dataSource;

  /// Default page size — small enough that the non-virtualized `ShadTable`
  /// renders comfortably (PRD assumption, §9).
  static const pageSize = 25;

  Future<Either<AppException, List<Cliente>>> getPage(int pageIndex) =>
      _guard(() => _dataSource.fetchPage(pageIndex, pageSize));

  Future<Either<AppException, int>> count() => _guard(_dataSource.count);

  /// Runs [action], converting any driver error into a typed [AppException].
  Future<Either<AppException, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return right(await action());
    } on OracleException catch (e) {
      return left(e.toAppException());
    } catch (e) {
      return left(AppException.unexpected(e.toString()));
    }
  }
}
