# Exemplar source

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-opening-brief.pdf` (28 pages, text-based; pdftotext yields text) |
| Court | United States Court of Appeals for the Second Circuit |
| Case | *United States v. Munafo* |
| Docket | No. 25-3142-cr |
| Document | Brief for Defendant-Appellant Jonathan Munafo (appellant's opening brief) |
| Filer | James P. Egan, Assistant Federal Public Defender (Office of the Federal Public Defender, N.D.N.Y., appointed under the Criminal Justice Act) |
| Date filed | March 16, 2026 (ACMS docket entry 13.1, per the filing header) |
| URL fetched from | https://www.courtlistener.com/docket/73147826/13/united-states-of-america-v-munafo/ (RECAP copy; PDF at https://storage.courtlistener.com/recap/gov.uscourts.ca2.9166a760-66c2-4f35-8274-0d91ba776b5c/gov.uscourts.ca2.9166a760-66c2-4f35-8274-0d91ba776b5c.13.0.pdf) |
| Date fetched | 2026-10-14 |

Found through the CourtListener search API (`type=rd`, `court=ca2`), which lists RECAP documents with their titles, so that a brief could be picked by its title and PDF availability.

Filer note: this is a single-filer exemplar (one Federal Public Defender brief). `usage/` should hold two or three exemplars from different filers before tier-2 conventions are judged (docs/EVAL-LOOP.md); this doc type has one, so tier-2 judgments are provisional. See `../README.md`.

## 2. Second filer: `FILED-EXAMPLE-opening-brief-2.pdf`

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-opening-brief-2.pdf` (74 pages, 612 x 792 pt, text-based: every page yields text with pdftotext; fonts Times New Roman, embedded) |
| Court | United States Court of Appeals for the Second Circuit |
| Case | *Hachette Book Group, Inc. v. Internet Archive* |
| Docket | No. 23-1260 (S.D.N.Y. No. 1:20-cv-4160, Hon. John G. Koeltl) |
| Document | Brief for Defendant-Appellant Internet Archive (Public), Document 60 (CM/ECF stamp "Case 23-1260, Document 60, 12/15/2023, 3598398, Page1 of 74") |
| Filer | Defendant-Appellant Internet Archive (counsel: Joseph R. Palmore and Joseph C. Gratz, Morrison & Foerster LLP; Corynne M. McSherry, Electronic Frontier Foundation). Different party and different counsel from entry 1 (Munafo / Federal Public Defender, N.D.N.Y.). |
| Date filed | December 15, 2023 (CM/ECF stamp) |
| Contents | Cover; corporate disclosure statement; table of contents; table of authorities; jurisdictional statement; introduction; issues; statement of the case; summary of argument; standard of review; argument; conclusion; certificate of compliance ("contains 13,993 words"; "14-point Times New Roman font"; cites FRAP 32(a)(7)(B) and Second Circuit Rule 32.1(a)(4)); certificate of service |
| URL fetched | https://www.eff.org/files/2023/12/15/internet_archives_opening_brief_public.pdf (linked from https://www.eff.org/document/internet-archive-opening-brief-us-court-appeals-second-circuit, the EFF case page https://www.eff.org/cases/hachette-v-internet-archive) |
| Date retrieved | 2026-10-17 |
| sha256 | `27e887e666b29e1368e64a8112571f5b710e751845e0aeb811dddd7aace19455` |

Note: the public (redacted) version, as filed on CM/ECF (the court's stamp is on every page). pdfinfo reports "Syntax Warning: Invalid number of shared object groups" (a linearization hint table issue); text extraction and rendering are unaffected. The CourtListener search API was rate-limited (HTTP 429) from this box on 2026-10-17, so this copy came from the counsel's (EFF's) site.
