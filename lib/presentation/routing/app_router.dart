import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../clientes/cliente_list_page.dart';

part 'app_router.g.dart';

/// Single-route go_router, stubbed for the one screen. Kept as a router (not a
/// bare home widget) so adding screens later is a one-line change (FR: routing).
@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ClienteListPage(),
      ),
    ],
  );
}
