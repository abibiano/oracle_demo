// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente_oracle_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns the [OraclePool] for the app's lifetime (`keepAlive`).
///
/// The pool runs [_sessionInitSql] via its `sessionCallback` exactly once per
/// session creation/tag-change — the demo's primary teaching point (FR-3).

@ProviderFor(oraclePool)
final oraclePoolProvider = OraclePoolProvider._();

/// Owns the [OraclePool] for the app's lifetime (`keepAlive`).
///
/// The pool runs [_sessionInitSql] via its `sessionCallback` exactly once per
/// session creation/tag-change — the demo's primary teaching point (FR-3).

final class OraclePoolProvider
    extends
        $FunctionalProvider<
          AsyncValue<OraclePool>,
          OraclePool,
          FutureOr<OraclePool>
        >
    with $FutureModifier<OraclePool>, $FutureProvider<OraclePool> {
  /// Owns the [OraclePool] for the app's lifetime (`keepAlive`).
  ///
  /// The pool runs [_sessionInitSql] via its `sessionCallback` exactly once per
  /// session creation/tag-change — the demo's primary teaching point (FR-3).
  OraclePoolProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oraclePoolProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oraclePoolHash();

  @$internal
  @override
  $FutureProviderElement<OraclePool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<OraclePool> create(Ref ref) {
    return oraclePool(ref);
  }
}

String _$oraclePoolHash() => r'3c3c46d39234da47a43f9c716eb9f8842bfcab4c';

@ProviderFor(clienteOracleDataSource)
final clienteOracleDataSourceProvider = ClienteOracleDataSourceProvider._();

final class ClienteOracleDataSourceProvider
    extends
        $FunctionalProvider<
          ClienteOracleDataSource,
          ClienteOracleDataSource,
          ClienteOracleDataSource
        >
    with $Provider<ClienteOracleDataSource> {
  ClienteOracleDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clienteOracleDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clienteOracleDataSourceHash();

  @$internal
  @override
  $ProviderElement<ClienteOracleDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClienteOracleDataSource create(Ref ref) {
    return clienteOracleDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClienteOracleDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClienteOracleDataSource>(value),
    );
  }
}

String _$clienteOracleDataSourceHash() =>
    r'b99a53acdf49373047656f8986a5aea2ecf0e49d';
