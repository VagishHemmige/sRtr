# Web sources and papers

## Retrieved and read

### SRTR, About SRTR Standard Analysis Files

- **URL:** https://srtr.hrsa.gov/requesting-data/about-srtr-standard-analysis-files-safs/
- **Accessed:** 2026-11-14. Previous path retrieved 2026-11-02 returned 404
  during reverification; the current official page was retrieved.
- **Content:** scope and access only. Nothing on cleaning, plausible ranges,
  missing values or derived variables. Files link at the person level and
  come with an electronic data dictionary; SAFs generally exclude geographic
  data and text fields.

### SRTR, Technical Methods for the Program-Specific Reports

- **URL:** https://srtr.hrsa.gov/transplant-professionals/program-specific-report/technical-methods-for-the-program-specific-reports/
- **Accessed:** 2026-11-14, live official page; posttransplant outcome sections
  read. The quotations below were recorded from the preview site on 2026-11-02,
  not newly transcribed from the live page.
- **Scope:** organ-specific PSR graft/patient survival. These evaluation methods
  are not a universal research estimand; do not silently combine historical
  endpoint definitions with the current page.
- **Key passages (quoted):**
  - Missing data: "In general, 10 iterations of multiple imputation via
    chained equations handles missing values." "To determine the expected
    number of events, missing data are assigned the least beneficial value."
  - Death sources: "In the case of conflicting death dates from various
    sources, the OPTN death date takes precedence. If there is no OPTN death
    date and dates from SSDMF and CMS conflict, the SSDMF date takes
    precedence." "Patients not reported to have died in any source are
    assumed to be alive." "These data sources are not designed to identify
    all deaths, so the deaths reported may represent an under-count."
  - Some calculations "do not include deaths that occur after loss to
    follow-up in the OPTN database".
  - Graft failure recorded before the transplant date: analysed as censored
    (lost to follow-up) on the day of transplant.
  - About 1% of patients "are found to have died or undergone transplant
    before being removed"; some candidates have removal codes indicating
    transplant but no transplant or follow-up record.
  - "Patient follow-up is not censored in the event of death or removal due
    to deteriorated medical status."
  - Administrative censoring of listings after 7 years (kidney) and 5 years
    (other organs) in one table.

### Snyder JJ et al., Developing statistical models to assess transplant outcomes using national registries: the process in the United States. *Transplantation* 2016

- **URL:** https://srtr.hrsa.gov/media/beznwdnv/snyderjj_developing-srtr-risk-adjustment-models-transplantation-2016.pdf
  (PubMed: https://pubmed.ncbi.nlm.nih.gov/26814440/)
- **Accessed:** 2026-11-02
- **Key passages (quoted):**
  - Plausible ranges are "determined by expert opinion (SRTR staff, STAC
    members, and OPTN committee input)" and are "generally conservative in
    allowing extreme but potentially plausible values." An out-of-range value
    "will be treated as missing."
  - "SRTR considers Unknown responses to be missing." Imputation by
    "multiple imputation by chained equations", with "predictive mean
    matching for continuous variables".
  - Continuous variables truncated "at the first and 99th percentiles" so
    "splines are not estimated in the extreme tails of the distribution."
  - "As of March 31, 2015, OPTN removed all nonrequired elements from data
    collection forms."
  - Programs can review their data and correct values before evaluation.
- **Not found:** a published per-variable list of SRTR's plausible ranges.

### Axelrod et al., Systematic evaluation of pancreas allograft quality, outcomes and geographic variation in utilization (2010)

- **Sources:** [Wiley](https://onlinelibrary.wiley.com/doi/pdfdirect/10.1111/j.1600-6143.2009.02996.x),
  [Alliance-hosted paper](https://www.organdonationalliance.org/wp-content/uploads/2020/10/Systematic-Evaluation-of-Pancreas-Allograft-Quality_Outcomes_and_-Geographic_Variation_in_Utilization.pdf).
- **Verified:** 2026-11-14, full-paper text plus visual comparison of printed
  p840, Table 2 equation; Methods p838. Adult US SPK/PAK/PTA, 2000-2006.
- **Source discrepancy:** the Wiley copy prints BMI coefficient -0.00986347;
  the Alliance copy prints -0.000986347. The rounded BMI30 illustration (1.17)
  supports the latter. Corrected-equation provenance remains unresolved;
  extraction alone did not reliably distinguish the copies.
- **Interpretation:** PDRI is relative risk, not an absolute probability. The
  CVA interaction applies to PAK; identification of PAK from registry history
  fields needs an independently justified mapping.

### Kim et al., MELD 3.0 (2021)

- **Source:** https://pmc.ncbi.nlm.nih.gov/articles/PMC8608337/;
  doi:10.1053/j.gastro.2021.08.050, Methods/Results.
- **Verified:** full text retrieved 2026-11-14; replaces the earlier memory-only
  entry. Model equations and allocation implementation are distinct.
- **Official context:** [HRSA MELD calculator](https://www.hrsa.gov/optn/data-calculators/allocation-calculators/meld-calculator),
  retrieved 2026-11-14, includes qualifying dialysis and age-dependent inputs.
  A complete historical equation/policy comparison was not performed.

### Registry dictionaries and geographic sources

- **Dictionary:** https://www.srtr.org/docs/datadictionary.html, retrieved
  2026-11-14, title 2609. The repository's HTML snapshot identifies release
  2203. Targeted fields were checked, not an exhaustive release diff.
- **OPTN regions:** [Management and membership policies](https://www.hrsa.gov/sites/default/files/hrsa/optn/optn-management-and-membership-policies.pdf),
  effective 2026-04-22, Policy C; retrieved/read 2026-11-14. Use dated policy
  for substate membership rather than inferring it from whole-state outlines.
- **Census boundaries:** [2018 1:20m state layer](https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_state_20m.zip).
  Full bundled `.shp.iso.xml` and `.shp.ea.iso.xml` metadata read 2026-11-14;
  metadata published May 2019. Generalized small-scale display geometry;
  constraints exclude precise geographic, area/perimeter, and geocoding use.
  Reprojection does not restore omitted detail. Retain Census attribution.
- **HRSA layers:** [center points (1)](https://gisportal.hrsa.gov/server/rest/services/Organs/OrganProcurementAndTransplantation_FS/MapServer/1)
  and [OPO areas (3)](https://gisportal.hrsa.gov/server/rest/services/Organs/OrganProcurementAndTransplantation_FS/MapServer/3),
  official metadata read 2026-11-14: EPSG:3857, record limit 1000, pagination
  supported. OPO areas are not OPTN regions. Feature completeness and historical
  snapshot availability were not established by reading metadata.

## Partially retrieved organ-specific literature

These were examined on 2026-11-14 through search-retrieved article sections.
Direct PMC full-page retrieval was blocked or incomplete; supplements and exact
SAF-field mappings are not verified. Treat them as qualified background leads,
not fully checked phenotype specifications.

| Source | Useful background and limitation |
| --- | --- |
| [Cancer diagnoses comparison, 2016](https://pmc.ncbi.nlm.nih.gov/articles/PMC5055411/) | Cancer-registry linkage and ascertainment/classification limitations; a SAF malignancy flag alone is not complete incident-cancer ascertainment. |
| [Liver acute rejection, 2017](https://pmc.ncbi.nlm.nih.gov/articles/PMC5326609/) | A2ALL 2003-2014 / SRTR 2005-2013; imputed rejection timing, not proof of exact onset from status dates. |
| [Heart treated rejection, 2024](https://pmc.ncbi.nlm.nih.gov/articles/PMC10817284/) | Adult isolated heart 2000-2021; treated-rejection phenotype does not establish cross-organ field equivalence. |
| [Place-based lung outcomes](https://pmc.ncbi.nlm.nih.gov/articles/PMC11362981/) | Lung treated rejection and geographic context; registry flags do not encode every clinical rejection subtype. |
| [2023 intestine annual report](https://pmc.ncbi.nlm.nih.gov/articles/PMC12334177/) | Outcomes with/without liver; national definitions do not validate a particular derived-date algorithm. |

The [NCI Transplant Cancer Match methods page](https://dceg.cancer.gov/research/who-we-study/cohorts/tcm-methods-paper)
was also examined via official search retrieval; it describes cancer-registry
linkage rather than relying on SAF malignancy flags alone.

## Cited but not yet retrieved

Verify before relying on these.

- Wood NL et al. Life expectancy without a transplant of status 1A liver
  transplant candidates. *Am J Transplant* 2021. doi:10.1111/ajt.16830
  (cited in the repository README).
- Kim WR et al. Hyponatremia and mortality among patients on the
  liver-transplant waiting list. *N Engl J Med* 2008 (MELD-Na). Cited from
  memory; not verified.
- SRTR Program-Specific Reports on Outcomes: A Guide for the New Reader,
  *Am J Transplant*:
  https://www.sciencedirect.com/science/article/pii/S1600613522029586
  (fetch failed on 2026-11-02).
- OPTN MPSC performance metrics materials, surfaced by search:
  https://optn.transplant.hrsa.gov/media/r5lmmgcl/mpsc_performancemetrics_3242022b.pdf
