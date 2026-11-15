# Synthetic outcome audit checks

Run from an isolated, inspected clone with R and package dependencies installed:

```sh
bash tools/reference-review/run.sh
```

Set `AUDIT_RSCRIPT` to select another Rscript executable if needed. The Bash
runner disables site/user startup files and real-SAF settings, checks child-process
isolation, and runs only these synthetic tests in a temporary package copy.
Loaders are mocked; identifiers and dates are invented. Do not use a connected
working copy or an active RStudio session. Windows requires a Bash environment;
the runner has only been exercised on Linux.

## Checks and intended use

| Check | Purpose | Use |
| --- | --- | --- |
| Report ordering and duplicates | Earliest positive report date should be invariant to row order and duplicate forms. | Candidate permanent test. |
| Repeated person and shared donor | Keep separate transplant episodes and attach reports to the correct episode. | Candidate permanent test; does not validate real identifier mappings. |
| Ascertainment extension | Extending mortality coverage should leave other outcomes unchanged. | Candidate permanent test. |
| Death-composite overwrite | Demonstrate the pipeline replacing a selected earliest composite with precedence. | Characterization only; do not adopt overwrite as a permanent guarantee. |
| Missing admission duration, KI and KP | Preserve affirmative rejection evidence despite missing inpatient length of stay. | Two regression cases; onset-date policy remains undecided. |

The runner returns nonzero for failed expectations. At the original tested
revision `c36dcc26bfa4d5b7cc9b7762d150bff44b01fb51`, the two rejection cases
produced three failing assertions. Treat that as a historical baseline, not an
instruction to accept failures on later code.

[permanent-tests.patch](permanent-tests.patch) is an **unapplied proposal** containing
only the first three cases, placed in their existing owning test files. Check its
applicability against the target revision before use. None of these files installs
new package tests or activates CI. Synthetic results establish code behavior,
not clinical validity.

## Test rationale

- [PMC11426084](https://pmc.ncbi.nlm.nih.gov/articles/PMC11426084/), Exposures,
  motivates distinguishing the date of a positive report from clinical onset.
- [PMC11935373](https://pmc.ncbi.nlm.nih.gov/articles/PMC11935373/), Methods/Table 1,
  motivates preserving recipient episodes within shared-donor groups. Its graft
  definition is not imported into these tests.
- [PMC11972892](https://pmc.ncbi.nlm.nih.gov/articles/PMC11972892/), Methods:
  Mortality Ascertainment, supplies an earliest-death use case, not a universal
  default. The composition probe compares existing package options.
- Missing-duration cases test the package's affirmative-rejection contract.
  They do not choose an imputed onset date or a clinical rejection definition.
