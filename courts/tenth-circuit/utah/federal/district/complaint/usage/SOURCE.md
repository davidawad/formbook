# Exemplar source: complaint (utd)

| Item | Value |
|---|---|
| File | `FILED-EXAMPLE-complaint.pdf` |
| Court | United States District Court for the District of Utah (`utd`) |
| Case | *Fastre v. Weber County* |
| Docket no. | 1:26-cv-00060-TS-CMR |
| Document | Complaint and Demand for Jury Trial (ECF No. 1), 15 pages |
| Filer | Plaintiffs Finn Fastre and Jason Fastre, individually and as personal representatives of the Estate of Hans Fastre; counsel Burbidge \| Mitchell (Richard D. Burbidge, Beau R. Burbidge, Carolyn LeDuc) |
| Date filed | 2026-05-06 (ECF header: "Filed 05/06/26"; signature block: "DATED this 6th day of May 2026") |
| Fetched from | https://storage.courtlistener.com/recap/gov.uscourts.utd.164239/gov.uscourts.utd.164239.1.0.pdf (RECAP archive copy of ECF No. 1) |
| Docket page | https://www.courtlistener.com/docket/73308463/fastre-v-weber-county/ |
| Date fetched | 2026-10-14 |
| Text layer | Yes: `pdffonts` shows embedded TimesNewRoman and Arial; `pdftotext` reads the full text |
| Public record | Yes: a public RECAP-archived court filing, unsealed, used as published |

## Why this exemplar

It is a counsel-filed complaint in this district with the usual caption (counsel block, court title, party column, title, case number, judge line), numbered paragraphs under FRCP 10(b), headings for parties, jurisdiction, general allegations and claims, a prayer, a jury demand, and a signature block. Its counsel block and caption are the structure the template follows.

## Alternates seen in the search (not saved: one exemplar per doc type)

| Case | Docket | Pages | Why not used | URL |
|---|---|---|---|---|
| *Keller v. Danford* | 2:25-cv-00595-TS-JCB, ECF 1 | 31 | Counsel-filed; pleading-paper line numbers 1 to 26; allegations are sensitive (trafficking) | https://storage.courtlistener.com/recap/gov.uscourts.utd.157998/gov.uscourts.utd.157998.1.0.pdf |
| *The Preserve v. Kamas City* | 2:25-cv-00735-TS-DBP, ECF 1 | 27 | Counsel-filed (Lex Tecnica); pleading-paper line numbers | https://storage.courtlistener.com/recap/gov.uscourts.utd.158871/gov.uscourts.utd.158871.1.0.pdf |
| *Owen v. State of Utah Legislative Services* | 2:25-cv-00485-RJS-CMR, ECF 1 | 18 | Pro se filer; no counsel block | https://storage.courtlistener.com/recap/gov.uscourts.utd.157367/gov.uscourts.utd.157367.1.0.pdf |

Tier-2 cross-checks against two or three filers were not run for this doc type (see the README's known gaps). The three alternates above are the candidates for that check.

## Searches tried

- CourtListener RECAP search API (`type=r`, `court=utd`), queries for complaints with "Utah", "demand for jury", filed 2024 onward.
- Results were filtered to ECF No. 1 PDFs of 5 to 30 pages with a text layer.
