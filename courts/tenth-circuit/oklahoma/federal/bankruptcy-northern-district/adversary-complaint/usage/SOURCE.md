# Exemplar source: adversary complaint, N.D. Okla. Bankruptcy Court (oknb)

**Status: exemplar=yes.** One filed adversary complaint from this court, text-based, saved as `SAMPLE-oknb-adversary-complaint-retherford0901059.pdf`.

| Field | Value |
|---|---|
| URL (PDF, RECAP) | https://storage.courtlistener.com/recap/gov.uscourts.oknb.117350/gov.uscourts.oknb.117350.1.0_1.pdf |
| Docket page | https://www.courtlistener.com/docket/18683262/ (CourtListener docket 18683262) |
| Case | *Atlas Telephone Company, Inc. v. Retherford*, Bankr. N.D. Okla., main case *In re Richard Louis Retherford*, Case No. 09-01996-M, Chapter 7 |
| Adversary docket | 09-01059-M (Document 1, the complaint; 8 pages; file stamp "Filed in USBC ND/OK on 07/01/09") |
| Filer | Plaintiffs Ervin D. "Bud" Raus, Barbara A. Summa, Ricky J. Raus (f/k/a Ricky J. Cartwright), and Atlas Telephone Company, Inc. Counsel: Mark A. Craige, OBA No. 1992, MorrelSaffaCraige, P.C., Tulsa |
| Date filed | July 1, 2009 (file stamp on Document 1; RECAP date_filed 2009-07-01) |
| Date fetched | 2026-10-14 (CourtListener v4 search API, anonymous; PDF from storage.courtlistener.com) |
| Text layer | Yes. Body text extracts with `pdftotext`; LiberationSans embedded (TrueType). Scanned-image check: none. |
| Why this one | Text-based; a complete complaint in this court; 8 pages (inside the 8-14 page target); a dischargeability complaint under 11 U.S.C. § 523(a)(2)(A), (a)(4) and (a)(6), which is the claim type the sample uses. |

## Searches that led here

1. WebSearch, several queries for "Northern District of Oklahoma" adversary complaint / dischargeability / 523 (standard and extended): returned only the court's how-to (`Filing a New Adversary Proceeding.pdf`, May 2024, which is guidance, not a filing) and other districts' complaints. Not used.
2. CourtListener HTML search (`courtlistener.com/?q=...`) returns HTTP 403 to automated fetches. The v4 REST search (`/api/rest/v4/search/?type=r&court=oknb&q=...`) answers anonymously and was used instead, for `dischargeability` and `"adversary proceeding" complaint` (RECAP documents, `court=oknb`).
3. Candidate complaints from that search, each downloaded and checked with `pdftotext` and `pdfimages`:
   - 25-01010 *Braden v. Bonilla*, Doc 1 (2025, 5 pp.): **scanned** (300 dpi CCITT images, header stamp is the only text). Rejected: not text-based.
   - 14-01048 *Stone* (4 pp.): scanned (4 images, 56 words). Rejected.
   - 03-00248 *MPF v. Bartmann* (47 pp.): scanned (47 images, 658 words). Rejected.
   - 09-01036 *Whitfield* (2 pp., 378 words): short, a § 727 objection; not chosen.
   - 15-01056 *Hansen v. Curran* (6 pp., 1,304 words, § 523(a)(2)(A) and (a)(4)): text-based, a valid alternate. Not chosen because it is shorter than the 8-14 page target.
   - 18-01017 *Myers v. Trive Capital* (8 pp., 2,033 words): text-based, but a trustee's avoidance complaint (§§ 544, 547, 548), not a dischargeability complaint. Not chosen.
   - 23-01005, 23-01015 (Department of Education, student-loan discharge, 3-4 pp.): text-based, short, not chosen.
   - **09-01059 *Atlas Telephone v. Retherford* (8 pp., 2,126 words, § 523(a)(2)(A), (a)(4), (a)(6)): chosen.**

## Known differences from the template (recorded in `../README.md`)

- The filing has **no consent statement** (FRBP 7008(a)). The template generates one from `core.consent`; the transcription sets `consent: false` so the generated sentence reads "does not consent". That sentence is generated, not in the exemplar; the exemplar says nothing on consent.
- The filing predates the current LBR 9004-1 / 9004-2 (2025) caption and the LBR 7003-1 cover sheet. The caption, double spacing and margins are as filed in 2009. This folder has one exemplar, from one filer (Craige, MorrelSaffaCraige). Tier 2 is therefore judged against this filing and the rules, not against two or three filers; the second-filer comparison is not available from this court's public record on this box (searches above).
- The complaint's own numbered paragraphs 1-2 (jurisdiction) are represented by the template's generated jurisdiction section; the sample does not repeat them.
