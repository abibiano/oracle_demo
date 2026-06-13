import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repository/cliente_repository.dart';
import '../../domain/cliente.dart';
import '../../exceptions/app_exception.dart';

part 'cliente_list_controllers.g.dart';

/// Current zero-based page index. `keepAlive` so it survives widget rebuilds —
/// the `concurs` page-index idiom (FR-11).
@Riverpod(keepAlive: true)
class PageIndex extends _$PageIndex {
  @override
  int build() => 0;

  void next() => state = state + 1;

  void previous() {
    if (state > 0) state = state - 1;
  }
}

/// Paged read for a given page index — a `family` provider so each page is a
/// distinct, independently-cached request (the SQL-paginated read idiom).
@riverpod
Future<Either<AppException, List<Cliente>>> clientePage(Ref ref, int page) {
  return ref.watch(clienteRepositoryProvider).getPage(page);
}

/// Total `cliente` count, read once and cached, so the `page X of N` indicator
/// stays stable across page navigation instead of flickering with each load.
@riverpod
Future<Either<AppException, int>> clienteCount(Ref ref) {
  return ref.watch(clienteRepositoryProvider).count();
}

/// Total page count from a row total: `N = ceil(total / pageSize)`, minimum 1.
/// Pure and testable in isolation.
int pageCountFor(int totalRows, int pageSize) =>
    totalRows <= 0 ? 1 : (totalRows + pageSize - 1) ~/ pageSize;
