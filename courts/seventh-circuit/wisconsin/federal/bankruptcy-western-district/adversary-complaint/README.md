# W.D. Wis. Bankruptcy Court: adversary complaint

Doc type: **adversary complaint** (the debtor's complaint commencing an adversary proceeding, here under Fed. R. Bankr. P. 7001(2): determining the validity of a claimed lien). Court: United States Bankruptcy Court, Western District of Wisconsin (`wiwb`). Folder: `courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district/adversary-complaint/`.

Status: exemplar=yes (one filed exemplar, from 2015), render=ok, overlay=ok, pages reviewed 3 of 3. Nothing here sets `court.json` status.

## Governing rules

Rule text was read from the Legal Information Institute (LII) pages on 2026-10-14 (LII shows the 2024 restyled text). Quotations are short; the rest is paraphrase.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| WIWB-AP-001 | Fed. R. Bankr. P. 7001 | An adversary proceeding is commenced by a complaint. Category (2) is a proceeding to determine the validity, priority or extent of a lien. Cited in the title, as the exemplar does. Rule text not fetched; the category is the sample's, not the template's. | `title` (frontmatter); caption title line |
| WIWB-AP-002 | Fed. R. Bankr. P. 7008(a) | The complaint states the grounds for jurisdiction, and whether the pleader consents to entry of final orders or judgment by the bankruptcy court. Since the 2016 amendment, the core/non-core allegation is no longer required. | Template **asserts** a `# JURISDICTION` heading and the word "consent" in the body (fails the build otherwise). |
| WIWB-AP-003 | Fed. R. Bankr. P. 7010 | Fed. R. Civ. P. 10 applies to adversary pleadings; the caption must substantially conform to Official Form 416 (the caption series). | `court-title()`, `caption()` |
| WIWB-AP-004 | Fed. R. Bankr. P. 9004(b) | Caption: (1) court name; (2) case title; (3) case number and, if appropriate, adversary-proceeding number; (4) brief designation of the document. | `court-title()` (1), `meta.debtor` + `meta.bankruptcy_case` (2, 3), "Adversary Case No." (3), `meta.title` (4) |
| WIWB-AP-005 | Fed. R. Bankr. P. 9004(a) | Legibility: the document must be clearly legible. | body type 12 pt, `type-size` |
| WIWB-AP-006 | Fed. R. Civ. P. 10(b) | Claims are stated in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `allegations()`: each plain paragraph is numbered; prayer items are lettered (a), (b), ... |
| WIWB-AP-007 | Fed. R. Civ. P. 10(a) | The title of the complaint must name all the parties. | caption: both parties' names in the party column |
| WIWB-AP-008 | Fed. R. Bankr. P. 9011 (signature) | Signature of an attorney, with address, telephone and bar number (e-mail address too, if the signer has one). Rule text not fetched. | `signature()`: date, firm, `/s/` line, signer, lines from frontmatter |

**Not generated, on purpose:** the Official Form 104 adversary cover sheet (Fed. R. Bankr. P. 7003 requires one), the summons (Official Form 287, Fed. R. Bankr. P. 7004), and any exhibits (the exemplar attaches a stipulation). The ECF header ("Case 3-15-00105-rdm Doc 1 Filed ...") is added by the court's system and is not drawn.

### Local rules

The court's published local rules page (`https://ecf.wiwb.uscourts.gov/wiwb/Decisions/local_rules.htm`, "Revised 6/2015", fetched 2026-10-14) lists seven rules: LBR 1002-1, 1007-1-2, 1007-2, 1019-1, 4004-1, 4008-1, 7004-1. **None of them governs caption, typeface, margins, spacing, or the form of a complaint.** The only format rule on that page is LBR 1007-2 (creditor matrix, 8½ × 11, Arial, Times New Roman or Courier at 10 pt minimum), which does not apply to a complaint. The published page may not be the current rule set (a 2017 notice says the rules were being amended; the current text was not found). Until the current LBRs are read, the form in this template is taken from the Federal Rules and from the exemplar, and is marked as a convention wherever it is not a rule.

## Parameters: rule or convention

| Parameter | Value | Basis |
|---|---|---|
| Paper | 8½ × 11 in, 1 in margins | Convention (no W.D. Wis. rule found). |
| Typeface | Face required: none. Vendored substitute: none, EB Garamond kept (OFL), 12 pt. Fit: n/a. | No face is named by a rule that governs a complaint. The W.D. Wis. LBR 1007-2 names Arial, Times New Roman or Courier, but only for the creditor matrix of a voluntary petition. Per `docs/FONTS.md` ("No face named"), EB Garamond stays. The exemplar is Times; the template does not follow it. |
| Line spacing | 24 pt baseline pitch in the body (leading 1.35em, paragraph gap 1.35em; EB Garamond's line box is 0.65em) | Convention, measured on the render with `pdftotext -bbox-layout` (page 2: 24.0 pt between body lines). Not a rule. |
| Numbered paragraphs | 1., 2., ... with a 0.5 in first-line indent | Fed. R. Civ. P. 10(b). |
| Caption | Court title centered and bold; party column with a right and bottom rule; "Adversary Case No." to the right, blank line for the clerk unless the sample gives it | Fed. R. Bankr. P. 9004(b); Official Form 416 series (the exact form text was not fetched). |
| Section headings | Centered, bold, capitals (`#`), unnumbered, as in the exemplar | Convention, from the exemplar. |

## Exemplar

- `usage/FILED-EXAMPLE-adversary-complaint.pdf`: "Complaint Determining the Validity of a Claimed Lien under Rule 7001(2)", *Wenzel v. Green Tree Servicing LLC*, adversary 3-15-00105 (underlying Bankr. No. 13-15445), filed by the debtor's counsel July 17, 2015. 3 pages, text layer present. Provenance and searches are in `usage/SOURCE.md`.
- **Only one exemplar.** The eval loop wants two or three from different filers before tier 2 is judged. Searches for a second one are in `usage/SOURCE.md`: none found with a text layer. Tier 2 is therefore judged against one filing and the rules, not against a set.
- The exemplar predates the 2016 amendment to Rule 7008(a). It states that the proceeding is "core" and has no consent statement. The template requires the consent statement (see Known gaps).

## Sample

- `usage/INPUT-adversary-complaint.md`: a transcription of the exemplar's caption, title, every body paragraph (1–17), the prayer for relief, and the signature block, with the sample's `caption`, `signature` and `date` frontmatter. The body is transcribed as the filer wrote it; section headings are typed; paragraph numbers are not (the template numbers them).
- **One added paragraph.** Paragraph 5, "Plaintiff does not consent to the entry of final orders or judgment by the bankruptcy court.", is not in the exemplar. It is added so the sample meets the 2016 rule (Fed. R. Bankr. P. 7008(a)). The choice of "does not" is the sample's; the template does not decide it. Because of this paragraph, the sample's numbering runs one higher than the exemplar from paragraph 5 onward.
- The sample's frontmatter also carries `authorities:` (one entry, unused by this template). Keep it or drop it; the template ignores it.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick (micromamba env)
sh tools/render.sh courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district/adversary-complaint usage/INPUT-adversary-complaint.md
sh tools/overlay.sh courts/seventh-circuit/wisconsin/federal/bankruptcy-western-district/adversary-complaint wenzel-complaint
```

- File names follow the repo's tools, not the brief's shorthand: `usage/INPUT-adversary-complaint.md` (the sample), `usage/OUTPUT-adversary-complaint.typst.pdf` (our render, default name from `tools/render.sh`), `usage/OVERLAY-wenzel-complaint.pdf` and `.txt` (from `tools/overlay.sh`).
- Typst compiled with no warnings (`render.sh` fails on any). `pdffonts` shows only the vendored EB Garamond (regular and bold, embedded as Identity-H).
- The overlay pairs pages by word overlap: ours p.1–3 ↔ filed p.1–3 (word overlap 77%, 77%, 74%). Red is our render, blue the exemplar, black both. The pages do not line up exactly because the exemplar's text is set in Times and the caption and paragraph breaks differ. It is a diagnostic, not a score.

## Visual review (Gate 2 record, all 3 pages, rendered at 60 dpi and looked at)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (In re block, party column with "Plaintiff," / "Defendant." designations, "v."), title, PARTIES, JURISDICTION (¶¶ 1–3) | OK after two fixes: (a) numbered paragraphs were overlapping because paragraph blocks had no gap (fixed by using normal paragraph flow); (b) the court-name lines were touching (now a single stack with leading). |
| 2 | ¶¶ 4–15 (jurisdiction end, FACTUAL ALLEGATIONS) | OK. Paragraph gaps match the line pitch (24 pt, measured). |
| 3 | ¶¶ 16–18, WHEREFORE, prayer (a)–(c), date, firm, /s/ line, signer, bar number, address, phone | OK. The signature block sits on the page with the last paragraphs, not alone. |

Reviewed pages: 3 of 3.

## Known gaps and open choices

1. **Second exemplar.** One filing only (see Exemplar). Needs a second filed adversary complaint from a different filer, with a text layer, to meet the eval-loop tier-2 rule.
2. **Consent paragraph.** The exemplar has none. The template asserts one (Rule 7008(a), since December 1, 2016); the sample adds it as paragraph 5. Confirm the sample's choice ("does not consent") with the filer's counsel or with David before any real use.
3. **Local rules.** The seven published LBRs say nothing on caption or form. The current W.D. Wis. bankruptcy local rules text was not found. If a current LBR sets type size, margins, spacing or caption format, the parameters table must follow it.
4. **Typeface and size.** EB Garamond at 12 pt, not Times New Roman. The rules give no typeface for bankruptcy pleadings; the choice is the vendored font.
5. **Caption layout.** The party column and rules are a convention drawn from the exemplar's layout, not from Official Form 416's exact text (not fetched).
6. **Rule 9011 and 7001(2) text.** Cited from the exemplar and general knowledge, not fetched. Check the verbatim text before a rule-level claim is published.
7. **Not generated:** cover sheet (Official Form 104), summons, exhibits, certificate of service (none in the exemplar), ECF header.
8. **Line numbers.** None. The exemplar has none, and bankruptcy pleadings in this court are not on pleading paper in this sample. Not verified against any local practice.

## Engines

DOCX (`docx/`): `docx/build-reference.sh` builds `docx/reference.docx` from pandoc's default reference; `docx/wiwb.lua` lays out the cover, caption, numbered allegations, prayer and signature. Built with `sh tools/render.sh --engine docx <this dir> usage/INPUT-adversary-complaint.md`, which writes `usage/OUTPUT-adversary-complaint.docx`.

- **Matches the typst form (by its parameters, not seen on a page):** EB Garamond 12 pt; body lines at 24 pt exact (the typst baseline pitch); first-line indent 0.5 in; allegations numbered 1., 2., ... with the text at 1 in; prayer items (a), (b), ... with a hanging label; level-1 headings bold capitals, centred; caption with a 3.4 in party column, right and bottom rules on it, and "Adversary Case No." at the right; title centred bold; signature block in the right 3.1 in column that does not break across pages; 11 pt centred page number; letter paper, 1 in margins. The court name and "Respectfully submitted," are the template's text, as in the typst form.
- **Differs or unverified:** the numbers are typed text, not Word list numbering (they do not renumber on edit). The caption rules are table borders, and the "Adversary Case No." and "/s/" blanks are underscores, so their length depends on the font. The title and date metadata are printed once, on the cover and in the signature block (pandoc's own title block is suppressed). Word and LibreOffice may space the caption table differently from typst; not compared.
- **BLOCKED (docx.pdf and page review):** `soffice` is not installed on this box (no conda package, no root), so `usage/OUTPUT-wenzel-complaint.docx.pdf` was not produced, `tools/check.sh --engine docx` cannot run, and no page was rendered or reviewed (pages reviewed for docx: 0). The render script fails at the soffice step after writing the .docx; the .docx itself is valid (zip and every XML part well-formed).
- **BLOCKED (not verified):** the .docx has not been opened in Word or LibreOffice (whether it opens without a repair prompt is not confirmed); the font name "EB Garamond" is declared, so the font must be installed for the file to show it; pagination is not measured.
- **TOC, TOA:** none, because the typst form has none; no field update is needed.
