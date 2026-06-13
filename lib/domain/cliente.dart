import 'package:freezed_annotation/freezed_annotation.dart';

part 'cliente.freezed.dart';

/// A CRM client row from the Oracle `cliente` table.
///
/// Column→type mapping is provisional pending live column metadata (PRD OQ#1):
/// text-ish columns are kept as [String], sales as [num], dates as [DateTime].
/// All fields are nullable to tolerate NULLs and unconfirmed types.
@freezed
abstract class Cliente with _$Cliente {
  const factory Cliente({
    required String? altaCli,
    required String? potencial,
    required String? codCli,
    required String? nombCli,
    required String? nombFiscalCli,
    required String? nifCli,
    required String? dir1Fiscal,
    required String? dir2Fiscal,
    required String? codPosFiscal,
    required String? poblFiscal,
    required String? codProvFiscal,
    required num? vtasAnyoAct,
    required num? vtasAnyoAnt,
    required num? vtasHaceDosAnyos,
    required num? vtasHaceTresAnyos,
    required DateTime? fecAltaCli,
  }) = _Cliente;
}
