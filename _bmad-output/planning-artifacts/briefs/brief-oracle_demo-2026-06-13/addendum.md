# Addendum — oracle_demo

Implementation-grade detail captured during the brief conversation. Belongs to downstream PRD / architecture / dev, not the executive brief.

## Connection

- TNS descriptor (provided):
  ```
  CELO =
    (DESCRIPTION=
      (ADDRESS=(PROTOCOL=TCP)(HOST=192.168.2.30)(PORT=1521))
      (CONNECT_DATA=(SERVICE_NAME=CELO))
    )
  ```
- EZ Connect equivalent for `oracledb`: `192.168.2.30:1521/CELO`
- User: `NIK` · Password: from `.env` (never hard-coded)
- Suggested `.env` keys: `ORACLE_HOST=192.168.2.30`, `ORACLE_PORT=1521`, `ORACLE_SERVICE=CELO`, `ORACLE_USER=NIK`, `ORACLE_PASSWORD=…`

## Mandatory per-session initialization

This block sets session variables the database relies on and **must run on every connection** before any query:

```sql
BEGIN
  crm.crm_set_filial(dbo.constants.filial_esp);
  crm.crm_conexion_pkg.set_usuario_id('NIK');
  crm.crm_conexion_pkg.set_nik_idioma('castellano');
  dbo.conexion_pkg.set_cod_idioma_actual('castellano');
END;
```

**Best-practice mapping:** run this inside the `OraclePool` `sessionCallback` so every borrowed/recycled session is initialized exactly once on creation/tag-change — not re-run on every query. This is the canonical use of the pool's session-state feature and a key thing the demo teaches.

## Target query — `cliente`

Base SELECT (page body):

```sql
SELECT alta_cli
      ,potencial
      ,cod_cli
      ,nomb_cli
      ,nomb_fiscal_cli
      ,nif_cli
      ,dir1_fiscal
      ,dir2_fiscal
      ,cod_pos_fiscal
      ,pobl_fiscal
      ,cod_prov_fiscal
      ,vtas_anyo_act
      ,vtas_anyo_ant
      ,vtas_hace_dos_anyos
      ,vtas_hace_tres_anyos
      ,fec_alta_cli
  FROM cliente
ORDER BY alta_cli DESC, potencial, nomb_cli
```

(Note: the user's original list repeated `nomb_fiscal_cli`; deduplicated above — confirm column set during dev.)

Columns → suggested Freezed `Cliente` domain model fields (Oracle returns by name, e.g. `row['NOMB_CLI']`):

| Column | Meaning (inferred) | Type |
| --- | --- | --- |
| alta_cli | active/registered flag | (confirm: String/num/bool) |
| potencial | client potential rating | (confirm) |
| cod_cli | client code (key) | String/int |
| nomb_cli | client name | String |
| nomb_fiscal_cli | fiscal name | String |
| nif_cli | tax ID | String |
| dir1_fiscal / dir2_fiscal | fiscal address lines | String |
| cod_pos_fiscal | postal code | String |
| pobl_fiscal | town/city | String |
| cod_prov_fiscal | province code | String |
| vtas_anyo_act | sales current year | num |
| vtas_anyo_ant | sales previous year | num |
| vtas_hace_dos_anyos | sales 2 years ago | num |
| vtas_hace_tres_anyos | sales 3 years ago | num |
| fec_alta_cli | registration date | DateTime |

## UI: table rendering

- Component library: **`shadcn_ui`** (flutter-shadcn-ui).
- Table: **`ShadTable` / `ShadTable.list`** — styled, but presentation-only (no built-in sort/filter/paging) and meant for small tables (builds every child, no virtualization). Acceptable here because SQL-side paging means only one small page (~20–50 rows) renders at a time.
- Pagination controls: composed from **`ShadButton`** (prev/next) + a page-indicator (`page X of N`). No third-party data-grid.
- Alternatives considered and rejected for v1: **Trina Grid** (maintained PlutoGrid fork) and **Syncfusion DataGrid** — both render unthemed, non-shadcn widgets; reach for one only if in-table sort/filter is needed later. Built-in `TableView` (`two_dimensional_scrollables`) is the virtualized-but-manual fallback.

## Pagination

- Wrap the base query for paged reads:
  ```sql
  SELECT … FROM cliente
  ORDER BY alta_cli DESC, potencial, nomb_cli
  OFFSET :offset ROWS FETCH NEXT :pageSize ROWS ONLY
  ```
- Total pages from a `SELECT COUNT(*) FROM cliente`.
- Page index held in a local `@Riverpod(keepAlive: true)` provider (concurs idiom); request flows through a `FutureProvider.family`.

## Open / to confirm during dev

- Exact Dart types per column (inspect column metadata / sample rows).
- Deduplicated column list (`nomb_fiscal_cli` appeared twice in source).
- Whether `idioma`/`filial` should be configurable later (currently hard-set in the init block).
