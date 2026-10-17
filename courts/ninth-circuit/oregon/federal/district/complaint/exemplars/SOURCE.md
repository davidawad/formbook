# Exemplar source: complaint (ord)

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-kliewer-fender-3-26-cv-02238-complaint.pdf` |
| URL fetched from | https://storage.courtlistener.com/recap/gov.uscourts.ord.197289/gov.uscourts.ord.197289.1.0.pdf (CourtListener RECAP copy of the ECF document) |
| How it was found | CourtListener search API, `type=r`, `court=ord`, `q=complaint`, sorted by date filed: https://www.courtlistener.com/api/rest/v4/search/?type=r&court=ord&q=complaint&order_by=dateFiled+desc&page_size=10 |
| Case | *Kliewer v. Fender Musical Instruments Corporation* |
| Court and division | United States District Court, District of Oregon, Portland Division |
| Docket number | 3:26-cv-02238-AR |
| Document | Document 1: Class Action Complaint (18 pages) |
| Filer | Richard Kliewer (plaintiff); filed by Peter Schneider, Northwest Debt Resolution, LLC (plaintiff's counsel). Docket text: "(Schneider, Peter)" |
| Date filed | 10/13/26 (ECF header: "Filed 10/13/26") |
| Date fetched | 2026-10-14 |
| Public record | Yes: a federal court filing on CourtListener RECAP, not sealed |
| Text layer | Yes. `pdftotext` reads the whole document. Fonts: Times New Roman (body), Times New Roman Bold, Arial, Avenir Next (footer), embedded |

## Notes on the exemplar

- The ECF header (case number, "Document 1", "Filed", "Page n of 18") sits in the top margin on every page. It is part of the court's record copy, not the filer's text.
- The filer's counsel block appears only in the page footers ("NORTHWEST DEBT RESOLUTION" and address). The top of page 1 has no counsel block. LR 10-2(a) puts counsel information in the upper left corner of the first page; the template follows the rule, not this exemplar.
- Pleading-paper line numbers (1 to 26) run down the left margin of every page. LR 10-1(d), as quoted in the README, says pages must not be numbered down the left margin. The template follows the rule, and this difference is an open question for David (see README).
- The class-definition, call-log and count sections are long. The sample transcribes only part of the filing (see `samples/INPUT-kliewer-complaint.md`).

## Other candidates found and not saved

The brief asks for one exemplar per doc type. These were seen in the same search and are candidates if a second filer is wanted for tier 2:

- *Brown v. Lincoln County*, 6:26-cv-02227 (filed 10/12/26, 25 pages, RECAP `gov.uscourts.ord.197261.1.0.pdf`), counsel-filed.
- *Butler v. LeGore*, 2:26-cv-02234 (filed 10/13/26, 14 pages, RECAP `gov.uscourts.ord.197278.1.0_1.pdf`), pro se prisoner complaint with IFP status; a different form, not a counsel model.

## Second exemplar (retrieved 2026-10-17)

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-lo-brown-6-26-cv-02227-complaint.pdf` |
| Filer | Connor Brown, filed by attorneys Viktoria Lo and Stephanie Pollan (different filer from Kliewer) |
| Case | *Brown v. Lincoln County*, No. 6:26-cv-02227-AP |
| Document | Document 1, Complaint, 25 pages |
| Date filed | 2026-10-12 (ECF header) |
| URL | https://storage.courtlistener.com/recap/gov.uscourts.ord.197261/gov.uscourts.ord.197261.1.0.pdf |
| Date retrieved | 2026-10-17 |
| SHA-256 | `fed7fb23291c7aab99ebf145c29262d828820c57b7c223bbc60f9cdd11364cc6` |
| Public record | CourtListener RECAP copy of the non-sealed ECF filing |

Downloaded from the public RECAP storage URL and checked with `pdfinfo` and `pdftotext`; the PDF is 25 pages with extractable text.
