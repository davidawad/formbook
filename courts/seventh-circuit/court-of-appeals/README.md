# Court of Appeals for the Seventh Circuit

- Alias: `ca7`
- CourtListener: [ca7](https://www.courtlistener.com/?court=ca7)
- Level: appellate
- Circuit: `ca7`
- Status: **todo** (0%); manual status in `court.json`: `todo`

## Checklist

- [ ] `rules.md` present
- [ ] `usage/` has at least 2 filed PDFs (different filers)
- [ ] `usage/` has at least 2 .md samples
- [ ] typst engine passes (`usage/.check-typst.txt` valid)
- [ ] latex engine passes (`usage/.check-latex.txt` valid)
- [ ] docx engine passes (`usage/.check-docx.txt` valid)
- [ ] overlay PDF present (`usage/*-overlay.pdf`)
- [ ] a review file in `reviews/`

Engines: typst `—`, latex `—`, docx `—`.

`done` is set by a human in `court.json` (`"status": "done"`); nothing automated writes it.
A court is `up for review` when `rules.md` is present and the typst engine passes `tools/check.sh` (valid stamp).

## Typeface

The rules name no face. Fed. R. App. P. 32(a)(5)(A) requires a proportionally spaced face with serifs, 14 pt or larger. Circuit Rule 32(b) lowers that to 12 pt in the body and 11 pt in footnotes. Both are in the Seventh Circuit's rules PDF, <https://www.ca7.uscourts.gov/assets/pdf/rules.pdf> (read 2026-10-15; current as of December 1, 2025; Circuit Rule 32(b) at its p. 89, FRAP 32(a)(5) at p. 86). No face is named, so every doc type keeps **EB Garamond** (vendored, "No face named" row of `docs/FONTS.md`). Only the sizes and margins come from the rules.

| Doc type | Face required (rule) | Typst family | Latex engine | Changed in the fonts pass |
|---|---|---|---|---|
| `opening-brief` | None named; serif, proportional (FRAP 32(a)(5)(A); Cir. R. 32(b)) | `EB Garamond` | `EBGaramond` (same) | No |
| `answering-brief` | None named (same) | `EB Garamond` | `EBGaramond` (same) | No |
| `reply-brief` | None named (same) | `EB Garamond` | `EBGaramond` (same) | No |

The Seventh Circuit's typography handbook (<https://www.ca7.uscourts.gov/assets/pdf/type.pdf>, 2018) is guidance, not a rule. It recommends Century and Bookman families and calls Times and Garamond less legible. It is not adopted here: the rule allows any proportional serif, and the handbook is not the court's rule. TeX Gyre Schola (Century) is now vendored, so a switch is one line per template. Open question for David: switch the three doc types to Schola, or keep EB Garamond?

## Folders

- `typst/` Typst template (primary)
- `latex/` LaTeX template
- `docx/` Word template (reference.docx + filters)
- `usage/` real filed examples from different filers (PDF) and `SOURCE.md`
- `usage/` sample inputs (.md); renders `<id>.pdf`, `<id>.latex.pdf`, `<id>.docx`, `<id>.docx.pdf`; stamps `.check-<engine>.txt`

[Formbook index](../../../README.md) | [Status table](../../../STATUS.md)
