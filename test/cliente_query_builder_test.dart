import 'package:flutter_test/flutter_test.dart';
import 'package:oracle_demo/data/datasource/cliente_oracle_data_source.dart';

void main() {
  const defaultOrderBy = 'ORDER BY alta_cli DESC, potencial, nomb_cli, cod_cli';

  group('buildClienteOrderBy', () {
    test('no sort -> addendum default order', () {
      expect(buildClienteOrderBy(null), defaultOrderBy);
    });

    test('unknown field -> default order (never interpolated)', () {
      final sql = buildClienteOrderBy(
        const ClienteSort(field: 'nombre; DROP TABLE cliente', descending: false),
      );
      expect(sql, defaultOrderBy);
    });

    test('ascending sort maps field -> column, NULLS LAST, with tiebreaker', () {
      expect(
        buildClienteOrderBy(const ClienteSort(field: 'nombre', descending: false)),
        'ORDER BY nomb_cli ASC NULLS LAST, cod_cli',
      );
    });

    test('descending sort maps field -> column, NULLS LAST, with tiebreaker', () {
      expect(
        buildClienteOrderBy(const ClienteSort(field: 'nombre', descending: true)),
        'ORDER BY nomb_cli DESC NULLS LAST, cod_cli',
      );
    });

    test('sorting by the tiebreaker column does not duplicate it', () {
      expect(
        buildClienteOrderBy(const ClienteSort(field: 'codigo', descending: false)),
        'ORDER BY cod_cli ASC NULLS LAST',
      );
    });
  });

  group('buildClienteWhere', () {
    test('no filters -> empty clause, no binds', () {
      final where = buildClienteWhere(const []);
      expect(where.sql, '');
      expect(where.binds, isEmpty);
    });

    test('contains -> bound LIKE both sides', () {
      final where = buildClienteWhere(const [
        ClienteFilter(
          field: 'nombre',
          match: ClienteFilterMatch.contains,
          value: 'ace',
        ),
      ]);
      expect(where.sql, "WHERE UPPER(nomb_cli) LIKE UPPER('%' || :f0 || '%')");
      expect(where.binds, {'f0': 'ace'});
    });

    test('equals / startsWith / endsWith map to the right SQL shape', () {
      expect(
        buildClienteWhere(const [
          ClienteFilter(field: 'nif', match: ClienteFilterMatch.equals, value: 'B1'),
        ]).sql,
        'WHERE UPPER(nif_cli) = UPPER(:f0)',
      );
      expect(
        buildClienteWhere(const [
          ClienteFilter(
              field: 'nombre', match: ClienteFilterMatch.startsWith, value: 'a'),
        ]).sql,
        "WHERE UPPER(nomb_cli) LIKE UPPER(:f0 || '%')",
      );
      expect(
        buildClienteWhere(const [
          ClienteFilter(
              field: 'nombre', match: ClienteFilterMatch.endsWith, value: 'z'),
        ]).sql,
        "WHERE UPPER(nomb_cli) LIKE UPPER('%' || :f0)",
      );
    });

    test('multiple filters are AND-joined with distinct binds', () {
      final where = buildClienteWhere(const [
        ClienteFilter(field: 'nombre', match: ClienteFilterMatch.contains, value: 'ace'),
        ClienteFilter(field: 'nif', match: ClienteFilterMatch.equals, value: 'B1'),
      ]);
      expect(
        where.sql,
        "WHERE UPPER(nomb_cli) LIKE UPPER('%' || :f0 || '%') "
        'AND UPPER(nif_cli) = UPPER(:f1)',
      );
      expect(where.binds, {'f0': 'ace', 'f1': 'B1'});
    });

    test('unknown field is dropped (injection guard)', () {
      final where = buildClienteWhere(const [
        ClienteFilter(
          field: "cod_cli'; DROP TABLE cliente; --",
          match: ClienteFilterMatch.contains,
          value: 'x',
        ),
      ]);
      expect(where.sql, '');
      expect(where.binds, isEmpty);
    });

    test('known-but-non-filterable field (sales) is dropped', () {
      final where = buildClienteWhere(const [
        ClienteFilter(
          field: 'ventas_act',
          match: ClienteFilterMatch.contains,
          value: '1000',
        ),
      ]);
      expect(where.sql, '');
      expect(where.binds, isEmpty);
    });

    test('blank value is omitted', () {
      final where = buildClienteWhere(const [
        ClienteFilter(field: 'nombre', match: ClienteFilterMatch.contains, value: '   '),
      ]);
      expect(where.sql, '');
      expect(where.binds, isEmpty);
    });

    test('malicious value is bound, never interpolated', () {
      const payload = "x') OR '1'='1";
      final where = buildClienteWhere(const [
        ClienteFilter(
          field: 'nombre',
          match: ClienteFilterMatch.contains,
          value: payload,
        ),
      ]);
      // The value reaches SQL only through the bind, not the clause text.
      expect(where.sql.contains(payload), isFalse);
      expect(where.sql.contains(':f0'), isTrue);
      expect(where.binds['f0'], payload);
    });
  });
}
