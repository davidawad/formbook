# moeb: motion (and brief)

Doc type: **motion** (a motion with numbered paragraphs, WHEREFORE clause, signature block and certificate of service; an optional supporting memorandum, L.R. 9013-1(E)) in the United States Bankruptcy Court for the Eastern District of Missouri, Eastern Division (`moeb`). Folder: `courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district/motion-brief/`.

| Item | Status |
|---|---|
| template | `typst/main.typ` (entry) and `typst/moeb-motion-brief.typ` (template). Built from the court's rules, structured like `../adversary-complaint/typst/`. |
| exemplar | yes: `usage/SAMPLE-moeb-motion-brief-qmaxx2041063motiontoabstain.pdf` (1 filer; see `usage/SOURCE.md`) |
| sample md | `usage/INPUT-moeb-motion-brief-qmaxxabstain.md` (the whole motion, all 11 paragraphs, the five footnotes, the WHEREFORE clause, the signature block and the certificate of service, transcribed from the 5-page exemplar) |
| render | ok: `usage/OUTPUT-moeb-motion-brief-qmaxxabstain.typst.pdf`, 6 pages, typst 0.15.0, vendored EB Garamond only, no warnings (`tools/render.sh`, exit 0) |
| overlay | ok: `usage/OVERLAY-qmaxx-abstain.pdf` and `usage/OVERLAY-qmaxx-abstain.txt` (page map) |
| pages reviewed | 6 of 6 (every page rendered at 60 dpi and viewed; pages 5 and 6 viewed again after the layout fix; see the review table) |

The sample is `INPUT-moeb-motion-brief-qmaxxabstain.md`, so `tools/render.sh` and `tools/overlay.sh` write `OUTPUT-moeb-motion-brief-qmaxxabstain.typst.pdf` and `OVERLAY-qmaxx-abstain.{pdf,txt}`. These are the repo's file-role names (CLAUDE.md), not the `<id>.pdf` names in the brief; the tools fix them.

The folder did not exist in this checkout before this pass. Only the adversary-complaint folder of this court was present, and that folder's exemplar and overlay PDFs are not in this snapshot (only the `.txt` page map and the `.md` sample are). This folder is new; the adversary folder is unchanged.

## Governing rules

Primary source: **E.D. Mo. Local Rules of Bankruptcy Procedure, "as revised effective December 1, 2025"** (cover page of the PDF). Fetched 2026-10-14 from https://www.moeb.uscourts.gov/sites/moeb/files/Local_Rules_Dec_1_2025.pdf (104 pages; `pdftotext -layout`; quotations below are from that text).

Caveat (same as the adversary-complaint folder): the rule text's own L.R. 1001(C) still reads "These Rules become effective on December 1, 2022." The cover page says 2025. This template follows the 2025 cover page. David should confirm which is current.

| ID | Rule | Requirement | Where it lives |
|---|---|---|---|
| MOEB-MO-001 | L.R. 9004(A) | Caption: court and division at the top. Top left: the debtor, and "all filings and orders concerning motions must also list the name of the movant and respondent on the top left." Top right: case number with judge code; chapter; motion number (once assigned); current hearing date, time and location; date any response must be filed. (Local Form 22.) | `caption()` in `typst/moeb-motion-brief.typ`; `caption.debtor`, `caption.parties` (movant, respondent), `case_number`, `judge`, `chapter`, optional `motion_number`, `hearing`, `response_date` in the sample frontmatter. |
| MOEB-MO-002 | L.R. 9004(B) | "All filings must bear a descriptive title accurately stating the nature of the relief sought." | `title` (sample frontmatter), set in capitals by the template. |
| MOEB-MO-003 | L.R. 9004(C) | Paper 8½ × 11 inches; margins no less than 1 inch; one side; "standard, 12-point font"; "Except for memoranda of law, all factual and legal allegations in any pleading should be set forth in separately numbered paragraphs." Without leave, "no motion, memorandum or brief is to exceed fifteen (15) pages exclusive of the signature page, certificate of service and attachments." | `margin = 1in`, `type-size = 12pt` (footer included), `paper: "us-letter"`; numbered paragraphs in `allegations()`. The 15-page cap is not enforced by the template (see gaps). |
| MOEB-MO-004 | L.R. 9004(D) | "All filings must include, or be accompanied by, a certificate of service, signed by the party serving the document, identifying (i) each person or entity served with the filing; (ii) the date of service; and (iii) the manner of service." | `certificate-block()`. The template asserts that a `certificate` exists in the sample (required, not optional, for a motion). The sample's certificate names each party served, the date, and the manner (CM/ECF or first-class mail). |
| MOEB-MO-005 | L.R. 9013-1(A) | Service of motions and responses: the debtor and the debtor's attorney; all parties directly affected; the Trustee; and all parties who have filed a request for notice (in Chapter 13, all creditors who filed a proof of claim; in Chapter 11, per L.R. 9013-3(E)). | Not a template element. The certificate lists the parties served (the U.S. Trustee and counsel for the debtor's side). See gaps. |
| MOEB-MO-006 | L.R. 9013-1(B) | Response deadline: "if the matter is set for hearing, any response must be filed no later than seven (7) days before the date of hearing." Negative notice: L.R. 9061(B). | `response_date` (optional line in the caption). |
| MOEB-MO-007 | L.R. 9013-1(E) | "a memorandum of law is not required in support of a motion. If a memorandum is filed, it must be filed with the motion or at the latest, no later than seven (7) days prior to hearing. Without leave of Court, no memorandum is to exceed fifteen (15) pages, exclusive of the signature page, certificate of service and attachments." | The body accepts `#` section headings, so a memorandum can follow the motion in the same sample. No memorandum exemplar is saved (see gaps). |
| MOEB-MO-008 | L.R. 9013-1(F) | "The title of a consent motion must state that the motion is by consent." | Not enforced: the template prints the title as given. No consent motion is in this sample. |

Not produced (separate filings, or the court's own forms): the proposed order (required for filings and orders by L.R. 9004(A) "All filings and proposed orders"); the notice of hearing (L.R. 9013-2 and the calendar); the filing fee.

## Layout choices (not rule-fixed)

- **Font**: EB Garamond 12 pt, the only vendored face (`fonts/`). L.R. 9004(C) names no typeface. The exemplar uses Times.
- **Spacing**: double (27.6 pt baseline pitch, 2 × the 13.8 pt single line), as in the exemplar. Caption, signature and certificate lines are single-spaced.
- **Footer**: arabic page number, centered, bottom. The exemplar's ECF header (`Case 20-41063 Doc 17 Filed … Pg n of 5`) and the `#2445144v3` document number at the foot of each page are court or word-processor output; not reproduced.
- **Caption**: the debtor block, the movant and respondent block (rule-required), and a rule on the right and bottom of the left column; the case block sits in the right column.
- **Paragraph numbers**: the template numbers the paragraphs 1, 2, …; the sample transcribes the text without its numbers, and the numbers match the exemplar's because the order is the same. The WHEREFORE clause is unnumbered (`%` marker), as in the exemplar.
- **Footnotes**: the sample writes the five footnotes as markdown footnotes (`[^n]` with a `[^n]: …` definition). The template gathers each definition and attaches it to the paragraph that cites it, so a footnote lands on the page of its reference. Tested with the vendored cmarker before use.
- **Section sign and U.S.C.**: non-breaking spaces after "U.S.C." and "§", so "11 U.S.C. § 548" does not split. The exemplar's own "11 U.S.C. 305(a)" is transcribed as printed.
- **Trailing spacing**: each paragraph block carries `below: body-leading`. Typst does not include a paragraph's trailing leading in its height; without it paragraphs collide (the same fix as the adversary template).
- **Keep-together**: the last numbered paragraph, the WHEREFORE clause and the signature block are one unbreakable block, so a signature never stands alone on a page. The certificate of service is a separate unbreakable block (it moves to the next page as a whole when it does not fit). In the first render the certificate was kept with the signature and jumped to page 6, leaving page 5 mostly blank; the split above fixed that.
- **Service list**: the exemplar's two-column service list is rendered as one block per party, in reading order, not as a table (the markdown contract allows no tables).

## Markdown contract (for samples)

- YAML frontmatter: `case_number`, `judge`, `chapter`, `caption.debtor` (lines), `caption.parties` (`names`, `designation`; the movant first, then the respondent), `title`, `lead_in` (unnumbered first paragraph), `signature` (`date`, `firm`, `by`, `attorneys`, `lines`), `certificate` (`paragraphs`, `served` as a list of parties, each a list of lines, `date`, `signature`), and optional `motion_number`, `hearing` (lines) and `response_date`.
- Body: blank-line-separated chunks. `# …` section heading (centered caps, for a memorandum section); `## …` sub-heading (centered bold); `1. …` or `- …` is a lettered list (`(a)`, `(b)`, …), so numbered paragraphs must not carry their numbers; `%…` unnumbered paragraph (WHEREFORE); `%%…` centered, unnumbered; `[^key]: …` footnote definition; anything else a numbered paragraph.
- No tables, no forced line breaks, no raw typst in the sample.

## Render and overlay

```sh
export PATH="$HOME/tb/bin:$PATH"   # typst 0.15.0, poppler, ImageMagick, gawk, jq (micromamba env)
sh tools/render.sh courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district/motion-brief usage/INPUT-moeb-motion-brief-qmaxxabstain.md
sh tools/overlay.sh courts/eighth-circuit/missouri/federal/bankruptcy-eastern-district/motion-brief qmaxx-abstain
```

Toolchain: `micromamba create -p ~/tb -c conda-forge typst=0.15.0 poppler imagemagick gawk jq` (the box has no root and no typst; `typst --version` → 0.15.0).

## Overlay (what it shows)

`usage/OVERLAY-qmaxx-abstain.pdf` is red (our render only), blue (the filed exemplar only) and black (both agree). The page map (`usage/OVERLAY-qmaxx-abstain.txt`): ours p.1 ↔ filed p.1 (71.7% word overlap), p.2 ↔ p.2 (76.1%), p.3 ↔ p.3 (86.5%), p.4 ↔ p.4 (90.4%), p.5 ↔ p.5 (50.0%), p.6 ↔ p.5 (51.5%).

The pairing is by word overlap (coarse). The overlay is a diagnostic, not a score. Pages 1–4 pair with their exemplar pages at 71–90% word overlap. The lower overlap on pages 5 and 6 comes from the layout at the end: the exemplar's page 5 carries ¶¶ 10–11, the WHEREFORE, the signature and the certificate; ours puts the WHEREFORE and signature on page 5 and the certificate on page 6. The movant and respondent lines in the caption are the rule-required addition (gap 3), so they differ from the exemplar's caption. The overlay file was checked by viewing page 1 and page 6 as images; the colour split was not measured.

## Gate 2: visual review (every page, rendered at 60 dpi and viewed)

| Page | What it is | Finding |
|---|---|---|
| 1 | Court title, caption (debtor, movant, respondent left; case block right), title, lead-in, ¶ 1, footnote 1 | OK. Caption rule closes the left column. Footnote 1 is on the page of its reference. |
| 2 | ¶¶ 2–3, footnotes 2–4 | OK. Three footnotes on the page, each on the page of its reference. |
| 3 | ¶¶ 4–5 (the § 305(a) factors), footnote 5 | OK. "11 U.S.C. 305(a)" kept as printed in the exemplar. |
| 4 | ¶¶ 6–9 | OK. Paragraph numbers in order. |
| 5 | ¶¶ 10–11, WHEREFORE, signature block | OK. The signature is with the WHEREFORE clause (not alone). About the lower third of the page is empty because the certificate is kept whole and moves to page 6. |
| 6 | Certificate of service (CM/ECF and mail), service list, date and signature | OK. The certificate is whole on one page. |

Layout findings fixed during this review (not in the final render): the first render kept the WHEREFORE, the signature and the whole certificate as one unbreakable tail, which pushed the entire certificate to page 6 and left page 5 two-thirds blank; fixed by splitting the tail (the signature stays with the WHEREFORE; the certificate is its own block). The service entries ran together with no gap; they now have a blank line between them.

## Open questions and gaps (for David)

1. **One filer only (tier 2).** CLAUDE.md asks for 2 or 3 filers for tier 2. The only motion saved is this one (Summers Compton Wells LLC, for the movants). Other motions in the court's RECAP records (*Directory Distributing*, adv. 400563, doc 36, a supporting memorandum; *Phillips 66 v. Miltenberger*, 377511, doc 33, a motion to dismiss with memorandum) could not be downloaded in full from this box: doc 36 is not a PDF in storage, and the rest had no storage copy. A second filer's motion is still needed for a full tier-2 judgment.
2. **Exemplar length.** The motion is 5 pages, so the target of 8–14 pages does not apply. No text was added to reach a longer length.
3. **Movant and respondent in the caption.** L.R. 9004(A) requires the movant and respondent on the top left of a motion. The exemplar shows only the debtor. The sample adds the movants' names (from the body's lead-in) and "Respondent. QMaxx Products Group, Inc." (the debtor, which is also the respondent in an involuntary petition). This is the rule applied, not the exemplar's caption. Decision needed: whether the respondent line should be the debtor, or left out, for an involuntary motion.
4. **Memorandum.** This motion reserves a memorandum (¶ 11) and none was filed with it. The template has no separate memorandum fixture; the 15-page cap of L.R. 9013-1(E) and 9004(C) is not enforced (no page counter).
5. **Consent-motion title (L.R. 9013-1(F)).** Not enforced; no consent motion in the sample. A consent motion would need the title to say "by consent".
6. **Response and hearing fields.** The caption's `hearing`, `response_date` and `motion_number` lines render only when the sample supplies them. This exemplar has none (the motion was filed before a hearing was set), so those lines are not exercised by the render.
7. **Certificate of service recipients.** The exemplar's list is the U.S. Trustee and three counsel/parties. L.R. 9013-1(A) requires service on the debtor and its attorney, parties directly affected, the Trustee, and parties who requested notice. Whether this certificate meets all of those is not checked here.
8. **Italics.** The text layer does not show italic type; the case names (In re NRG Energy, etc.) are transcribed in roman. The exemplar's italic styling was not verified.
9. **Effective date.** See the caveat under Governing rules (L.R. 1001(C) says 2022; the cover says 2025).
10. **Proposed order.** L.R. 9004(A) refers to "filings and proposed orders"; no proposed order is produced here.

## Exemplar search (what was tried)

- CourtListener REST search, `type=r` and `type=rd`, for E.D. Mo. motions (`court=moeb`): many hits were hearing notices, orders and first-day motions. Searches for relief-from-stay and dismiss motions returned dockets; the docket pages and REST docket API are blocked (HTTP 403) or rate-limited (5 requests per minute) from this box.
- Storage scan of known RECAP paths (`https://storage.courtlistener.com/recap/gov.uscourts.moeb.<pacer id>/…`), which is not rate-limited: the 23andMe adversary (463084) doc 3 (summons, 4 pp.) and doc 4 (stipulation of dismissal, 4 pp.); Riske adversary (464212) doc 7 (notice of hearing, 2 pp.) and doc 15 (default judgment, 4 pp.). None is a motion.
- CourtListener RECAP search (`type=r`) with `recap_documents[].filepath_local` gave storage paths for: QMAXX Products Group (433781) doc 17, **Motion to Abstain, 5 pp., 2020-04-03: saved**; Directory Distributing (400563) doc 36 (memorandum supplement, 14 pp.; the storage object was an HTML error page, so not usable).
- WebSearch: found a 2009 adversary opinion (govinfo, 09-04213) that quotes a memorandum supporting a motion to dismiss; an opinion, not the filing. Hearing calendars on the court's site (files.moeb.uscourts.gov) list motions but are not filings.
- The local rules were fetched by curl (the court's site allowed the PDF download from this box on 2026-10-14).

## Engines

Three engines from one markdown contract. typst is the primary template and is unchanged here. This section covers the docx engine (`docx/`), added with the DOCX export (fb-595.23.14).

| Engine | Folder | Output for `qmaxx-abstain` | Status |
|---|---|---|---|
| typst (primary) | `typst/` | `usage/OUTPUT-moeb-motion-brief-qmaxxabstain.typst.pdf` (not in the snapshot; `tools/render.sh`) | unchanged |
| docx | `docx/` | `usage/OUTPUT-moeb-motion-brief-qmaxxabstain.docx`, `usage/OUTPUT-moeb-motion-brief-qmaxxabstain.docx.pdf` | rendered by LibreOffice; all 6 pages rendered at 60 dpi and viewed |

Build: `sh docx/make-reference.sh <absolute path>/docx/reference.docx` rebuilds the reference. `sh tools/render.sh --engine docx <court-dir> usage/INPUT-moeb-motion-brief-qmaxxabstain.md` writes the `.docx` and the LibreOffice PDF. `docx/moeb-motion-brief.lua` builds the caption table, the numbered paragraphs, the signature block and the certificate of service. Footnotes are pandoc's own.

LibreOffice here is 26.8.1, unpacked from the document-foundation Linux tarball (conda-forge has no LibreOffice). The vendored EB Garamond is installed for the user running LibreOffice (`docs/DOCX.md`).

**Matches typst** (measured on page 1 of both PDFs with `pdftotext -bbox`, and read on every page):

- US Letter, 1 in margins, arabic page number centred at the foot, 12 pt including the footer.
- EB Garamond 12 pt throughout. Body at 27.6 pt (double), caption, signature block and served entries at 13.8 pt (single).
- Caption: the movant and respondent block left with a rule on the right and bottom; case block right; court name centred and bold; title centred bold caps.
- Numbered paragraphs, `%` (unnumbered) and `%%` (centred) paragraphs, as in the adversary complaint.
- Signature block: "Date" at the left, "Respectfully Submitted," and the firm from 3.2 in. The signature stays with the last paragraph; the certificate moves as one block, as in typst.
- Footer page number; six pages in both, with the certificate on page 6 in both.

**Differs from typst** (not tier-1):

- Two-digit paragraph numbers: typst's text starts about 6 pt further right than the docx, which uses one tab stop for every number (see the adversary complaint README).
- Footnotes: 10 pt in the docx, about 10.2 pt in typst (typst's footnote size is 0.85 em). Line pitch 11.75 pt against 11.73 pt.
- Heading 1 is 17 pt in the docx, 16.8 pt in typst. The caption title and the lead-in sit within about 4 pt of typst.
- Widow/orphan control is off, as in typst. Page 4 ends after the first line of ¶ 10 in the docx and after ¶ 9 in typst.
- Not opened in Microsoft Word. LibreOffice opens and converts the file; the renderer checks the parts are well-formed XML.
- The sample has no italics, so the EB Garamond italic face is installed but not exercised by this sample.

**docx BLOCKED items:**

- `usage/INPUT-moeb-motion-brief-directorymemorandum.md`: BLOCKED for typst and docx alike. The sample writes footnote markers `[^1]` to `[^n]` but no definitions (no `[^n]: …` lines), so `typst/main.typ` stops with "footnote [^1] has no definition". No `.docx` is produced for it. The sample is not changed here; its footnote text has to come from the filed memorandum.
- Gate runner (`tools/check.sh --engine docx`): not run, because this court folder has no `rules.md`, `checks.yaml` or `reviews/` yet. BLOCKED: gates 0 to 3 on docx, until those files exist.
