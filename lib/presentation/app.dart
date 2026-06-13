import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'routing/app_router.dart';

/// Root widget. Diverges from `concurs` (Material + flex_color_scheme) to use
/// `shadcn_ui`'s [ShadApp] over the single-route go_router — a deliberate,
/// documented presentation-layer choice (PRD §4.4).
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return ShadApp.router(
      title: 'oracle_demo',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
