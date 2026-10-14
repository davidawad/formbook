# wvsd: complaint

Doc type: **complaint** in the United States District Court for the Southern District of West Virginia (`wvsd`).
Folder: `courts/fourth-circuit/west-virginia/federal/southern-district/complaint/`.

| Item | Status |
|---|---|
| exemplar | yes, with limits: `exemplars/FILED-EXAMPLE-castro-2-23-cv-00598-complaint.pdf` (35 pages, **image-only**, filed **pro se**; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-castro-complaint.md` (a portion: caption, opening, Sections I and II, Injunctive Relief, signature, verification; see Known gaps) |
| render | ok: `samples/OUTPUT-castro-complaint.pdf`, 9 pages (caption page, table of contents, body numbered 1 to 6 with the signature, verification), typst 0.15.0, vendored EB Garamond only, no warnings (re-rendered 2026-10-14) |
| overlay | ran 2026-10-14, produced `samples/OVERLAY-castro-complaint.pdf` and `.txt`; **not a meaningful comparison**: the exemplar has no text layer, so every page pairs at 0 to 2.6% word overlap (see Overlay). The exemplar was restored from the URL in `exemplars/SOURCE.md` (35 pages, sha256 `a84eea9daf59bafce0ed8d23b8bb33771f6f79f0bee02deccaf1de4c95ee62f0`) because it was missing from the snapshot |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed on 2026-10-14) |

File names: the tools write `OUTPUT-<id>.pdf` and `OVERLAY-<id>.pdf/.txt`, so those names are used (see the motion-brief README for the same note).

## Governing rules

The local rules set no layout rule for a complaint: LR Civ P 7.1(a)(3) and (4) (paper, spacing, margins, typeface) apply to *memoranda*. The complaint's form therefore comes from the Federal Rules, and the layout is the memorandum template's (EB Garamond 12 pt, double-spaced, 1-inch margins) so that every doc type of this court has one look. That is a choice, recorded here, not a rule.

| Rule | Requirement | Where it is in the template |
|---|---|---|
| Fed. R. Civ. P. 8(a) | A short and plain statement of the grounds for jurisdiction, of the claim, and a demand for the relief sought. | Author content (the sample's Claim for Relief sections, the Demand for Relief). The template does not check the wording. |
| Fed. R. Civ. P. 10(a) | Caption with the court's name, a title, a file number and a Rule 7(a) designation. | `caption` (court title, parties, "Civil Action No.", judge if given) and `brief_title`. |
| Fed. R. Civ. P. 10(b) | Claims in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Every body paragraph is numbered by the template (1, 2, ...); headings, lists and quotations are not numbered. |
| LR Civ P 3.4(a) | A civil docket cover sheet, in the clerk's form, must be completed and submitted with any complaint, citing the statute under which the action is filed. | Not produced by this template (a separate form; see Known gaps). |

Sources and dates:
- Fed. R. Civ. P. 8(a), 10(a)-(b): https://www.law.cornell.edu/rules/frcp/rule_8 and https://www.law.cornell.edu/rules/frcp/rule_10, text fetched 2026-10-14.
- LR Civ P 3.4(a): *Local Rules of Procedure, Southern District of West Virginia*, amended June 8, 2017, https://www.wvsd.uscourts.gov/sites/wvsd/files/LocalRulesofProcedure-June2017.pdf, fetched 2026-10-14. The June 8, 2017 version is the latest I found; see the motion-brief README for the 2025 advisory-committee review.

## Layout

- Caption page: the court title (three centered bold lines; the division from `division`), the caption (parties with their addresses where the filing gives them, a column of ")" marks, and the case number at the right), and the title in bold capitals. The caption page has no page number.
- Table of contents (when `toc: true`): a page numbered "i", generated from the sample's headings to the depth in `toc_depth` (default 2). The filed table of contents is not reproduced.
- Body: numbered from 1, double-spaced. Lead-in paragraphs before the body are unnumbered; the first is flush left (the address to the court), the rest indented. Each body paragraph is numbered with the number at 0.5 inch.
- Headings, all in the body size: level 1 I. (bold); level 2 A. (bold); level 3 1. (bold); level 4 (i); level 5 (1); level 6 (A). The numbers are generated.
- Signature block after the body: the date at the left, the signature lines at the right, kept together.
- Verification (when given): on its own page, under 28 U.S.C. § 1746: a heading, the declaration lead-in, numbered items, "Executed on [date]", and the signature lines.

## Markdown contract (for samples)

- YAML frontmatter, then the body. Frontmatter fields: `case_number`, `division`, `judge` (optional), `caption` (list of sides: `names` as lines, `designation`, and an optional `lead`, which defaults to "v." between sides and is "" for none), `civil_action`, `brief_title`, `lead_in` (list of unnumbered paragraphs), `toc` (true or false), `toc_depth`, `date`, `signature` (list of single-spaced lines; "" is a blank line), and optionally `verification` (`heading`, `lead`, `items`, `executed`, `signature`).
- Body: `#` through `######` for the headings (no numbers typed); a paragraph is an allegation and is numbered; list items, enumerations and block quotations are not numbered; footnotes `text[^1]` with `[^1]: ...` definitions.
- Not supported: tables, raw typst.

## Gate 2 review (every page, 60 dpi, final template)

- p.1 (caption): court title, caption with the addresses on one line each (the party column is 3.7 inches wide so no address wraps), the ")" column aligned with each caption line, the case number at right, the title. Pass.
- p.2 (table of contents): the generated entries and page numbers for the sample's headings; page numbered "i". Pass.
- p.3 (body 1): the lead-in ("TO THE HONORABLE COURT:" flush left; the opening paragraph indented), the headings I. to II. in body size, numbered paragraphs 1 to 7. Pass.
- p.4 (body 2): paragraphs 8 to 13, numbers at 0.5 inch, wrapped lines at the margin. Pass.
- p.5 (body 3): paragraphs 14 to 18; heading E. and II. in body size. Pass.
- p.6 (body 4): heading A.; paragraphs 19 to 21 (21 begins at the foot) with footnotes 1 to 6 at 12 pt, single-spaced. Pass.
- p.7 (body 5): paragraphs 22 to 24 with footnotes 7 to 9; heading B. Pass.
- p.8 (body 6): heading 1. and 2. (the template's numbers, see Known gaps), paragraphs 25 to 29, the signature block (date at left; "Respectfully submitted," and the signature lines at right) on one page. Pass.
- p.9 (verification): heading, the declaration lead-in, items 1 to 4, "Executed on September 4, 2023.", signature lines. Pass.

The first render showed the heading text and numbers larger than the body and the caption addresses wrapping (the ")" marks then fell out of line with the text); both are fixed. The lead-in paragraph was not indented because typst does not indent the first paragraph of a block unless `all: true` is set; fixed.

## Overlay

`samples/OVERLAY-castro-complaint.pdf` ran and wrote its page map. It is **not a comparison**: the exemplar's text layer holds only the 13-word ECF header per page, so `tools/overlay.sh` finds no matching filed page (0.0 to 2.6% word overlap on every page). The page-map numbers are meaningless here. A meaningful overlay needs an OCR'd copy of the exemplar; OCR is not installed in this environment, and the exemplar is not altered.

## Known gaps and open choices

1. **Exemplar is image-only and pro se.** The filing has no text layer, so the sample was transcribed by reading the 90-dpi page images. A reading error in small type is possible; the text is as read, not verified against a text layer. The filer is an unrepresented plaintiff, so the caption, signature and verification formats are a pro se filer's, not a counsel's. EVAL-LOOP's tier-2 rule (2 or 3 filers from different filers) is not met.
2. **Sample is a portion.** Paragraphs 23 to 106 of the filing are omitted; paragraphs 107 to 113 are included. The template numbers the sample's paragraphs 1 to 29, so the filed paragraph numbers after paragraph 22 differ from those shown.
3. **Headings after the omitted part.** The filed Injunctive Relief section is "C." (after a Section II "B." that the sample omits), with four sub-headings (1) to (4). The sample has only the two sub-headings for (3) and (4), which the template numbers "1." and "2.", and its Injunctive Relief section is "B.". The filed numbering is not reproduced.
4. **Table of contents is generated.** The filed table of contents runs to the depth of its headings (about 4 pages); the template's TOC is generated from the sample's headings only.
5. **Caption addresses.** The filed caption gives the parties' addresses; the template prints whatever `names` lines the sample gives. A filing without addresses prints none.
6. **Not produced:** the civil docket cover sheet (LR Civ P 3.4(a)); a summons; a disclosure statement. The verification is included because the filed complaint has one; a complaint need not be verified.
7. **Typeface.** EB Garamond, as in the memorandum template (see that README). No local rule names a face for a complaint, so no substitute is used; the memorandum's rule (LR Civ P 7.1(a)(4)) requires no particular face either, so EB Garamond is kept as a choice, not a court requirement.
8. **Check scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md` at the court root, and this doc-type folder is not that shape. The brief forbids editing `tools/`, so the gates were not run.

## Searches tried (exemplar)

- CourtListener search API, `court=wvsd`, `type=r`, for complaints with stored PDFs (`filepath_local`): none found for a complaint other than Castro (ECF 1, image-only). The recap-documents endpoint requires authentication.
- Complaints listed without stored PDFs: Simmons v. EIDP (2:26-cv-00655, ECF 1), Polan v. Beane (2:26-cv-00644, ECF 1), Alward v. FCI Beckley Warden (5:26-cv-00123, ECF 1).
- Clearinghouse (clearinghouse.net) listed text-based complaints for this court (EEOC v. Wrightway Ready-Mix, 2:25-cv-00711; Wiley v. Kennedy, 2:25-cv-00227; Rose v. Jividen, 5:22-cv-00405; Baxley v. Jividen, 3:18-cv-01526). Clearinghouse returned HTTP 403 to every request (with and without a browser user agent), so none could be downloaded.
- WebSearch for S.D. W. Va. complaints (several phrasings, including "Civil Action No." and "Jury Trial Demanded"): the results were Clearinghouse listings and West Virginia state-court forms only.
- Castro v. Warner, 2:23-cv-00598: docs 1, 2, 44 to 48 fetched from `storage.courtlistener.com/recap/`. Doc 1 is the only complaint in the set; it is image-only.
