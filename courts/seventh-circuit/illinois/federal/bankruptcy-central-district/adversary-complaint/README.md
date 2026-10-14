# ilcb: adversary complaint (U.S. Bankruptcy Court, C.D. Illinois)

Doc type: the complaint that commences an adversary proceeding (FRBP 7001, 7003; ILCB LR 7003-1). Court alias `ilcb`. Court-level status is in `../../court.json` and is not changed here.

## Layout

| Path | What |
|---|---|
| `exemplars/` | Two filed complaints from different filers, with `SOURCE.md` (URLs, filers, dates). |
| `typst/ilcb-adversary-complaint.typ` | The template: `ilcb-adversary-complaint(meta, md)`. Content-agnostic; each number is a named parameter at the top. |
| `typst/main.typ` | Entry point; reads the sample named by `--input sample=...`. |
| `samples/INPUT-i80-adversary-complaint.md` | Transcribed from the first exemplar (I80 Equipment, First Midwest Bank), with the FRBP 7008 consent sentence added (see Gaps). |
| `samples/OUTPUT-i80-adversary-complaint.pdf` | Our render (10 pages). |
| `samples/OVERLAY-i80-adversary-complaint.pdf`, `.txt` | Red/blue overlay against the first exemplar, and the page map. |

File names follow the repo's role convention (`INPUT-`, `OUTPUT-`, `OVERLAY-`) because `tools/render.sh` and `tools/overlay.sh` read and write those names. The brief's `<id>.md` / `<id>-overlay.pdf` names were not used for that reason.

Build (from the repo root, with the toolchain on PATH):

```sh
sh tools/render.sh courts/seventh-circuit/illinois/federal/bankruptcy-central-district/adversary-complaint samples/INPUT-i80-adversary-complaint.md
sh tools/overlay.sh courts/seventh-circuit/illinois/federal/bankruptcy-central-district/adversary-complaint i80-adversary-complaint courts/seventh-circuit/illinois/federal/bankruptcy-central-district/adversary-complaint/exemplars/FILED-EXAMPLE-i80-first-midwest-18-08003-adversary-complaint.pdf
```

The overlay takes the exemplar as an explicit argument, because its default (the alphabetically first exemplar) is the 3-page Erickson complaint, not the 9-page I80 complaint the sample comes from.

## Governing rules

Verified 2026-10-14. "M" is mandated by a rule, "C" is the court's own convention or guidance, "A" is the filer's responsibility, "T" is a project choice.

| ID | Kind | Requirement | Source (URL, rule, date verified) | How the template handles it |
|---|---|---|---|---|
| ILCB-7010-1 | M | Caption: name of court, title of proceeding, adversary number, designation as a complaint. Civil Rule 10 applies; the caption must substantially conform to Form 416. | FRBP 7010, https://www.law.cornell.edu/rules/frbp/rule_7010 (verified 2026-10-14) | Court name is fixed in the template; parties, debtor case number, chapter and adversary number come from the frontmatter `caption`. |
| ILCB-9004-1 | M | Legible; caption contents (court, title, case number, adversary number, designation). | FRBP 9004(a)-(b), https://www.law.cornell.edu/rules/frbp/rule_9004 (verified 2026-10-14). The Cornell page shows only (a) and (b); no subdivision (c) on paper size was retrieved, see Gaps. | Typeset in a single legible face; caption as above. |
| ILCB-7008-1 | M | Pleader must state whether it does or does not consent to the entry of final orders or judgment by the bankruptcy court. Civil Rule 8 applies, so the jurisdiction statement must identify the case name, number and chapter, and the district and division. | FRBP 7008, https://www.law.cornell.edu/rules/frbp/rule_7008 (verified 2026-10-14) | Author text in the sample (paragraph 2). The template does not generate it; see Gaps. |
| ILCB-10-1 | M | Numbered paragraphs, each limited as far as practicable to a single set of circumstances (Civil Rule 10(b), applied by FRBP 7010). | FRBP 7010 (above); Fed. R. Civ. P. 10(b) | Paragraph numbers are typed by the author (escaped `1\.` so they stay paragraphs); first-line indent. |
| ILCB-7003-1 | M (local) | Complaint is docketed under the event that matches the nature of the suit. | ILCB Local Rules, https://www.ilcb.uscourts.gov/sites/ilcb/files/ILCB%20Local%20Rules%2010.1.2024.pdf (effective Oct. 1, 2024; verified 2026-10-14) | Not a layout rule. Filer responsibility (A). |
| ILCB-SIG-1 | C | Electronic signature: "/s/" followed by the typed name. | Bankruptcy Practice Guide, "Signature Requirements" section, https://www.ilcb.uscourts.gov/sites/ilcb/files/Bankr%20Practice%20Guide%2012.1.25%20rule%20restyling.pdf (Dec. 1, 2025; verified 2026-10-14) | `By: /s/ <signer>` from `signature.signer`. |
| ILCB-SVC-1 | A | Summons issued by the clerk and served under FRBP 7004; proof of service is filed as "Summons Service Executed" (LR 7004-1). | ILCB LR 7004-1 (above) | Not part of the complaint. No certificate is generated for the complaint. |
| ILCB-TYPE-1 | T | Typography: 13 pt EB Garamond (vendored serif), double spacing, 1 in margins, centered page number. No CDIL typography rule exists; see Gaps. | Tier 2, from the three exemplars (measured: 27.6 pt line pitch on body pages; Times or Arial; 1 in margins) | `type-size`, `body-leading`, `page-margin` at the top of the template. |

## Markdown contract

A sample is one `.md` file: YAML frontmatter, then the body.

| Field | Required | Feeds |
|---|---|---|
| `caption.left` | yes | list of party lines, one per line, in the left column (inline markdown allowed). Use ` ` for indentation. |
| `caption.right` | yes | list of case lines, aligned by row with `left` (bankruptcy case number, chapter, adversary number). |
| `document_title` | yes | the title, centered and bold. Wraps naturally; no line breaks. |
| `dated` | no | "Dated: ..." line above the signature block. |
| `signature.firm`, `signature.signer` | yes | the firm (bold), and the typed name after "By: /s/". |
| `signature.counsel` | no | counsel of record lines at the left margin under the signature. |

Body: `#` is a centered bold section heading (INTRODUCTION, COUNTS, REQUEST FOR RELIEF). `##` is a bold heading at the left; `###` bold italic; `####` italic. Heading numbers are typed. Escape paragraph numbers (`1\.`). Footnotes use `[^key]` with a definition anywhere in the file (the template carries definitions to every render call). Sub-paragraphs such as `(i)` are plain paragraphs. The signature block is kept with the last paragraph.

## Overlay

`samples/OVERLAY-i80-adversary-complaint.pdf`: red is our render, blue is the filed I80 complaint, black is where they agree. The page map (`.txt`) pairs our pages to the filed pages by shared words: our pages 1 to 4 pair with filed pages 1 to 4; our page 5 pairs with filed page 4 by word overlap (the pairing is the tool's rule; the page-by-page review did not find a content gap there); our pages 6 to 10 pair with filed pages 5 to 9. Word overlap runs from 30.5% (our page 4) to 83.9% (our page 7). The differences the overlay shows are tier 2 or tier 3, not tier 1: the typeface (EB Garamond against Helvetica and Liberation in the filed copy), the sub-paragraph layout (ours first-line indented, theirs hanging), the footnote text size, and the `Dated:` line wording. The filed copy also carries the CM/ECF header ("Case 18-08003 Doc 1 Filed ...") that the court system adds on filing, which the template does not generate.

## Pages reviewed

Final render, 2026-10-14, every page viewed at 60 dpi (`pdftoppm -r 60`) after the last change:

- pages 1 to 10: reviewed. Page 1: caption and title on the first page, no cover. Pages 2 to 9: numbered paragraphs, centered and left headings, counts, sub-paragraphs, footnote 1 on page 3. Page 10: the last prayer item kept with the signature and counsel block.

Defects found and fixed during review:

1. "§§" split across lines on page 2 (the no-break rule matched a single section sign). Fixed: the rule now covers `§§`.
2. The signature block and the last paragraph separated when a footnote definition ended the file. Fixed: footnote definitions travel with every render call, and the keep-with-signature logic looks at the body, not the definitions.

Pages reviewed: 10 of 10.

## Gaps

- No CDIL typography rule exists (the local rules and FRBP 9004(a) say only "legible"). The face, size, spacing and margins are tier 2, from the three exemplars. Times New Roman 12 pt (the Erickson and Walmart exemplars) is the most common face, but the only serif face vendored here is EB Garamond, so the template uses EB Garamond 13 pt, sized to match the x-height of 12 pt Times. This is a substitution, not a rule.
- FRBP 7008 consent sentence: the template does not generate it. The sample adds the sentence to paragraph 2 ("Plaintiff consents to the entry of final orders or judgment by the bankruptcy court."); the I80 exemplar did not have it. Filers must state consent or non-consent in every complaint.
- Paper size: FRBP 9004(c) was not retrieved (see ILCB-9004-1). The template uses US Letter, the size of every exemplar. The Practice Guide's 8.5 x 11 rule is for proposed orders, not complaints.
- Exhibits, the summons, and the civil cover sheet are not templated. The exemplars attach exhibits by reference only.
- The CM/ECF header ("Case ... Doc 1 Filed ...") is added by the court system, not by the template.
- Only one exemplar was used for the overlay. The second (Erickson, 3 pages) was checked by reading its text for the caption and signature; it was not overlaid.
