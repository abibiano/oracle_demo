import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'oracle_config.g.dart';

/// Immutable Oracle connection settings, sourced from `.env` (never hard-coded).
///
/// Changing the target database is a `.env` edit only — no code change (FR-1).
class OracleConfig {
  const OracleConfig({
    required this.connectionString,
    required this.user,
    required this.password,
  });

  /// EZ-Connect descriptor, e.g. `192.168.2.30:1521/CELO`.
  final String connectionString;
  final String user;
  final String password;
}

/// Builds [OracleConfig] from the loaded dotenv environment.
///
/// Missing required keys throw, which surfaces as a readable error state
/// rather than a silent failure.
@riverpod
OracleConfig oracleConfig(Ref ref) {
  final host = dotenv.get('ORACLE_HOST');
  final port = dotenv.get('ORACLE_PORT', fallback: '1521');
  final service = dotenv.get('ORACLE_SERVICE');
  return OracleConfig(
    connectionString: '$host:$port/$service',
    user: dotenv.get('ORACLE_USER'),
    password: dotenv.get('ORACLE_PASSWORD'),
  );
}
