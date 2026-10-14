# nebraskab: adversary-complaint

Doc type: **adversary complaint** (FRBP 7001) in the United States Bankruptcy Court for the District of Nebraska (`nebraskab`).
Folder: `courts/eighth-circuit/nebraska/federal/bankruptcy-district/adversary-complaint/`.

| Item | Status |
|---|---|
| exemplar | yes: `exemplars/FILED-EXAMPLE-meta-interbake-18-08283-adversary-complaint.pdf` (1 filer, 9 pages; see `exemplars/SOURCE.md`) |
| sample md | `samples/INPUT-interbake-adversary-complaint.md` (the whole complaint body and the caption, the signature block, the prayer; the exemplar's footnote 1 is not transcribed, see Known gaps) |
| render | ok: `samples/OUTPUT-interbake-adversary-complaint.pdf`, 9 pages, typst 0.15.0, vendored EB Garamond only, no warnings |
| overlay | ok: `samples/OVERLAY-interbake-adversary-complaint.pdf` and `OVERLAY-interbake-adversary-complaint.txt` (page map) |
| pages reviewed | 9 of 9 (every page rendered at 60 dpi and viewed after the last change; see the review section) |
| tier 1 (rule-mandated) | see the rules table: each row is in the template, and the one the exemplar misses (FRBP 7008(a) consent statement) is asserted by the template |

## Governing rules

Primary sources. Dates in the table are when each text was fetched (2026-10-14). The rule texts are the Cornell LII copies of the Federal Rules of Bankruptcy Procedure as amended effective 2024-12-01 (the restyled text; the Committee Notes say the restyling was stylistic only), and the District of Nebraska Local Rules as posted on `neb.uscourts.gov` (the "2026 FINAL AMENDED" PDF, 35 pages).

| Rule | Requirement | Where in the template / sample |
|---|---|---|
| FRBP 7001 | Adversary proceeding to recover money or property, to determine interests in property, etc.; a complaint commences it. | The document type itself. The sample is a § 547/§ 550/§ 502 avoidance complaint. |
| FRBP 7003 (applies FRCP 3) | Commencing an adversary proceeding is by complaint, filed with the clerk. Fetched text: "Fed. R. Civ. P. 3 applies in an adversary proceeding." | Not a template element. |
| FRBP 7008(a) | Allegation of jurisdiction must reference the name, number and Code chapter of the case the adversary relates to, and the district and division where it is pending. The complaint must state whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court. (Fetched 2026-10-14.) | Jurisdiction section of the sample: name and number of the main case, the District of Nebraska, and the consent sentence (`body.find("consent to the entry of final orders")`, asserted by the template). The exemplar does **not** state consent (see Decisions). |
| FRBP 7010 (applies Official Form 416) | The caption of a pleading in an adversary proceeding must substantially conform to the appropriate version of Official Form 416. (Fetched text: "Fed. R. Civ. P. 10 applies in an adversary proceeding — except that a pleading's caption must substantially conform to the appropriate version of Form 416.") | `caption()`: court name, *In re* block with chapter and case lines, parties with designations, adversary number line, title. The text of Form 416A itself was **not retrieved** (the uscourts.gov page returned 404); the caption follows the exemplar and FRBP 9004(b) rather than the form's exact layout. |
| FRBP 9004(a) | Papers must be clearly legible; common English abbreviations are acceptable. | Vendored EB Garamond, 13 pt, black on white. |
| FRBP 9004(b) | Caption: (1) court name; (2) case title; (3) case number and, if appropriate, the adversary-proceeding number; (4) a brief designation of the document's character. | `caption()` (court, parties, Case No., Adv. Pro. No.) and the title line. |
| FRCP 10(b) (applies via FRBP 7010) | Numbered paragraphs, each limited as far as practicable to a single set of circumstances. | `body-chunks()`: allegations numbered from the first heading to the prayer; intro and prayer unnumbered. |
| FRBP 9011(a) | Every pleading must be signed by at least one attorney of record in the attorney's own name, and must state the signer's address and telephone number. (Fetched text.) | `signature-block()`: name, address, telephone for each signer. |
| LR 9011-1(B) (D. Neb. Local Rules, 2026 text) | A CM/ECF participant may sign with "/s/" followed by the printed name. | `Respectfully submitted` block: "/s/ Douglas L. Lutz" then the printed name. |
| LR 1015-1(B) | After joint administration is ordered, document captions must state that the cases are jointly administered. | Caption line "(Jointly Administered)" in the sample (the case is jointly administered). |

Not in this template (separate filings, not part of the complaint): the adversary proceeding cover sheet (not verified as required by the local rules; the fetched rule text does not mention one); summons (FRBP 7004); the mailing matrix and any certificate of service (LR 5005-1(C) and Appendix E, which apply when a non-CM/ECF party must be served; a complaint is served by summons, and the sample has no certificate).

## Layout

- Court name, centered and bold, on two lines (constant for this court, not from the sample).
- Caption in two columns: the *In re* block with a rule under it, then the parties; the right column holds the chapter, the case lines and the adversary number line. "v." between the parties.
- Title in capitals, bold, centered.
- Body: double spaced (26 pt pitch at 13 pt), 1-inch margins, letter paper, left-aligned (the exemplar's justification is not readable from its text layer, so none is asserted). Headings are sticky: a heading never ends a page.
- Level-1 headings (`#`) are centered bold capitals; level-2 headings (`##`) are centered bold (COUNT subheadings). Paragraph numbers are 1, 2, 3 ... typed by the template.
- Prayer items are lettered (a), (b) ... with a hanging indent. The prayer paragraph is unnumbered.
- Footnotes: `text[^key]` with a `[^key]: ...` definition line (rendered at 11 pt).
- Signature block after the prayer: "Dated:" on the left; "Respectfully submitted," and each signer's block on the right, single spaced. The block is kept together (non-breakable), as in the exemplar, where the date and signature sit on the last page.
- Section symbols: a non-breaking space after "§" (and before it), so "§" never ends a line. The title is set the same way.

## Markdown contract (for samples)

Frontmatter (all keys read by `caption()` and `signature-block()`):

| Field | Type | Feeds |
|---|---|---|
| `in_re` | list of strings | the *In re* block, one line each |
| `chapter` | string | chapter line, e.g. `Chapter 11` |
| `case_lines` | list of strings | the case number lines, e.g. `Case No. 17-80304 (TLS)`, `(Jointly Administered)` |
| `adversary_line` | string | `Adv. Pro. No. ____` |
| `parties` | list of `{names: [...], designation: "Plaintiff,"}` | the party block, "v." between parties |
| `title` | string | the document title, set in capitals |
| `date` | string | `Dated:` line |
| `signature` | list of blocks, each a list of lines | the signature blocks; the first line is the `/s/` line |

Body: `# SECTION` (level 1), `## Subheading` (level 2), blank-line-separated paragraphs (numbered), `- item` lists (lettered), and `[^key]` footnotes with their definition. Do not type numbers: the template numbers the allegations. Do not type a heading level deeper than 2. Case names: `*Name*` (italic). The sample uses no italics (the exemplar's text layer has no italic markup).

## Decisions

- **Consent sentence (FRBP 7008(a)).** The exemplar does not state whether the plaintiff consents to final orders, and the rule requires it. The sample adds one sentence in the jurisdiction section, right after the core-proceeding paragraph: "Plaintiff [does / does not] consent to the entry of final orders or judgment by the Court." The bracket is an unfilled choice for the filer, not a legal position; the template refuses to build a complaint that lacks the statement. This is the only sentence in the sample that is not in the exemplar, and it adds one numbered paragraph, so paragraphs 6 to 39 of the sample are one number higher than the exemplar's (5 to 38).
- **Font: EB Garamond at 13 pt.** The exemplar is Times New Roman, 12 pt. Only EB Garamond is vendored, and at 12 pt it reads smaller than Times, so 13 pt matches the apparent size. No Nebraska rule sets a font or a size (FRBP 9004(a) requires legibility only).
- **Margins and spacing: 1 inch, double.** No rule in the fetched local rules sets margins or line spacing for adversary complaints. The exemplar is double spaced with 1-inch margins; the template matches that.
- **No pleading paper.** The N.D. Cal. complaint template uses numbered lines (a California rule, Civil L.R. 3-4). Nebraska has no such rule, and the exemplar has none.
- **Counsel block at the signature, not at the top.** The exemplar puts counsel at the signature. Nebraska has no upper-left counsel rule in the fetched text.

## Known gaps and open questions

1. **One exemplar.** Tier-2 review is against one filer (META Advisors, plan administrator, Frost Brown Todd and Koley Jessen). A second complaint in this court (*Kelly v. Zuhlke*, Adv. 24-04011, Doc 1, 5 pages) was downloaded and read for conventions but not saved, because the brief asks for one exemplar per doc type. The search (CourtListener API, `type=r`, `court=nebraskab`) also found *Myers v. Stehlik*, Adv. 21-04025, Doc 1 (15 pages, text layer), which is a later, individual-debtor-style complaint; it is not reviewed here.
2. **Caption footnote 1 (the debtors' list) is not reproduced.** The template has no caption footnote. The exemplar's footnote 1 lists the six debtors with their last four EIN digits; it is part of the caption in the filing. The footnote numbering therefore starts at 1 for the plan reference (the exemplar shows 2). A caption footnote would need a template field.
3. **Exhibit A is not included.** The complaint refers to Exhibit A (the transfer schedule); the exhibit is not part of the complaint document and is not in the sample.
4. **The FRBP 7008(a) chapter reference.** The exemplar's jurisdiction paragraph names the main case, its number, and the district, but the word "chapter 11" appears in paragraph 1, not in the jurisdiction paragraph. Whether that satisfies "Code chapter" is not settled by the rule text; the template does not check it.
5. **The local rules conflict on adversary motions (not used here).** The 2026 local rules say LR 9013-1 does not apply to motions in adversary proceedings (LR 7007-1(A)). General Order 22-08 (2022) replaced LR 9013-1 and says it applies to "bankruptcy cases and adversary proceedings". The 2026 text is later; the motion-brief README records what that means for briefs.
6. **Word limits (not applied).** The Nebraska District Court's civil rules (NECivR 7.1(d)) set 13,000 words for a supporting brief. LR 1001-1(B) makes the *general* rules of the district court applicable in adversary proceedings, but it is not confirmed that NECivR applies, and the bankruptcy local rules set no limit. No word limit is applied; if one applies, the motion-brief template would need a word-count certificate.
7. **Cover sheet (Official Form 1040) and summons (FRBP 7004)** are not part of this template; not verified as to the court's practice.
8. **Check scripts not run.** `tools/check.sh` expects a court root with `court.json` and `rules.md`, and this folder is not that shape. The brief forbids touching `tools/`. Render and overlay were run; the review below is the Gate 2 equivalent for this doc type.
9. **No `reviews/` folder** for this doc type; the review is recorded here.

## Review of the rendered pages (final build, 9 pages)

Each page was rendered at 60 dpi and viewed after the last change. Paragraph ranges were read from the PDF text layer.

- Page 1: court name; *In re* block with the rule under it; the META party block; "v."; Interbake Foods; the title in capitals on three lines; the unnumbered opening paragraph; heading "NATURE OF THE CASE"; paragraph 1. Pass.
- Page 2: paragraphs 2 to 8; heading "JURISDICTION AND VENUE" (paragraphs 3 to 7, including the consent paragraph, numbered 5); heading "PROCEDURAL BACKGROUND" (paragraph 8). Pass.
- Page 3: paragraphs 9 to 14; heading "PARTIES" (paragraphs 13 and 14); footnote 1 at the foot. Pass.
- Page 4: heading "FACTUAL BACKGROUND" (moved to the top of the page with its paragraph 15); paragraphs 15 to 20 (paragraph 20, the reservation of amendments, runs onto page 5). Pass.
- Page 5: the end of paragraph 20; heading "COUNT I" with its parenthetical; paragraphs 21 to 27. Pass.
- Page 6: paragraph 28 (runs from page 5); paragraphs 29 and 30 (end of Count I); heading "COUNT II" with its parenthetical (paragraphs 31 to 34). Pass.
- Page 7: heading "COUNT III" with its parenthetical (paragraphs 35 to 39); heading "PRAYER FOR RELIEF" (unnumbered); the WHEREFORE paragraph (unnumbered); items (a) and (b). Pass.
- Page 8: prayer items (c) to (f), then white space. The signature block did not fit and moved to page 9, so this page holds prayer text only. Pass (layout), with the note below.
- Page 9: "Dated:" line and the signature blocks (both signers, the "-and-" line, the counsel line in italics), kept together. The exemplar's signature also sits alone on its last page. Pass.

No heading at the foot of a page with its paragraph on the next page; no paragraph number missing or repeated; the caption does not overlap the title; no body line overlaps another.

Open layout choice: the signature block is non-breakable, so it moves whole to page 9 and leaves page 8 with prayer items only. Keeping the last prayer item with the signature would fix that; it was not changed, because the exemplar does the same.
