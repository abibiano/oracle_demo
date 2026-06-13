// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oracle_config.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Builds [OracleConfig] from the loaded dotenv environment.
///
/// Missing required keys throw, which surfaces as a readable error state
/// rather than a silent failure.

@ProviderFor(oracleConfig)
final oracleConfigProvider = OracleConfigProvider._();

/// Builds [OracleConfig] from the loaded dotenv environment.
///
/// Missing required keys throw, which surfaces as a readable error state
/// rather than a silent failure.

final class OracleConfigProvider
    extends $FunctionalProvider<OracleConfig, OracleConfig, OracleConfig>
    with $Provider<OracleConfig> {
  /// Builds [OracleConfig] from the loaded dotenv environment.
  ///
  /// Missing required keys throw, which surfaces as a readable error state
  /// rather than a silent failure.
  OracleConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'oracleConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$oracleConfigHash();

  @$internal
  @override
  $ProviderElement<OracleConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OracleConfig create(Ref ref) {
    return oracleConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OracleConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OracleConfig>(value),
    );
  }
}

String _$oracleConfigHash() => r'7ae31df3176579d8109a272c25c89006a059ccbc';
