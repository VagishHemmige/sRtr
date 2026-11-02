# Web sources and papers

## Retrieved and read

### SRTR, About SRTR Standard Analysis Files

- **URL:** https://srtr.org/requesting-srtr-data/about-srtr-standard-analysis-files
- **Accessed:** 2026-11-02
- **Content:** scope and access only. Nothing on cleaning, plausible ranges,
  missing values or derived variables. Files link at the person level and
  come with an electronic data dictionary; SAFs generally exclude geographic
  data and text fields.

### SRTR, Technical Methods for the Program-Specific Reports

- **URL:** https://preview.srtr.org/about-the-data/technical-methods-for-the-program-specific-reports/
- **Accessed:** 2026-11-02. This is SRTR's **preview** site; check the live
  page before citing.
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
- **Informs:** #5, #6, #18, #31

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
- **Informs:** #27, #28, #29, #30, #32

## Cited but not yet retrieved

Verify before relying on these.

- Wood NL et al. Life expectancy without a transplant of status 1A liver
  transplant candidates. *Am J Transplant* 2021. doi:10.1111/ajt.16830
  (cited in the repository README).
- Kim WR et al. Hyponatremia and mortality among patients on the
  liver-transplant waiting list. *N Engl J Med* 2008 (MELD-Na). Cited from
  memory for #8.
- Kim WR et al. MELD 3.0. *Gastroenterology* 2021. Cited from memory for #8.
- SRTR Program-Specific Reports on Outcomes: A Guide for the New Reader,
  *Am J Transplant*:
  https://www.sciencedirect.com/science/article/pii/S1600613522029586
  (fetch failed on 2026-11-02).
- OPTN MPSC performance metrics materials, surfaced by search:
  https://optn.transplant.hrsa.gov/media/r5lmmgcl/mpsc_performancemetrics_3242022b.pdf
