# OPTN KDPI and EPTS mapping tables

The tables OPTN publishes for turning a scaled KDRI into a KDPI and a
raw EPTS into an EPTS score, one per year, as used by
[`add_kdpi()`](https://vagishhemmige.github.io/sRtr/reference/add_kdpi.md)
and
[`add_epts()`](https://vagishhemmige.github.io/sRtr/reference/add_epts.md).
Each table is a list of intervals: a value maps to the percentile of the
interval with `lower < value <= upper`.

## Format

A list of three tibbles:

- tables:

  One row per table: `score` (`"kdpi"` or `"epts"`), `label`,
  `reference` (donor recovery year for KDPI; snapshot date for EPTS),
  `data_as_of` (OPTN database date printed on the table),
  `scaling_factor` (median KDRI_RAO of the reference donors; not printed
  on the 2010 and 2011 tables), `diabetes_pct` and `hypertension_pct`
  (percentages of reference donors, used by OPTN for unknown history;
  printed from 2014), `kdri_formula` (`"rao2009"` or `"refit2024"`),
  `formula_basis`, and the source `file`, `url` and `sha256`.

- rows:

  One row per interval: `score`, `label`, `row`, `lower`, `upper` and
  `percentile`.

- effective:

  When each table took effect in allocation: `score`, `label`,
  `kdri_formula`, `effective_from`, `basis` and `stored`. The basis is
  either an OPTN publication or, where none was found, the June 1
  deadline in OPTN Policy 8.4.B, labelled as a convention. It includes
  the 2024-donor KDPI table (`label = "2024-donors"`, `stored = FALSE`),
  so the period when that table was in force is known.

## Source

OPTN KDRI-to-KDPI and EPTS mapping tables, retrieved 2026-11-16 from
<https://www.hrsa.gov/optn/data/allocation-calculators/archived-allocation-calculator-resources>
and the current tables linked from the OPTN KDPI and EPTS guides. Parsed
by `data-raw/optn_tables_parse.R`; each file's address and sha256 are in
`data-raw/optn-tables/manifest.csv`.

## Details

Tables are labelled as OPTN labels them. A KDPI table's reference
population is the deceased kidney donors recovered in one year, and its
label is usually that year. The exception is the table labelled
`"2024"`: it re-maps the 2023 donors (OPTN data as of 2024-09-06) with a
different scaling factor from the `"2023"` table, shortly before the
refit KDRI took effect on 2024-10-31, and is taken to be the first refit
table. OPTN does not say this on the table, so `formula_basis` records
it as an inference. The table built from 2024 donors (scaling factor
1.40436817065005, cited in the OPTN KDPI guide) is not in OPTN's archive
and is not stored. An EPTS table's label is the year of its December 31
waiting-list snapshot. The newest table of each kind is labelled
`"current"`.

## See also

Guides:

- [Which mapping table: KDPI and
  EPTS](https://vagishhemmige.github.io/sRtr/articles/adding-columns.html#which-mapping-table-kdpi-and-epts)
