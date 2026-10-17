# Exemplars: adversary complaint (N.D. Ohio Bankruptcy Court)

Both files are public RECAP documents from CourtListener, fetched 2026-10-14 via the CourtListener search API (`/api/rest/v4/search/`, court `ohnb`, type RECAP) and the RECAP storage path listed below.

| File | Case / docket | Filer | Date filed | Document | Source URL |
|---|---|---|---|---|---|
| `FILED-EXAMPLE-alrachid-25-01091-adversary-complaint.pdf` | *Alrachid LLC v. Headway Capital LLC*, Adv. No. 25-01091 (main case 24-12309, Judge Koch) | Alrachid LLC, debtor in possession (counsel: Frederic P. Schwieg) | 2025-11-13 | Complaint (ECF Doc. 1, 31 pp., text-based) | https://www.courtlistener.com/docket/71909549/1/alrachid-llc-v-headway-capital-llc/ (PDF: https://storage.courtlistener.com/recap/gov.uscourts.ohnb.1144426/gov.uscourts.ohnb.1144426.1.0.pdf) |
| `FILED-EXAMPLE-stone-25-05001-adversary-complaint.pdf` | *Vara (U.S. Trustee, Region 9) v. Stone*, Adv. No. 25-05001 (main case 24-50671, Judge Koschik) | Andrew R. Vara, United States Trustee, Region 9 | 2025-01-10 | Complaint to deny discharge (ECF Doc. 1, 16 pp., text-based) | https://www.courtlistener.com/docket/69534447/1/chad-m-stone-adversary-proceeding/ (PDF: https://storage.courtlistener.com/recap/gov.uscourts.ohnb.1131961/gov.uscourts.ohnb.1131961.1.0.pdf) |

Different filers: the debtor's counsel (Alrachid) and the U.S. Trustee (Stone).

## Selected replacement

The Alrachid complaint is flagged for Segoe UI. The saved Stone complaint is the selected replacement: a same-court adversary complaint from a different filer, with an extractable text layer and embedded Times New Roman. The Alrachid sample remains paired with its source and must be rebuilt before replacing that PDF.

Notes:
- The Alrachid complaint's exhibits (Exhibit B payment ledger, pp. 16-31) are not transcribed; `samples/INPUT-adversary-complaint.md` transcribes the body (caption, jurisdiction, parties, background, counts, prayer, signature).
- The Stone caption shows the adversary number blank in the filed form; the number `25-05001` is the CourtListener docket number.
- The Alrachid complaint's Count I heading does not appear in the text layer; the transcription does not invent one.
