# Bankruptcy Court, District of the Northern Mariana Islands (nmib): adversary complaint

Doc type: **adversary-complaint** (the complaint that commences an adversary proceeding, FRBP 7001 and 7003).
Folder: `courts/ninth-circuit/northern-mariana-islands/federal/bankruptcy-district/adversary-complaint/`. Nothing here sets `court.json` status.

**BLOCKED: no exemplar.** No filed adversary complaint from this court with public text was found (searches below). The template is built from the rules alone. Its sample is synthetic (placeholder parties), for render checks only; it is not a transcription and it does not test content.

| Item | Status |
|---|---|
| exemplar | no (BLOCKED: no exemplar; see the searches below) |
| sample md | `samples/INPUT-synthetic-complaint.md` (synthetic; placeholder names, numbers and dates; not a transcription of any filing) |
| render | ok: `samples/OUTPUT-synthetic-complaint.pdf`, 3 pages, typst 0.15.0, vendored EB Garamond only (`pdffonts`), no warnings |
| typeface | face required: none (LR 5.2(a): "serif font"); font kept: EB Garamond (serif, vendored); no substitute needed |
| overlay | fail: `tools/overlay.sh` needs an exemplar PDF in `exemplars/`; none exists, so no overlay was produced |
| pages reviewed | 3 of 3 (every page rendered at 60 dpi and viewed on 2026-10-15) |

## Searches tried (for an exemplar)

All on 2026-10-14. Nothing usable was found.

1. Web search: "United States Bankruptcy Court Northern Mariana Islands adversary complaint pdf". Results: other courts' adversary guidance, the court's PACER page, a third-party courtrules.net summary. No NMI complaint.
2. Web search: NMI bankruptcy "adversary proceeding" complaint with the case-number prefixes 1:19-bk, 1:24-bk, 1:25-bk. No complaint.
3. Web search: "gov.uscourts.nmib" complaint adversary proceeding. No result for this court.
4. Justia dockets, court `nmib` (https://dockets.justia.com/court/nmib): HTTP 200, 7 cases, 9 documents. Adversary entries: *Lee v. Yeom*, 1:13-ap-00003 ("Close Adversary Case", no PDF) and *Taitingfong v. Commonwealth Development Authority*, 1:15-ap-00001 ("Close Adversary Case", no PDF). Neither has a complaint available.
5. Web search for *Taitingfong v. Commonwealth Development Authority* adversary complaint: nothing for the adversary (results were NMI district-court opinions).
6. Justia docket for *Imperial Pacific International (CNMI), LLC*, 1:24-bk-00002: HTTP 403. (The memorandum in `../motion-brief/` came from this case's Justia listing; the adversary complaints of this case were not listed in the three available documents.)
7. CourtListener search and API for `court=nmib`, `type=r`: HTTP 403.
8. Web search for the NMI bankruptcy court's adversary complaints in justia/scribd: returned the same general material.
9. Second session, 2026-10-14. Direct fetches: CourtListener search page HTTP 403; CourtListener REST API timed out (no response); Justia `court/nmib` HTTP 403; the court's own site `nmib.uscourts.gov` does not resolve (the NMI district court is `nmid.uscourts.gov`, which hosts forms and the local rules only).
10. Web search (standard and extended modes) for "Northern Mariana Islands" bankruptcy adversary complaint with adversary numbers 1:12-ap, 1:13-ap, 1:15-ap, 1:17-ap, 1:19-ap: no complaint text. Results were forms (B 416D, B 1040), the NMID local bankruptcy rules, and unrelated out-of-district complaints.
11. inforuptcy.com docket pages for `1:12-bk-00003`, `1:24-bk-00002` (Imperial Pacific International (CNMI), LLC) and `1:17-bk-00001` (Saipan Sea Ventures): HTTP 403 to this box. Search snippets show no adversary complaint on those pages. The only adversary entries seen in snippets were the 2012 `1:12-ap-1` (closed) listing.
12. Web search for a filed NMI bankruptcy complaint quoted in an opinion or appendix (Commonwealth Development Authority, Saipan): nothing. The one hit was a Leagle snippet for a different court's complaint, not tied to this court.

Result of the search: no public, text-based filed adversary complaint from this court was found. Not reachable from this box: PACER, CourtListener, Justia dockets, inforuptcy dockets. Next step if David wants an exemplar: a PACER or CourtListener RECAP pull of an NMI adversary docket, from a box that can reach them.

Not done: PACER's case locator (requires an account; not available to this box). A search by the adversary numbers on PACER is the next step if David wants an exemplar.

## Governing rules

Requirement IDs are `NMIB-ADV-...`.

| ID | Rule | Requirement | Source (read 2026-10-14) | Where in the template |
|---|---|---|---|---|
| NMIB-ADV-001 | FRBP 7001 | The adversary proceedings (a) to recover money or property, (b) to determine a lien, (d) to object to discharge, (f) to determine dischargeability, and others. | Cornell LII, Rule 7001 (as amended Dec. 1, 2024) | author content; the template does not check the category |
| NMIB-ADV-002 | FRBP 7003 | Commencement: Fed. R. Civ. P. 3 applies in an adversary proceeding. | Cornell LII, Rule 7003 (as amended Dec. 1, 2024) | body (author-written) |
| NMIB-ADV-003 | FRBP 7008 | Fed. R. Civ. P. 8 applies. The complaint's jurisdiction allegation states the case's name, number and chapter, and the district and division; and states whether the pleader does or does not consent to the entry of final orders or judgment by the bankruptcy court. | Cornell LII, Rule 7008 (read in summary; the consent statement is quoted in summary form) | body (`::` paragraphs and author content; the sample has a placeholder for the consent statement, not checked) |
| NMIB-ADV-004 | FRBP 7010 | Fed. R. Civ. P. 10 applies, except that the caption must substantially conform to the appropriate version of Official Form 416. | Cornell LII, Rule 7010 (as amended Dec. 1, 2024; quoted in full) | caption (below) |
| NMIB-ADV-005 | Official Form 416D (12/15) | Caption for use in an adversary proceeding: court name and district; "In re [debtor], Debtor"; Plaintiff; Defendant; right column Case No., Chapter, Adv. Proc. No.; the document title ("COMPLAINT [or other designation]"). | uscourts.gov Form 416D PDF (the text was extracted from the saved download, 2026-10-14) | `caption` (sides stacked with no "v."); right column `case_number`, `chapter`, `adv_number`, `brief_title` |
| NMIB-ADV-006 | LBR 5005-1(b)(1) | The caption includes the chapter. | primary LBR PDF (`lbkr20181217.pdf`, see `../motion-brief/README.md` for the version caveat) | `chapter` field |
| NMIB-ADV-007 | LBR 7003-1 | A complaint is accompanied by a cover sheet substantially conforming to the Adversary Proceeding Cover Sheet (Official Form B 1040). | primary LBR PDF | not generated: the cover sheet is a separate form |
| NMIB-ADV-008 | LBR 7004-1 | When service is by first-class mail on an officer or agent of a corporation, the certificate of service names the officer or agent (or explains why not). | primary LBR PDF | not generated (the certificate is a separate filing) |
| NMIB-ADV-009 | Fed. R. Civ. P. 10(b) (as applied by FRBP 7010) | Claims are in numbered paragraphs, each limited as far as practicable to a single set of circumstances. | Fed. R. Civ. P. 10 text as quoted in `../../../../california/federal/northern-district/complaint/README.md` (fetched there 2026-10-14) | numbering: every paragraph is numbered by the template (`allegations()`); headings, lists and `::` paragraphs are not |
| NMIB-ADV-010 | LBR 9004-1 → LR 5.2 (summary) | Form of papers: same as the motion (see `../motion-brief/README.md`, NMIB-FORM-001 to 004). | third-party summary (not verified) | same constants as the motion template |

Not generated here: the summons (Form 287 adversary summons, FRBP 7004), the cover sheet (B 1040), the service certificate, the civil cover sheet, and any Rule 7.1 disclosure. These are separate filings.

## Markdown contract (for samples)

- YAML frontmatter, then the body.
- Frontmatter: `case_number`; `chapter`; `court` (list of lines); `counsel` (lines); `counsel_role`; `caption` (list of sides, each `names` and `designation`; no "v." between sides, as Form 416D does not use one); `brief_title` (the document title, e.g. "COMPLAINT TO DETERMINE..."); `adv_number` (optional; a blank line is printed if omitted); `footer_title`; `jury_demand` (optional); `signature` (`firm` lines, `signer`, `lines`); `date`.
- Body: `# Heading` (level 1, centered caps); `## Heading` (level 2, bold centered); `### Heading` (level 3, bold italic). Paragraphs are **numbered by the template: do not type the number**. A paragraph that starts with `:: ` is unnumbered (use it for WHEREFORE and other lead-ins). Markdown lists (`1. ...`, written without blank lines between items) become lettered items (a), (b), ... (the prayer for relief).
- Consent statement and jurisdiction: author content, placeholder in the synthetic sample.

## Layout

- Numbered lines 1 to 24 down the left margin, a double rule at the text's left edge and a single rule at its right (pleading form, same geometry as the motion template).
- Top margin 1.5 in; body on the 24 pt pitch, every block rounded to a whole pitch (`on-grid`), so body text lines fall on the numbers. Verified by reading baselines from the PDF: they sit at 108 + 24k pt (1.5 in top margin).
- Counsel block on lines 1 to 7 (single-spaced); the court title follows. Caption: left column is the parties (closed by a rule at the right and the bottom), right column is the case number, chapter, adversary number, title, and "DEMAND FOR JURY TRIAL" when `jury_demand` is set.
- Footer: the footer title (left) and the case number (right), with the page number above, as in the cand complaint template.

## Render

```sh
export PATH="$HOME/tb/bin:$PATH"
sh tools/render.sh courts/ninth-circuit/northern-mariana-islands/federal/bankruptcy-district/adversary-complaint samples/INPUT-synthetic-complaint.md
```

The overlay command (`sh tools/overlay.sh <court-dir>`) exits 2 here with `tools/overlay.sh: 16: 2: parameter not set` (2026-10-14, run for real): it needs `exemplars/*.pdf`. Nothing was produced.

## Visual review (Gate 2 record, all 3 pages, rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 (cover) | Counsel block, court title, Form 416D caption, title, jury demand | OK. Caption closed by a rule; "In re", debtor, plaintiff and defendant blocks stacked; "Adv. Proc. No. ________" printed as a blank for the clerk. |
| 2 | Numbered paragraphs 1–11 and headings | OK after the fixes below. Headings unnumbered, paragraphs numbered from 1 by the template, the level-3 sub-heading not numbered. |
| 3 | Claim heading, paragraphs 12–14, prayer (a)–(d), jury demand, signature | OK after the signature spacing fix. WHEREFORE lead-in unnumbered, prayer lettered, signature block on the grid. |

Change log for this review: (1) text edges set to ascender/descender, as in the motion template (without them the line box was shorter and lines overlapped); (2) the sample's typed paragraph numbers removed (the template numbers them; typed numbers doubled); (3) the sub-heading changed from a bold paragraph (which was numbered) to a level-3 heading; (4) "v." removed from the sample's caption (Form 416D has none); (5) a line of space above the signature block.

Reviewed pages: 3 of 3. Re-rendered 2026-10-14 (second session, `tools/render.sh`, exit 0, 3 pages); all 3 pages rasterized at 60 dpi and viewed again. No template change in that session.

## Known gaps and open choices

1. **No exemplar (BLOCKED).** Tier 2 cannot be judged. The layout follows the rules, the Form 416D caption and the NMI motion's pleading form. A filed complaint from this court would settle conventions (the numbered-paragraph style, the consent-statement wording, the jury-demand placement) that the rules leave open.
2. **Court title in the caption.** Form 416D says "United States Bankruptcy Court … District Of …". This template prints the court title used on the filed motion in this court ("United States District Court for the Northern Mariana Islands, Bankruptcy Division"). FRBP 7010 needs only "substantially conform"; which wording the clerk prefers is for David or the court.
3. **Synthetic sample.** The sample's parties, numbers, dates and addresses are placeholders. Its checks are layout checks only.
4. **LR 5.2 values are a third-party summary** (see `../motion-brief/README.md`, NMIB-FORM-001).
5. **Type size and face.** 13 pt EB Garamond. LR 5.2(a) (primary text, read 2026-10-15) requires 12-point type or larger in a serif font and names no face, so EB Garamond is kept (see `../motion-brief/README.md`, item 5).
6. **Not checked:** the consent statement (FRBP 7008), the core-proceeding statement, the 34-day and page limits (not applicable to a complaint), LBR 7003-1 cover-sheet conformance, and LBR 7004-1 service naming (no certificate is generated).
7. **Gate scripts not run.** `tools/check.sh` and `tools/check-selftest.sh` expect a court folder with `court.json` and `rules.md`; this doc-type folder does not have that shape, and the brief forbids edits to `tools/`.

## Third session (fb-595.20.11, 2026-10-15)

Re-searched with CourtListener's REST API v4 (anonymous, throttled to 5/min; no API key on this box) and WebSearch.

13. CourtListener search, `court=nmib`, `type=rd` (RECAP documents), queries "complaint", "adversary complaint", "Complaint Filed by Plaintiff", "Adversary Proceeding Cover Sheet", "Plaintiff Defendant adversary", "Adv. Proc. complaint": no adversary complaint returned. Hits were main-case documents of 1:24-bk-00002 (Imperial Pacific) and other bankruptcy dockets, plus one answer to a complaint in 1:17-bk-00001 (Saipan Sea Ventures, not available).
14. CourtListener search, `court=nmib`, `type=r`, for adversary dockets (`-ap-`): these exist, but none lists an available RECAP document (`recap_documents` empty or `is_available: false`): CNMI v. Manglona 1:13-ap-00001; CDA v. Manglona 1:13-ap-00002; Lee v. Yeom 1:13-ap-00003; Taitingfong v. CDA 1:15-ap-00001; NMI Retirement Fund v. (seven defendants) 1:12-ap-00001 to 00007; Cabrera v. U.S. Department of Education 1:26-ap-00001 (filed 2026-01-20, docket id 72160170).
15. CourtListener docket-entries and dockets endpoints: HTTP 401 "Authentication credentials were not provided" (entries) and null `pacer_case_id` (dockets), so the RECAP storage path `gov.uscourts.nmib.<pacer_case_id>.<doc>.0.pdf` cannot be built for any adversary docket.
16. CourtListener docket HTML pages (3 adversary dockets): HTTP 403 to this box.
17. WebSearch (standard): "Cabrera v. U.S. Department of Education" with Northern Mariana Islands bankruptcy complaint: no hit for the case or the court (student-loan dischargeability cases elsewhere). WebSearch (standard): NMI bankruptcy adversary complaint PDF with 1:24/1:25/1:26-ap: PACER court page, the district's general orders, an inforuptcy 2012 docket listing (1:12-ap-1, closed), and out-of-district material. No complaint.

Result: still no public, text-based adversary complaint from this court. The one live lead is the Cabrera adversary (1:26-ap-00001, filed 2026-01-20): its docket exists, but no document is in the RECAP index, and the storage path needs a `pacer_case_id` this anonymous API does not return. Next step: an authenticated CourtListener (or PACER) pull of `1:26-ap-00001` doc 1, or a Cabrera docket from a box that can reach it.

Re-verified this session: `sh tools/render.sh` exit 0, `samples/OUTPUT-synthetic-complaint.pdf`, 3 pages, EB Garamond only (`pdffonts`). All 3 pages rasterized at 60 dpi (`pdftoppm -r 60`) and viewed: page 1 caption and title, page 2 paragraphs 1 to 11 and sub-heading, page 3 claim, prayer, jury demand and signature. No template change. `sh tools/overlay.sh <dir>` exit 2 (`parameter not set`, no exemplar PDF). The overlay stays not produced.
