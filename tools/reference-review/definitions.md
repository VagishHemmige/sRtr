# Definitions source-use ledger

Frozen revision and consolidated conclusions: [report](README.md). All assigned catalogue annotations were read; primary verification is explicitly bounded below. These are coverage records, not independent full-paper rereads.

## Authoritative sources and source dispositions

| Catalogue source | This pass / disposition |
| --- | --- |
| About SAFs | Catalogue fully read; access/scope background, no outcome authority. No new independent retrieval needed for a finding. |
| [PSR Technical Methods](https://srtr.hrsa.gov/transplant-professionals/program-specific-report/technical-methods-for-the-program-specific-reports/) | Independently retrieved 2026-11-14, page July 7 2026/Spring 2026, Section C estimated graft survival and patient survival. Organ distinction and source precedence confirmed. Defines PSR estimands only. |
| Snyder 2016 | Catalogue read; conservative plausibility, imputation and truncation are distinct modeling steps. No complete source reverification in this pass; cannot define a generic missing-code list or plausible bounds. |
| [Axelrod 2010, Alliance copy](https://www.organdonationalliance.org/wp-content/uploads/2020/10/Systematic-Evaluation-of-Pancreas-Allograft-Quality_Outcomes_and_-Geographic_Variation_in_Utilization.pdf) | Independently retrieved Methods p838 and Table 2 p840 text: risk ratio, PAK-specific CVA term, reference donor and equation confirmed. Numeric BMI coefficient in this copy is -0.000986347, agreeing with code. Screenshot retrieval attempted but not visually inspected; publisher-copy discrepancy remains inherited/unresolved, not independently settled. |
| Kim 2021 MELD 3.0; HRSA calculator | Catalogue read; model versus policy distinction useful. No MELD calculation in assigned R files; no coefficient assertion or new implementation warranted. Historical/allocation comparison remains unverified. |
| [2024 ADR Pancreas](https://srtr.hrsa.gov/adr/2024/Pancreas/) | Independently retrieved official PA47 via authoritative search: SPK kidney composite includes failure, retransplant, dialysis return and death. Do not assume these are all encoded in TFL_GRAFT_DT. Catalogue's pancreas era discrepancy remains unresolved; no cutoff proposed. |
| Williams 1990 DAB486-IL-2 | Catalogue read; mechanism evidence has a limited scope. Outside outcome/score assignment; no new class definition endorsed. |
| [Public dictionary 2609](https://www.srtr.org/docs/datadictionary.html) and bundled HTML 2203 | Targeted independent public retrieval and bundled metadata reads: TX/TXF_KP grain, TRR_ID/TRR_ID_PA, REC_PREV_KI label, REC_POSTX_LOS and follow-up reporting. Not a full release diff. Workbook codes are inherited checks, not newly verified here. |
| OPTN membership; Census; HRSA layers | Catalogue entries read; outside statistical outcome assignment. Keep dated source/geographic limitations; no new verification claimed. |
| Cancer comparison PMC5055411; liver rejection PMC5326609; heart rejection PMC10817284; lung PMC11362981; intestine ADR PMC12334177; NCI TCM methods | Entries read, qualified access retained. Background practice/ascertainment leads only; none used as defining authority for current code. |
| Wood 2021; Kim 2008 MELD-Na; PSR reader guide; MPSC material | Explicit unverified status retained. No inference that published practice settles package defaults. |
| Liver ADR PMC12334193 | Retrieval limitation retained. Does not establish exact safety-net/SLK cohort rules in this pass. |

The methodological catalogue correctly separates observation processes, estimands and record grain. Preserve those distinctions; the additions belong in implementation issues/tests, with only source facts added to references. Existing scientific choices are not approved by the catalogue.
