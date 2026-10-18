# Exemplar source

Doc type: **complaint**, United States District Court for the District of New Jersey (`njd`).

## 1. `FILED-EXAMPLE-complaint.pdf` (primary)

- Court: United States District Court, District of New Jersey (Judge stamp on page 1: `SDW-SDA`)
- Case: *DGL Group Ltd. v. GoLabs, Inc.*
- Docket: No. 2:26-cv-13086 (Document 1)
- Document: Complaint, "Jury Trial Demanded" (12 pages)
- Filer: Plaintiff DGL Group Ltd., by counsel Kasowitz LLP (Christian T. Becker)
- Date filed: 2026-10-07 (header "Filed 10/07/26" on every page)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.njd.610208/gov.uscourts.njd.610208.1.0.pdf (CourtListener RECAP; docket https://www.courtlistener.com/docket/74930273/)
- Date fetched: 2026-10-14
- Text layer: yes (`pdftotext` yields text; embedded TrueType, body 12 pt)

## 2. `FILED-EXAMPLE-complaint-2.pdf` (second filer)

- Court: United States District Court, District of New Jersey
- Case: *Gomez v. Town of West New York, New Jersey*
- Docket: No. 2:25-cv-02242 (Document 1; "Civil Action No." left blank on the caption)
- Document: Complaint (17 pages)
- Filer: Plaintiff Jorge E. Gomez, by counsel The Law Offices of Richard Malagiere, P.C.
- Date filed: 2025-04-02 (header "Filed 04/02/25" on every page)
- Fetched from: https://storage.courtlistener.com/recap/gov.uscourts.njd.565099/gov.uscourts.njd.565099.1.0.pdf (CourtListener RECAP; docket https://www.courtlistener.com/docket/69835233/)
- Date fetched: 2026-10-14
- Text layer: yes

Both files are public court records (RECAP). Used only as visual and structural references for tier 2 (house conventions across two filers).

## Selected replacement

The DGL complaint is flagged for unnamed `Z_C00000.tmp` fonts. The saved Gomez complaint is the selected replacement: same court and document type, public RECAP filing, extractable text, and embedded Times New Roman in the body. The DGL sample remains paired with its source until it is rebuilt against Gomez.
