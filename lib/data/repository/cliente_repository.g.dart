// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clienteRepository)
final clienteRepositoryProvider = ClienteRepositoryProvider._();

final class ClienteRepositoryProvider
    extends
        $FunctionalProvider<
          ClienteRepository,
          ClienteRepository,
          ClienteRepository
        >
    with $Provider<ClienteRepository> {
  ClienteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clienteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clienteRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClienteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClienteRepository create(Ref ref) {
    return clienteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClienteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClienteRepository>(value),
    );
  }
}

String _$clienteRepositoryHash() => r'ab28a13b5f15b97a6498361381bd2c3cade40e23';
