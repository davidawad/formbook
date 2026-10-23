<!-- fb:generated:start -->
# Trademark Trial and Appeal Board

- Alias: `ttab`
- CourtListener: [ttab](https://www.courtlistener.com/?court=ttab)
- Level: agency
- Circuit: `cafc`
- Status: **up for review** (29%); manual status in `court.json`: `todo`

## Checklist

- [x] `rules.md` present
- [ ] `usage/SOURCE.md` names at least 2 FILED-EXAMPLE PDFs (different filers)
- [ ] `usage/` has at least 2 INPUT .md samples
- [ ] typst engine passes (`usage/.check-typst.txt` valid)
- [ ] latex engine passes (`usage/.check-latex.txt` valid)
- [ ] docx engine passes (`usage/.check-docx.txt` valid)
- [x] a review file in `reviews/`

Engines (doc folders passing / with that template): typst `4/4`, latex `—`, docx `4/4`.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and every doc folder under it with a `usage/INPUT-*.md` has a valid `usage/.check-typst.txt` stamp (`just eval` writes them; the default checks are `data/checks-default.yaml`).

## Doc folders

4 of 4 doc folders with an INPUT pass the typst eval.

| Doc type | Status | Typst | LaTeX | DOCX |
|---|---|---|---|---|
| [answer](answer) | up for review | pass | — | pass |
| [notice-of-appearance](notice-of-appearance) | up for review | pass | — | pass |
| [notice-of-opposition](notice-of-opposition) | up for review | pass | — | pass |
| [trial-brief](trial-brief) | up for review | pass | — | pass |

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (`reference.xml`, or a committed `reference.docx`, plus `*.lua` filters; `fb render --engine docx` builds it)
- `usage/` filed examples `FILED-EXAMPLE-<doctype>[-<n>].pdf` from different filers and `SOURCE.md`; sample inputs `INPUT-<doctype>[-<n>].md`; renders `OUTPUT-<doctype>[-<n>].typst.pdf`, `.latex.pdf`, `.docx`, `.docx.pdf` (same id as the INPUT); stamps `.check-<engine>.txt`

## Doc types

| Folder | Paper | Rules (rules.md section) | Exemplars |
|---|---|---|---|
| [notice-of-opposition](notice-of-opposition) | Notice of opposition (37 C.F.R. §§ 2.101, 2.104) | "Doc type: notice-of-opposition" (TTAB-CONT, TTAB-CERT-010/011) | 2 filers |
| [notice-of-appearance](notice-of-appearance) | Notice of appearance of counsel, alone or with a change of correspondence address and/or a power of attorney (37 C.F.R. §§ 2.17, 2.18, 2.19(a)(4); TBMP §§ 114.03, 117) | "Doc type: notice-of-appearance" (TTAB-NOA-001 to -010) | 4 filers |
| [answer](answer) | Answer to a notice of opposition or petition to cancel, alone or with a counterclaim (§§ 2.106, 2.114) | "Doc type: answer" (TTAB-ANS, TTAB-DEF, TTAB-CC) | 2 filers |
| [trial-brief](trial-brief) | Brief on the case at final hearing (§ 2.128) | "Doc type: trial-brief" (TTAB-LEN-020 to TTAB-ELEC-021) | 2 filers |

Court-wide requirements (form, caption, signature, service, electronic filing) are in [rules.md](rules.md); loop history in [LOG.md](LOG.md); visual reviews in [reviews/](reviews/).

[Formbook index](../../../README.md) | [Status table](../../../STATUS.md)
<!-- fb:generated:end -->

- [ ] `usage/` has at least 2 filed PDFs (different filers)
- [ ] `usage/` has at least 2 .md samples

- [ ] overlay PDF present (`usage/*-overlay.pdf`)

- `usage/` real filed examples from different filers (PDF) and `SOURCE.md`
- `usage/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`
