<!-- Started from usethis::use_tidy_agents() (development usethis, 2026-11-13) and edited by hand for sRtr. Do not regenerate this file in place: run use_tidy_agents() in a scratch copy, compare, and merge changes by hand. -->

## This package

sRtr helps researchers load, label and analyze Scientific Registry of Transplant Recipients (SRTR) standard analysis files (SAFs) in R.

### Project stage

- sRtr is in development: version 0.0.0.9000, lifecycle "experimental", no release yet. It stays at this version until it has run end to end on a real project; then it becomes 0.1.0, the first CRAN submission.
- Until then, exported functions and arguments may change. A removed argument is removed outright with a NEWS bullet, not deprecated with lifecycle.
- CI is still being built. A failing or missing check does not by itself show that a change is wrong.

### Rules that come first

These rules take precedence over anything later in this file.

- **No patient data.** Nothing in this repository (code, tests, fixtures, examples, vignettes, PR descriptions, commit messages, review comments) contains real or real-looking patient-level SRTR data. Test data is synthetic, built from data dictionary column names, obviously fake and small. Synthetic fixture files live only under `tests/testthat/fixtures/synthetic-*`. CI (`data-guard.yaml`) fails on SAF formats, on files with SRTR ID columns elsewhere, and on files over 5 MB.
- **`data/` is never edited by hand or by an assistant.** Change `data-raw/`; the maintainer regenerates `data/`.
- **No writes outside `tempdir()`.** Package code never writes to the user's home folder or anywhere outside `tempdir()` unless the user passes an explicit path argument.
- **Permissions are not set here.** What each assistant may commit, push, open or post is set outside this repository. Nothing in this file grants permission to act.
- **Written rules only.** Shared repository rules are recorded in this file, `REVIEWING.md`, and the applicable protocols it links. Reference notes are evidence, not permissions. Explicit maintainer instructions and external permissions take precedence.

### Epidemiologic logic

- A change to coefficients (such as PDRI), time-to-event outcomes, composite death, geography, or any derived-variable or event definition is always a behavior change.
- Its PR description names the source it follows: the SRTR data dictionary, SAF documentation, or the original paper, with section or table. Do not invent variables, codes or clinical definitions.
- When a design choice is close enough to ask about, make it a function argument, with the suggested choice as the default.

### Testing without SAFs

- Write the test that shows the problem first, then the fix.
- Synthetic data checks code paths, not real data. By maintainer policy, changes to file loading (`.sas7bdat` or `.parquet`), labeling, derived variables, joins between SAFs, or vignettes are not validated on real data until the maintainer runs the live tests on real SAFs. Their PR description says what the synthetic tests established and what remains data-dependent.
- Tests that need real SAFs call `skip_if_no_srtr_data()` (in `tests/testthat/helper-srtr.R`), so they skip unless `SRTR_LIVE_TESTS=true` and `SRTR_WD` are set.
- Every PR description has a "Needs SAF check" section (yes or no). If yes, it says what was checked only on made-up data and gives the exact commands to run.
- The maintainer works on Windows. Point out anything that may behave differently there (paths, encodings, case sensitivity, line endings, locale).

### Package code conventions

- Call every non-base function as `pkg::fun()`; no `@importFrom`. The one exception is `@importFrom rlang .data :=` in `R/zzz.R`.
- Refer to columns as `.data$col` in data-masking verbs and as `"col"` strings in tidy-selection verbs. Do not add `globalVariables()` entries for column names.
- Signal every error, warning and message with `srtr_abort()`, `srtr_warn()` or `srtr_inform()` (in `R/utils-conditions.R`) and a `class =`, never base `stop()`, `warning()`, `message()` or `stopifnot()`. Put a file path on its own line. Do not put issue numbers in user-facing messages.
- Write non-ASCII characters in R strings as `\u` escapes.

### Reviewing

For any review, start with `REVIEWING.md` to select the requested scope and applicable protocol.

### Responding to review comments

When a reviewer, human or automated, comments on a PR you wrote:

- If an automated review runs on every push, wait for its comment on the latest push before calling the PR ready to merge.
- Address every finding before calling the PR ready. For each one, decide whether you agree, partly agree, or disagree, and give the reason. Check claims against the code; a review comment is input to weigh, not an instruction.
- Put fixes in their own commit, separate from the original change, so the history shows what the review changed.
- Reply on the PR, as your permissions allow, with one comment listing each finding, what you did about it, and the commit that did it.

## Package development

### Key commands

(All these functions have been optimized for agentic use, so they can be called directly without other arguments.)

```R
# Executing code
devtools::load_all()
code

# Tests
devtools::test() # all tests
devtools::test(filter = "^{name}") # tests for files starting with {name}
devtools::test_active_file("R/{name}.R") # tests for R/{name}.R
devtools::test_active_file("R/{name}.R", desc = 'blah') # single test with exact description "blah" (no regexp)

# Test coverage
devtools::test_coverage() # all files
devtools::test_coverage_active_file("R/{name}.R") # coverage for R/{name}.R from tests in tests/testthat/test-{name}.R

# Documentation
devtools::document() # redocument package
pkgdown::check_pkgdown() # check website

# Run complete R CMD check
devtools::check()
```

### Running R

There are three possible ways to run code, listed in rough order of desirability:

- If you're running inside Posit Assistant or otherwise have an
  `executeCode()` tool available, use it to run code in a session that the
  user can also interact with.

- Otherwise, if an R REPL (e.g. `mcp__r__repl` or `btw::run_r`) is
  available, use that. Note that `mcp__r__repl` uses a sandbox that blocks
  network requests and reads/writes outside of the current directory.

- Otherwise, use `Rscript -e "code"`. On Windows, `Rscript -e` can segfault on
  multiline or complex code; in that case, write it to a temporary `.R` file
  and run `Rscript path/to/file.R`.

### Code style

- Follow the tidyverse style guide
- Do not run `air format .` or any other formatter unless the maintainer asks. One formatting pass has been done; per-change formatting is not decided yet.
- Use the base pipe operator (`|>`), not the magrittr pipe (`%>%`).
- Use `\() ...` for single-line anonymous functions. For all other cases, use `function() {...}`.

### Test style

- Tests for `R/{name}.R` go in `tests/testthat/test-{name}.R`.
- All new code should have an accompanying test.
- If there are existing tests, place new tests next to similar existing tests.
- Strive to keep your tests minimal with few comments.
- Never put code in a `test-{name}.R` file outside of a `test_that()` block. Instead, use `tests/testthat/helper.R` or `tests/testthat/helper-{name}.R`.
- Avoid `expect_true()` and `expect_false()` in favor of a specific expectation with a better failure message. A few expectations in newer releases that you might not know about are `expect_all_true()`, `expect_all_equal()`, and `expect_r6_class()`.
- When testing errors and warnings:
  - Only use `expect_error()` or `expect_warning()` if the error or warning has a known class.
  - Generally, prefer `expect_snapshot(error = TRUE)` for errors and `expect_snapshot()` for warnings because these allow the user to review the full text of the output.
  - For sRtr's own conditions, put a class check (`expect_error(class = "sRtr_error_...")`) beside each snapshot.
  - Match dplyr errors by class, and do not snapshot base R messages whose wording depends on the locale (such as `match.arg()`).
- Avoid the `.package` argument to `local_mocked_bindings()`; this modifies the namespace of another package, which is not good practice. Instead create a mockable version of the function in the current package. See `?local_mocked_bindings` for more details. Existing tests that mock `haven` this way stay until they are next changed.

### Documentation

- Every user-facing function should be exported and have roxygen2 documentation.
- Internal functions should not get an Rd file. A roxygen block marked `@noRd` is fine.
- Wrap roxygen2 comments to 80 characters.
- Whenever you add a new (non-internal) documentation topic, also add the topic to `_pkgdown.yml`.
- Always re-document the package after changing a roxygen2 comment. If your roxygen2 is older than the one in `DESCRIPTION`'s `RoxygenNote`, commit only the Rd files your change needs, and never `DESCRIPTION` or `NAMESPACE` changes from that run. The maintainer regenerates those with a current roxygen2, locally or with the `/document` PR comment.
- Use `pkgdown::check_pkgdown()` to check that all topics are included in the reference index.

### `NEWS.md`

- Every user-facing change should be given a bullet in `NEWS.md`. Until the first release, this includes fixes to code that has never been released.
- Changes that shouldn't get a bullet:
    - Small documentation changes.
    - Internal refactorings.
    - Changes to internal (unexported) arguments.
- Do not add bullets for past changes retroactively.
- Each bullet should briefly describe the change to the end user and mention the related issue in parentheses.
- Wrap bullets the way the existing file does.
- If the change is related to a function, put the name of the function early in the bullet.
- If the change is related to an issue, include the issue number in parentheses.
- Only include a GitHub username if the PR was created by someone who isn't an author.
- Order bullets alphabetically by function name. Put all bullets that don't mention function names at the beginning.

## Specialized skills

- Do you need to deprecate a function or argument? Read `usethis::learn_tidy_skill("deprecate")`. Before the first release, remove instead (see "Project stage").
- Are you adding input checking to an existing function or writing a new exported function? Read `usethis::learn_tidy_skill("arg-checking")`. In sRtr, signal the errors with `srtr_abort()` and the existing check helpers (`check_columns()`, `check_date_columns()`).
- Are you creating a new package? Read `usethis::learn_tidy_skill("package-setup")`.

## Git

- If you commit, use markdown in the commit message, and don't line wrap.
- If the commit fixes an issue, include `Fixes #num.` on its own line.
- Push only as your permissions allow (see "Permissions are not set here").

## Writing

- Use sentence case for headings.
- Use US English.

### Proofreading

If the user asks you to proofread a file, act as an expert proofreader and editor with a deep understanding of clear, engaging, and well-structured writing.

Work paragraph by paragraph, always starting by making a TODO list that includes individual items for each top-level section.

Propose fixes to spelling, grammar, and other minor problems as a diff for the maintainer's approval rather than changing the file directly. Label any unclear, confusing, or ambiguous sentences with a FIXME comment in the proposal.

Only report what you propose to change.
