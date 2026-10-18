# Exemplars: motion to dismiss brief (M.D. Ala.)

Both files are public records of the United States District Court for the Middle District of Alabama, obtained from the RECAP archive of CourtListener (the document as filed on the court's ECF docket). Retrieved 2026-10-14 with `curl`, unmodified. Each file's text layer was checked with `pdftotext` (it yields text).

| File | Case / docket | Filer | Date filed (per footer) | Pages | sha256 | URL fetched |
|---|---|---|---|---|---|---|
| `FILED-EXAMPLE-motion-brief.pdf` | *Nutrien Ag Solutions, Inc. v. Fillingim*, No. 1:25-cv-00302-RAH-SMD (M.D. Ala., Southern Division). Brief in support of motion to dismiss defendants' amended counterclaim, Doc. 43 | Plaintiff Nutrien Ag Solutions, Inc., by Capell & Howard, P.C. | 12/17/2025 | 29 | `822ddeb6d8ef2bf12f9d95fcda08653feea4b785683656cf01a4f769216e2b89` | https://storage.courtlistener.com/recap/gov.uscourts.almd.86335/gov.uscourts.almd.86335.43.0.pdf |
| `FILED-EXAMPLE-motion-brief-2.pdf` | *Beasley, Allen, Crow, Methvin, Portis & Miles, P.C. v. The Smith Law Firm, PLLC*, No. 2:24-cv-00582-RAH-JTA (M.D. Ala.). Memorandum in support of motion to dismiss, Doc. 76 | Defendants The Smith Law Firm, PLLC and Robert Allen Smith, Jr. | 03/26/2025 | 26 | `650647537fa5dbc45e2de46880513f45c84ef85ff9fdb3deec491706f6ff51f9` | https://storage.courtlistener.com/recap/gov.uscourts.almd.84160/gov.uscourts.almd.84160.76.0.pdf |

Filers: two different parties (a plaintiff's Rule 12(b)(6) brief against a counterclaim, and a defendant's motion memorandum), so the tier-2 comparison is not one filer's house style.

Used as follows: the Nutrien brief is transcribed (an excerpt) into `usage/INPUT-motion-brief.md` and overlaid (`usage/OVERLAY-nutrien-motion-brief.pdf`). The Beasley Allen memorandum was measured (body line pitch 32.2 pt, the same double spacing as Nutrien at 14 pt) but not overlaid and not compared page by page; it is a second-filer check on the type-size convention only.
