import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oracledb/oracledb.dart';

part 'app_exception.freezed.dart';

/// Typed failure surfaced through `Either<AppException, T>` instead of being
/// thrown into the UI — the concrete form of the PRD's `Result<T, AppFailure>`.
///
/// Every variant carries a `message`, so `appException.message` is available
/// regardless of the case (a Freezed shared-property getter).
@freezed
sealed class AppException with _$AppException {
  /// Bad credentials / locked / expired password.
  const factory AppException.auth(String message) = AuthException;

  /// Host unreachable, listener down, or network failure.
  const factory AppException.connection(String message) = ConnectionException;

  /// SQL or other database execution error.
  const factory AppException.query(String message) = QueryException;

  /// Anything that did not originate from the Oracle driver.
  const factory AppException.unexpected(String message) = UnexpectedException;
}

/// Maps a driver [OracleException] to a typed [AppException] by error code.
///
/// Pure and dependency-free so it is unit-testable without a live database.
extension OracleExceptionMapping on OracleException {
  AppException toAppException() {
    switch (errorCode) {
      case oraInvalidCredentials:
      // ORA-28000 (account locked) and ORA-28001 (password expired) are auth
      // failures too, but are not exported as named constants by the oracledb
      // barrel, so they are matched by literal code.
      case 28000:
      case 28001:
        return AppException.auth(message);
      case oraNetworkError:
      case oraConnectTimeout:
      case oraHostUnreachable:
      case oraConnectionRefused:
      case oraConnectionClosed:
      case oraProtocolError:
      case oraTlsHandshakeFailed:
      case oraTlsCertificateError:
        return AppException.connection(message);
      default:
        return AppException.query(message);
    }
  }
}
