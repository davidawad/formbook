# Exemplar source

| Field | Value |
|---|---|
| Court | U.S. Court of Appeals for the Sixth Circuit |
| Case | *NetChoice, LLC v. Jonathan Skrmetti*, in his official capacity as Tennessee Attorney General & Reporter |
| Docket no. | 25-5660 |
| Document | "Brief of Appellant NetChoice" (opening brief, appellant's principal brief), CourtListener docket entry 16 |
| Filer | NetChoice, LLC (Plaintiff-Appellant); counsel Lehotsky Keller Cohn LLP |
| Date filed | September 3, 2025 (CourtListener `entry_date_filed` 2025-09-03; the brief's own certificate of service is dated September 3, 2025) |
| URL fetched | https://storage.courtlistener.com/recap/gov.uscourts.ca6.155650/gov.uscourts.ca6.155650.16.0.pdf (docket: https://www.courtlistener.com/docket/70965097/16/netchoice-llc-v-jonathan-skrmetti/) |
| Date fetched | 2026-10-14 |
| Size | 90 pages, text-based PDF (`pdftotext` yields the text; fonts Palatino Linotype embedded) |
| Public record | Yes: RECAP document, public court filing |

Found by searching CourtListener's API for Sixth Circuit RECAP documents whose description is an appellant's brief (`q="opening brief" OR "brief of appellant"`, `court=ca6`, `available_only=on`). Chosen because it is a text-based PDF with a full cover, disclosure statement, table of contents, table of authorities, oral-argument statement, certificates, and the Rule 30(g) district-court designation, all of which the template must reproduce.

Only the brief's structure and the text of its opening pages were transcribed into `samples/`. The filer is a trade association (NetChoice), not a government party; the exemplar is an interlocutory preliminary-injunction appeal.
