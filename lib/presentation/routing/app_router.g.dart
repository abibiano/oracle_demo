// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Single-route go_router, stubbed for the one screen. Kept as a router (not a
/// bare home widget) so adding screens later is a one-line change (FR: routing).

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Single-route go_router, stubbed for the one screen. Kept as a router (not a
/// bare home widget) so adding screens later is a one-line change (FR: routing).

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Single-route go_router, stubbed for the one screen. Kept as a router (not a
  /// bare home widget) so adding screens later is a one-line change (FR: routing).
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'55daa1c7dfb6e0ff3d6b1a40b47382f2951fd242';
