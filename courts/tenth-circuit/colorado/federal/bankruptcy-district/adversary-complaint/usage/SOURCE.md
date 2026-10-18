# Exemplar source

## Primary: `SAMPLE-cob-adversary-complaint-golec2401083.pdf`

- Court: United States Bankruptcy Court for the District of Colorado
- Case: *Golec, et al. v. Weinant*, Adv. Proc. No. 24-01083-MER (main case No. 23-15585 MER, Chapter 7)
- Document: Complaint to Determine Dischargeability of Debt (11 U.S.C. § 523(a)(6)), 5 pages, ECF/Doc 1.
- Filer: Plaintiffs Thomas Golec, Mara Lynn Looney, Mark K. Nicholson, Andrew H. Soliday, Laurie A. Soliday, Andrew A. Soliday, and Jeanne M. Wicks. Counsel: Coan, Payton & Payne LLC (Steven T. Mulligan, #19901) and The Ferguson Schindler Law Firm, P.C. (Michelle K. Schindler, #48076).
- Date filed: 2024-04-10 (ECF header "Filed:04/10/24" on every page)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.cob.519876/gov.uscourts.cob.519876.1.0.pdf (CourtListener RECAP; found by the RECAP search `court=cob`, `type=r`, query "complaint to determine dischargeability")
- Date fetched: 2026-10-14
- Text layer: yes (`pdftotext` reads it; embedded fonts).
- Public court record (RECAP). Transcribed to `usage/INPUT-cob-adversary-complaint-golec.md`; the overlay is `usage/OVERLAY-golec-adversary-complaint.pdf`.

## Second exemplar (not yet saved)

The Golec complaint is the only adversary complaint this folder has. The CourtListener search above returned no other complaint with a RECAP storage copy (the other hits are orders, motions and extension requests). A second filer's complaint is still needed for the tier-2 comparison that `docs/EVAL-LOOP.md` asks for; see `../README.md`, gap 1.

## Other samples

- `usage/INPUT-cob-adversary-complaint-reitmair.md` is a pro se complaint (Dawn Reitmair, dated 6/15/2026). It has no exemplar in this folder: its source was not recorded, and it is kept as an existing sample. It is used to show the FRBP 7008(a) "consent missing" flag. It is not a transcription of a filed document this folder holds.

## Searches tried

- CourtListener REST search (`/api/rest/v4/search/`, `court=cob`, `type=r`) for "complaint to determine dischargeability": 105 results; four had RECAP storage paths: Golec (Doc 1, used), American Express v. Alnamer (Doc 4 exhibit A and Doc 9 order, not complaints), Vandenberg (discovery requests).
- WebSearch for cob adversary complaints: returned the court's blank caption and summons forms only.
