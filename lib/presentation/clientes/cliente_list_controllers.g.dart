// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente_list_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Current zero-based page index. `keepAlive` so it survives widget rebuilds —
/// the `concurs` page-index idiom (FR-11).

@ProviderFor(PageIndex)
final pageIndexProvider = PageIndexProvider._();

/// Current zero-based page index. `keepAlive` so it survives widget rebuilds —
/// the `concurs` page-index idiom (FR-11).
final class PageIndexProvider extends $NotifierProvider<PageIndex, int> {
  /// Current zero-based page index. `keepAlive` so it survives widget rebuilds —
  /// the `concurs` page-index idiom (FR-11).
  PageIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pageIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pageIndexHash();

  @$internal
  @override
  PageIndex create() => PageIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$pageIndexHash() => r'242f0d2ae73323770f42c1ac54a16ac930acb1ba';

/// Current zero-based page index. `keepAlive` so it survives widget rebuilds —
/// the `concurs` page-index idiom (FR-11).

abstract class _$PageIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Paged read for a given page index — a `family` provider so each page is a
/// distinct, independently-cached request (the SQL-paginated read idiom).

@ProviderFor(clientePage)
final clientePageProvider = ClientePageFamily._();

/// Paged read for a given page index — a `family` provider so each page is a
/// distinct, independently-cached request (the SQL-paginated read idiom).

final class ClientePageProvider
    extends
        $FunctionalProvider<
          AsyncValue<Either<AppException, List<Cliente>>>,
          Either<AppException, List<Cliente>>,
          FutureOr<Either<AppException, List<Cliente>>>
        >
    with
        $FutureModifier<Either<AppException, List<Cliente>>>,
        $FutureProvider<Either<AppException, List<Cliente>>> {
  /// Paged read for a given page index — a `family` provider so each page is a
  /// distinct, independently-cached request (the SQL-paginated read idiom).
  ClientePageProvider._({
    required ClientePageFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'clientePageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clientePageHash();

  @override
  String toString() {
    return r'clientePageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Either<AppException, List<Cliente>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Either<AppException, List<Cliente>>> create(Ref ref) {
    final argument = this.argument as int;
    return clientePage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientePageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clientePageHash() => r'9a2fb8337a0fa58aeb0666c85aeb68aecf4fbb59';

/// Paged read for a given page index — a `family` provider so each page is a
/// distinct, independently-cached request (the SQL-paginated read idiom).

final class ClientePageFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Either<AppException, List<Cliente>>>,
          int
        > {
  ClientePageFamily._()
    : super(
        retry: null,
        name: r'clientePageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Paged read for a given page index — a `family` provider so each page is a
  /// distinct, independently-cached request (the SQL-paginated read idiom).

  ClientePageProvider call(int page) =>
      ClientePageProvider._(argument: page, from: this);

  @override
  String toString() => r'clientePageProvider';
}

/// Total `cliente` count, read once and cached, so the `page X of N` indicator
/// stays stable across page navigation instead of flickering with each load.

@ProviderFor(clienteCount)
final clienteCountProvider = ClienteCountProvider._();

/// Total `cliente` count, read once and cached, so the `page X of N` indicator
/// stays stable across page navigation instead of flickering with each load.

final class ClienteCountProvider
    extends
        $FunctionalProvider<
          AsyncValue<Either<AppException, int>>,
          Either<AppException, int>,
          FutureOr<Either<AppException, int>>
        >
    with
        $FutureModifier<Either<AppException, int>>,
        $FutureProvider<Either<AppException, int>> {
  /// Total `cliente` count, read once and cached, so the `page X of N` indicator
  /// stays stable across page navigation instead of flickering with each load.
  ClienteCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clienteCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clienteCountHash();

  @$internal
  @override
  $FutureProviderElement<Either<AppException, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Either<AppException, int>> create(Ref ref) {
    return clienteCount(ref);
  }
}

String _$clienteCountHash() => r'675b04e197b24a4afc208cfbbfd2824590663698';
