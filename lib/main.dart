import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load connection settings from `.env` before any provider reads them.
  await dotenv.load();
  runApp(const ProviderScope(child: App()));
}
