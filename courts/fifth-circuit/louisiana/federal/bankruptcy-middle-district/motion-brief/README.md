# lamb (Bankruptcy Court, M.D. La.): motion with incorporated memorandum

Doc type: **motion** with an incorporated memorandum (FRBP 9013; LR 9013-1 motions, LR 9013-2 memoranda) in the United States Bankruptcy Court for the Middle District of Louisiana (`lamb`).
Folder: `courts/fifth-circuit/louisiana/federal/bankruptcy-middle-district/motion-brief/`.

| Item | Status |
|---|---|
| exemplar | **no**: `BLOCKED: no exemplar`. No filed M.D. La. motion found. Searches are in `exemplars/SOURCE.md`. |
| sample md | `samples/INPUT-motion-brief-sample.md`: **fictitious**, built from the rules, not transcribed from a filing. |
| render | ok: `samples/OUTPUT-motion-brief-sample.pdf`, 5 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | **fail**: `sh tools/overlay.sh` exits 1 with "no exemplar pdf in exemplars" (no filed exemplar exists). No `OVERLAY-*` file is written. |
| pages reviewed | 5 of 5 (every page rendered at 60 dpi and viewed after the last template change) |

File names. The brief asks for `samples/<id>.md`, `samples/<id>.pdf` and `<id>-overlay.pdf`. The repo tools read and write `samples/OUTPUT-<id>.pdf` and `samples/OVERLAY-<id>.pdf/.txt`, and `tools/` is not to be edited, so the tool names are used.

## Governing rules

Primary sources, verified 2026-10-14. The court's rules were read from its own 2022 PDF (https://www.lamb.uscourts.gov/sites/lamb/files/2022_Local_Rules.pdf, amended January 1, 2022). FRBP 9013 was read through a summarizing fetch of https://www.law.cornell.edu/rules/frbp/rule_9013, not the official text, so its quoted words should be checked against the official rule.

| ID | Source | Requirement | Where it lives |
|---|---|---|---|
| LAMB-FORM-001 | LR 5005-2(a) | 8½ × 11 inches. | `page` in `typst/lamb-motion-brief.typ`. |
| LAMB-FORM-002 | LR 5005-2(b) | 12-point font, double-spaced, for all documents except pro se parties. | `type-size = 12pt` everywhere, headings and footer included. |
| LAMB-FORM-003 | LR 5005-2(b) | Double-spaced. | `body-leading = 0.7em`, baseline pitch 24.06 pt on body pages (`pdftotext -bbox-layout`). Block quotations and headings are single-spaced. |
| LAMB-FORM-004 | FRBP 9004(a) | Clearly legible. | Vendored EB Garamond; `fallback: false`. |
| LAMB-CAP-001 | FRBP 7010 (adversary proceeding caption, Form 416) and FRBP 9004 as applied to motions in a main case | Caption with court, parties and numbers. | `caption(meta)`. An adversary caption is used when `plaintiff` is given; a main-case caption otherwise. |
| LAMB-MOT-001 | FRBP 9013(b) | "A motion must state its grounds with particularity and set forth the relief or order requested." (from the summarizing fetch above) | Author writes the grounds in the body; the `relief` field is printed in the notice. The template requires `relief` and `title`. |
| LAMB-MOT-002 | LR 9013-1(a) | Every motion and proposed order includes the filer's current, direct e-mail address, a current operable telephone number, and physical address. | `contact` frontmatter (`email`, `phone`, `address`), printed in the signature block. The template panics if any is missing. |
| LAMB-MOT-003 | LR 9013-1(b)(2)(i)-(iii) | The notice states the motion's title, concisely describes its content and relief, and gives the date, time and place of the hearing. It states that an objection or response is due no later than eight days before the hearing, and must be served on the mover or its counsel; it may not say the hearing will be held only if an opposition is filed. | `notice(meta)`. The objection sentence follows the rule; the hearing details come from the `hearing` frontmatter. The template does not use the prohibited "only if" wording. |
| LAMB-MOT-004 | LR 9013-1(e), LR 9013-5(a)-(c) | The mover submits a proposed order by e-mail to orders@lamb.uscourts.gov, in Microsoft Word with 12-point font; the caption of an order shows no numbers other than the case and adversary numbers; the introductory phrase identifies the mover and the motion. | **Not generated**: the proposed order is a separate Word document. |
| LAMB-MOT-005 | LR 9013-2 | If the motion needs a memorandum, the mover files it with the motion; it is double-spaced, paginated, and does not exceed fifteen pages, excluding attachments, without leave of court. | Body is double-spaced; footer page numbers on every page. The 15-page limit is **not checked by the template**: the page count is the author's to check (see the review section). |
| LAMB-MOT-006 | LR 9013-4(a)-(b) | A certificate of service is filed separately, in CM/ECF, identifying the documents served, the persons served by name and address, and the date and method; a collective designation such as "all interested parties" does not comply. Service goes to the trustee, the debtor, debtor's counsel and the U.S. Trustee. | **Not generated**: separate filing. The template does not print one. |

Not checked by the template: the grounds stated in the body, the authorities cited, the defendants' or the mover's standing, the hearing-date rules of LR 9013-3 (motion-day scheduling), and the requirement that a motion be in writing (FRBP 9013(a)).

## Layout and template

- Caption: as in the complaint template (court name centred; two-column caption; right column case, chapter and adversary numbers).
- Title: centred, bold capitals, from `title`.
- Notice of motion and opportunity for hearing (LR 9013-1(b)(2)): a centred heading, then three paragraphs: the filing and relief; the hearing date, time and place; the objection deadline. The template prints this on page 1 before the body.
- Body: the whole markdown body rendered by cmarker. `#` headings are centred bold capitals; `##` bold; `###` bold italic. Paragraphs are double-spaced with a first-line indent. Block quotations are single-spaced and indented 0.5 in on each side. Footnotes are 12 pt (the template sets the footnote entry size).
- Signature: `Dated:` on the left; on the right, `Respectfully submitted,`, the signer as `/s/`, the counsel lines in italic, then the address, telephone and e-mail from `contact`.
- Not generated: proposed order (LR 9013-5, separate Word file); certificate of service (LR 9013-4, separate filing); a table of contents or table of authorities (LR 9013-2 does not require one; add if the court or a judge asks).

## Frontmatter (schema)

| Field | Required | Feeds |
|---|---|---|
| `title` | yes | Title under the caption; PDF title; notice. |
| `relief` | yes | Notice: "The motion seeks ..." (ends with a full stop). |
| `hearing` | yes | `date`, `time`, `place`: the notice's hearing sentence. |
| `debtor` | yes | "In re:" line. |
| `case_no`, `chapter` | yes | Case number and chapter. |
| `adv_no` | no | "Adversary Proceeding No." (shown when given). |
| `plaintiff`, `defendants` | when `plaintiff` is given | Adversary caption parties. |
| `date` | yes | "Dated:" line. |
| `signature` | yes | `signer` and `lines` (counsel block). |
| `contact` | yes | `email`, `phone`, `address`, printed in the signature block (LR 9013-1(a)). |

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
D=courts/fifth-circuit/louisiana/federal/bankruptcy-middle-district/motion-brief
sh tools/render.sh $D samples/INPUT-motion-brief-sample.md        # -> samples/OUTPUT-motion-brief-sample.pdf
sh tools/overlay.sh $D motion-brief-sample                  # fails: no exemplar pdf
```

Render: `pdfinfo` reports 5 pages, us-letter. `pdffonts`: EBGaramond-Regular, -Bold and -Italic only, all embedded. `render.sh` exits 0 with no typst output.

Pitch: 24.06 pt on the body lines of page 2.

## Visual review (Gate 2 record, 5 pages, 60 dpi, every page viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Caption, title, notice of motion (three paragraphs), first paragraph of the motion | OK after two fixes: the notice sentences had run together (now separate paragraphs), and the heading sizes were larger than body (typst's built-in heading size is now overridden). |
| 2 | Relief requested, "Memorandum in Support", Introduction, Background | OK. |
| 3 | Argument A and B | OK. Heading wraps across two lines with the leading kept. |
| 4 | Argument B end, C, D, E | OK. |
| 5 | End of E, Conclusion, signature block with contact details | OK. |

## Known gaps and open choices

1. **No exemplar** (`BLOCKED: no exemplar`). The layout of the notice, the memorandum's headings and the signature block come from the rules, not from a filing.
2. **Length.** 5 pages. The 8-14 page target applies only where an exemplar is that long; there is none. The memorandum is well under the 15-page limit of LR 9013-2. The 15-page count is not checked by the template.
3. **The notice is printed by the template.** The rule requires the content of the notice, not a particular layout. The text of the objection sentence follows LR 9013-1(b)(2)(ii) as read from the 2022 rules.
4. **Font.** EB Garamond at 12 pt, not Times New Roman. The rules name no typeface; see the complaint README for the same note.
5. **FRBP 9013 wording.** Quoted from a summarizing fetch (see Governing rules). Check the official text before this template is treated as final.
6. **Court's current rules.** Read from the 2022 PDF. Standing Order 2024-2 amends LR 4001-1(f) and refers to LR 9013-5. Other amendments after 2022 were not checked because the court's site is blocked from this box.
7. **No table of contents or authorities.** Not required by LR 9013-2; a brief over fifteen pages would need leave and may need them.
8. **Overlay.** Cannot run without an exemplar. `OVERLAY-*` is not produced.
9. **Not exercised by the sample.** Block quotations and footnotes are styled in the template (12 pt, single-spaced quotations) but the sample has neither, so those styles are unchecked on a rendered page.
