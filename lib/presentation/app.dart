import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'routing/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return FTheme(
      data: FThemes.zinc.light.desktop,
      child: MaterialApp.router(
        title: 'oracle_demo',
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
