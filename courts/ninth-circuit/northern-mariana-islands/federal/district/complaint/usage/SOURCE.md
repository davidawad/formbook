# Exemplar source

- File: `FILED-EXAMPLE-complaint.pdf` (12 pages, text layer present: `pdftotext` reads it; Word-generated, embedded fonts)
- URL fetched from: https://storage.courtlistener.com/recap/gov.uscourts.nmid.5451.2.0.pdf (CourtListener RECAP; docket page https://www.courtlistener.com/docket/6082335/2/ewing-v-imperial-pacific-international-cnmi-llc/, found through the CourtListener search API with `court=nmid`)
- Court: United States District Court for the Northern Mariana Islands
- Case: *Ewing v. Imperial Pacific International (CNMI), LLC*
- Docket no.: Civil Case No. 16-00034 (caption). Docket entry 2.
- Document: First Amended Complaint (docket entry 2; the caption title is "FIRST AMENDED COMPLAINT"; no jury demand appears in the filing)
- Filer: Plaintiff Danny Ewing, by counsel William M. Fitzgerald (Law Offices of William M. Fitzgerald, Saipan)
- Date filed: December 22, 2016 (signature date "DATED this 22nd day of December, 2016"; the RECAP entry is dated 2016-12-22)
- Date fetched: 2026-10-14

## Why this one

Searched CourtListener (search API, `court=nmid`, `type=r`, `q="COMPLAINT against"`, `filed_after=2014-01-01`) for counsel-filed complaints in this court. Options with a text layer: Ewing (this, 2016, counsel, 12 pages, pleading paper with line numbers, a complete cause-of-action structure); Murphy v. CNMI Government (1:14-cv-00026, amended complaint, 14 pages, not fetched); Kalarikkal v. World Corporation (1:19-cv-00002, complaint, 13 pages; the RECAP storage link returned NoSuchKey, not used). Garcia v. Poong-In Saipan (1:08-cv-00017, Doc 3, 2008, 7 pages, counsel Stephen Woodruff): a scanned paper capture with an OCR text layer, pleading-form numbered lines; checked and not saved. The brief asks for one exemplar per doc type.

## Caveats

- This is a **first amended** complaint. The complaint form is the same as an original complaint (the caption, numbered paragraphs, causes of action, prayer, signature). The sample's title is the filed title.
- The 2016 filing predates the 2017 Local Rules text used by the template (see `../README.md`): the filed page has 28 numbered lines; the template follows the 2017 rules (25 lines, 1.5 inch top margin).
- The filing has no LR 5.2.c bar identification number for counsel; the template prints the counsel block as given.

## Second filer

Not collected in this pass (see above). EVAL-LOOP's tier-2 rule (2 or 3 filers) is not met; recorded in `../README.md`.
