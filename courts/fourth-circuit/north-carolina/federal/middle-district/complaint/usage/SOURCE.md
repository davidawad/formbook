# Exemplar source: complaint, M.D.N.C.

| Field | Value |
|---|---|
| Exemplar file | `SAMPLE-ncmd-complaint-prillaman26cv01154.pdf` |
| Case | *Prillaman v. Wake Forest University*, No. 1:26-cv-01154 (M.D.N.C.) (caption: "Civil Action No. 26-1154") |
| Document | Document 1, "Complaint (Jury Trial Demanded)", 16 pages |
| Filer | Carol Prillaman, Plaintiff (counsel: Randolph M. James, N.C. Bar #10,000) |
| Date filed | September 29, 2026 (ECF header "Filed 09/29/26") |
| URL fetched from | https://storage.courtlistener.com/recap/gov.uscourts.ncmd.106090/gov.uscourts.ncmd.106090.1.0.pdf |
| Docket page | https://www.courtlistener.com/docket/74870106/1/prillaman-v-wake-forest-university/ |
| Date fetched | 2026-10-14 |
| Text layer | Yes (`pdftotext` reads it; `pdffonts` shows embedded text fonts) |
| Public record | RECAP copy of a public PACER filing |

## How it was found

CourtListener search API (`/api/rest/v4/search/`, `type=r`, `court=ncmd`, query `COMPLAINT "JURY TRIAL DEMANDED"`, ordered by date filed). The result set includes several MDNC complaints with RECAP PDFs. This one was chosen because it is a counsel-drafted, text-based, single-plaintiff complaint with a jury demand, a caption, numbered paragraphs, headings, a prayer and a signature block, which covers the structure the template needs.

## Other candidates seen (not saved; one exemplar per doc type)

- *USConnect, LLC v. Cantaloupe, LLC*, No. 1:26-cv-00771 (M.D.N.C., filed 08/06/26), Document 1, 21 pages, text layer present. Counsel-drafted patent declaratory-judgment complaint; uses a ")" column caption.
- *Richardson-McGriff v. W.D. Wright Contracting, Inc.*, No. 1:26-cv-00831 (M.D.N.C., filed 08/14/26), Document 1, 10 pages, text layer present. ")" column caption, "Jury Trial Demanded".
- *Dunson v. City of Winston-Salem*, No. 1:26-cv-00844 (M.D.N.C., filed 08/18/26), Document 1, 18 pages. Winston-Salem Division.
- *Nelson v. Overbrook Life LLC*, No. 1:26-cv-00374 (M.D.N.C., filed 05/05/26), Document 1, 15 pages. Class action.

These are kept as the second and third filers for a later tier-2 pass (EVAL-LOOP asks for two or three filers); they are not transcribed.
