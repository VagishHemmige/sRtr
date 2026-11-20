# Glossary

Short definitions of the terms that trip up new readers of SRTR data,
each with a link to the guide that explains it. Start with the
identifiers: which one you count decides what your numbers mean.

## Identifiers: what each one counts

| Identifier | One per | Watch for |
|----|----|----|
| `PX_ID` | Waitlist registration | One person can be listed more than once, at several centers or for several organs. |
| `PERS_ID` | Person | A person transplanted twice has two transplant registrations. The donor files also hold a `PERS_ID`, with its own meaning. |
| `TRR_ID` | Transplant registration | Repeats on every follow-up form for that transplant. |
| `TX_ID` | Transplant event | Shared by the registrations of one multi-organ transplant, which can sit in several organ files. |
| `TRR_FOL_ID` | Follow-up form | Several per transplant registration. |
| `DONOR_ID` | Donor | One deceased donor can give organs to several recipients. |
| `CTR_ID` | Center | Transplant files hold center identifiers such as `REC_CTR_ID`. |

These roles come from the variable labels in the SRTR data dictionary,
which are not always consistent, so check a key on your own files before
joining on it. See [What are you
counting?](https://vagishhemmige.github.io/sRtr/articles/files-and-keys.html#what-are-you-counting)
and [Transplants are not
people](https://vagishhemmige.github.io/sRtr/articles/files-and-keys.html#transplants-are-not-people).

## Files and releases

**SAF (standard analysis file).** One of the files SRTR delivers to
researchers, such as `TX_KI`. sRtr calls the name a *file key*. See
[Getting
started](https://vagishhemmige.github.io/sRtr/articles/getting-started.html#load-a-file).

**Release.** A delivery of SAFs, named by year and month: `"2303"` is
the March 2023 release. Variables are added and dropped between
releases. See
[Releases](https://vagishhemmige.github.io/sRtr/articles/releases-and-warnings.html#releases).

**File names.** The first part says what the file holds and the second
says the organ:

- `CAND_` waitlist candidates, `STATHIST_` waitlist status history,
  `TX_` transplants, `TXF_` transplant follow-up forms; `DONOR_DECEASED`
  and `DONOR_LIVE` donors.
- Organs: `KI` kidney, `LI` liver, `PA` pancreas, `KP` kidney-pancreas,
  `HR` heart, `LU` lung, `HL` heart-lung, `IN` intestine. Candidate and
  status files group organs: `KIPA` (kidney and pancreas), `LIIN` (liver
  and intestine), `THOR` (thoracic: heart and lung).

See [Organs and multi-organ
transplants](https://vagishhemmige.github.io/sRtr/articles/files-and-keys.html#organs-and-multi-organ-transplants).

**Data dictionary.** SRTR’s published list of every variable, its label
and its format. sRtr ships copies as `dictionary` and
`dictionary_versions`. See [Releases, the data dictionary and
warnings](https://vagishhemmige.github.io/sRtr/articles/releases-and-warnings.md).

## Codes and missing values

**Format.** The code list that gives a variable’s values their meaning,
such as `1` for “Yes”. The same code can mean different things in
different formats. See [Labels and
codes](https://vagishhemmige.github.io/sRtr/articles/getting-started.html#labels-and-codes).

**Code in no format.** A value in your file that the dictionary’s format
does not list. sRtr keeps it and warns. See [Codes in no
format](https://vagishhemmige.github.io/sRtr/articles/releases-and-warnings.html#codes-in-no-format).

**Unknown, not done, not applicable.** Different kinds of missing value,
each with its own codes. Once they all become `NA`, they look the same.
See [What the codes
mean](https://vagishhemmige.github.io/sRtr/articles/missing-data.html#what-the-codes-mean)
and [Choosing what becomes
NA](https://vagishhemmige.github.io/sRtr/articles/missing-data.html#choosing-what-becomes-na).

## Dates and outcomes

**Transplant date** (`REC_TX_DT`). Where post-transplant time starts.

**Last follow-up date** (`TFL_LAFUDATE`, “last graft follow up date”).
The last date the transplant was known to be followed, where follow-up
of the graft ends. See [Whose
follow-up?](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.html#whose-follow-up)

**Graft failure date** (`TFL_GRAFT_DT`). See [Graft failure and death on
the same
day](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.html#graft-failure-and-death-on-the-same-day).

**Death dates.** Three sources: the OPTN death date
(`PERS_OPTN_DEATH_DT`), the Social Security death date
(`PERS_SSA_DEATH_DT`) and the date on the follow-up forms
(`TFL_DEATH_DT`). A *composite death date* takes the first available in
a fixed order. See [Which death
date?](https://vagishhemmige.github.io/sRtr/articles/follow-up-windows.html#which-death-date)

**Follow-up form date** (`TFL_PX_STAT_DT`). The date of the form that
reported an event, not the date the event began. See [A form date is not
an onset
date](https://vagishhemmige.github.io/sRtr/articles/follow-up-forms.html#a-form-date-is-not-an-onset-date).

**Listing date** (`CAN_LISTING_DT`). When a candidate was added to the
waiting list; it does not change when the listing is transferred.

## Risk scores

**KDRI and KDPI** (kidney donor risk index and profile index), **EPTS**
(estimated post-transplant survival), **LKDPI** (living kidney donor
profile index), **PDRI** (pancreas donor risk index), **donor eGFR**
(estimated kidney function) and **PVR** (pulmonary vascular resistance).
Each is added by an `add_*()` function. See [The
scores](https://vagishhemmige.github.io/sRtr/articles/adding-columns.html#the-scores).

## Organizations and rules

**SRTR.** The Scientific Registry of Transplant Recipients, which
analyzes the national transplant data and distributes the SAFs.

**OPTN.** The Organ Procurement and Transplantation Network, which
collects the data and sets allocation policy. Its regions are mapped by
[`get_hrsa_optn_regions()`](https://vagishhemmige.github.io/sRtr/reference/get_hrsa_optn_regions.md).
**UNOS** has operated the OPTN.

**OPO.** An organ procurement organization, which recovers deceased
donor organs within its service area. See [Plotting OPO service
areas](https://vagishhemmige.github.io/sRtr/articles/mapping.html#plotting-opo-service-areas).

**HRSA.** The Health Resources and Services Administration, which
oversees the OPTN and publishes the center and service-area maps sRtr
downloads.

**PSR.** SRTR’s program-specific reports on each transplant program.
Their technical methods define many of the outcomes sRtr follows.

**DUA (data use agreement).** The agreement under which a researcher
receives SAFs. Real results leave your computer only as aggregate
counts. See [Share counts, never
rows](https://vagishhemmige.github.io/sRtr/articles/getting-started.html#share-counts-never-rows)
and [how to share counts
safely](https://vagishhemmige.github.io/sRtr/articles/checking-your-safs.html#share-counts-only).
