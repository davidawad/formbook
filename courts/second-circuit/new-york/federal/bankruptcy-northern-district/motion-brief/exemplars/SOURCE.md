# Exemplars: motion-brief (nynb)

**Status: exemplar found (1 of 2 or 3 wanted).** `FILED-EXAMPLE-ef-consulting-v-gecc-10-90175-motion-brief.pdf` is a real,
public, text-based memorandum of law in support of a motion to dismiss, filed in this court in an adversary proceeding.
The sample (`samples/INPUT-motion-brief.md`) is an excerpt transcription of it. Only one filer is on file, so tier 2 is
judged against this single exemplar; a second memorandum from a different filer is still wanted.

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-ef-consulting-v-gecc-10-90175-motion-brief.pdf` |
| Source URL | https://storage.courtlistener.com/recap/gov.uscourts.nynb.316142/gov.uscourts.nynb.316142.6.0.pdf |
| Docket page | https://www.courtlistener.com/docket/4325831/6/ef-consulting-llc-v-general-electric-capital-corporation/ (CourtListener RECAP) |
| Court | United States Bankruptcy Court, N.D.N.Y. |
| Case | *EF Consulting LLC and Oasis HC LLC v. General Electric Capital Corporation* |
| Main case / adversary | Bankr. No. 07-11068 (REL) (Highgate LTC Management, LLC, et al., Chapter 11, jointly administered) / Adv. Pro. No. 10-90175 |
| Docket / document | Adv. Dkt 6 (Memorandum of Law in Support of GECC's Motion to Dismiss the Adversary Complaint under Bankruptcy Rule 7012(b)(6)) |
| Filer | General Electric Capital Corporation (defendant), by Moritt Hock & Hamroff LLP, Garden City, New York (Marc L. Hamroff) |
| Date filed | January 6, 2011 (the memorandum's date and the affidavit of service's date; the ECF filed-stamp is not in the text layer) |
| Date fetched | 2026-10-14 |
| Form | 42 pages, letter, text layer present (11,677 words extracted by `pdftotext`). Fonts not embedded (Times-Roman). Includes a table of contents, table of authorities, footnotes, and an affidavit of service. |
| SHA-256 | `263adb9f8f3b7c4271509143426c67692c8c1bd878edb2c38bf6caddbbb933c5` |

## How it was found

Searches run 2026-10-14. The CourtListener REST search API (`/api/rest/v4/search/`, `court=nynb`, `type=rd`) found the
adversary docket and its RECAP documents. The first-round web searches found only opinions and forms (see the search
log in the earlier record, superseded by this result).

| # | Source | Query or URL | Result |
|---|---|---|---|
| 1 | CourtListener API, RECAP documents | `q="Memorandum of Law in Support of Motion to Dismiss"` with `adversary` and `available_only` | Mostly main-case memoranda (Ch. 11 plans, fee applications) and opinions. No adversary motion brief except the next row. |
| 2 | CourtListener API, RECAP documents | `q="adversary case"` family, `q=ef consulting` | Found docket 4325831 (EF Consulting v. GECC, adv. 10-90175): Dkt 6 (42 pp, text), Dkt 13 (plaintiffs' opposition and cross-motion memo, 66 pp, text), Dkt 21 (GECC reply memo, 20 pp, text), Dkt 15 and 17 (declaration and Rule 56.1 statement, text), Dkt 5 (23 pp, scanned). |
| 3 | Storage check | `storage.courtlistener.com/recap/gov.uscourts.nynb.316142/...N.0.pdf` | Dkt 6 chosen: the opening memorandum in support of the motion to dismiss, text-based, all first pages read. |
| 4 | CourtListener API, Fangio v. Vehifax (adv. 15-50001) | RECAP | Dkt 25 (memorandum in support of summary judgment) is listed but not in RECAP storage. Not used. |

## Excerpt

The filing has 42 pages. The sample transcribes printed pages 1 to 7 (PDF pages 8 to 14: Preliminary Statement, Overview,
Statement of Facts A to D, up to "In its Cash Collateral Order, this Court specifically found that:"), the Conclusion
(printed page 34), and the affidavit of service (unnumbered last page). Not transcribed: the table of contents and table of
authorities (PDF pages 1 to 7), Points I to VII and the printed pages 8 to 33, and the three footnotes.

## Redactions and changes

None to the filing's text. Changes made in the transcription, all disclosed in the sample's frontmatter comment:
footnote reference numbers removed from the body text (footnotes are not transcribed); the affidavit's jurat is kept as a
paragraph (the template has no notary block); the "STATE OF NEW YORK ) ss." venue line is kept as a paragraph; the TIN line
is a placeholder (the 2011 filing has no TIN line; LBR 9004-1(c) requires the last four digits).

## 2. Second exemplar (added 2026-10-17): plaintiffs' memorandum, EF Consulting v. GECC, Dkt 13

A second filer: the opposing party (plaintiffs EF Consulting LLC and Oasis HC LLC, not GECC) and a different firm
(Backenroth Frankel & Krinsky LLP, not Moritt Hock & Hamroff LLP). Same adversary proceeding as exemplar 1 (no other
nynb memorandum could be reached: the CourtListener search API was rate-limited, 50/hour, for the whole session on
2026-10-17). It is a memorandum of law in opposition to GECC's motion to dismiss and in support of the plaintiffs'
cross-motion for partial summary judgment, so it is a memorandum supporting a motion (the cross-motion); it also shows
the answering-papers form.

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-ef-consulting-10-90175-motion-brief.pdf` |
| Source URL | https://storage.courtlistener.com/recap/gov.uscourts.nynb.316142.13.0.pdf (link taken from the docket page https://www.courtlistener.com/docket/4325831/ef-consulting-llc-v-general-electric-capital-corporation/, entry 13, "Main Document", "Uploaded March 9, 2011") |
| Court | United States Bankruptcy Court, N.D.N.Y. |
| Case | *EF Consulting LLC and Oasis HC LLC v. General Electric Capital Corporation* |
| Main case / adversary | Bankr. No. 07-11068 (REL) (Highgate LTC Management, LLC, Chapter 11) / Adv. Pro. No. 10-90175 |
| Docket / document | Adv. Dkt 13 (Plaintiffs' Memorandum of Law in Opposition to Defendant's Motion to Dismiss and in Support of Plaintiff's Motion for Partial Summary Judgment) |
| Filer | EF Consulting LLC and Oasis HC LLC (plaintiffs). Counsel: Backenroth Frankel & Krinsky LLP, New York, New York (signed "By: /s/ Abraham Backenroth"; Mark Frankel named in the top-left counsel block) |
| Date filed | Not shown: the PDF has no ECF header stamp and the CourtListener docket row gives no filing date. The memorandum is dated February 7, 2011. |
| Date retrieved | 2026-10-17 |
| Form | 66 pages (cover page with counsel block top left, caption, title and firm block; table of contents and table of authorities on PDF pages 2 to 12, numbered in roman to xi (page 2 has no printed number); body printed pages 1 to 54 on PDF pages 13 to 66), letter (612 x 792 pt), text layer present (19,516 words extracted by `pdftotext`), produced by Acrobat Distiller 7.0.5 from PScript5. Body font Times New Roman, not embedded (`TimesNewRomanPSMT` and variants); some Cambria/Calibri/Arial. Not scanned. 0.2 MB. Each page carries the firm's document number "{043289}" at the foot. |
| SHA-256 | `ada2f463cf8f8ac4aa52f9f6696a83991e12201bde728fe2d667345327c3e981` |

Verified with `pdfinfo` and `pdftotext`: page 1 has the N.D.N.Y. caption (UNITED STATES BANKRUPTCY COURT / NORTHERN
DISTRICT OF NEW YORK; In re Highgate LTC Management, LLC, Chapter 11, Case No: 07-11068 (REL); EF Consulting LLC and Oasis
HC LLC v. General Electric Capital Corporation, Adversary Pro. No. 10-90175) and the title centred below; the CONCLUSION,
"Dated: New York, New York / February 7, 2011" and the `/s/` signature block are on the last page (printed page 54).

Tier-2 notes against exemplar 1 (GECC, Moritt Hock): both use a separate cover page, a table of contents and table of
authorities in roman numerals, the body from arabic 1, a centred title below the caption, a centred "CONCLUSION", and a
"Dated:" line at left with the firm block at right. Differences (filer style): this filer puts a counsel block at the
top left of page 1 and draws the caption with dashed rules. Neither exemplar has a hearing block above the case number
(the 2011 rule text was not checked).
