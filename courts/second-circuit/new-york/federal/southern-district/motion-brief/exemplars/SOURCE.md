# Exemplar source: nysd motion brief (memorandum of law in support of a Rule 12(b) motion)

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-minerva-26-cv-06789-motion-brief.pdf` (17 pages; text layer present, from an OCR paper-capture; `pdftotext` reads it with some OCR errors, which the sample corrects by reading the page images' text as printed) |
| Case | *Minerva Bunkering Pte Ltd. v. Ashfaque J. Rahman and Mahween Rahman* (in admiralty) |
| Court | United States District Court, Southern District of New York |
| Docket no. | 1:26-cv-06789-VEC (page header: `Document 14 Filed 08/28/26`) |
| Document | Document 14: Memorandum of Law in Support of Motion to Dismiss (Rule 12(b)(6)); certificate of compliance under Individual Practice Rule 4(B) of the assigned judge |
| Filer | Defendants' counsel, Michael J. Frevola, Holland & Knight LLP |
| Date filed | August 28, 2026 (header and signature block) |
| URL fetched | https://storage.courtlistener.com/recap/gov.uscourts.nysd.670151/gov.uscourts.nysd.670151.14.0.pdf (RECAP copy) |
| Docket page | https://www.courtlistener.com/docket/73739597/minerva-bunkering-pte-ltd-v-rahman/ |
| How found | CourtListener RECAP search (`type=r&court=nysd`, query "motion to dismiss" "memorandum of law", filed after 2026-06-01 / 2026-07-01), filtered to documents with `is_available: true` |
| Date fetched | 2026-10-14 |

## Why this one

- Counsel-filed Rule 12(b)(6) memorandum in this court, public RECAP copy.
- Shows the form features the template needs: counsel block at upper left, court name, caption with the case number and assigned judge's initials, the title of the paper, a table of contents and a table of authorities (roman-numbered pages), a preliminary statement, background, legal standard, argument headings (I, II, A to D), leave to amend, conclusion, signature block, and a certificate of compliance with the word count and the typeface.

## Limits of this exemplar (tier 2 caveat)

- One filer only. The second SDNY memorandum found, *Better Home & Finance Holding Co. v. Garg*, No. 1:26-cv-07025-CM (RECAP copy of Doc. 41, 30 pages, filed 09/08/26 by counsel; `gov.uscourts.nysd.670733.41.0.pdf`), was downloaded and checked for text, but not saved (the brief asks for one exemplar per doc type). Tier 2 is therefore not yet judged against two filers.
- The exemplar's certificate says "Times New Roman, 12 point font", and this is the typeface the judge's rule asks for. The template uses EB Garamond (the only typeface vendored in `fonts/`). See `../README.md` (gaps).
- The text layer has OCR errors (e.g. "Complainf s", "Comp!.", "Malrn·een", "MahYveen"); the sample is a corrected transcription, not a copy of the text layer.

## Searches tried (for the record)

- CourtListener RECAP, nysd, memoranda and motions filed since 2026-06-01: about 40 results. Available memoranda in support of a motion to dismiss: 670151 (this one, 17 pp., counsel-filed) and 670733 (Garg, 30 pp., counsel-filed). This one is closer to the 8 to 14 page render target.
- Not used: 669744 (37 pp. MTD for lack of jurisdiction or summary judgment, not a Rule 12(b)(6) memorandum), 674295 (33 pp., a Dimon/JPMorgan MTD, too long for the target).

## 2. Better Home & Finance Holding Co. v. Garg (added 2026-10-17)

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-garg-26-cv-07025-motion-brief.pdf` (30 pages, letter, native text layer from Word via Acrobat PDFMaker, `pdftotext` reads it cleanly; not scanned) |
| Case | *Better Home & Finance Holding Company v. Vishal Garg* |
| Court | United States District Court, Southern District of New York |
| Docket no. | 1:26-cv-07025-CM (page header: `Case 1:26-cv-07025-CM Document 41 Filed 09/08/26`) |
| Document | Document 41: Defendant's Memorandum of Law in Support of Motion to Dismiss the First Amended Complaint (Rule 12(b)(1) and 12(b)(6)) |
| Filer | Defendant Vishal Garg; counsel Quinn Emanuel Urquhart & Sullivan, LLP (signed "/s/ Michael E. Swartz"; also Alex Spiro, Minji Reem, Linda Moon, Robert M. Garsson). Different party and firm from entry 1 (Rahman defendants / Holland & Knight). |
| Date filed | September 8, 2026 (header) |
| URL fetched | https://storage.courtlistener.com/recap/gov.uscourts.nysd.670733/gov.uscourts.nysd.670733.41.0.pdf (RECAP copy) |
| Docket page | https://www.courtlistener.com/docket/74661924/better-home-finance-holding-company-v-garg/ |
| How found | Named in entry 1's "Limits" note (found in the 2026-10-14 RECAP search); fetched again and checked on 2026-10-17 |
| Fonts (`pdffonts`) | Times New Roman (regular, bold, italic, bold italic) for the text; Calibri, Arial Bold, Symbol in small amounts; Liberation Sans is the ECF stamp |
| Date retrieved | 2026-10-17 |
| sha256 | `653fb472932572ae6c5858bdb157269090bf3b3cf4c664508f3c140381022735` |

Form notes (tier 2): page 1 is a caption-only cover (court name, parties at left, "Case No." at right, title centered below; no counsel block on the cover, unlike entry 1); table of contents, table of authorities and a table of defined terms on roman-numbered pages; body arabic from 1, page number centered at the foot; centered caps top-level headings (PRELIMINARY STATEMENT, BACKGROUND, ARGUMENT, CONCLUSION); argument headings I./II., then A./B., then 1./2.; signature block after the conclusion with "/s/". No certificate of compliance with a word count appears in this PDF (Local Civ. R. 7.1(c) requires one for attorney-filed briefs; whether it was filed separately was not checked).

## Selected replacement

The Minerva filing is flagged as an OCR paper-capture. The saved Garg memorandum is a same-court, same-document-type public filing with a native text layer, Times New Roman body text, and distinct counsel. It is the selected replacement for Minerva; the sample is already based on Garg.
