# nmb: motion-brief

Doc type: **motion with memorandum** (FRBP 9013 motion in an adversary proceeding, or a contested matter) in the United States Bankruptcy Court for the District of New Mexico (`nmb`, Tenth Circuit).
Folder: `courts/tenth-circuit/new-mexico/federal/bankruptcy-district/motion-brief/`.

**BLOCKED: no exemplar.** No public, text-layer, filed motion-with-memorandum from this court was found. The template is built from the rules and tested on a clearly fictional sample. Tier 2 (convention) is not judged against any filed exemplar.

| Item | Status |
|---|---|
| exemplar | **no** (`BLOCKED: no exemplar`; see `exemplars/SOURCE.md` and "Searches tried" below) |
| sample md | `samples/INPUT-fictional-motion-brief.md`: FICTIONAL, structure test only (placeholder names, placeholder text). Not a transcription. |
| render | ok (re-run 2026-10-14 with `sh tools/render.sh <dir> samples/INPUT-fictional-motion-brief.md`): `samples/OUTPUT-fictional-motion-brief.pdf`, 3 pages, letter, EB Garamond only, no typst warnings |
| overlay | **fail**: `sh tools/overlay.sh <dir> fictional-motion-brief` exits 1, "no exemplar pdf in .../exemplars". Expected: there is no filed exemplar to overlay. |
| pages reviewed | 3 of 3 (every page of the current render at 60 dpi, viewed) |
| check.sh / selftest | not run (same reason as the adversary-complaint folder) |

## Governing rules

Primary sources fetched 2026-10-14.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| NM LBR 9013-1(a) (Bankr. D.N.M. local rules, 2023 PDF, see `../adversary-complaint/README.md` for the URL) | The title of a motion describes the relief sought. | Frontmatter `title` (`DEFENDANT’S MOTION TO DISMISS ADVERSARY COMPLAINT AND MEMORANDUM IN SUPPORT` in the sample; the sample's title is fictional). |
| NM LBR 9013-1(b) | An opposed motion says so; if concurrence was not obtained, the motion recites the attempts made. | Author content: the sample's paragraph 3 recites an attempt. Not a template check. |
| NM LBR 9013-1(d) | For opposed motions and motions requiring notice, the movant files and serves a notice that complies with NM LBR 9004-1; the objection deadline is 21 days from service unless ordered otherwise. | Not in the template. The notice is a separate paper; it is not generated here. |
| NM LBR 9013-1(i) | Briefs or supporting points need not be submitted with a motion, unless the court orders otherwise or NM LBR 7056-1 applies. | The memorandum section is written by the author in the sample. Its presence is a choice, not a rule. |
| NM LBR 7007-1 (adversary proceedings) | All motions in adversary proceedings are served; responses are due 21 days after service; optional replies 14 days after the response; briefs are optional unless the court orders otherwise. | Not a template check. |
| NM LBR 7007-2 | Sur-replies need leave of the court. | Not a template item. |
| NM LBR 9013-1(j) | A certificate of service is filed for all motions and notices, within a reasonable time; it may be part of the motion. | `certificate` frontmatter block, printed as "CERTIFICATE OF SERVICE" after the signature. |
| NM LBR 9011-1(a) | Name, address, telephone and e-mail below the signature line. | `signature()`; the `email` line prints from the frontmatter. |
| NM LBR 9004-2 | Case number format with chapter, judge and location initials. | `case_number` frontmatter. |
| Fed. R. Bankr. P. 9004(a), (b) | Legible; caption with the court's name, the title, the case and adversary numbers, and a designation of the paper. | Same caption as the adversary complaint (`caption()`). |

Not fetched in this pass (cited from memory; check before use): FRBP 9013 (motions state with particularity the grounds and the relief sought), FRBP 7012 (adversary-proceeding motion practice and consent statement), FRBP 9014. The template contains no assertion that depends on them.

## Layout

Identical to `../adversary-complaint/` (same caption, numbering, quotation, sub-item, footnote, footer and signature code). Differences:
- Lead-in paragraph and prayer are frontmatter, as in the complaint.
- Headings `#`, `##`, `###` are centered bold; the sample uses `# Motion`, `# Memorandum`, `## Background`, `### A. ...`.
- The `certificate` block is printed after the signature block as a centered "CERTIFICATE OF SERVICE" heading and a paragraph.

## Markdown contract (for samples)

Same as `../adversary-complaint/README.md`, plus the `certificate` frontmatter string.

## Known gaps and open choices

1. **No exemplar.** Nothing in this court is filed here to compare with. Every layout choice is a convention (C) or a choice the rules leave open, and nothing has been judged against a filer. This is why the overlay fails.
2. **Typeface, margins, page size.** Same open choices as the complaint (see `../adversary-complaint/README.md`, Known gaps 1 and 2).
3. **Memorandum format.** Whether a court-ordered brief is needed depends on the judge and the motion (NM LBR 7007-1, 9013-1(i)). The template supports a memorandum section, not a required length.
4. **Notice and objection deadline.** NM LBR 9013-1(d) requires a separate notice with the 21-day objection deadline for opposed motions. The template does not generate it.
5. **Sample is fictional.** `samples/INPUT-fictional-motion-brief.md` is structure-only: placeholder names, placeholder paragraphs, a placeholder footnote, and a placeholder e-mail. It exists so the template can be rendered and looked at. It is not evidence of the court's format.
6. **Footnote and certificate.** The certificate wording in the sample is a placeholder, not a form.

## Searches tried (2026-10-14)

Web search (standard and extended):
- "Bankruptcy Court for the District of New Mexico" adversary proceeding complaint pdf
- courtlistener nmb adversary complaint "District of New Mexico" bankruptcy 7001 recap document
- New Mexico bankruptcy adversary proceeding complaint filed pdf "Adv. Pro. No." "Bankr. D.N.M." (extended)
- govinfo USCOURTS-nmb adversary complaint pdf (extended)
- "Bankr. D.N.M." motion to dismiss adversary 2024 pdf memorandum (standard; returned only court opinions)
- "District of New Mexico" bankruptcy adversary "motion to dismiss" memorandum brief Rule 7012 (standard; returned only court opinions from 2004 to 2015 and a 2026 opinion)
- NM bankruptcy local rules PDF with formatting terms (extended; returned the local rules only)

CourtListener REST API (`api/rest/v4/search`, `type=r`, `court=nmb`), read through WebFetch:
- "adversary complaint": returned adversary dockets with complaints; the web page (`/?q=` form) returned HTTP 403.
- "motion to dismiss" memorandum adversary: one filing (Montoya v. Goldstein, Doc 9, brief in support of a motion to dismiss, 2020-07-06). No local PDF.
- "memorandum in support" or "motion for summary judgment" adversary: several motions with no local PDF (Quality Sleep Solutions 18-01035 Docs 20, 29, 36; Johnson v. Marker 24-01003 Doc 16, 2024-04-09; Pidcock v. McCune 21-01013 Docs 168, 185, 190). Only orders and opinions had local PDFs.

Direct storage downloads (`storage.courtlistener.com/recap/gov.uscourts.nmb.<id>/...`):
- Montoya v. Goldstein (168297) Docs 8 and 9: not PDFs (an XML error page).
- Johnson v. Marker (173562) Docs 6 and 16: not PDFs (an XML error page).

Second pass (2026-10-14, same day, brief `fb-595.32.16`):
- WebSearch, standard and extended (about 14 queries): "Bankr. D.N.M." / "Bankruptcy Court for the District of New Mexico" with "memorandum in support", "memorandum brief", "motion to dismiss", "motion for summary judgment", "Adv. Pro. No."; Justia, DocketBird, PacerMonitor, Inforuptcy, Scribd, DocumentCloud, Casetext and Tenth Circuit appendix terms; Vaughan Co. Realtors (Wagner trustee) adversary briefs. Results were court opinions, local rules, or other districts' papers only.
- GovInfo `USCOURTS-nmb-1_*` packages downloaded and read (text layer, `pdftotext`): 04-ap-01159-0 (30 pp, carries a "PACER Cover Sheet for Electronically Filed Documents", but the filed document is the court's Memorandum Opinion, Doc 36), 06-ap-01078-0, 08-ap-01065-0, 09-ap-01093-0, 10-ap-01166-0, 10-ap-01200-1, 11-ap-01227-0, 12-ap-01110-1, 12-bk-12457-1, 13-ap-01069-0, 20-ap-01070-7, 24-bk-10185-0. All are opinions; none includes a party's motion or memorandum.
- CourtListener REST API (`api/rest/v4/search`, `type=r`, `court=nmb`): HTTP 429, `Retry-After` about 6.3 hours, so this pass could not query it again.
- inforuptcy.com docket page: HTTP 403.

What would settle it: a PACER copy (or a CourtListener RECAP upload by a user with access) of one of the motions above, with a text layer, saved as `exemplars/FILED-EXAMPLE-<case>-<docket>-motion-brief.pdf` and recorded in `exemplars/SOURCE.md`. Then re-run the overlay.
