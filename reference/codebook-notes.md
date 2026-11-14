# Codebook notes

Field and code meanings checked against
`data-raw/SRTR_format_codebooks.xlsx` and `data-raw/dataDictionary.html`
on 2026-11-02. Codebooks change between releases; recheck against the
codebook for the release in use.

## Removal codes (`CAN_REM_CD`, format `REMCD`)

| Code | Meaning | Grouping note |
|---|---|---|
| 4 | Deceased Donor tx, removed by transplanting center | Deceased-donor transplant |
| 5 | Medically Unsuitable | Sometimes counted as death (Wood 2021); a judgment call |
| 6 | Refused transplant | |
| 7 | Transferred to another center | |
| 8 | Died | Death |
| 9 | Other | |
| 10 | Candidate listed in error | |
| 11 | Candidate listed for unacceptable antigens only | |
| 12 | Candidate condition improved, tx not needed | |
| 13 | Candidate condition deteriorated, too sick for tx | Often counted as death |
| 14 | Transplant at another center (multi-listed) | Donor type not given; **not** deceased-donor by definition |
| 15 | Living Donor tx, removed by transplanting center | Living-donor transplant |
| 16 | Candidate Removed in Error | |
| 17 | Changed to KP (by system) | |
| 18 | Deceased Donor Emergency Tx | Deceased-donor transplant |
| 19 | Deceased Donor Multi-Organ Tx | Deceased-donor transplant |
| 20 | Program inactive for 2+ years | |
| 21 | Patient died during TX procedure | Death |
| 22 | Transplanted in another country | |
| 23 | Patient died during Living Donor TX procedure | Death |
| 24 | Unable to contact candidate | |

Multi-listing: one person (`PERS_ID`) can have several listings (`PX_ID`).
Code 14 closes the other listings when the person is transplanted elsewhere.

## Follow-up codes (`TFL_FOL_CD`, format `FOLCD`)

- 1 = hospital discharge; 3, 6 = months; 10, 20, ..., 790 = years 1–79
- 800 = graft failure; 801–850 = years 1–50 after graft failure
- 900 = lost to follow-up, reported alive; 998 = lost to follow-up;
  999 = recipient death

## Functional status (format `FUNCSTAT`)

Three systems in one format:

- 1–3: activities of daily living with no, some, or total assistance
- 2010–2100: Karnofsky scale (adults), in steps of 10%
- 4010–4100: Lansky play-performance scale (children)
- 996: not applicable (patient < 1 year old); 998: unknown

## Missing-value codes

The same code number means different things in different formats (code 4
is "Unknown", "N/A", "Not tested" or "Yes, but CAD unknown" depending on the
format). Kinds found in the codebook: unknown, not applicable, not done,
pending, cannot disclose, indeterminate, partly known, and SAS missing.
A missingness taxonomy must be checked against each applicable format.

## Representation and release scope

Code values and display labels are distinct representations. Exported labels can
contain padding; match against the applicable format rather than assuming an
arbitrary label string is stable across software or releases.

On 2026-11-14, metadata-only inspection of the workbook at repository revision
`ebd869acf5d0618c4d64c9ec71fb62e9a85be701` reverified REMCD 14/18/19/21/23,
FOLCD 900/998/999, RACE 16 (Black) and 64 (Asian), and ACREJEPF below. The bundled
HTML dictionary identifies itself as SRTR 2203; that does not independently
establish the workbook's release. The official dictionary retrieved during that
review was 2609; no exhaustive cross-release comparison was performed.

## Rejection and status dates

ACREJEPF: 1 = treated rejection; 2 = untreated rejection; 3 = no rejection;
998 = unknown. A treated-rejection definition differs from any-rejection and
cannot silently classify untreated rejection as absence of all rejection.
Check each organ/table/era's field-to-format assignment before reuse.
TFL_PX_STAT_DT is a status date, not proof of exact clinical onset.

## Liver status and prior transplant history

In the inspected CANDSTAT table, 6106 is labeled MELD/PELD -94 and 6206 is
MELD/PELD 6. The prefixes alone do not distinguish MELD from PELD; use the
appropriate score-type fields and policy era. REC_PREV_KI is described as prior
kidney transplantation but has no confirming binary format in the inspected
HTML dictionary; a universal 0/1 or PAK mapping is not established by that label.

## Admission timing and medication indication

Rechecked 2026-11-14 against the bundled SRTR 2203 HTML dictionary and workbook
at revision `e7a74d1fba67d25970703545cb11eda07007080c` (metadata only).
REC_POSTX_LOS is labeled "Time after first Tx, same stay". A retransplant during
that admission therefore requires checking the time origin before interpreting
length of stay as time from the later operation; the label alone does not verify
a replacement discharge-date calculation.

IMMUNO distinguishes REC_DRUG_CD (format DRUG) from REC_DRUG_INDUCTION,
REC_DRUG_MAINT, and REC_DRUG_ANTI_REJ. Drug identity alone does not establish its
indication. The workbook maps DRUG 20 to DAB486-IL-2; the mechanism source in
[web-sources.md](web-sources.md#williams-et-al-cellular-processing-of-dab486-il-2-1990)
explains why name-based grouping with receptor-blocking antibodies is unsafe.
The workbook's independent release remains unestablished. These targeted checks
do not validate every medication class, indication value, or organ-specific linkage.
