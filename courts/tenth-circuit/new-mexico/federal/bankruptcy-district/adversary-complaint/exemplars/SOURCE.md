# Exemplar source: adversary-complaint (D.N.M. bankruptcy)

| Field | Value |
|---|---|
| File | `FILED-EXAMPLE-johnson-v-marker-24-01003-adversary-complaint.pdf` |
| Court | United States Bankruptcy Court, District of New Mexico (`nmb`) |
| Case | In re Lawrence Edward Marker, Case No. 23-11087-j13 (Chapter 13) |
| Adversary | Amanda Johnson v. Lawrence Edward Marker, Adv. No. 24-01003-j |
| Document | Complaint Objecting to Discharge of Obligation (ECF Doc. 1, 10 pages) |
| Filer | Amanda Johnson, plaintiff, by Hinkle Shanor LLP (Lucas M. Williams) |
| Date filed | 2024-01-15 (header: "Filed 01/15/24") |
| Fetched from | https://storage.courtlistener.com/recap/gov.uscourts.nmb.173562/gov.uscourts.nmb.173562.1.0.pdf |
| Docket page | https://www.courtlistener.com/docket/68160767/1/johnson-v-marker/ |
| Date fetched | 2026-10-14 |

Text layer: yes (pdftotext returns the full text, 2,966 words).
Public court record (RECAP). Found by CourtListener search `type=r`, `court=nmb`, adversary complaints.

## Other candidates found in the same search (not saved here)

The brief asks for one exemplar per doc type. These are complaints in this court with a text layer, from other filers, that would let tier 2 be judged against two or three filers (EVAL-LOOP). Not downloaded into `exemplars/`.

| Case | Docket | Filer | Filed | Pages | RECAP PDF |
|---|---|---|---|---|---|
| Quorum Health Resources, LLC v. Bailey (Otero County Hospital Ass'n) | Adv. 18-01028 | Quorum Health Resources, LLC | 2018-05-17 | 14 | https://storage.courtlistener.com/recap/gov.uscourts.nmb.162129/gov.uscourts.nmb.162129.1.0.pdf |
| Montoya v. Goldstein (Chuza Oil Co.) | Adv. 20-01027 | Philip J. Montoya | 2020-05-07 | 21 | https://storage.courtlistener.com/recap/gov.uscourts.nmb.168297/gov.uscourts.nmb.168297.1.0.pdf |
| Castillo (adversary) | Adv. 18-01013 | Epifanio Castillo | 2018-03-13 | 4 | https://storage.courtlistener.com/recap/gov.uscourts.nmb.161454/gov.uscourts.nmb.161454.1.0.pdf |

Checked 2026-10-14: each has a text layer (pdftotext returns words). The Sanchez v. Guajardo complaint (Adv. 19-01040) returns almost no text (a scan) and was not used.

## Font-audit selected replacement — Quorum Health Resources v. Bailey

The Johnson exemplar is flagged for EquityA. The saved Quorum complaint is a public filing in the same court and document type, with a text layer (3,890 extracted words) and Times New Roman. It is the selected replacement for the Johnson font-audit item. Johnson remains paired with the existing sample until its transcription is rebuilt against Quorum.

- File: `FILED-EXAMPLE-quorum-health-resources-18-01028-adversary-complaint.pdf`
- Case: *Quorum Health Resources, LLC v. Bailey* (Otero County Hospital Association), Adv. No. 18-01028
- Filer: Quorum Health Resources, LLC
- Date filed: 2018-05-17
- PDF: https://storage.courtlistener.com/recap/gov.uscourts.nmb.162129/gov.uscourts.nmb.162129.1.0.pdf
- Text layer: yes; Times New Roman is present and not embedded
- SHA-256: `7c5000ef721c3ad68af76cc572a54b3bbcf5e83bbceddb0daed26b4b1a3a2418`
- Retrieved: 2026-10-17
