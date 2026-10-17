# Exemplars: adversary-complaint (nynb)

**Status: exemplar found (1 of 2 or 3 wanted).** `FILED-EXAMPLE-fangio-v-vehifax-15-50001-adversary-complaint.pdf` is a
real, public, text-based adversary complaint filed in this court. The sample (`samples/INPUT-adversary-complaint.md`) is a
transcription of it. Only one filer is on file, so tier 2 is judged against this single exemplar; a second complaint from
a different filer is still wanted (see "Other candidates").

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-fangio-v-vehifax-15-50001-adversary-complaint.pdf` |
| Source URL | https://storage.courtlistener.com/recap/gov.uscourts.nynb.349360/gov.uscourts.nynb.349360.1.0.pdf |
| Docket page | https://www.courtlistener.com/docket/5164695/1/fangio-trustee-v-vehifax-corp/ (CourtListener RECAP, Adversary case 15-50001-5) |
| Court | United States Bankruptcy Court, N.D.N.Y. |
| Case | *Mary Lannon Fangio, as Chapter 11 trustee of the estate of Ajax Integrated, LLC v. Vehifax Corp.* |
| Main case / adversary | Bankr. No. 14-30435 (Ajax Integrated, LLC, Chapter 11) / Adv. No. 15-50001 |
| Docket / document | Adv. Dkt 1 (Complaint) |
| Filer | Mary Lannon Fangio, Chapter 11 trustee (plaintiff). Counsel: The Crossmore Law Office, Ithaca, New York (the signature block names Edward Crossmore; the CourtListener docket lists him as the filing attorney) |
| Date filed | 01/16/2015 (ECF stamp in the page header; the complaint is dated January 15, 2015) |
| Date fetched | 2026-10-14 |
| Form | 6 pages, letter, scanned-era word-processor PDF with a text layer (1,588 words extracted by `pdftotext`). Fonts are not embedded (Times-Roman, Helvetica), so the file is not PDF/A and is not an e-filing-compliant PDF; it is a reference, not a standard for the output. |
| SHA-256 | `5330d2a17b09c3e262ffa0b8a0e06e13b79a0a6fd1cbed727ae1188a94e0fdce` |

## How it was found

Searches run 2026-10-14. The CourtListener REST search API (`/api/rest/v4/search/`, no key needed for search) with
`court=nynb` and `type=rd` found the adversary dockets and their RECAP documents. The earlier web searches (the first
search log below) found only opinions, docket trackers and forms.

| # | Source | Query or URL | Result |
|---|---|---|---|
| 1 | CourtListener API, RECAP documents, court `nynb` | `q="adversary complaint"` (type `rd`, available only) | Adversary "Complaint by ..." entries, Dkt 1. Most were scanned images with no text layer. |
| 2 | Same | `q="Adversary case" "Complaint by"` | Candidates: Celli v. City of Troy (18-90026), Davidson (23-90018), Sherman (18-90007), Levine-Trustee (24-90021), Fangio v. Vehifax (15-50001), Stevens (26-90046). Dkt 1 PDFs downloaded and tested for a text layer: Celli and Davidson are scanned (no text); Sherman and Leakh are short; Fangio and Stevens have text. |
| 3 | Same | `q=Vehifax` (type `rd`) | Found Fangio v. Vehifax Dkt 1 (text) and Dkt 25 (memorandum in support of summary judgment; not in RECAP storage). |
| 4 | CourtListener storage, Fangio docket | `storage.courtlistener.com/recap/gov.uscourts.nynb.349360/...N.0.pdf` for N = 2 to 60 | Only N = 1 and N = 52 exist; N = 52 is a 30-page scanned document, not used. |

## Selected replacement

The Fangio filing is classified as an OCR scan by the font audit. The saved Stevens complaint is a same-court adversary complaint with an extractable text layer and Times New Roman in the body, and is the selected replacement. Fangio remains paired with the existing sample.
| 5 | Web search, PacerMonitor, Trellis, Justia, Stretto, inforuptcy | adversary and docket names | Docket listings only; no complaint PDFs. Justia and inforuptcy return HTTP 403. |
| 6 | Web search, the Dakari (N.D.N.Y. 04-cv-452) and Diocese of Syracuse matters | adversary and appeal names | Opinions and claims-site pages; no adversary complaint PDF. |

The first-round searches (2026-10-14, earlier in this session) that found no exemplar are superseded by the result above.

## Other candidates (not used)

- Stevens, as plaintiff, Adv. No. 26-90046, Dkt 1 (https://storage.courtlistener.com/recap/gov.uscourts.nynb.403424/gov.uscourts.nynb.403424.1.0.pdf): 33 pages, text layer (8,742 words), filed 2026. A second complaint from a different filer, so the right candidate for the tier-2 second exemplar.
- Levine-Trustee v. ..., Adv. No. 24-90021, Dkt 1 (https://storage.courtlistener.com/recap/gov.uscourts.nynb.396199/gov.uscourts.nynb.396199.1.0.pdf): 8 pages, only 553 words extracted; check whether the text layer is complete before using it.
- Celli, Adv. No. 18-90026, Dkt 1 and Davidson, Adv. No. 23-90018, Dkt 1: scanned, no text layer. Not usable under the text-based rule.

## Redactions and changes

None to the filing's text. The transcription omits the ECF header line only (the court's stamp, not authored text).

## 2. Second exemplar (added 2026-10-17): Stevens v. Evepark London LP

A second filer, different party and different firm from exemplar 1 (Fangio, trustee, by The Crossmore Law Office). This is
the "Stevens, Adv. No. 26-90046" candidate listed above under "Other candidates"; it is now on file.

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-stevens-v-evepark-26-90046-adversary-complaint.pdf` |
| Source URL | https://storage.courtlistener.com/recap/gov.uscourts.nynb.403424/gov.uscourts.nynb.403424.1.0.pdf |
| Court | United States Bankruptcy Court, N.D.N.Y. |
| Case | *Fred Stevens, as Plan Administrator v. Evepark London LP* |
| Main case / adversary | Bankr. No. 24-11029 (PGR) (Prime Capital Ventures, LLC, Chapter 11) / Adv. Pro. No. 26-90046 (ECF header "Case 26-90046-1") |
| Docket / document | Adv. Dkt 1 (Complaint seeking (I) the avoidance and recovery of fraudulent transfers pursuant to 11 U.S.C. §§ 544(a), 548(a)(1)(A) and 550(a) and N.Y. DCL § 273(a)(1); and (II) payment of pre-judgment interest and attorneys' fees) |
| Filer | Fred Stevens, Plan Administrator (plaintiff). Counsel: Klestadt Winters Jureller Southard & Stevens, LLP, New York, New York (Fred Stevens, Lauren C. Kiss, Kevin B. Collins; signed "/s/ Fred Stevens") |
| Date filed | 09/15/26 (ECF header "Filed 09/15/26 Entered 09/15/26 14:49:20"; the complaint is dated September 15, 2026) |
| Date retrieved | 2026-10-17 |
| Form | 33 pages (cover page with counsel block, caption and title; table of contents; 30 numbered body pages; 1-page Exhibit A), letter (612 x 792 pt), text layer present (8,735 words extracted by `pdftotext`), produced by Acrobat PDFMaker 26 for Word. Body font Times New Roman (embedded subset `TimesNewRomanPSMT`); the court's ECF header stamp adds non-embedded Helvetica/Courier. Not scanned. 1.9 MB. |
| SHA-256 | `7e3ab2d19d560d536cbe61530e31d79301c5a546787b1fabb863be4ff692dcc8` |

Verified with `pdfinfo` and `pdftotext`: page 1 carries the N.D.N.Y. caption ("UNITED STATES BANKRUPTCY COURT /
NORTHERN DISTRICT OF NEW YORK"), the bankruptcy caption (In re Prime Capital Ventures, LLC, Chapter 11, Case No.
24-11029 (PGR)) and the adversary caption (Fred Stevens, as Plan Administrator, Plaintiff, -against- Evepark London LP,
Defendant, Adv. Pro. No. 26-________), with the title of the complaint centred below. Paragraph 3 states the plaintiff's
consent to the entry of final orders or judgments (FRBP 7008). The prayer ("WHEREFORE ...", items A to C) and the `/s/`
signature block are on PDF page 32.

Differences from exemplar 1 worth recording for tier 2 (each seen in one filer only, so filer style, not convention):
counsel block at the top left of page 1; a separate cover page and a table of contents; caption drawn with a dashed rule
and a column of colons (S.D.N.Y. style); prayer items lettered "A." to "C."; no SSN/TIN line in the caption (as in
exemplar 1; LBR 9004-1(c) still requires it).
