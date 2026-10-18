# Exemplar source: motion-brief (utd)

| Item | Value |
|---|---|
| File | `SAMPLE-utd-motion-brief-millerstormont225cv00857.pdf` |
| Court | United States District Court for the District of Utah, Central Division (`utd`) |
| Case | *Miller v. Stormont* (Hon. Charles A. Stormont, Utah district judge, sued in his personal capacity, with other defendants) |
| Docket no. | 2:25-cv-00857-DAO (Judge Daphne A. Oberg) |
| Document | Defendant Stormont's Motion to Dismiss and Memorandum in Support (ECF No. 22), 22 pages: caption and motion (pp. i–ii), table of contents (iii), table of authorities (iv–vi), memorandum (1–16) |
| Filer | Defendant Hon. Charles A. Stormont, by the Office of the Utah Attorney General (Justin P. Anderson, Assistant Utah Attorney General) |
| Date filed | 2025-11-25 (ECF header: "Filed 11/25/25"; signature block: "DATED: November 25, 2025") |
| Fetched from | https://storage.courtlistener.com/recap/gov.uscourts.utd.159669/gov.uscourts.utd.159669.22.0.pdf (RECAP archive copy of ECF No. 22) |
| Docket page | https://www.courtlistener.com/docket/71470225/miller-v-stormont/ |
| Date fetched | 2026-10-14 |
| Text layer | Yes: `pdffonts` shows embedded TimesNewRoman, Charter, Cambria and Arial; `pdftotext` reads the full text |
| Public record | Yes: a public RECAP-archived court filing, used as published |

## Why this exemplar

It is a Rule 12(b)(1) and 12(b)(6) motion with a memorandum in one document, which is the shape DUCivR 7-1(a)(1) describes. It has the initial separate motion section, a table of contents, a table of authorities, Roman-numbered argument headings with sub-headings, footnotes, a fact list, and a signature block. It is a Utah Attorney General filing, so the counsel block is the state-agency form.

## Alternates seen in the search (not saved: one exemplar per doc type)

| Case | Docket | Pages | Filer | Why not used | URL |
|---|---|---|---|---|---|
| *Adams v. Tooele County School District* | 2:25-cv-00438-DBB-JCB, ECF 31 | 18 | Tooele County School District (Assistant Utah AG Katherine Bushman) | Has TOC and TOA. Same filing office as *Miller* (Utah AG), so it is the closer second filer for a tier-2 check, not a different office | https://storage.courtlistener.com/recap/gov.uscourts.utd.156973/gov.uscourts.utd.156973.31.0.pdf |
| *Fox v. University of Utah* | 2:26-cv-00225-DBB-DAO, ECF 7 | 11 | University of Utah (Assistant Utah AG Brett Andrus) | Motion and memorandum, shorter; no TOC or TOA (checked on the text layer) | https://storage.courtlistener.com/recap/gov.uscourts.utd.163093/gov.uscourts.utd.163093.7.0.pdf |
| *Xlear, Inc. v. FTC* | 2:25-cv-00484-DBB, ECF 26 | 83 | Federal Trade Commission (Byron, Hoffman, Zuver) | Federal-agency motion to dismiss the first amended complaint; far longer than the sample's target | https://storage.courtlistener.com/recap/gov.uscourts.utd.157357/gov.uscourts.utd.157357.26.0.pdf |

Not usable as motions: *Sullivan v. Tang* and *Morris v. Young* (the RECAP PDFs returned are not valid PDFs); *Murray v. Alphabet* ECF 21 is an answer, not a motion.

## Searches tried

- CourtListener RECAP search API (`type=r`, `court=utd`), queries for "motion to dismiss" with "memorandum in support", filed 2025 onward; results filtered to 8 to 30 pages.
- Each candidate was downloaded to its own directory and checked with `pdftotext` for a text layer and for its first-page caption.

## Font-audit selected replacement — Adams v. Tooele County School District

The Miller exemplar is flagged for Charter. The saved Adams memorandum is a same-court, same-document-type public filing with an extractable text layer and embedded Times New Roman. It is a selected replacement for the Miller font-audit item, although it comes from the Utah Attorney General's office, as does Miller. Miller's current sample remains paired with its source until rebuilt against Adams.

- File: `SAMPLE-utd-motion-brief-adams225cv00438.pdf`
- Docket: 2:25-cv-00438-DBB-JCB, ECF No. 31
- Filer: Tooele County School District, through Assistant Utah Attorney General Katherine Bushman
- PDF: https://storage.courtlistener.com/recap/gov.uscourts.utd.156973/gov.uscourts.utd.156973.31.0.pdf
- Text layer: yes; Times New Roman embedded
- SHA-256: `cab018690b3ef824c3623c5cd90dc2fd26e923b6bb3109fd4995f8bbddbf3411`
- Retrieved: 2026-10-17
