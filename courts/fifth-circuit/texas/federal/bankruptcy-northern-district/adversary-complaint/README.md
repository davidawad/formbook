# txnb: adversary-complaint

Doc type: **adversary complaint** in the United States Bankruptcy Court for the Northern District of Texas (`txnb`).
Folder: `courts/fifth-circuit/texas/federal/bankruptcy-northern-district/adversary-complaint/`.

BLOCKED: no exemplar. No filed adversary complaint from this court could be found or downloaded (searches listed in `exemplars/SOURCE.md`). The template is built from the rules below; the layout choices the rules leave open are conventions, not checked against a filing.

| Item | Status |
|---|---|
| exemplar | no (`BLOCKED: no exemplar`; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-synthetic-adversary-complaint.md`: a SYNTHETIC test fixture, not a transcription of a filing. It exists only to exercise the template. |
| render | ok on the synthetic fixture: `tools/render.sh` ran with typst 0.15.0, vendored EB Garamond only, no warnings. The PDF is `samples/OUTPUT-synthetic-adversary-complaint.pdf` (kept out of git, see Known gaps). |
| overlay | fail: `tools/overlay.sh` exits 1 with "no exemplar pdf in exemplars". There is nothing to overlay against. |
| pages reviewed | 2 of 2 (synthetic render, every page rendered at 60 dpi and viewed after the last template change) |

## Governing rules

Primary sources, fetched 2026-10-14 (the date this folder was checked):

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Bankr. P. 7001 | Lists the proceedings that are adversary proceedings (recovery of money or property, lien validity, dischargeability, objections to discharge, injunctions, subordination, declaratory judgments, etc.). Fetched from https://www.law.cornell.edu/rules/frbp/rule_7001 on 2026-10-14 (paraphrased; the page's quote limit prevented verbatim quoting). | Scope of the document type only; the template does not check the claim category. |
| Fed. R. Bankr. P. 7003 | "Fed. R. Civ. P. 3 applies in an adversary proceeding." Fetched from https://www.law.cornell.edu/rules/frbp/rule_7003 on 2026-10-14. | Commencement by complaint; no template element. |
| Fed. R. Bankr. P. 7010 | Fed. R. Civ. P. 10 applies to a pleading in an adversary proceeding, except that the caption must substantially conform to Official Form 416. Fetched from https://www.law.cornell.edu/rules/frbp/rule_7010 on 2026-10-14. | Caption: `caption()` is the Form 416 layout (debtor on top, adversary parties under it, chapter, case number and adversary number on the right). |
| Fed. R. Bankr. P. 9004(a)-(b) | Papers must be clearly legible; a document presented for filing must contain a caption with (1) the court's name, (2) the case title, (3) the case number and adversary-proceeding number, (4) a brief designation of the document. Fetched from https://www.law.cornell.edu/rules/frbp/rule_9004 on 2026-10-14. | `court-title()` (court name), `caption()` (case and adversary numbers), `cover()` title line (designation: `title` frontmatter). |
| Fed. R. Civ. P. 10(b) (via Rule 7010) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each body paragraph is numbered; headings and lists are not; `[unnumbered]` marks a paragraph that is not numbered (prayer, jury demand). |
| L.B.R. 7001-1 | An adversary complaint is filed in the division where the related chapter case is pending (unless 28 U.S.C. § 1409 requires otherwise). Local rules revised 12/1/16, fetched from https://www.txnb.uscourts.gov/sites/txnb/files/local_rules/TXNB_Local_Rules_Revised_12.1.16_0.pdf on 2026-10-14. | `division` frontmatter, shown under the court name. |
| L.B.R. 7003-1 | Every adversary proceeding must be accompanied by an adversary proceeding cover sheet. (Same local rules copy.) | Not produced by this template. The cover sheet is a separate filing (see Known gaps). |
| L.B.R. 7007-2(a) | A brief shall be printed, typewritten, or presented in some other legible form. | Applies to briefs (see `motion-brief`), not to a complaint. |

No font, margin or line-spacing rule for complaints was found in the N.D. Tex. bankruptcy local rules (the copy above). The mailing-matrix type rule (10 to 14 pt, Courier, Times Roman, Helvetica or Orator) is for the matrix in a complex Chapter 11 case and is not applied to the complaint.

The local rules copy is dated "Revised 12/1/16". A later revision may exist on the court's site; this run did not find one. Recheck before filing.

## Layout

- Letter size, 1-inch margins, page number centered in the footer.
- Counsel block single-spaced at the top left (the N.D. Tex. bankruptcy local rules do not say where counsel goes; this is a convention).
- Court title centered and bold: UNITED STATES BANKRUPTCY COURT / NORTHERN DISTRICT OF TEXAS / DIVISION.
- Form 416 caption: left column, the debtor ("In re: ..., Debtor.") above the adversary parties ("Plaintiff. v. Defendant."), closed by a rule on the right and bottom; right column, Chapter, Case No., Adversary Proceeding No.
- Title centered and bold.
- Body double-spaced (about 24 pt pitch at 12 pt, a convention). Headings: level 1 centered bold caps; level 2 bold; level 3 bold italic.
- Numbered paragraphs, first line indented 0.5 in. Lists are lettered (a), (b), ... by the template.
- Signature block: "Dated", "Respectfully submitted," the firm, "By: /s/ <signer>", bar number. Kept together on one block.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `caption` (`debtor` optional; `parties` as a list of `{names, designation}`; "v." is inserted between parties), `chapter` (number), `case_number`, `adversary_number`, `division`, `title`, `counsel` (lines), `date`, `signature` (`firm` lines, `signer`, `lines`).
- Body: blank-line-separated chunks. A `#` heading; a list (`1.`, `-`, `*`, `+`); or a paragraph. A paragraph is numbered unless it starts with `[unnumbered]`.
- Not supported: tables, footnotes, raw typst. The template does not number paragraphs in the text itself.

## Known gaps and open choices

1. **No exemplar (blocking for tier 2).** The brief asks for a filed exemplar; none was found (see `exemplars/SOURCE.md`). Every layout choice that the rules leave open (spacing, caption details, counsel block placement, signature block) is unchecked against a filing. Tier 2 cannot be judged. The overlay cannot run.
2. **Synthetic fixture.** `samples/INPUT-synthetic-adversary-complaint.md` is a placeholder test document. It is not an exemplar and is not evidence of how a filing looks. Its render is for template testing only.
3. **Adversary cover sheet (L.B.R. 7003-1) and summons.** Not generated. The cover sheet is a separate filing that must accompany the complaint; the N.D. Tex. form is not in the vendored set, and the Southern District's B104 form found in search is not this court's form. Needs a decision.
4. **Certificates and proposed order.** Not part of a complaint in this template. A certificate of service of the summons may be needed; not in scope.
5. **Font.** No font rule was found for complaints, so EB Garamond at 12 pt (the only vendored font) is used. It is smaller in apparent size than Times New Roman at 12 pt. Whether the court expects a different font is a question for David.
6. **Output PDFs are not committed.** Following the snapshot's rule against PDFs in the repo, `OUTPUT-synthetic-adversary-complaint.pdf` was moved to `/work/artifacts/` after review. Rerun `sh tools/render.sh <this-folder> samples/INPUT-synthetic-adversary-complaint.md` to regenerate it.
7. **Paragraph numbering is not checked for continuity across sections or claim headings.** Numbering is by the template only; a complaint that restarts numbering per claim would need a change.
8. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder is not that shape, and `tools/` is out of scope for this box. The gates were not run.

## Review of the rendered pages (synthetic fixture, final template)

- Page 1: counsel block at top left; court title centered on three lines; Form 416 caption with the debtor, plaintiff, defendant and the chapter / case / adversary numbers on the right; the title centered below. No overlap. Pass.
- Page 1 (continued): the first heading (fixture text) with paragraph 1, the unnumbered line under JURISDICTION AND VENUE, paragraphs 2 and 3 under PARTIES. Paragraph text is line-spaced and spaced between paragraphs. Pass.
- Page 2: paragraph 4 (wraps to a second line), FACTUAL BACKGROUND with paragraphs 5 and 6, the first claim sub-heading with paragraph 7, REQUEST FOR RELIEF with the unnumbered WHEREFORE line, relief items (a) and (b), and the date and signature block. The signature block is not split. Pass.

Earlier template versions overlapped headings and body text (block-wrapped paragraphs with `context`); the final version puts paragraphs in plain content separated by `parbreak()`, which fixed it. Both pages were re-reviewed after that change.

[Formbook index](../../../../../../README.md) | [Court README](../README.md)
