import 'package:flutter_test/flutter_test.dart';
import 'package:oracle_demo/exceptions/app_exception.dart';
import 'package:oracle_demo/presentation/clientes/cliente_list_controllers.dart';
import 'package:oracledb/oracledb.dart';

void main() {
  group('OracleException -> AppException mapping', () {
    AppException map(int code) =>
        OracleException(errorCode: code, message: 'ORA-$code').toAppException();

    test('invalid credentials -> auth', () {
      expect(map(oraInvalidCredentials), isA<AuthException>());
    });

    test('account locked / password expired -> auth', () {
      expect(map(28000), isA<AuthException>()); // ORA-28000 account locked
      expect(map(28001), isA<AuthException>()); // ORA-28001 password expired
    });

    test('network/connectivity codes -> connection', () {
      for (final code in [
        oraNetworkError,
        oraConnectTimeout,
        oraHostUnreachable,
        oraConnectionRefused,
        oraConnectionClosed,
        oraProtocolError,
      ]) {
        expect(map(code), isA<ConnectionException>(), reason: 'code $code');
      }
    });

    test('unknown SQL error -> query', () {
      expect(map(942), isA<QueryException>()); // ORA-00942: table does not exist
    });

    test('mapped message is preserved', () {
      expect(map(oraInvalidCredentials).message, 'ORA-$oraInvalidCredentials');
    });
  });

  group('pageCountFor (N = ceil(total / size))', () {
    test('exact multiple', () => expect(pageCountFor(100, 25), 4));
    test('rounds up the remainder', () => expect(pageCountFor(101, 25), 5));
    test('fewer than one page', () => expect(pageCountFor(10, 25), 1));
    test('empty set is one page', () => expect(pageCountFor(0, 25), 1));
  });
}
