# N.D. Ohio Bankruptcy Court: adversary complaint

Status: template built, sample rendered, overlay run, every page reviewed (Gate 2 by eye). Engines: typst only; latex and docx not built.

## Governing rules (verified 2026-10-14)

| Requirement | Kind | Source | Verified | What the template does |
|---|---|---|---|---|
| Caption: court name, title of the case, case number and adversary number, brief designation of the document | M | FRBP 9004(b) (https://www.law.cornell.edu/rules/frbp/rule_9004) | 2026-10-14 | Court name, debtor caption, case no., chapter, judge, adversary no., title |
| Caption substantially conforms to Official Form 416A; FRCP 10 applies in an adversary proceeding | M | FRBP 7010 (https://www.law.cornell.edu/rules/frbp/rule_7010) | 2026-10-14 | Caption layout (parties on the left, numbers on the right) |
| Jurisdiction allegation names the bankruptcy case (name, number, chapter, district, division) and states whether the pleader consents to final orders by the bankruptcy court | M | FRBP 7008(a) (https://www.law.cornell.edu/rules/frbp/rule_7008) | 2026-10-14 | Frontmatter fields for case no. and chapter; the body carries the consent paragraph (Rule 7012(b)) |
| Paper: 8 1/2 x 11 inch, one side, no pre-punched holes | M | LBR 5005-1(a) (N.D. Ohio Local Bankruptcy Rules, last revised May 16, 2011, https://www.ohnb.uscourts.gov/sites/default/files/file-list/local-bankruptcy-rules.pdf) | 2026-10-14 | US Letter, one-sided output |
| Signature block: typewritten name, firm, address, telephone, e-mail, bar number, "s/name" | M | LBR 5005-1(c) (same PDF) | 2026-10-14 | `signature` block; the sample carries the bar number |
| Adversary cover sheet at commencement | M | LBR 7003-1 (same PDF) | 2026-10-14 | **Not generated** (see Known gaps) |
| Complaint in numbered paragraphs, one set of circumstances each | M (via FRCP 10(b), which FRBP 7010 applies) | FRBP 7010 text, above | 2026-10-14 (the FRCP 10(b) text itself was not fetched) | Numbered paragraphs written as escaped markdown (`1\. `) |
| Type size 12 pt | C | LBR 9013-2(a) sets 12 pt for motions and briefs only; complaints have no N.D. Ohio size rule | 2026-10-14 | 12 pt EB Garamond (convention) |
| Margins, double spacing, heading style | C | No N.D. Ohio rule found; chosen from the filed exemplar | - | 1 in margins, 24 pt line pitch, centred bold caps headings |

Not verified in this session: FRBP 7001 (adversary categories) and FRCP 10(b) text. Nothing in the template depends on them beyond the citations above.

## Files

- `typst/main.typ`: entry point; reads `samples/<id>.md` (`--input sample=`).
- `typst/ohnb-adversary-complaint.typ`: template `ohnb-adversary-complaint(meta, body)`.
- `exemplars/`: two filed complaints (Alrachid, debtor counsel; Stone, U.S. Trustee). Sources in `exemplars/SOURCE.md`.
- `samples/INPUT-adversary-complaint.md`: body of the Alrachid complaint (caption, jurisdiction, parties, background, Counts II to VI, prayer, signature). Exhibits are not transcribed.
- `samples/OUTPUT-adversary-complaint.pdf`: our render (5 pages).
- `samples/OVERLAY-adversary-complaint.pdf` and `.txt`: red/blue overlay against the Alrachid exemplar (`tools/overlay.sh` default). The overlay file names follow the tool (`OVERLAY-<id>`), not `<id>-overlay`.

Build and check:

```sh
export PATH="$HOME/tb/bin:$PATH"
cd /work/repo
sh tools/render.sh courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/adversary-complaint samples/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/sixth-circuit/ohio/federal/bankruptcy-northern-district/adversary-complaint adversary-complaint
```

## Gate 2 review (by eye, every page of the current PDF)

Reviewed 2026-10-14 against the Alrachid exemplar pages.

| Page | Finding | Status |
|---|---|---|
| 1 | Caption: court name, debtor, plaintiff and defendant lines, numbers column, centred title. Parties and caption line up; the plaintiff name wraps onto two lines, as in the exemplar. | PASS |
| 2 | Background paragraphs and the count II heading at the foot. Paragraph indent and double spacing match the exemplar's. | PASS |
| 3 | Counts II to IV, headings centred and bold, numbering continuous. | PASS |
| 4 | Counts VI, V; heading size matches body (fixed: headings had been rendered at the typst default size). | FIXED |
| 5 | Prayer for relief, signature block with italic lines (fixed: the signature lines had shown literal asterisks). | FIXED |

## Known gaps

- Length: the sample renders to 5 pages, short of the 8 to 14 page target. The transcription covers the whole body of the exemplar (paragraphs 1 to 39 and the prayer); the exemplar's extra length is the exhibit ledger (pp. 8 to 31), which is not transcribed.
- Adversary cover sheet (LBR 7003-1) is not generated. A court-issued form is required; the PR for this court must carry it separately.
- FRBP 7008(a) requires the jurisdiction allegation to name the bankruptcy case, its number, chapter, district and division. The Alrachid exemplar does not do so in paragraph 1, and the sample transcribes it as filed. The template does not generate that sentence and no check enforces it yet: a tier-1 gap for a future check, to be closed before this doc type is marked done.
- Count I's heading does not appear in the exemplar's text layer. The sample does not invent one.
- Tier 2 (line spacing, caption ")" column, heading style) is judged against the Alrachid and Stone exemplars only by eye; the overlay is not a score. Stone's caption shows the adversary number blank.
- LaTeX and docx engines are not built.
