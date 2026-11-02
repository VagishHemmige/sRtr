# Codebook notes

Code tables that other projects got wrong, checked against
`data-raw/SRTR_format_codebooks.xlsx` and `data-raw/dataDictionary.html`
on 2026-11-02. Codebooks change between releases (#26); recheck against the
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
See #27 for the draft classification of every format value.

## Label format

`apply_srtr_factors()` labels values as `"code: Meaning"` (e.g. `"8: Died"`).
Stata exports of SAFs pad these with leading spaces, which breaks exact
string matching; match on the code where possible.
